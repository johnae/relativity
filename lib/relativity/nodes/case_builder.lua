local define = require('classy').define
local Node = require("relativity.nodes.node")
local Expressions = require("relativity.expressions")
local Predications = require("relativity.predications")
local Case = define('Case', function()
  parent(Node)
  include(Expressions)
  include(Predications)
  return instance({
    initialize = function(self, base, cases, _else)
      self._base = base
      self._cases = cases
      self._else = _else
    end
  })
end)
return define('CaseBuilder', function()
  parent(Node)
  return instance({
    initialize = function(self, base)
      self._base = base
      self._cases = { }
      self._else = nil
    end,
    When = function(self, cond, res)
      local cases = self._cases
      cases[#cases + 1] = {
        cond,
        res
      }
      return self
    end,
    Else = function(self, res)
      self._else = res
      return self
    end,
    End = function(self)
      return Case.new(self._base, self._cases, self._else)
    end
  })
end)
