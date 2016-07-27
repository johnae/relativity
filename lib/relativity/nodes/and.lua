local Class = require("relativity.class")
local Node = require("relativity.nodes.node")
local And = Class("And", Node)
And.initialize = function(self, children, right)
  if right == nil then
    right = nil
  end
  if not (type(children) == 'table' and #children > 0) then
    children = {
      children,
      right
    }
  end
  self.children = children
end
And.left = function(self)
  return self.children[1]
end
And.right = function(self)
  return self.children[2]
end
return And
