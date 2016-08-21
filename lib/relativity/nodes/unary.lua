local define = require('classy').define
local Node = require("relativity.nodes.node")
return define('Unary', function()
  parent(Node)
  return instance({
    initialize = function(self, expr)
      self.value = expr
    end
  })
end)
