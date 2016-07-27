Nodes = require 'relativity.nodes.nodes'
Range = require 'relativity.range'
Table = require 'relativity.table'
SelectManager = require 'relativity.select_manager'
InsertManager = require 'relativity.select_manager'
UpdateManager = require 'relativity.select_manager'
CaseBuilder = require 'relativity.nodes.case_builder'
{:SqlLiteral, :FunctionNode, :ConstLit, :UnqualifiedName, :As, :Null} = Nodes

null = Null.new!
star = SqlLiteral.new '*'

{
  VERSION: '0.0.1'

  sql: (raw_sql) =>
    SqlLiteral.new raw_sql

  null: -> null

  star: -> star

  range: (start, finish) =>
    Range.new start, finish

  func: (name) => (...) ->
    args = {...}
    FunctionNode.new args, @sql(name)

  lit: (value) => ConstLit.new value

  as: (a,b) => As.new a, UnqualifiedName.new(b)

  cast: (a,b) => @func('CAST') @as(a, b)

  :Nodes
  :Table

  table: (...) -> Table.new ...
  select: -> SelectManager.new!
  insert: -> InsertManager.new!
  update: -> UpdateManager.new!
  case: (...) -> CaseBuilder.new ...
}
