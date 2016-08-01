local defer = require('relativity.defer')
local Nodes = defer(function()
  return require('relativity.nodes.nodes')
end)
return {
  count = function(self, distinct)
    if distinct == nil then
      distinct = false
    end
    return Nodes.Count.new(self, distinct)
  end,
  sum = function(self)
    return Nodes.Sum.new(self)
  end,
  maximum = function(self)
    return Nodes.Max.new(self)
  end,
  minimum = function(self)
    return Nodes.Min.new(self)
  end,
  average = function(self)
    return Nodes.Avg.new(self)
  end
}
