Node = require 'relativity.nodes.node'
Class = require 'relativity.class'

UpdateStatement = Class 'UpdateStatement', Node
UpdateStatement.initialize = =>
  @relation = nil
  @wheres = {}
  @values = {}
  @orders = {}
  @limit = nil
  @key = nil

UpdateStatement

-- TODO: copy?
