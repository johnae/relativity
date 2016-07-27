FactoryMethods = require 'relativity.factory_methods'
Class = require 'relativity.class'
defer = require 'relativity.defer'

TreeManager = Class 'TreeManager', FactoryMethods
ToSql = defer -> require 'relativity.visitors.to_sql'

TreeManager.initialize = =>
  @ast = nil
  @ctx = nil

TreeManager.to_sql = => ToSql @ast

TreeManager.where = (expr) =>
  if TreeManager == expr
    expr = expr.ast
  @ctx.wheres or= {}
  w = @ctx.wheres
  w[#w + 1] = expr
  @

TreeManager
