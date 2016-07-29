require('relativity.globals')
local MultiMethod = require('relativity.visitors.multimethod')
local Nodes = require('relativity.nodes.nodes')
local Attributes = require('relativity.attributes')
local Attribute
Attribute = Attributes.Attribute
local SelectStatement, In, SqlLiteral
SelectStatement, In, SqlLiteral = Nodes.SelectStatement, Nodes.In, Nodes.SqlLiteral
local concat, empty, any, sort, map
do
  local _obj_0 = table
  concat, empty, any, sort, map = _obj_0.concat, _obj_0.empty, _obj_0.any, _obj_0.sort, _obj_0.map
end
local ToSql = MultiMethod.new(function(node)
  local node_type = type(node)
  if node_type == 'table' and node.__class then
    return node.__class
  else
    return node_type
  end
end)
ToSql.all = function(self, list)
  return map(list, function(node)
    return self(node)
  end)
end
ToSql.DeleteStatement = function(self, node)
  local d = "DELETE FROM " .. tostring(self(node.relation))
  if not (empty(node.wheres)) then
    d = tostring(d) .. " WHERE " .. tostring(concat(self:all(node.wheres), ' AND '))
  end
  return d
end
ToSql.SelectManager = function(self, node)
  return "(" .. tostring(self(node.ast)) .. ")"
