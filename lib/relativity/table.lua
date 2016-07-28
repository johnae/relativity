local SelectManager = require('relativity.select_manager')
local InsertManager = require('relativity.insert_manager')
local defer = require('relativity.defer')
local Attributes = require('relativity.attributes')
local Nodes = defer(function()
  return require('relativity.nodes.nodes')
end)
local FactoryMethods = require('relativity.factory_methods')
local Crud = require('relativity.crud')
local Class = require('relativity.class')
local Attribute = Attributes.Attribute
local Table = Class('Table')
Table.includes(FactoryMethods)
Table.includes(Crud)
Table.initialize = function(self, name, opts)
  if opts == nil then
    opts = { }
  end
  self.name = name
  self.columns = nil
  self.aliases = { }
  if opts.as then
    self.table_alias = opts.as
  end
end
Table.from = function(self, table)
  return SelectManager.new(table)
end
Table.project = function(self, ...)
  return self:from(self):project(...)
end
Table.attribute = function(self, name)
  return Attribute.new(self, name)
end
Table.alias = function(self, name)
  if not (name) then
    name = tostring(self.name) .. "_2"
  end
  local aliases = self.aliases
  aliases[#aliases + 1] = Nodes.TableAlias.new(self, name)
  return aliases[#aliases]
end
Table.__call = function(self, name)
  return Attribute.new(self, name)
end
Table.json = function(self, ...)
  local opts = { }
  local _list_0 = {
    ...
  }
  for _index_0 = 1, #_list_0 do
    local attr = _list_0[_index_0]
    opts[attr] = self(attr)
  end
  return Nodes.JsonBuildObject.new(opts)
end
Table.join = function(self, relation, klazz)
  klazz = klazz or Nodes.InnerJoin
  if not (relation) then
    return self:from(self)
  end
  if relation == Nodes.StringJoin or type(relation) == 'string' then
    klazz = Nodes.StringJoin
  else
    klazz = klazz
  end
  return self:from(self):join(relation, klazz)
end
Table.insert_manager = function(self)
  return InsertManager.new()
end
Table.skip = function(self, amount)
  return self:from(self):skip(amount)
end
Table.select_manager = function(self)
  return SelectManager.new()
end
Table.having = function(self, expr)
  return self:from(self):having(expr)
end
Table.group = function(self, ...)
  return self:from(self):group(...)
end
Table.order = function(self, ...)
  return self:from(self):order(...)
end
Table.take = function(self, amount)
  return self:from(self):take(amount)
end
Table.where = function(self, condition)
  return self:from(self):where(condition)
end
Table.star = function(self)
  return Nodes.TableStar.new(self)
end
return Table
