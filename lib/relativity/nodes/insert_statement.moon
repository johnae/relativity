Node = require 'relativity.nodes.node'
Class = require 'relativity.class'

InsertStatement = Class 'InsertStatement', Node
InsertStatement.initialize = =>
  @relation = nil
  @columns = {}
  @values = nil

InsertStatement

-- TODO: copy?
