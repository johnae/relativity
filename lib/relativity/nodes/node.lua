local Class = require("relativity.class")
local defer = require("relativity.defer")
local ToSql = defer(function()
  return require("relativity.visitors.to_sql")
end)
local Not = defer(function()
  return require("relativity.nodes.nodes").Not
end)
local Grouping = defer(function()
  return require("relativity.nodes.nodes").Grouping
end)
local Or = defer(function()
  return require("relativity.nodes.nodes").Or
end)
local And = defer(function()
  return require("relativity.nodes.nodes").And
end)
local Node = Class("Node")
Node.Not = function(self)
  return Not.new(self)
end
Node.__unm = function(self, right)
  return self:Not()
end
Node.Or = function(self, right)
  return Grouping.new(Or.new(self, right))
end
Node.__add = function(self, right)
  return self:Or(right)
end
Node.And = function(self, right)
  return And.new({
    self,
    right
  })
end
Node.__mul = function(self, right)
  return self:And(right)
end
Node.to_sql = function(self)
  return ToSql(self)
end
return Node
