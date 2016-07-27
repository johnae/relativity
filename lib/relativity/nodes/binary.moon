Class = require "relativity.class"
Node = require "relativity.nodes.node"

Binary = Class "Binary", Node
Binary.initialize = (left, right) =>
  @left, @right = left, right
Binary
