FactoryMethods = require 'relativity.factory_methods'
define = require'classy'.define
defer = require 'relativity.defer'
ToSql = defer -> require 'relativity.visitors.to_sql'

define 'TreeManager', ->
  include FactoryMethods

  instance
    initialize: =>
      @ast = nil
      @ctx = nil

    to_sql: =>
      ToSql @ast

    where: (expr) =>
      if expr == @
        expr = expr.ast
      @ctx.wheres or= {}
      w = @ctx.wheres
      w[#w + 1] = expr
      @
