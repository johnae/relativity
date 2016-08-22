define = require'classy'.define
SelectCore = require 'relativity.nodes.select_core'

define 'SelectStatement', ->
  instance
    initialize: (cores) =>
      @cores = cores or {SelectCore.new!}
      @orders = {}
      @limit = nil
      @lock = nil
      @offset = nil
      @with = nil
