local defer = require('relativity.defer')
local Nodes = defer(function()
  return require('relativity.nodes.nodes')
end)
return {
  count = function(self, distinct)
    if distinct == nil then
      distinct = false
    end
    return Nodes.Count.new({
      self
    }, distinct)
  end,
  sum = function(self)
    return Nodes.Sum.new({
      self
    }, Nodes.SqlLiteral.new('sum_id'))
  end,
  maximum = function(self)
    return Nodes.Max.new({
      self
    }, Nodes.SqlLiteral.new('max_id'))
  end,
  minimum = function(self)
    return Nodes.Min.new({
      self
    }, Nodes.SqlLiteral.new('min_id'))
  end,
  average = function(self)
    return Nodes.Avg.new({
      self
    }, Nodes.SqlLiteral.new('avg_id'))
  end
}
