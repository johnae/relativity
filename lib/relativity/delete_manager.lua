local TreeManager = require('relativity.tree_manager')
local DeleteStatement = require('relativity.nodes.delete_statement')
local Class = require('relativity.class')
local DeleteManager = Class('DeleteManager', TreeManager)
DeleteManager.initialize = function(self)
  self:super()
  self.ast = DeleteStatement.new()
  self.ctx = self.ast
end
DeleteManager.from = function(self, relation)
  self.ast.relation = relation
  return self
end
DeleteManager.wheres = function(self, list)
  self.ast.wheres = list
  return self
end
return DeleteManager
