local TreeManager = require('relativity.tree_manager')
local UpdateStatement = require('relativity.nodes.update_statement')
local Nodes = require('relativity.nodes.nodes')
local Class = require('relativity.class')
local Limit, SqlLiteral, Assignment, UnqualifiedName
Limit, SqlLiteral, Assignment, UnqualifiedName = Nodes.Limit, Nodes.SqlLiteral, Nodes.Assignment, Nodes.UnqualifiedName
local UpdateManager = Class('UpdateManager', TreeManager)
UpdateManager.initialize = function(self)
  self:super()
  self.ast = UpdateStatement.new()
  self.ctx = self.ast
end
UpdateManager.take = function(self, limit)
  if limit then
    self.ast.limit = Limit.new(limit)
  end
  return self
end
UpdateManager.key = function(self, key)
  self.ast.key = key
end
UpdateManager.order = function(self, ...)
  self.ast.orders = {
    ...
  }
  return self
end
UpdateManager.table = function(self, table)
  self.ast.relation = table
  return self
end
UpdateManager.wheres = function(self, ...)
  self.ast.wheres = {
    ...
  }
end
UpdateManager.where = function(self, expr)
  local w = self.ast.wheres
  w[#w + 1] = expr
  return self
end
UpdateManager.set = function(self, values)
  if type(values) == 'string' or values == SqlLiteral then
    self.ast.values = {
      values
    }
  else
    local v = { }
    for _index_0 = 1, #values do
      local def = values[_index_0]
      local column = def[1]
      local value = def[2]
      v[#v + 1] = Assignment.new(UnqualifiedName.new(column), value)
    end
    self.ast.values = v
  end
  return self
end
return UpdateManager
