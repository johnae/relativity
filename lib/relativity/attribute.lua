require("relativity.globals")
local copy_value = copy_value
local define = require('classy').define
local Predications = require('relativity.predications')
local Expressions = require('relativity.expressions')
local defer = require('relativity.defer')
local ToSql = defer(function()
  return require('relativity.visitors.to_sql')
end)
return define('Attribute', function()
  include(Expressions)
  include(Predications)
  instance({
    initialize = function(self, relation, name)
      self.relation = relation
      self.name = name
    end,
    to_sql = function(self)
      return ToSql(self)
    end
  })
  return meta({
    __tostring = function(self)
      return self.name
    end
  })
end)
