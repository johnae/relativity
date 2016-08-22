TreeManager = require 'relativity.tree_manager'
DeleteStatement = require 'relativity.nodes.delete_statement'
define = require'classy'.define

define 'DeleteManager', ->
  parent TreeManager
  instance
    initialize: =>
      super @
      @ast = DeleteStatement.new!
      @ctx = @ast
    from: (relation) =>
      @ast.relation = relation
      @
    wheres: (list) =>
      @ast.wheres = list
      @
