local Class = require("relativity.class")
local Node = require("relativity.nodes.node")
local Expressions = require("relativity.expressions")
local Predications = require("relativity.predications")
local Case = Class("Case", Node)
Case.initialize = function(self, base, cases, _else)
  self._base = base
  self._cases = cases
  self._else = _else
end
Case.includes(Expressions)
Case.includes(Predications)
local CaseBuilder = Class("CaseBuilder", Node)
CaseBuilder.initialize = function(self, base)
  self._base = base
  self._cases = { }
  self._else = nil
end
CaseBuilder.When = function(self, cond, res)
  local cases = self._cases
  cases[#cases + 1] = {
    cond,
    res
  }
  return self
end
CaseBuilder.Else = function(self, res)
  self._else = res
  return self
end
CaseBuilder.End = function(self)
  return Case.new(self._base, self._cases, self._else)
end
return CaseBuilder
