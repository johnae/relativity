local Class = require("relativity.class")
local Node = require("relativity.nodes.node")
local Binary = Class("Binary", Node)
Binary.initialize = function(self, left, right)
  self.left, self.right = left, right
end
return Binary
