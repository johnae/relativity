Node = require 'relativity.nodes.node'
JoinSource = require 'relativity.nodes.join_source'
Class = require 'relativity.class'

SelectCore = Class 'SelectCore', Node
SelectCore.initialize = =>
  @source = JoinSource.new!
  @top = nil
  @projections = {}
  @wheres = {}
  @groups = {}
  @having = nil

SelectCore.get_from = =>
  @source.left

SelectCore.set_from = (value) =>
  @source.left = value
  @source.left

SelectCore

-- TODO: copy?
