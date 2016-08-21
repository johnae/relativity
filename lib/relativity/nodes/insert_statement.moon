Node = require 'relativity.nodes.node'
define = require'classy'.define

define 'InsertStatement', ->
  parent Node
  instance
    initialize: =>
      @relation = nil
      @columns = {}
      @values = nil
