local Class = require("relativity.class")
local Node = require("relativity.nodes.node")
local Unary = Class("Unary", Node)
Unary.initialize = function(self, expr)
  self.value = expr
end
return Unary
