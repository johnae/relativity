Binary = require 'relativity.nodes.binary'
Class = require 'relativity.class'

JoinSource = Class 'JoinSource', Binary
JoinSource.initialize = (single_source, joinop) =>
  Binary.initialize @, single_source, joinop
  @right = {}

JoinSource
