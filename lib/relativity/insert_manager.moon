require 'relativity.globals'
{:empty} = table
TreeManager = require 'relativity.tree_manager'
InsertStatement = require 'relativity.nodes.insert_statement'
Class = require 'relativity.class'
Nodes = require 'relativity.nodes.nodes'
{:InsertStatement, :Values, :SqlLiteral} = Nodes

InsertManager = Class 'InsertManager', TreeManager
InsertManager.initialize = =>
  @super!
  @ast = InsertStatement.new!

InsertManager.create_values = (values, columns) =>
  Values.new values, columns

InsertManager.get_columns = =>
  @ast.columns

InsertManager.set_values = (values) =>
  @ast.values = values

InsertManager.get_values = =>
  @ast.values

InsertManager.insert = (fields) =>
  return if empty fields
  if type(fields) == 'string'
    @ast.values = SqlLiteral.new fields
  else
    @ast.relation or= fields[1][1].relation
    values = {}
    columns = @ast.columns
    for field in *fields
      column = field[1]
      value = field[2]
      columns[#columns + 1] = column
      values[#values + 1] = value

    @ast.values = @create_values values, @ast.columns

InsertManager.into = (table) =>
  @ast.relation = table
  @

InsertManager
