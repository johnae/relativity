local Class = require('relativity.class')
local SelectCore = require('relativity.nodes.select_core')
local SelectStatement = Class('SelectStatement')
SelectStatement.initialize = function(self, cores)
  self.cores = cores or {
    SelectCore.new()
  }
  self.orders = { }
  self.limit = nil
  self.lock = nil
  self.offset = nil
  self.with = nil
end
return SelectStatement
