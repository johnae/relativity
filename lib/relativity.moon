Nodes = require 'relativity.nodes.nodes'
Range = require 'relativity.range'
Table = require 'relativity.table'
SelectManager = require 'relativity.select_manager'
InsertManager = require 'relativity.select_manager'
UpdateManager = require 'relativity.select_manager'
DeleteManager = require 'relativity.delete_manager'
CaseBuilder = require 'relativity.nodes.case_builder'
{:SqlLiteral, :FunctionNode, :ConstLit, :UnqualifiedName, :As, :TableAlias} = Nodes

null = SqlLiteral.new 'NULL'
star = SqlLiteral.new '*'
sql = (raw_sql) -> SqlLiteral.new raw_sql
as = (a,b) -> As.new a, UnqualifiedName.new(b)
alias = (a, b) -> TableAlias.new a, b

func = (name) -> (...) ->
  args = {...}
  FunctionNode.new args, sql name

opt_func = (name) -> (opts={}) ->
  args = {}
  for k, v in pairs opts
    args[#args + 1] = k
    args[#args + 1] = v
  FunctionNode.new args, sql name


{
  VERSION: '0.0.1'

  :sql
  :null
  :star
  :as
  :alias
  :func
  :opt_func

  range: (start, finish) -> Range.new start, finish
  lit: (value) -> ConstLit.new value
  cast: (a,b) -> func('CAST') as(a, b)

  :Nodes
  :Table

  table: (...) -> Table.new ...
  select: -> SelectManager.new!
  insert: -> InsertManager.new!
  update: -> UpdateManager.new!
  delete: -> DeleteManager.new!
  case: (...) -> CaseBuilder.new ...
}
