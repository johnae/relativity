local SelectManager = require('relativity.select_manager')
local InsertManager = require('relativity.insert_manager')
local defer = require('relativity.defer')
local Attributes = require('relativity.attributes')
local Nodes = defer(function()
  return require('relativity.nodes.nodes')
end)
local FactoryMethods = require('relativity.factory_methods')
local Crud = require('relativity.crud')
local define = require('classy').define
local Attribute = Attributes.Attribute
return define('Table', function()
  include(FactoryMethods)
  include(Crud)
  properties({
    star = function(self)
      return Nodes.TableStar.new(self)
    end
  })
  meta({
    __call = function(self, name)
      local attr = self.__cached_attributes[name]
      if attr then
        return attr
      end
      attr = Attribute.new(self, name)
      self.__cached_attributes[name] = attr
      return attr
    end
  })
  return instance({
    initialize = function(self, name, opts)
      if opts == nil then
        opts = { }
      end
      self.__cached_attributes = { }
      self.name = name
      self.columns = nil
      self.aliases = { }
      self.table_alias = opts.as
    end,
    from = function(self, table)
      return SelectManager.new(table)
    end,
    project = function(self, ...)
      return self:from(self):project(...)
    end,
    alias = function(self, name)
      if not (name) then
        name = tostring(self.name) .. "_2"
      end
      local aliases = self.aliases
      aliases[#aliases + 1] = Nodes.TableAlias.new(self, name)
      return aliases[#aliases]
    end,
    json = function(self, ...)
      local opts = { }
      local _list_0 = {
        ...
      }
      for _index_0 = 1, #_list_0 do
        local attr = _list_0[_index_0]
        opts[attr] = self(attr)
      end
      return Nodes.JsonBuildObject.new(opts)
    end,
    join = function(self, relation, klazz)
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
    end,
    insert_manager = function(self)
      return InsertManager.new()
    end,
    skip = function(self, amount)
      return self:from(self):skip(amount)
    end,
    select_manager = function(self)
      return SelectManager.new()
    end,
    having = function(self, expr)
      return self:from(self):having(expr)
    end,
    group = function(self, ...)
      return self:from(self):group(...)
    end,
    asc = function(self, ...)
      return self:from(self):asc(...)
    end,
    desc = function(self, ...)
      return self:from(self):desc(...)
    end,
    take = function(self, amount)
      return self:from(self):take(amount)
    end,
    where = function(self, condition)
      return self:from(self):where(condition)
    end
  })
end)
