local define = require('classy').define
return define('Range', function()
  return instance({
    initialize = function(self, start, finish)
      self.start, self.finish = start, finish
    end
  })
end)
