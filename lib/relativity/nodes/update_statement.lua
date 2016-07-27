local Node = require('relativity.nodes.node')
local Class = require('relativity.class')
local UpdateStatement = Class('UpdateStatement', Node)
UpdateStatement.initialize = function(self)
  self.relation = nil
  self.wheres = { }
  self.values = { }
  self.orders = { }
  self.limit = nil
  self.key = nil
end
return UpdateStatement
