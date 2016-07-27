TreeManager = require 'relativity.tree_manager'
UpdateStatement = require 'relativity.nodes.update_statement'
Nodes = require 'relativity.nodes.nodes'
Class = require 'relativity.class'
{:Limit, :SqlLiteral, :Assignment, :UnqualifiedName} = Nodes

UpdateManager = Class 'UpdateManager', TreeManager
UpdateManager.initialize = =>
  @super!
  @ast = UpdateStatement.new!
  @ctx = @ast

UpdateManager.take = (limit) =>
  @ast.limit = Limit.new limit if limit
  @

UpdateManager.key = (key) =>
  @ast.key = key

UpdateManager.order = (...) =>
  @ast.orders = {...}
  @

UpdateManager.table = (table) =>
  @ast.relation = table
  @

UpdateManager.wheres = (...) =>
  @ast.wheres = {...}

UpdateManager.where = (expr) =>
  w = @ast.wheres
  w[#w + 1] = expr
  @

UpdateManager.set = (values) =>
  if type(values) == 'string' or values == SqlLiteral
    @ast.values = {values}
  else
    v = {}
    for def in *values
      column = def[1]
      value = def[2]
      v[#v + 1] = Assignment.new UnqualifiedName.new(column), value
    @ast.values = v
  @

UpdateManager
