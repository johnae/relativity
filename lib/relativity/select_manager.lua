require('relativity.globals')
local insert, empty, concat, map
do
  local _obj_0 = table
  insert, empty, concat, map = _obj_0.insert, _obj_0.empty, _obj_0.concat, _obj_0.map
end
local TreeManager = require('relativity.tree_manager')
local ToSql = require('relativity.visitors.to_sql')
local Predications = require('relativity.predications')
local define = require('classy').define
local defer = require('relativity.defer')
local Nodes = defer(function()
  return require("relativity.nodes.nodes")
end)
return define('SelectManager', function()
  parent(TreeManager)
  include(Predications)
  local new_order
  new_order = function(expr, klazz)
    if type(expr) == 'string' then
      return klazz.new(Nodes.SqlLiteral.new(tostring(expr)))
    end
    return klazz.new(expr)
  end
  local skip
  skip = function(self, amount)
    if amount then
      self.ast.offset = Nodes.Offset.new(amount)
    else
      self.ast.offset = nil
    end
    return self
  end
  local capitalize
  capitalize = function(str)
    local title_case
    title_case = function(first, rest)
      return tostring(first:upper()) .. tostring(rest)
    end
    return str:gsub("(%a)([%w_']*)", title_case)
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
    return concat(map(node.source.right, function(j)
      return self(j)
    end), ' ')
  end
  local WhereSql
  do
    local _tbl_0 = { }
    for k, v in pairs(ToSql) do
      _tbl_0[k] = v
    end
    WhereSql = _tbl_0
  end
  WhereSql.SelectCore = function(self, node)
    return "WHERE " .. tostring(concat(map(node.wheres, function(w)
      return self(w)
    end), ' AND '))
  end
  setmetatable(WhereSql, getmetatable(ToSql))
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
  properties({
    orders = function(self)
      return self.ast.orders
    end,
    froms = function(self)
      local cores = self.ast.cores
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #cores do
        local core = cores[_index_0]
        _accum_0[_len_0] = core.from
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end,
    exists = function(self)
      return Nodes.Exists.new(self.ast)
    end,
    taken = function(self)
      if self.ast.limit then
        return self.ast.limit.value
      end
    end,
    order_clauses = function(self)
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
  })
  return instance({
    initialize = function(self, table)
      super(self)
      self.ast = Nodes.SelectStatement.new()
      local cores = self.ast.cores
      self.ctx = cores[#cores]
      return self:from(table)
    end,
    project = function(self, ...)
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
    end,
    asc = function(self, ...)
      local new_orders
      do
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = {
          ...
        }
        for _index_0 = 1, #_list_0 do
          local o = _list_0[_index_0]
          _accum_0[_len_0] = new_order(o, Nodes.Ascending)
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
    end,
    desc = function(self, ...)
      local new_orders
      do
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = {
          ...
        }
        for _index_0 = 1, #_list_0 do
          local o = _list_0[_index_0]
          _accum_0[_len_0] = new_order(o, Nodes.Descending)
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
    end,
    from = function(self, table)
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
    end,
    group = function(self, ...)
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
    end,
    as = function(self, other)
      return self:create_table_alias(self:grouping(self.ast), Nodes.SqlLiteral.new(other))
    end,
    having = function(self, ...)
      self.ctx.having = Nodes.Having.new(self:collapse({
        ...
      }, self.ctx.having))
      return self
    end,
    collapse = function(self, exprs, existing)
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
    end,
    join = function(self, relation, klazz)
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
    end,
    on = function(self, ...)
      local r_sources = self.ctx.source.right
      r_sources[#r_sources].right = Nodes.On.new(self:collapse({
        ...
      }))
      return self
    end,
    skip = skip,
    offset = skip,
    take = function(self, limit)
      if limit then
        self.ast.limit = Nodes.Limit.new(limit)
        self.ctx.top = Nodes.Top.new(limit)
      else
        self.ast.limit = nil
        self.ctx.top = nil
      end
      return self
    end,
    except = function(self, other)
      return Nodes.Except.new(self.ast, other.ast)
    end,
    minus = function(self, other)
      return self:except(other)
    end,
    intersect = function(self, other)
      return Nodes.Intersect.new(self.ast, other.ast)
    end,
    union = function(self, operation, other)
      local union_class
      if other then
        union_class = Nodes["Union" .. tostring(capitalize(operation))]
      else
        other = operation
        union_class = Nodes.Union
      end
      return union_class.new(self.ast, other.ast)
    end,
    With = function(self, ...)
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
        with_class = Nodes["With" .. tostring(capitalize(first))]
      else
        with_class = Nodes.With
      end
      self.ast.with = with_class.new(subqueries)
      return self
    end,
    join_sql = function(self)
      if not (self.ctx.source.right or empty(self.ctx.source.right)) then
        return 
      end
      local sql = JoinSql(self.ctx)
      if not (sql == '') then
        return Nodes.SqlLiteral.new(sql)
      end
    end,
    where_sql = function(self)
      if empty(self.ctx.wheres) then
        return 
      end
      local sql = WhereSql(self.ctx)
      return Nodes.SqlLiteral.new(sql)
    end
  })
end)
