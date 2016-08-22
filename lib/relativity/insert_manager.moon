require 'relativity.globals'
{:empty} = table
TreeManager = require 'relativity.tree_manager'
InsertStatement = require 'relativity.nodes.insert_statement'
define = require'classy'.define
Nodes = require 'relativity.nodes.nodes'
{:InsertStatement, :Values, :SqlLiteral} = Nodes
null = SqlLiteral.new 'NULL'

define 'InsertManager', ->
  parent TreeManager
  properties
    columns: => @ast.columns
    values:
      get: => @ast.values
      set: (values) => @ast.values = values
  instance
    initialize: =>
      super @
      @ast = InsertStatement.new!

    create_values: (values, columns) =>
      Values.new values, columns

    insert: (fields) =>
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
          value = null if value == nil
          columns[#columns + 1] = column
          values[#values + 1] = value

        @ast.values = @create_values values, @ast.columns

    into: (table) =>
      @ast.relation = table
      @
