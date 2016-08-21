require("relativity.globals")
local copy_value = copy_value
local define = require('classy').define
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
return define('Node', function()
  properties({
    ["not"] = function(self)
      return Not.new(self)
    end
  })
  instance({
    Or = function(self, right)
      return Grouping.new(Or.new(self, right))
    end,
    And = function(self, right)
      return And.new({
        self,
        right
      })
    end,
    to_sql = function(self)
      return ToSql(self)
    end
  })
  return meta({
    __unm = function(self)
      return Not.new(self)
    end,
    __add = function(self, right)
      return self:Or(right)
    end,
    __mul = function(self, right)
      return self:And(right)
    end
  })
end)
