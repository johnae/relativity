define = require'classy'.define
Node = require "relativity.nodes.node"

define 'Binary', ->
  parent Node
  instance
    initialize: (left, right) =>
      @left, @right = left, right
