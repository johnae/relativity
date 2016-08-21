Unary = require 'relativity.nodes.unary'
define = require'classy'.define
Expressions = require 'relativity.expressions'
Predications = require 'relativity.predications'

define 'ConstLit', ->
  parent Unary
  include Expressions
  include Predications
