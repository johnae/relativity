local Class = require('relativity.class')
local Unary = require('relativity.nodes.unary')
local Expressions = require('relativity.expressions')
local Predications = require('relativity.predications')
local SqlLiteral = Class('SqlLiteral', Unary)
SqlLiteral.includes(Expressions)
SqlLiteral.includes(Predications)
SqlLiteral.__tostring = function(self)
  return tostring(self.value)
end
return SqlLiteral
