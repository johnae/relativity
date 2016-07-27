require('relativity.globals')
local empty
empty = table.empty
local TreeManager = require('relativity.tree_manager')
local InsertStatement = require('relativity.nodes.insert_statement')
local Class = require('relativity.class')
local Nodes = require('relativity.nodes.nodes')
local Values, SqlLiteral
InsertStatement, Values, SqlLiteral = Nodes.InsertStatement, Nodes.Values, Nodes.SqlLiteral
local InsertManager = Class('InsertManager', TreeManager)
InsertManager.initialize = function(self)
  self:super()
  self.ast = InsertStatement.new()
end
InsertManager.create_values = function(self, values, columns)
  return Values.new(values, columns)
end
InsertManager.get_columns = function(self)
  return self.ast.columns
end
InsertManager.set_values = function(self, values)
  self.ast.values = values
end
InsertManager.get_values = function(self)
  return self.ast.values
end
InsertManager.insert = function(self, fields)
  if empty(fields) then
    return 
  end
  if type(fields) == 'string' then
    self.ast.values = SqlLiteral.new(fields)
  else
    self.ast.relation = self.ast.relation or fields[1][1].relation
    local values = { }
    local columns = self.ast.columns
    for _index_0 = 1, #fields do
      local field = fields[_index_0]
      local column = field[1]
      local value = field[2]
      columns[#columns + 1] = column
      values[#values + 1] = value
    end
    self.ast.values = self:create_values(values, self.ast.columns)
  end
end
InsertManager.into = function(self, table)
  self.ast.relation = table
  return self
end
return InsertManager
