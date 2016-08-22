local Binary = require('relativity.nodes.binary')
local define = require('classy').define
return define('DeleteStatement', function()
  parent(Binary)
  return instance({
    initialize = function(self, relation, wheres)
      return super(self, relation, wheres)
    end
  })
end)
