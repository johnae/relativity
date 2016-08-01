local Nodes = require('relativity.nodes.nodes')
local Range = require('relativity.range')
local Table = require('relativity.table')
local SelectManager = require('relativity.select_manager')
local InsertManager = require('relativity.select_manager')
local UpdateManager = require('relativity.select_manager')
local DeleteManager = require('relativity.delete_manager')
local CaseBuilder = require('relativity.nodes.case_builder')
local SqlLiteral, FunctionNode, ConstLit, UnqualifiedName, As, Null, TableAlias
SqlLiteral, FunctionNode, ConstLit, UnqualifiedName, As, Null, TableAlias = Nodes.SqlLiteral, Nodes.FunctionNode, Nodes.ConstLit, Nodes.UnqualifiedName, Nodes.As, Nodes.Null, Nodes.TableAlias
local null = Null.new()
local star = SqlLiteral.new('*')
local sql
sql = function(raw_sql)
  return SqlLiteral.new(raw_sql)
end
local as
as = function(a, b)
  return As.new(a, UnqualifiedName.new(b))
end
local alias
alias = function(a, b)
  return TableAlias.new(a, b)
end
local func
func = function(name)
  return function(...)
    local args = {
      ...
    }
    return FunctionNode.new(args, sql(name))
  end
end
return {
  VERSION = '0.0.1',
  sql = sql,
  null = null,
  star = star,
  as = as,
  alias = alias,
  func = func,
  range = function(start, finish)
    return Range.new(start, finish)
  end,
  lit = function(value)
    return ConstLit.new(value)
  end,
  cast = function(a, b)
    return func('CAST')(as(a, b))
  end,
  Nodes = Nodes,
  Table = Table,
  table = function(...)
    return Table.new(...)
  end,
  select = function()
    return SelectManager.new()
  end,
  insert = function()
    return InsertManager.new()
  end,
  update = function()
    return UpdateManager.new()
  end,
  delete = function()
    return DeleteManager.new()
  end,
  case = function(...)
    return CaseBuilder.new(...)
  end
}