end
ToSql.build_sub_select = function(self, key, node)
  local stmt = SelectStatement.new()
  local cores = stmt.cores
  local core = cores[#cores]
  core.froms = node.relation
  core.wheres = node.wheres
  core.projections = {
    key
  }
  stmt.limit = node.limit
  stmt.orders = node.orders
  return stmt
end
ToSql.UpdateStatement = function(self, node)
  local wheres
  if empty(node.orders) and not node.limit then
    wheres = node.wheres
  else
    local key = node.key
    wheres = {
      In.new(key, {
        self:build_sub_select(key, node)
      })
    }
  end
  local sql = "UPDATE " .. tostring(self(node.relation))
  if not (empty(node.values)) then
    sql = tostring(sql) .. " SET " .. tostring(concat(self:all(node.values), ', '))
  end
  if not (empty(wheres)) then
    sql = tostring(sql) .. " WHERE " .. tostring(concat(self:all(wheres), ' AND '))
  end
  return sql
end
ToSql.Assignment = function(self, node)
  local right = self:quote(node.right, self:column_for(node.left))
  return tostring(self(node.left)) .. " = " .. tostring(right)
end
ToSql.UnqualifiedName = function(self, node)
  return self:quote_column_name(node.name)
end
ToSql.InsertStatement = function(self, node)
  local sql = {
    "INSERT INTO " .. tostring(node.relation and self(node.relation) or 'NULL')
  }
  if not (empty(node.columns)) then
    sql[#sql + 1] = "(" .. tostring(concat(map(node.columns, function(c)
      return self:quote_column_name(c)
    end), ', ')) .. ")"
  end
  if node.values then
    sql[#sql + 1] = self(node.values)
  end
  return concat(sql, ' ')
end
ToSql.Values = function(self, node)
  local sql = map(node.expressions, function(expr)
    if expr == SqlLiteral then
      return self(expr)
    else
      return self:quote(expr, nil)
    end
  end)
  return "VALUES (" .. tostring(concat(sql, ', ')) .. ")"
end
ToSql.Exist = function(self, node)
  return "EXISTS (" .. tostring(self(node.expressions)) .. ")" .. tostring(node.alias and " AS " .. tostring(self(node.alias)) or '')
end
ToSql.SelectStatement = function(self, node)
  local sql = { }
  if node.with then
    sql[#sql + 1] = self(node.with)
  end
  sql[#sql + 1] = concat(map(node.cores, function(c)
    return self(c)
  end), ', ')
  if not (empty(node.orders)) then
    sql[#sql + 1] = "ORDER BY " .. tostring(concat(map(node.orders, function(o)
      return self(o)
    end), ', '))
  end
  if node.limit then
    sql[#sql + 1] = self(node.limit)
  end
  if node.offset then
    sql[#sql + 1] = self(node.offset)
  end
  if node.lock then
    sql[#sql + 1] = self(node.lock)
  end
  return concat(sql, ' ')
end
ToSql.SelectCore = function(self, node)
  local sql = {
    "SELECT"
  }
  if node.top then
    sql[#sql + 1] = self(node.top)
  end
  if not (empty(node.projections)) then
    sql[#sql + 1] = concat(map(node.projections, function(p)
      return self(p)
    end), ', ')
  end
  sql[#sql + 1] = self(node.source)
  if not (empty(node.wheres)) then
    sql[#sql + 1] = "WHERE " .. tostring(concat(map(node.wheres, function(w)
      return self(w)
    end), ' AND '))
  end
  if not (empty(node.groups)) then
    sql[#sql + 1] = "GROUP BY " .. tostring(concat(map(node.groups, function(g)
      return self(g)
    end), ', '))
  end
  if node.having then
    sql[#sql + 1] = self(node.having)
  end
  return concat(sql, ' ')
end
ToSql.JoinSource = function(self, node)
  if not (node.left or any(node.right)) then
    return 
  end
  local sql = {
    "FROM"
  }
  if node.left then
    sql[#sql + 1] = self(node.left)
  end
  if not (empty(node.right)) then
    sql[#sql + 1] = concat(map(node.right, function(j)
      return self(j)
    end), ' ')
  end
  return concat(sql, ' ')
end
ToSql.Table = function(self, node)
  if node.table_alias then
    return tostring(self:quote_table_name(node.name)) .. " " .. tostring(self:quote_table_name(node.table_alias))
  else
    return self:quote_table_name(node.name)
  end
end
ToSql.quote_table_name = function(self, name)
  if name == SqlLiteral then
    return name
  end
  return "\"" .. tostring(name) .. "\""
end
ToSql.quote_column_name = function(self, name)
  if name == SqlLiteral then
    return name
  else
    if name == Attribute then
      return "\"" .. tostring(name.name) .. "\""
    else
      return "\"" .. tostring(name) .. "\""
    end
  end
end
ToSql.Array = function(self, node)
  if empty(node) then
    return 'NULL'
  end
  return concat(map(node, function(elem)
    return self(elem)
  end), ', ')
end
ToSql.literal = function(self, node)
  return node
end
ToSql.SqlLiteral = function(self, node)
  return tostring(node.value)
end
ToSql.Ordering = function(self, node)
  return tostring(self(node.left)) .. " " .. tostring(node.right:upper())
end
ToSql.Group = function(self, node)
  return self(node.value)
end
ToSql.Attribute = function(self, node)
  self.last_column = self:column_for(node)
  local join_name = tostring((node.relation.table_alias or node.relation.name))
  return tostring(self:quote_table_name(join_name)) .. "." .. tostring(self:quote_column_name(node.name))
end
ToSql.TableStar = function(self, node)
  local rel = node.value
  local join_name = rel.table_alias or rel.name
  return tostring(self:quote_table_name(join_name)) .. ".*"
end
ToSql.AttrInteger = function(self, node)
  return self:Attribute(node)
end
ToSql.AttrFloat = function(self, node)
  return self:Attribute(node)
end
ToSql.AttrString = function(self, node)
  return self:Attribute(node)
end
ToSql.AttrTime = function(self, node)
  return self:Attribute(node)
end
ToSql.AttrBoolean = function(self, node)
  return self:Attribute(node)
end
ToSql.quoted = function(self, node)
  return self:quote(node, self.last_column)
end
ToSql.string = function(self, value)
  return self:quoted(value)
end
ToSql.date = function(self, value)
  return self:quoted(value)
end
ToSql.boolean = function(self, value)
  return self:quoted(value)
end
ToSql.number = function(self, value)
  return self:literal(value)
end
ToSql.table = function(self, value)
  return tostring(concat((function()
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #value do
      local v = value[_index_0]
      _accum_0[_len_0] = self:quoted(v)
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end)(), ', '))
end
ToSql.ConstLit = function(self, node)
  return self(node.value)
end
ToSql.Null = function(self, node)
  return 'NULL'
end
ToSql.quote = function(self, value, column)
  if type(value) == 'boolean' then
    return value and "'t'" or "'f'"
  else
    if not value then
      return 'NULL'
    else
      if type(value) == 'number' then
        return value
      else
        if type(value) == 'table' and value.__class == 'Null' then
          return 'NULL'
        else
          return "'" .. tostring(value) .. "'"
        end
      end
    end
  end
end
ToSql.column_for = function(self, attr)
  return tostring(attr.name)
end
ToSql.Having = function(self, node)
  return "HAVING " .. tostring(self(node.value))
end
ToSql.And = function(self, node)
  return concat(map(node.children, function(c)
    return self(c)
  end), ' AND ')
end
ToSql.Or = function(self, node)
  return tostring(self(node.left)) .. " OR " .. tostring(self(node.right))
end
ToSql.InnerJoin = function(self, node)
  local join = "INNER JOIN " .. tostring(self(node.left))
  if node.right and any(node.right) then
    join = tostring(join) .. " " .. tostring(self(node.right))
  end
  return join
end
ToSql.InnerJoinLateral = function(self, node)
  local join = "INNER JOIN LATERAL " .. tostring(self(node.left))
  if node.right and any(node.right) then
    join = tostring(join) .. " " .. tostring(self(node.right))
  end
  return join
end
ToSql.On = function(self, node)
  return "ON " .. tostring(self(node.value))
end
ToSql.TableAlias = function(self, node)
  return tostring(self(node.relation)) .. " " .. tostring(self:quote_table_name(tostring(node.name)))
end
ToSql.Offset = function(self, node)
  return "OFFSET " .. tostring(self(node.value))
end
ToSql.Exists = function(self, node)
  local e = node.alias and " AS " .. tostring(self(node.alias)) or ''
  return "EXISTS (" .. tostring(self(node.expressions)) .. ")" .. tostring(e)
end
ToSql.Union = function(self, node)
  return "(" .. tostring(self(node.left)) .. ") UNION (" .. tostring(self(node.right)) .. ")"
end
ToSql.Like = function(self, node)
  return tostring(self(node.left)) .. " LIKE " .. tostring(self(node.right))
end
ToSql.ILike = function(self, node)
  return tostring(self(node.left)) .. " ILIKE " .. tostring(self(node.right))
end
ToSql.LessThan = function(self, node)
  return tostring(self(node.left)) .. " < " .. tostring(self(node.right))
end
ToSql.LessThanOrEqual = function(self, node)
  return tostring(self(node.left)) .. " <= " .. tostring(self(node.right))
end
ToSql.GreaterThan = function(self, node)
  return tostring(self(node.left)) .. " > " .. tostring(self(node.right))
end
ToSql.GreaterThanOrEqual = function(self, node)
  return tostring(self(node.left)) .. " >= " .. tostring(self(node.right))
end
ToSql.NotEqual = function(self, node)
  return tostring(self(node.left)) .. " <> " .. tostring(self(node.right))
end
ToSql.Not = function(self, node)
  return "NOT (" .. tostring(self(node.value)) .. ")"
end
ToSql.UnionAll = function(self, node)
  return "(" .. tostring(self(node.left)) .. ") UNION ALL (" .. tostring(self(node.right)) .. ")"
end
ToSql.Except = function(self, node)
  return "(" .. tostring(self(node.left)) .. ") EXCEPT (" .. tostring(self(node.right)) .. ")"
end
ToSql.In = function(self, node)
  return tostring(self(node.left)) .. " IN (" .. tostring(self(node.right)) .. ")"
end
ToSql.Between = function(self, node)
  return tostring(self(node.left)) .. " BETWEEN (" .. tostring(self(node.right)) .. ")"
end
ToSql.Intersect = function(self, node)
  return "(" .. tostring(self(node.left)) .. ") INTERSECT (" .. tostring(self(node.right)) .. ")"
end
ToSql.with_helper = function(self, rec, node)
  local w = concat(((function()
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = node.children
    for _index_0 = 1, #_list_0 do
      local x = _list_0[_index_0]
      _accum_0[_len_0] = tostring(self(x.left)) .. " AS (" .. tostring(self(x.right)) .. ")"
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end)()), ', ')
  return "WITH" .. tostring(rec) .. " " .. tostring(w)
end
ToSql.With = function(self, node)
  return self:with_helper('', node)
end
ToSql.WithRecursive = function(self, node)
  return self:with_helper(' RECURSIVE', node)
end
ToSql.As = function(self, node)
  return tostring(self(node.left)) .. " AS " .. tostring(self(node.right))
end
ToSql.Equality = function(self, node)
  local right = node.right
  if right then
    return tostring(self(node.left)) .. " = " .. tostring(self(right))
  else
    return tostring(self(node.left)) .. " IS NULL"
  end
end
ToSql.Any = function(self, node)
  local right = node.right
  return tostring(self(node.left)) .. " = ANY(" .. tostring(self(right)) .. ")"
end
ToSql.ToJson = function(self, node)
  return "to_json(" .. tostring(self(node.value)) .. ")"
end
ToSql.ArrayAgg = function(self, node)
  return "array_agg(" .. tostring(self(node.value)) .. ")"
end
ToSql.JsonBuildObject = function(self, node)
  local json = { }
  local value = node.value
  local keys
  do
    local _accum_0 = { }
    local _len_0 = 1
    for k, v in pairs(value) do
      _accum_0[_len_0] = k
      _len_0 = _len_0 + 1
    end
    keys = _accum_0
  end
  sort(keys)
  for _index_0 = 1, #keys do
    local key = keys[_index_0]
    json[#json + 1] = "'" .. tostring(key) .. "'::text"
    json[#json + 1] = tostring(self(value[key]))
  end
  return "json_build_object(" .. tostring(concat(json, ', ')) .. ")"
end
ToSql.Lock = function(self, node) end
ToSql.outer_join_type = function(self, node, join_type, lateral)
  if lateral == nil then
    lateral = false
  end
  local join
  if lateral then
    join = tostring(join_type) .. " OUTER JOIN LATERAL " .. tostring(self(node.left))
  else
    join = tostring(join_type) .. " OUTER JOIN " .. tostring(self(node.left))
  end
  if node.right then
    join = tostring(join) .. " " .. tostring(self(node.right))
  end
  return join
end
ToSql.LeftOuterJoin = function(self, node)
  return self:outer_join_type(node, 'LEFT')
end
ToSql.LeftOuterJoinLateral = function(self, node)
  return self:outer_join_type(node, 'LEFT', true)
end
ToSql.RightOuterJoin = function(self, node)
  return self:outer_join_type(node, 'RIGHT')
end
ToSql.RightOuterJoinLateral = function(self, node)
  return self:outer_join_type(node, 'RIGHT', true)
end
ToSql.FullOuterJoin = function(self, node)
  return self:outer_join_type(node, 'FULL')
end
ToSql.FullOuterJoinLateral = function(self, node)
  return self:outer_join_type(node, 'FULL', true)
end
ToSql.StringJoin = function(self, node)
  local join = self(node.left)
  if node.right and any(node.right) then
    join = tostring(join) .. " " .. tostring(self(node.right))
  end
  return join
end
ToSql.Top = function(self, node)
  return nil
end
ToSql.Limit = function(self, node)
  return "LIMIT " .. tostring(self(node.value))
end
ToSql.Grouping = function(self, node)
  return "(" .. tostring(self(node.value)) .. ")"
end
ToSql.FunctionNode = function(self, node)
  return tostring(self(node.alias)) .. "(" .. tostring(concat((function()
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = node.expressions
    for _index_0 = 1, #_list_0 do
      local x = _list_0[_index_0]
      _accum_0[_len_0] = self(x)
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end)(), ', ')) .. ")"
end
ToSql.Coalesce = function(self, node)
  return "COALESCE(" .. tostring(self(node.left)) .. ", " .. tostring(self(node.right)) .. ")"
end
ToSql.Case = function(self, node)
  local sql = {
    'CASE'
  }
  if node._base then
    sql[#sql + 1] = self(node._base)
  end
  local _list_0 = node._cases
  for _index_0 = 1, #_list_0 do
    local stmt = _list_0[_index_0]
    local cond = stmt[1]
    local res = stmt[2]
    sql[#sql + 1] = "WHEN " .. tostring(self(cond)) .. " THEN " .. tostring(self(res))
  end
  if node._else then
    sql[#sql + 1] = "ELSE " .. tostring(self(node._else))
  end
  sql[#sql + 1] = "END"
  return concat(sql, ' ')
end
ToSql.Null = function(self)
  return 'NULL'
end
ToSql.IsNull = function(self, node)
  return tostring(self(node.value)) .. " IS NULL"
end
ToSql.NotNull = function(self, node)
  return tostring(self(node.value)) .. " IS NOT NULL"
end
return ToSql
