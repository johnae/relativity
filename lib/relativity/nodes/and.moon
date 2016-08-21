define = require'classy'.define
Node = require "relativity.nodes.node"

define 'And', ->
  parent Node
  properties
    left: => @children[1]
    right: => @children[2]
  instance
    initialize: (children, right) =>
      unless type(children) == 'table' and #children > 0
        children = {children, right}
      @children = children
