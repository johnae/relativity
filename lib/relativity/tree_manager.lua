local FactoryMethods = require('relativity.factory_methods')
local Class = require('relativity.class')
local defer = require('relativity.defer')
local TreeManager = Class('TreeManager', FactoryMethods)
local ToSql = defer(function()
  return require('relativity.visitors.to_sql')
end)
TreeManager.initialize = function(self)
  self.ast = nil
  self.ctx = nil
end
TreeManager.to_sql = function(self)
  return ToSql(self.ast)
end
TreeManager.where = function(self, expr)
  if TreeManager == expr then
    expr = expr.ast
  end
  self.ctx.wheres = self.ctx.wheres or { }
  local w = self.ctx.wheres
  w[#w + 1] = expr
  return self
end
return TreeManager
