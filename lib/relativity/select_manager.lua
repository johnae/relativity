require('relativity.globals')
local insert, empty, concat
do
  local _obj_0 = table
  insert, empty, concat = _obj_0.insert, _obj_0.empty, _obj_0.concat
end
local TreeManager = require('relativity.tree_manager')
local ToSql = require('relativity.visitors.to_sql')
local Predications = require('relativity.predications')
local Class = require('relativity.class')
local defer = require('relativity.defer')
local Nodes = defer(function()
  return require("relativity.nodes.nodes")
end)
local SelectManager = Class('SelectManager', TreeManager)
SelectManager.includes(Predications)
SelectManager.initialize = function(self, table)
  self:super()
  self.ast = Nodes.SelectStatement.new()
  local cores = self.ast.cores
  self.ctx = cores[#cores]
  return self:from(table)
end
SelectManager.project = function(self, ...)
  local p = self.ctx.projections
  local _list_0 = {
    ...
  }
  for _index_0 = 1, #_list_0 do
    local projection = _list_0[_index_0]
    if type(projection) == 'string' then
      projection = Nodes.SqlLiteral.new(projection)
    end
    p[#p + 1] = projection
  end
  return self
end
SelectManager.order = function(self, ...)
  local new_order
  new_order = function(x)
    return type(x) == 'string' and Nodes.SqlLiteral.new(tostring(x)) or x
  end
  local new_orders
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = {
      ...
    }
    for _index_0 = 1, #_list_0 do
      local o = _list_0[_index_0]
      _accum_0[_len_0] = new_order(o)
      _len_0 = _len_0 + 1
    end
    new_orders = _accum_0
  end
  local o = self.ast.orders
  for _index_0 = 1, #new_orders do
    local order = new_orders[_index_0]
    o[#o + 1] = order
  end
  return self
end
SelectManager.get_orders = function(self)
  return self.ast.orders
end
SelectManager.from = function(self, table)
  if table and type(table) == 'string' then
    table = Nodes.SqlLiteral.new(table)
  end
  if table then
    local r_sources = self.ctx.source.right
    if table.is_a[Nodes.Join] then
      r_sources[#r_sources + 1] = table
    else
      self.ctx.source.left = table
    end
  else
    self.ctx.source.left = nil
  end
  return self
end
SelectManager.get_froms = function(self)
  local cores = self.ast.cores
  local _accum_0 = { }
  local _len_0 = 1
  for _index_0 = 1, #cores do
    local core = cores[_index_0]
    _accum_0[_len_0] = core.from
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
SelectManager.group = function(self, ...)
  local _list_0 = {
    ...
  }
  for _index_0 = 1, #_list_0 do
    local column = _list_0[_index_0]
    local c = type(column) == 'string' and Nodes.SqlLiteral.new(tostring(column)) or column
    local g = self.ctx.groups
    g[#g + 1] = Nodes.Group.new(c)
  end
  return self
end
SelectManager.as = function(self, other)
  return self:create_table_alias(self:grouping(self.ast), Nodes.SqlLiteral.new(other))
end
SelectManager.having = function(self, ...)
  self.ctx.having = Nodes.Having.new(self:collapse({
    ...
  }, self.ctx.having))
  return self
end
SelectManager.collapse = function(self, exprs, existing)
  if existing == nil then
    existing = nil
  end
  if existing then
    insert(exprs, 1, existing)
  end
  local new_expr
  new_expr = function(expr)
    if type(expr) == 'string' then
      return Nodes.SqlLiteral.new(expr)
    else
      return expr
    end
  end
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #exprs do
      local expr = exprs[_index_0]
      _accum_0[_len_0] = new_expr(expr)
      _len_0 = _len_0 + 1
    end
    exprs = _accum_0
  end
  if #exprs == 1 then
    return exprs[1]
  else
    return self:create_and(exprs)
  end
end
SelectManager.join = function(self, relation, klazz)
  if not (relation) then
    return self
  end
  klazz = klazz or Nodes.InnerJoin
  if type(relation) == 'string' or relation.is_a[Nodes.SqlLiteral] then
    klazz = Nodes.StringJoin
  end
  local r_sources = self.ctx.source.right
  r_sources[#r_sources + 1] = self:create_join(relation, nil, klazz)
  return self
end
SelectManager.on = function(self, ...)
  local r_sources = self.ctx.source.right
  r_sources[#r_sources].right = Nodes.On.new(self:collapse({
    ...
  }))
  return self
end
SelectManager.skip = function(self, amount)
  if amount then
    self.ast.offset = Nodes.Offset.new(amount)
  else
    self.ast.offset = nil
  end
  return self
end
SelectManager.offset = SelectManager.skip
SelectManager.exists = function(self)
  return Nodes.Exists.new(self.ast)
end
SelectManager.take = function(self, limit)
  if limit then
    self.ast.limit = Nodes.Limit.new(limit)
    self.ctx.top = Nodes.Top.new(limit)
  else
    self.ast.limit = nil
    self.ctx.top = nil
  end
  return self
end
SelectManager.except = function(self, other)
  return Nodes.Except.new(self.ast, other.ast)
end
SelectManager.minus = function(self, other)
  return self:except(other)
end
SelectManager.intersect = function(self, other)
  return Nodes.Intersect.new(self.ast, other.ast)
end
SelectManager.capitalize = function(self, str)
  local title_case
  title_case = function(first, rest)
    return tostring(first:upper()) .. tostring(rest)
  end
  return str:gsub("(%a)([%w_']*)", title_case)
end
SelectManager.union = function(self, operation, other)
  local union_class
  if other then
    union_class = Nodes["Union" .. tostring(self:capitalize(operation))]
  else
    other = operation
    union_class = Nodes.Union
  end
  return union_class.new(self.ast, other.ast)
end
SelectManager.With = function(self, ...)
  local subqueries = {
    ...
  }
  local with_class
  if type(subqueries[1]) == 'string' then
    local first = subqueries[1]
    do
      local _accum_0 = { }
      local _len_0 = 1
      for i, q in ipairs(subqueries) do
        if i > 1 then
          _accum_0[_len_0] = q
          _len_0 = _len_0 + 1
        end
      end
      subqueries = _accum_0
    end
    with_class = Nodes["With" .. tostring(self:capitalize(first))]
  else
    with_class = Nodes.With
  end
  self.ast.with = with_class.new(subqueries)
  return self
end
SelectManager.get_taken = function(self)
  if self.ast.limit then
    return self.ast.limit.value
  end
end
local JoinSql
do
  local _tbl_0 = { }
  for k, v in pairs(ToSql) do
    _tbl_0[k] = v
  end
  JoinSql = _tbl_0
end
setmetatable(JoinSql, getmetatable(ToSql))
JoinSql.SelectCore = function(self, node)
  return concat(self:map(node.source.right, function(j)
    return self(j)
  end), ' ')
end
SelectManager.join_sql = function(self)
  if not (self.ctx.source.right or empty(self.ctx.source.right)) then
    return 
  end
  local sql = JoinSql(self.ctx)
  if not (sql == '') then
    return Nodes.SqlLiteral.new(sql)
  end
end
local OrderClauses
do
  local _tbl_0 = { }
  for k, v in pairs(ToSql) do
    _tbl_0[k] = v
  end
  OrderClauses = _tbl_0
end
setmetatable(OrderClauses, getmetatable(ToSql))
OrderClauses.SelectStatement = function(self, node)
  return self:all(node.orders)
end
SelectManager.get_order_clauses = function(self)
  local _accum_0 = { }
  local _len_0 = 1
  local _list_0 = OrderClauses(self.ast)
  for _index_0 = 1, #_list_0 do
    local c = _list_0[_index_0]
    _accum_0[_len_0] = Nodes.SqlLiteral.new(c)
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
local WhereSql
do
  local _tbl_0 = { }
  for k, v in pairs(ToSql) do
    _tbl_0[k] = v
  end
  WhereSql = _tbl_0
end
setmetatable(WhereSql, getmetatable(ToSql))
WhereSql.SelectCore = function(self, node)
  return "WHERE " .. tostring(concat(self:map(node.wheres, function(w)
    return self(w)
  end), ' AND '))
end
SelectManager.where_sql = function(self)
  if empty(self.ctx.wheres) then
    return 
  end
  local sql = WhereSql(self.ctx)
  return Nodes.SqlLiteral.new(sql)
end
return SelectManager
