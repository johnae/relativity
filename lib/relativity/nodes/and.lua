local define = require('classy').define
local Node = require("relativity.nodes.node")
return define('And', function()
  parent(Node)
  properties({
    left = function(self)
      return self.children[1]
    end,
    right = function(self)
      return self.children[2]
    end
  })
  return instance({
    initialize = function(self, children, right)
      if not (type(children) == 'table' and #children > 0) then
        children = {
          children,
          right
        }
      end
      self.children = children
    end
  })
end)
