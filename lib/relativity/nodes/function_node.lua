local Node = require('relativity.nodes.node')
local define = require('classy').define
local Expressions = require('relativity.expressions')
local Predications = require('relativity.predications')
return define('FunctionNode', function()
  parent(Node)
  include(Expressions)
  include(Predications)
  return instance({
    initialize = function(self, expressions, name)
      self.expressions = expressions
      self.name = name
      self.distinct = false
    end
  })
end)
