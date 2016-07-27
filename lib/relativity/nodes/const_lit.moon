Unary = require 'relativity.nodes.unary'
Class = require 'relativity.class'
Expressions = require 'relativity.expressions'
Predications = require 'relativity.predications'

ConstLit = Class 'ConstLit', Unary
ConstLit.includes Expressions
ConstLit.includes Predications
ConstLit
