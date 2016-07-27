local Class = require('relativity.class')
local Predications = require('relativity.predications')
local Expressions = require('relativity.expressions')
local Attribute = Class('Attribute')
Attribute.initialize = function(self, relation, name)
  self.relation = relation
  self.name = name
end
Attribute.includes(Expressions)
Attribute.includes(Predications)
return Attribute
