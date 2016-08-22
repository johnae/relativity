local TreeManager = require('relativity.tree_manager')
local UpdateStatement = require('relativity.nodes.update_statement')
local Nodes = require('relativity.nodes.nodes')
local define = require('classy').define
local Limit, SqlLiteral, Assignment, UnqualifiedName
Limit, SqlLiteral, Assignment, UnqualifiedName = Nodes.Limit, Nodes.SqlLiteral, Nodes.Assignment, Nodes.UnqualifiedName
return define('UpdateManager', function()
  parent(TreeManager)
  return instance({
    initialize = function(self)
      super(self)
      self.ast = UpdateStatement.new()
      self.ctx = self.ast
    end,
    take = function(self, limit)
      if limit then
        self.ast.limit = Limit.new(limit)
      end
      return self
    end,
    key = function(self, key)
      self.ast.key = key
    end,
    order = function(self, ...)
      self.ast.orders = {
        ...
      }
      return self
    end,
    table = function(self, table)
      self.ast.relation = table
      return self
    end,
    wheres = function(self, ...)
      self.ast.wheres = {
        ...
      }
    end,
    where = function(self, expr)
      local w = self.ast.wheres
      w[#w + 1] = expr
      return self
    end,
    set = function(self, values)
      local t = type(values)
      if t == 'string' or (t == 'table' and values.__type == SqlLiteral.__type) then
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
  })
end)
