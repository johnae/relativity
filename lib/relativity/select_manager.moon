require 'relativity.globals'
{:insert, :empty, :concat, :map} = table
TreeManager = require 'relativity.tree_manager'
ToSql = require 'relativity.visitors.to_sql'
Predications = require 'relativity.predications'
Class = require 'relativity.class'
defer = require 'relativity.defer'
Nodes = defer -> require "relativity.nodes.nodes"

SelectManager = Class 'SelectManager', TreeManager
SelectManager.includes Predications
SelectManager.initialize = (table) =>
  @super!
  @ast = Nodes.SelectStatement.new!
  cores = @ast.cores
  @ctx = cores[#cores]
  @from table

SelectManager.project = (...) =>
  p = @ctx.projections
  for projection in *{...}
    if type(projection) == 'string'
      projection = Nodes.SqlLiteral.new projection
    p[#p + 1] = projection
  @

SelectManager.order = (...) =>
  new_order = (x) -> type(x) == 'string' and Nodes.SqlLiteral.new(tostring(x)) or x
  new_orders = [new_order(o) for o in *{...}]
  o = @ast.orders
  for order in *new_orders
    o[#o + 1] = order
  @

SelectManager.get_orders = => @ast.orders

SelectManager.from = (table) =>
  table = Nodes.SqlLiteral.new(table) if table and type(table) == 'string'
  if table
    r_sources = @ctx.source.right
    if table.is_a[Nodes.Join]
      r_sources[#r_sources + 1] = table
    else
      @ctx.source.left = table
  else
    @ctx.source.left = nil
  @
    
SelectManager.get_froms = =>
  cores = @ast.cores
  [core.from for core in *cores]

SelectManager.group = (...) =>
  for column in *{...}
    c = type(column) == 'string' and Nodes.SqlLiteral.new(tostring(column)) or column
    g = @ctx.groups
    g[#g + 1] = Nodes.Group.new(c)
  @

SelectManager.as = (other) =>
  @create_table_alias @grouping(@ast), Nodes.SqlLiteral.new(other)

SelectManager.having = (...) =>
  @ctx.having = Nodes.Having.new(@collapse({...}, @ctx.having))
  @

SelectManager.collapse = (exprs, existing=nil) =>
  insert exprs, 1, existing if existing
  new_expr = (expr) ->
    if type(expr) == 'string'
      Nodes.SqlLiteral.new expr
    else 
      expr
  exprs = [new_expr(expr) for expr in *exprs]

  if #exprs == 1
    exprs[1]
  else
    @create_and exprs

SelectManager.join = (relation, klazz) =>
  return @ unless relation
  klazz or= Nodes.InnerJoin
  if type(relation) == 'string' or relation.is_a[Nodes.SqlLiteral]
    klazz = Nodes.StringJoin
  r_sources = @ctx.source.right
  r_sources[#r_sources + 1] = @create_join relation, nil, klazz
  @

SelectManager.on = (...) =>
  r_sources = @ctx.source.right
  r_sources[#r_sources].right = Nodes.On.new @collapse({...})
  @

SelectManager.skip = (amount) =>
  if amount
    @ast.offset = Nodes.Offset.new amount
  else
    @ast.offset = nil
  @

SelectManager.offset = SelectManager.skip

SelectManager.exists = =>
  Nodes.Exists.new @ast

SelectManager.take = (limit) =>
  if limit
    @ast.limit = Nodes.Limit.new limit
    @ctx.top = Nodes.Top.new limit
  else
    @ast.limit = nil
    @ctx.top = nil
  @

SelectManager.except = (other) =>
  Nodes.Except.new @ast, other.ast

SelectManager.minus = (other) =>
  @except other

SelectManager.intersect = (other) =>
  Nodes.Intersect.new @ast, other.ast

SelectManager.capitalize = (str) =>
  title_case = (first, rest) -> "#{first\upper!}#{rest}"
  str\gsub "(%a)([%w_']*)", title_case

SelectManager.union = (operation, other) =>
  union_class = if other
    Nodes["Union#{@capitalize(operation)}"]
  else
    other = operation
    Nodes.Union

  union_class.new @ast, other.ast

SelectManager.With = (...) =>
  subqueries = {...}
  with_class = if type(subqueries[1]) == 'string'
    first = subqueries[1]
    subqueries = [q for i, q in ipairs(subqueries) when i > 1]
    Nodes["With#{@capitalize(first)}"]
  else
    Nodes.With
  @ast.with = with_class.new subqueries

  @

SelectManager.get_taken = =>
  if @ast.limit
    @ast.limit.value

-- TODO: a bit ugly, find another way
JoinSql = {k, v for k, v in pairs ToSql}
setmetatable JoinSql, getmetatable(ToSql)
JoinSql.SelectCore = (node) =>
  concat map(node.source.right, (j) -> @ j), ' '

SelectManager.join_sql = =>
  return unless @ctx.source.right or empty(@ctx.source.right)

  sql = JoinSql @ctx
  Nodes.SqlLiteral.new sql unless sql == ''

OrderClauses = {k, v for k, v in pairs ToSql}
setmetatable OrderClauses, getmetatable(ToSql)
OrderClauses.SelectStatement = (node) => @all node.orders

SelectManager.get_order_clauses = =>
  [Nodes.SqlLiteral.new(c) for c in *OrderClauses(@ast)]

WhereSql = {k, v for k, v in pairs ToSql}
setmetatable WhereSql, getmetatable(ToSql)
WhereSql.SelectCore = (node) =>
  "WHERE #{concat map(node.wheres, (w) -> @ w), ' AND '}"

SelectManager.where_sql = =>
  return if empty(@ctx.wheres)
  sql = WhereSql @ctx
  Nodes.SqlLiteral.new sql

-- TODO: lock?, locked

SelectManager
