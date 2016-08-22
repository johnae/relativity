TreeManager = require 'relativity.tree_manager'
UpdateStatement = require 'relativity.nodes.update_statement'
Nodes = require 'relativity.nodes.nodes'
define = require'classy'.define
{:Limit, :SqlLiteral, :Assignment, :UnqualifiedName} = Nodes

define 'UpdateManager', ->
  parent TreeManager
  instance
    initialize: =>
      super @
      @ast = UpdateStatement.new!
      @ctx = @ast

    take: (limit) =>
      @ast.limit = Limit.new limit if limit
      @

    key: (key) =>
      @ast.key = key

    order: (...) =>
      @ast.orders = {...}
      @

    table: (table) =>
      @ast.relation = table
      @

    wheres: (...) =>
      @ast.wheres = {...}

    where: (expr) =>
      w = @ast.wheres
      w[#w + 1] = expr
      @

    set: (values) =>
      t = type values
      if t == 'string' or (t == 'table' and values.__type == SqlLiteral.__type)
        @ast.values = {values}
      else
        v = {}
        for def in *values
          column = def[1]
          value = def[2]
          v[#v + 1] = Assignment.new UnqualifiedName.new(column), value
        @ast.values = v
      @
