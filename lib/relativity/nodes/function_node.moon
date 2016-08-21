Node = require 'relativity.nodes.node'
define = require'classy'.define
Expressions = require 'relativity.expressions'
Predications = require 'relativity.predications'

define 'FunctionNode', ->
  parent Node
  include Expressions
  include Predications
  instance
    initialize: (expressions, name) =>
      @expressions = expressions
      @name = name
      @distinct = false
