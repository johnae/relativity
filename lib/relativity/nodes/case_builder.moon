define = require'classy'.define
Node = require "relativity.nodes.node"
Expressions = require "relativity.expressions"
Predications = require "relativity.predications"

Case = define 'Case', ->
  parent Node
  include Expressions
  include Predications
  instance
    initialize: (base, cases, _else) =>
      @_base = base
      @_cases = cases
      @_else = _else

define 'CaseBuilder', ->
  parent Node
  instance
    initialize: (base) =>
      @_base = base
      @_cases = {}
      @_else = nil

    When: (cond, res) =>
      cases = @_cases
      cases[#cases + 1] = {cond, res}
      @

    Else: (res) =>
      @_else = res
      @

    End: =>
      Case.new @_base, @_cases, @_else
