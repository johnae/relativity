local Binary = require('relativity.nodes.binary')
local Class = require('relativity.class')
local DeleteStatement = Class('DeleteStatement', Binary)
DeleteStatement.initialize = function(self, relation, wheres)
  return Binary.initialize(self, relation, wheres)
end
return DeleteStatement
