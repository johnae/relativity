Node = require 'relativity.nodes.node'
JoinSource = require 'relativity.nodes.join_source'
define = require'classy'.define

define 'SelectCore', ->
  parent Node
  properties
    from:
      get: => @source.left
      set:(value) => @source.left = value
  instance
    initialize: =>
      @source = JoinSource.new!
      @top = nil
      @projections = {}
      @wheres = {}
      @groups = {}
      @having = nil
