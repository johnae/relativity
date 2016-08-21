Node = require 'relativity.nodes.node'
define = require'classy'.define

define 'UpdateStatement', ->
  parent Node
  instance
    initialize: =>
      @relation = nil
      @wheres = {}
      @values = {}
      @orders = {}
      @limit = nil
      @key = nil
