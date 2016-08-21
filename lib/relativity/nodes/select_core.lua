local Node = require('relativity.nodes.node')
local JoinSource = require('relativity.nodes.join_source')
local define = require('classy').define
return define('SelectCore', function()
  parent(Node)
  properties({
    from = {
      get = function(self)
        return self.source.left
      end,
      set = function(self, value)
        self.source.left = value
      end
    }
  })
  return instance({
    initialize = function(self)
      self.source = JoinSource.new()
      self.top = nil
      self.projections = { }
      self.wheres = { }
      self.groups = { }
      self.having = nil
    end
  })
end)
