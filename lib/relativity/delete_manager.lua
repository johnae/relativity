local TreeManager = require('relativity.tree_manager')
local DeleteStatement = require('relativity.nodes.delete_statement')
local define = require('classy').define
return define('DeleteManager', function()
  parent(TreeManager)
  return instance({
    initialize = function(self)
      super(self)
      self.ast = DeleteStatement.new()
      self.ctx = self.ast
    end,
    from = function(self, relation)
      self.ast.relation = relation
      return self
    end,
    wheres = function(self, list)
      self.ast.wheres = list
      return self
    end
  })
end)
