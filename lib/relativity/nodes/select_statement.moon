Class = require 'relativity.class'
SelectCore = require 'relativity.nodes.select_core'

SelectStatement = Class 'SelectStatement'
SelectStatement.initialize = (cores) =>
  @cores = cores or {SelectCore.new!}
  @orders = {}
  @limit = nil
  @lock = nil
  @offset = nil
  @with = nil

SelectStatement

-- TODO: copy?
