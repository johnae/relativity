Class = require 'relativity.class'
Unary = require 'relativity.nodes.unary'
Expressions = require 'relativity.expressions'
Predications = require 'relativity.predications'

SqlLiteral = Class 'SqlLiteral', Unary
SqlLiteral.includes Expressions
SqlLiteral.includes Predications
SqlLiteral.__tostring = => tostring(@value)
SqlLiteral
