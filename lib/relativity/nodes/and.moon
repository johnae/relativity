Class = require "relativity.class"
Node = require "relativity.nodes.node"

And = Class "And", Node
And.initialize = (children, right=nil) =>
  unless type(children) == 'table' and #children > 0
    children = {children, right}
  @children = children
And.left = =>
  @children[1]
And.right = =>
  @children[2]
And
