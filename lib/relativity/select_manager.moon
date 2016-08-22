require 'relativity.globals'
{:insert, :empty, :concat, :map} = table
TreeManager = require 'relativity.tree_manager'
ToSql = require 'relativity.visitors.to_sql'
Predications = require 'relativity.predications'
define = require'classy'.define
defer = require 'relativity.defer'
Nodes = defer -> require "relativity.nodes.nodes"

define 'SelectManager', ->
  parent TreeManager
  include Predications

  new_order = (expr, klazz) ->
    if type(expr) == 'string'
      return klazz.new Nodes.SqlLiteral.new(tostring(expr))
    klazz.new expr

  skip = (amount) =>
    if amount
      @ast.offset = Nodes.Offset.new amount
    else
      @ast.offset = nil
    @

  capitalize = (str) ->
    title_case = (first, rest) -> "#{first\upper!}#{rest}"
    str\gsub "(%a)([%w_']*)", title_case

  -- TODO: a bit ugly, find another way
  JoinSql = {k, v for k, v in pairs ToSql}
  setmetatable JoinSql, getmetatable(ToSql)
  JoinSql.SelectCore = (node) =>
    concat map(node.source.right, (j) -> @ j), ' '

  WhereSql = {k, v for k, v in pairs ToSql}
  WhereSql.SelectCore = (node) =>
    "WHERE #{concat map(node.wheres, (w) -> @ w), ' AND '}"
  setmetatable WhereSql, getmetatable(ToSql)

  OrderClauses = {k, v for k, v in pairs ToSql}
  setmetatable OrderClauses, getmetatable(ToSql)
  OrderClauses.SelectStatement = (node) => @all node.orders

  properties
    orders: => @ast.orders
    froms: =>
      cores = @ast.cores
      [core.from for core in *cores]
    exists: => Nodes.Exists.new @ast
    taken: =>
      if @ast.limit
        @ast.limit.value

    order_clauses: =>
      [Nodes.SqlLiteral.new(c) for c in *OrderClauses(@ast)]

  instance
    initialize: (table) =>
      super @
      @ast = Nodes.SelectStatement.new!
      cores = @ast.cores
      @ctx = cores[#cores]
      @from table

    project: (...) =>
      p = @ctx.projections
      for projection in *{...}
        if type(projection) == 'string'
          projection = Nodes.SqlLiteral.new projection
        p[#p + 1] = projection
      @

    asc: (...) =>
      new_orders = [new_order(o, Nodes.Ascending) for o in *{...}]
      o = @ast.orders
      for order in *new_orders
        o[#o + 1] = order
      @

    desc: (...) =>
      new_orders = [new_order(o, Nodes.Descending) for o in *{...}]
      o = @ast.orders
      for order in *new_orders
        o[#o + 1] = order
      @

    from: (table) =>
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

    group: (...) =>
      for column in *{...}
        c = type(column) == 'string' and Nodes.SqlLiteral.new(tostring(column)) or column
        g = @ctx.groups
        g[#g + 1] = Nodes.Group.new(c)
      @

    as: (other) =>
      @create_table_alias @grouping(@ast), Nodes.SqlLiteral.new(other)

    having: (...) =>
      @ctx.having = Nodes.Having.new(@collapse({...}, @ctx.having))
      @

    collapse: (exprs, existing=nil) =>
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

    join: (relation, klazz) =>
      return @ unless relation
      klazz or= Nodes.InnerJoin
      if type(relation) == 'string' or relation.is_a[Nodes.SqlLiteral]
        klazz = Nodes.StringJoin
      r_sources = @ctx.source.right
      r_sources[#r_sources + 1] = @create_join relation, nil, klazz
      @

    on: (...) =>
      r_sources = @ctx.source.right
      r_sources[#r_sources].right = Nodes.On.new @collapse({...})
      @

    :skip
    offset: skip

    take: (limit) =>
      if limit
        @ast.limit = Nodes.Limit.new limit
        @ctx.top = Nodes.Top.new limit
      else
        @ast.limit = nil
        @ctx.top = nil
      @

    except: (other) =>
      Nodes.Except.new @ast, other.ast

    minus: (other) =>
      @except other

    intersect: (other) =>
      Nodes.Intersect.new @ast, other.ast

    union: (operation, other) =>
      union_class = if other
        Nodes["Union#{capitalize(operation)}"]
      else
        other = operation
        Nodes.Union

      union_class.new @ast, other.ast

    With: (...) =>
      subqueries = {...}
      with_class = if type(subqueries[1]) == 'string'
        first = subqueries[1]
        subqueries = [q for i, q in ipairs(subqueries) when i > 1]
        Nodes["With#{capitalize(first)}"]
      else
        Nodes.With
      @ast.with = with_class.new subqueries

      @

    join_sql: =>
      return unless @ctx.source.right or empty(@ctx.source.right)
      sql = JoinSql @ctx
      Nodes.SqlLiteral.new sql unless sql == ''

    where_sql: =>
      return if empty(@ctx.wheres)
      sql = WhereSql @ctx
      Nodes.SqlLiteral.new sql

    -- TODO: lock?, locked
