local Nodes = require('relativity.nodes.nodes')
local Range = require('relativity.range')
local Table = require('relativity.table')
local SelectManager = require('relativity.select_manager')
local InsertManager = require('relativity.select_manager')
local UpdateManager = require('relativity.select_manager')
local CaseBuilder = require('relativity.nodes.case_builder')
local SqlLiteral, FunctionNode, ConstLit, UnqualifiedName, As, Null
SqlLiteral, FunctionNode, ConstLit, UnqualifiedName, As, Null = Nodes.SqlLiteral, Nodes.FunctionNode, Nodes.ConstLit, Nodes.UnqualifiedName, Nodes.As, Nodes.Null
local null = Null.new()
local star = SqlLiteral.new('*')
return {
  VERSION = '0.0.1',
  sql = function(self, raw_sql)
    return SqlLiteral.new(raw_sql)
  end,
  null = function()
    return null
  end,
  star = function()
    return star
  end,
  range = function(self, start, finish)
    return Range.new(start, finish)
  end,
  func = function(self, name)
    return function(...)
      local args = {
        ...
      }
      return FunctionNode.new(args, self:sql(name))
    end
  end,
  lit = function(self, value)
    return ConstLit.new(value)
  end,
  as = function(self, a, b)
    return As.new(a, UnqualifiedName.new(b))
  end,
  cast = function(self, a, b)
    return self:func('CAST')(self:as(a, b))
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
  case = function(...)
    return CaseBuilder.new(...)
  end
}
