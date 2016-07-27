local Node = require('relativity.nodes.node')
local JoinSource = require('relativity.nodes.join_source')
local Class = require('relativity.class')
local SelectCore = Class('SelectCore', Node)
SelectCore.initialize = function(self)
  self.source = JoinSource.new()
  self.top = nil
  self.projections = { }
  self.wheres = { }
  self.groups = { }
  self.having = nil
end
SelectCore.get_from = function(self)
  return self.source.left
end
SelectCore.set_from = function(self, value)
  self.source.left = value
  return self.source.left
end
return SelectCore
