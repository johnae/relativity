local Node = require('relativity.nodes.node')
local SqlLiteral = require('relativity.nodes.sql_literal')
local Class = require('relativity.class')
local Expressions = require('relativity.expressions')
local Predications = require('relativity.predications')
local FunctionNode = Class('FunctionNode', Node)
FunctionNode.initialize = function(self, expressions, alias)
  self.expressions = expressions
  self.alias = alias
  self.distinct = false
end
FunctionNode.as = function(self, alias)
  self.alias = SqlLiteral.new(alias)
  return self
end
FunctionNode.includes(Expressions)
FunctionNode.includes(Predications)
return FunctionNode
