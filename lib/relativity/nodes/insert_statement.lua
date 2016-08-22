local Node = require('relativity.nodes.node')
local define = require('classy').define
return define('InsertStatement', function()
  parent(Node)
  return instance({
    initialize = function(self)
      self.relation = nil
      self.columns = { }
      self.values = nil
    end
  })
end)
