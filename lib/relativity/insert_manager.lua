require('relativity.globals')
local empty
empty = table.empty
local TreeManager = require('relativity.tree_manager')
local InsertStatement = require('relativity.nodes.insert_statement')
local define = require('classy').define
local Nodes = require('relativity.nodes.nodes')
local Values, SqlLiteral
InsertStatement, Values, SqlLiteral = Nodes.InsertStatement, Nodes.Values, Nodes.SqlLiteral
local null = SqlLiteral.new('NULL')
return define('InsertManager', function()
  parent(TreeManager)
  properties({
    columns = function(self)
      return self.ast.columns
    end,
    values = {
      get = function(self)
        return self.ast.values
      end,
      set = function(self, values)
        self.ast.values = values
      end
    }
  })
  return instance({
    initialize = function(self)
      super(self)
      self.ast = InsertStatement.new()
    end,
    create_values = function(self, values, columns)
      return Values.new(values, columns)
    end,
    insert = function(self, fields)
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
          if value == nil then
            value = null
          end
          columns[#columns + 1] = column
          values[#values + 1] = value
        end
        self.ast.values = self:create_values(values, self.ast.columns)
      end
    end,
    into = function(self, table)
      self.ast.relation = table
      return self
    end
  })
end)
