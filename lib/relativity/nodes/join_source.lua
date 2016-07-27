local Binary = require('relativity.nodes.binary')
local Class = require('relativity.class')
local JoinSource = Class('JoinSource', Binary)
JoinSource.initialize = function(self, single_source, joinop)
  Binary.initialize(self, single_source, joinop)
  self.right = { }
end
return JoinSource
