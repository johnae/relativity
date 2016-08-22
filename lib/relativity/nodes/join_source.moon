Binary = require 'relativity.nodes.binary'
define = require'classy'.define

define 'JoinSource', ->
  parent Binary
  instance
    initialize: (single_source, joinop) =>
      super @, single_source, joinop
      @right = {}
