local Node = require('relativity.nodes.node')
local define = require('classy').define
return define('UpdateStatement', function()
  parent(Node)
  return instance({
    initialize = function(self)
      self.relation = nil
      self.wheres = { }
      self.values = { }
      self.orders = { }
      self.limit = nil
      self.key = nil
    end
  })
end)
