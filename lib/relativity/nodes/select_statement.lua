local define = require('classy').define
local SelectCore = require('relativity.nodes.select_core')
return define('SelectStatement', function()
  return instance({
    initialize = function(self, cores)
      self.cores = cores or {
        SelectCore.new()
      }
      self.orders = { }
      self.limit = nil
      self.lock = nil
      self.offset = nil
      self.with = nil
    end
  })
end)
