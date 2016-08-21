local Binary = require('relativity.nodes.binary')
local define = require('classy').define
return define('JoinSource', function()
  parent(Binary)
  return instance({
    initialize = function(self, single_source, joinop)
      super(self, single_source, joinop)
      self.right = { }
    end
  })
end)
