require 'relativity.globals'
MultiMethod = require 'relativity.visitors.multimethod'
Nodes = require 'relativity.nodes.nodes'
Attributes = require 'relativity.attributes'
{:Attribute} = Attributes
{:SelectStatement, :In, :SqlLiteral} = Nodes
{:concat, :empty, :any, :sort, :map} = table

ToSql = MultiMethod.new (node) ->
  node_type = type(node)
  if node_type == 'table' and node.__class
    node.__class
  else
    node_type

ToSql.all = (list) => map list, (node) -> @ node

ToSql.DeleteStatement = (node) =>
  d = "DELETE FROM #{@ node.relation}"
  d = "#{d} WHERE #{concat @all(node.wheres), ' AND '}" unless empty(node.wheres)
  d

ToSql.SelectManager = (node) =>
  "(#{@ node.ast})"

ToSql.build_sub_select = (key, node) =>
  stmt = SelectStatement.new!
  cores = stmt.cores
  core = cores[#cores]
  core.froms = node.relation
  core.wheres = node.wheres
  core.projections = {key}
  stmt.limit = node.limit
  stmt.orders = node.orders
  stmt

ToSql.UpdateStatement = (node) =>
  wheres = if empty(node.orders) and not node.limit
    node.wheres
  else
    key = node.key
    {In.new(key, {@build_sub_select(key, node)})}
  sql = "UPDATE #{@ node.relation}"
  sql = "#{sql} SET #{concat @all(node.values), ', '}" unless empty(node.values)
  sql = "#{sql} WHERE #{concat @all(wheres), ' AND '}" unless empty(wheres)
  sql

ToSql.Assignment = (node) =>
  right = @quote(node.right, @column_for(node.left))
  "#{@ node.left} = #{right}"

ToSql.UnqualifiedName = (node) =>
  @quote_column_name node.name

ToSql.InsertStatement = (node) =>
  sql = {"INSERT INTO #{node.relation and @(node.relation) or 'NULL'}"}
  unless empty(node.columns)
    sql[#sql + 1] = "(#{concat map(node.columns, (c) -> @quote_column_name c), ', '})"
  if node.values
    sql[#sql + 1] = @ node.values
  concat sql, ' '

ToSql.Values = (node) =>
  sql = map node.expressions, (expr) ->
    if expr == SqlLiteral
      @ expr
    else
      @quote expr, nil
  "VALUES (#{concat sql, ', '})"

ToSql.Exist = (node) =>
  "EXISTS (#{@ node.expressions})#{node.alias and " AS #{@ node.alias}" or ''}"

ToSql.SelectStatement = (node) =>
  sql = {}
  sql[#sql + 1] = @ node.with if node.with
  sql[#sql + 1] = concat map(node.cores, (c) -> @ c), ', '
  sql[#sql + 1] = "ORDER BY #{concat map(node.orders, (o) -> @ o), ', '}" unless empty(node.orders)
  sql[#sql + 1] = @ node.limit if node.limit
  sql[#sql + 1] = @ node.offset if node.offset
  sql[#sql + 1] = @ node.lock if node.lock
  concat sql, ' '

ToSql.SelectCore = (node) =>
  sql = {"SELECT"}
  sql[#sql + 1] = @ node.top if node.top
  sql[#sql + 1] = concat map(node.projections, (p) -> @ p), ', ' unless empty(node.projections)
  sql[#sql + 1] = @ node.source
  sql[#sql + 1] = "WHERE #{concat map(node.wheres, (w) -> @ w), ' AND '}" unless empty(node.wheres)
  sql[#sql + 1] = "GROUP BY #{concat map(node.groups, (g) -> @ g), ', '}" unless empty(node.groups)
  sql[#sql + 1] = @ node.having if node.having
  concat sql, ' '

ToSql.JoinSource = (node) =>
  return unless node.left or any(node.right)
  sql = {"FROM"}
  sql[#sql + 1] = @ node.left if node.left
  sql[#sql + 1] = concat map(node.right, (j) -> @ j), ' ' unless empty(node.right)
  concat sql, ' '

ToSql.Table = (node) =>
  if node.table_alias
    "#{@quote_table_name node.name} #{@quote_table_name node.table_alias}"
  else
    @quote_table_name node.name

ToSql.quote_table_name = (name) =>
  if name == SqlLiteral
    return name
  "\"#{name}\""

ToSql.quote_column_name = (name) =>
  if name == SqlLiteral
    name
  else if name == Attribute
    "\"#{name.name}\""
  else
    "\"#{name}\""

ToSql.Array = (node) =>
  return 'NULL' if empty(node)
  concat map(node, (elem) -> @ elem), ', '

ToSql.literal = (node) => node

ToSql.SqlLiteral = (node) => "#{node.value}"

ToSql.Ordering = (node) =>
  "#{@ node.left} #{node.right\upper!}"

ToSql.Group = (node) =>
  @ node.value

ToSql.Attribute = (node) =>
  @last_column = @column_for node
  join_name = tostring (node.relation.table_alias or node.relation.name)
  "#{@quote_table_name join_name}.#{@quote_column_name node.name}"

ToSql.TableStar = (node) =>
  rel = node.value
  join_name = rel.table_alias or rel.name
  "#{@quote_table_name join_name}.*"

ToSql.AttrInteger = (node) => @Attribute node
ToSql.AttrFloat = (node) => @Attribute node
ToSql.AttrString = (node) => @Attribute node
-- TODO: what about time?
ToSql.AttrTime = (node) => @Attribute node
ToSql.AttrBoolean = (node) => @Attribute node

ToSql.quoted = (node) =>
  @quote node, @last_column

ToSql.string = (value) => @quoted value
ToSql.date = (value) => @quoted value
ToSql.boolean = (value) => @quoted value
ToSql.number = (value) => @literal value
ToSql.table = (value) => "#{concat [@quoted(v) for v in *value], ', '}"

ToSql.ConstLit = (node) => @ node.value

ToSql.Null = (node) => 'NULL'

-- dates? time?
ToSql.quote = (value, column) =>
  if type(value) == 'boolean'
    value and "'t'" or "'f'"
  else if not value
    return 'NULL'
  else if type(value) == 'number'
    value
  else if type(value) == 'table' and value.__class == 'Null'
    'NULL'
  else
    "'#{value}'"


ToSql.column_for = (attr) =>
  tostring attr.name

ToSql.Having = (node) =>
  "HAVING #{@ node.value}"

ToSql.And = (node) =>
  concat map(node.children, (c) -> @ c), ' AND '

ToSql.Or = (node) =>
  "#{@ node.left} OR #{@ node.right}"

ToSql.InnerJoin = (node) =>
  join = "INNER JOIN #{@ node.left}"
  join = "#{join} #{@ node.right}" if node.right and any(node.right)
  join

ToSql.InnerJoinLateral = (node) =>
  join = "INNER JOIN LATERAL #{@ node.left}"
  join = "#{join} #{@ node.right}" if node.right and any(node.right)
  join

ToSql.On = (node) =>
  "ON #{@ node.value}"

ToSql.TableAlias = (node) =>
  "#{@ node.relation} #{@quote_table_name tostring(node.name)}"

ToSql.Offset = (node) =>
  "OFFSET #{@ node.value}"

ToSql.Exists = (node) =>
  e = node.alias and " AS #{@ node.alias}" or ''
  "EXISTS (#{@ node.expressions})#{e}"

ToSql.Union = (node) =>
  "(#{@ node.left}) UNION (#{@ node.right})"

ToSql.Like = (node) =>
  "#{@ node.left} LIKE #{@ node.right}"

ToSql.ILike = (node) =>
  "#{@ node.left} ILIKE #{@ node.right}"

ToSql.LessThan = (node) =>
  "#{@ node.left} < #{@ node.right}"

ToSql.LessThanOrEqual = (node) =>
  "#{@ node.left} <= #{@ node.right}"

ToSql.GreaterThan = (node) =>
  "#{@ node.left} > #{@ node.right}"

ToSql.GreaterThanOrEqual = (node) =>
  "#{@ node.left} >= #{@ node.right}"

ToSql.NotEqual = (node) =>
  "#{@ node.left} <> #{@ node.right}"

ToSql.Not = (node) =>
  "NOT (#{@ node.value})"

ToSql.UnionAll = (node) =>
  "(#{@ node.left}) UNION ALL (#{@ node.right})"

ToSql.Except = (node) =>
  "(#{@ node.left}) EXCEPT (#{@ node.right})"

ToSql.In = (node) =>
  "#{@ node.left} IN (#{@ node.right})"

ToSql.Between = (node) =>
  "#{@ node.left} BETWEEN (#{@ node.right})"

ToSql.Intersect = (node) =>
  "(#{@ node.left}) INTERSECT (#{@ node.right})"

ToSql.with_helper = (rec, node) =>
  w = concat (["#{@ x.left} AS (#{@ x.right})" for x in *node.children]), ', '
  "WITH#{rec} #{w}"

ToSql.With = (node) =>
  @with_helper '', node

ToSql.WithRecursive = (node) =>
  @with_helper ' RECURSIVE', node

ToSql.As = (node) =>
  "#{@ node.left} AS #{@ node.right}"

ToSql.Equality = (node) =>
  right = node.right
  if right
    "#{@ node.left} = #{@ right}"
  else
    "#{@ node.left} IS NULL"

ToSql.ToJson = (node) =>
  "to_json(#{@ node.value})"

ToSql.ArrayAgg = (node) =>
  "array_agg(#{@ node.value})"

ToSql.JsonBuildObject = (node) =>
  json = {}
  value = node.value
  -- sorting them to get the same ordering every time
  keys = [k for k,v in pairs value]
  sort keys
  for key in *keys
    json[#json + 1] = "'#{key}'::text"
    json[#json + 1] = "#{@ value[key]}"
  "json_build_object(#{concat json, ', '})"

ToSql.Lock = (node) =>

ToSql.outer_join_type = (node, join_type, lateral=false) =>
  join = if lateral
    "#{join_type} OUTER JOIN LATERAL #{@ node.left}"
  else
    "#{join_type} OUTER JOIN #{@ node.left}"
  join = "#{join} #{@ node.right}" if node.right
  join

ToSql.LeftOuterJoin = (node) =>
  @outer_join_type node, 'LEFT'

ToSql.LeftOuterJoinLateral = (node) =>
  @outer_join_type node, 'LEFT', true

ToSql.RightOuterJoin = (node) =>
  @outer_join_type node, 'RIGHT'

ToSql.RightOuterJoinLateral = (node) =>
  @outer_join_type node, 'RIGHT', true

ToSql.FullOuterJoin = (node) =>
  @outer_join_type node, 'FULL'

ToSql.FullOuterJoinLateral = (node) =>
  @outer_join_type node, 'FULL', true

ToSql.StringJoin = (node) =>
  join = @ node.left
  join = "#{join} #{@ node.right}" if node.right and any(node.right)
  join

ToSql.Top = (node) => nil

ToSql.Limit = (node) =>
  "LIMIT #{@ node.value}"

ToSql.Grouping = (node) =>
  "(#{@ node.value})"

ToSql.FunctionNode = (node) =>
  "#{@ node.alias}(#{concat [@(x) for x in *node.expressions], ', '})"

ToSql.Case = (node) =>
  sql = {'CASE'}
  sql[#sql + 1] = @ node._base if node._base
  for stmt in *node._cases
    cond = stmt[1]
    res = stmt[2]
    sql[#sql + 1] = "WHEN #{@ cond} THEN #{@ res}"
  sql[#sql + 1] = "ELSE #{@ node._else}" if node._else
  sql[#sql + 1] = "END"
  concat sql, ' '

ToSql.Null = => 'NULL'

ToSql.IsNull = (node) =>
  "#{@ node.value} IS NULL"

ToSql.NotNull = (node) =>
  "#{@ node.value} IS NOT NULL"

ToSql
