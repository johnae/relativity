local Unary = require('relativity.nodes.unary')
local define = require('classy').define
local Expressions = require('relativity.expressions')
local Predications = require('relativity.predications')
return define('ConstLit', function()
  parent(Unary)
  include(Expressions)
  return include(Predications)
end)
