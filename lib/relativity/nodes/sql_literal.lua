local define = require('classy').define
local Unary = require('relativity.nodes.unary')
local Expressions = require('relativity.expressions')
local Predications = require('relativity.predications')
return define('SqlLiteral', function()
  parent(Unary)
  include(Expressions)
  include(Predications)
  return meta({
    __tostring = function(self)
      return tostring(self.value)
    end
  })
end)
