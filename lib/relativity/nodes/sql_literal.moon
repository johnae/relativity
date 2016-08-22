define = require'classy'.define
Unary = require 'relativity.nodes.unary'
Expressions = require 'relativity.expressions'
Predications = require 'relativity.predications'

define 'SqlLiteral', ->
  parent Unary
  include Expressions
  include Predications
  meta
    __tostring: => tostring @value
