define = require'classy'.define
Node = require "relativity.nodes.node"

define 'Unary', ->
  parent Node
  instance
    initialize: (expr) =>
      @value = expr
