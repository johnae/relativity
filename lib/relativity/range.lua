local Class = require('relativity.class')
local Range = Class('Range')
Range.initialize = function(self, start, finish)
  self.start = start
  self.finish = finish
end
return Range
