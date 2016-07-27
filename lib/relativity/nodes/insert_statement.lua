local Node = require('relativity.nodes.node')
local Class = require('relativity.class')
local InsertStatement = Class('InsertStatement', Node)
InsertStatement.initialize = function(self)
  self.relation = nil
  self.columns = { }
  self.values = nil
end
return InsertStatement
