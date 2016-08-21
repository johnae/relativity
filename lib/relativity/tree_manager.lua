local FactoryMethods = require('relativity.factory_methods')
local define = require('classy').define
local defer = require('relativity.defer')
local ToSql = defer(function()
  return require('relativity.visitors.to_sql')
end)
return define('TreeManager', function()
  include(FactoryMethods)
  return instance({
    initialize = function(self)
      self.ast = nil
      self.ctx = nil
    end,
    to_sql = function(self)
      return ToSql(self.ast)
    end,
    where = function(self, expr)
      if expr == self then
        expr = expr.ast
      end
      self.ctx.wheres = self.ctx.wheres or { }
      local w = self.ctx.wheres
      w[#w + 1] = expr
      return self
    end
  })
end)
