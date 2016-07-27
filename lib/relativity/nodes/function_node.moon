Node = require 'relativity.nodes.node'
SqlLiteral = require 'relativity.nodes.sql_literal'
Class = require 'relativity.class'
Expressions = require 'relativity.expressions'
Predications = require 'relativity.predications'

FunctionNode = Class 'FunctionNode', Node
FunctionNode.initialize = (expressions, alias) =>
  @expressions = expressions
  @alias = alias
  @distinct = false

FunctionNode.as = (alias) =>
  @alias = SqlLiteral.new alias
  @

FunctionNode.includes Expressions
FunctionNode.includes Predications
FunctionNode
