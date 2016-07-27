local Unary = require('relativity.nodes.unary')
local Class = require('relativity.class')
local Expressions = require('relativity.expressions')
local Predications = require('relativity.predications')
local ConstLit = Class('ConstLit', Unary)
ConstLit.includes(Expressions)
ConstLit.includes(Predications)
return ConstLit
