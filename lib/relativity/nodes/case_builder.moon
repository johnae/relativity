Class = require "relativity.class"
Node = require "relativity.nodes.node"
Expressions = require "relativity.expressions"
Predications = require "relativity.predications"

Case = Class "Case", Node
Case.initialize = (base, cases, _else) =>
  @_base = base
  @_cases = cases
  @_else = _else

Case.includes Expressions
Case.includes Predications

CaseBuilder = Class "CaseBuilder", Node
CaseBuilder.initialize = (base) =>
  @_base = base
  @_cases = {}
  @_else = nil

CaseBuilder.When = (cond, res) =>
  cases = @_cases
  cases[#cases + 1] = {cond, res}
  @

CaseBuilder.Else = (res) =>
  @_else = res
  @

CaseBuilder.End = =>
  Case.new @_base, @_cases, @_else

CaseBuilder
