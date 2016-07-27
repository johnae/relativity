TreeManager = require 'relativity.tree_manager'
DeleteStatement = require 'relativity.nodes.delete_statement'
Class = require 'relativity.class'

DeleteManager = Class 'DeleteManager', TreeManager
DeleteManager.initialize = =>
  @super!
  @ast = DeleteStatement.new!
  @ctx = @ast

DeleteManager.from = (relation) =>
  @ast.relation = relation
  @

DeleteManager.wheres = (list) =>
  @ast.wheres = list
  @

DeleteManager
