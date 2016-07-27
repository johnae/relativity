Class = require "relativity.class"
Node = require "relativity.nodes.node"

Unary = Class "Unary", Node
Unary.initialize = (expr) =>
  @value = expr
Unary
