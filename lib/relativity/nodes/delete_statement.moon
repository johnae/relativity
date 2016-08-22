Binary = require 'relativity.nodes.binary'
define = require'classy'.define

define 'DeleteStatement', ->
  parent Binary
  instance
    initialize: (relation, wheres) =>
      super @, relation, wheres
