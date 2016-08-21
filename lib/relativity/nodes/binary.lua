local define = require('classy').define
local Node = require("relativity.nodes.node")
return define('Binary', function()
  parent(Node)
  return instance({
    initialize = function(self, left, right)
      self.left, self.right = left, right
    end
  })
end)
