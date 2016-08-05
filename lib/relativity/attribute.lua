require("relativity.globals")
local copy_value = copy_value
local Class = require('relativity.class')
local Predications = require('relativity.predications')
local Expressions = require('relativity.expressions')
local defer = require('relativity.defer')
local ToSql = defer(function()
  return require('relativity.visitors.to_sql')
end)
local Attribute = Class('Attribute')
Attribute.initialize = function(self, relation, name)
  self.relation = relation
  self.name = name
end
Attribute.to_sql = function(self)
  return ToSql(self)
end
Attribute.includes(Expressions)
Attribute.includes(Predications)
Attribute.__tostring = function(self)
  return self:to_sql()
end
Attribute.clone = function(self)
  return copy_value(self)
end
return Attribute
