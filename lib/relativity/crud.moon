InsertManager = require 'relativity.insert_manager'
DeleteManager = require 'relativity.delete_manager'
UpdateManager = require 'relativity.update_manager'
SqlLiteral = require 'relativity.nodes.sql_literal'

Crud = 
  compile_insert: (values) =>
    im = @create_insert!
    im\insert values
    im
  
  create_insert: =>
    InsertManager.new!
  
  compile_delete: =>
    dm = DeleteManager.new!
    dm\wheres @ctx.wheres
    dm\from @ctx.froms
    dm
  
  compile_update: (values) =>
    um = UpdateManager.new!
    relation = if values == SqlLiteral
      @ctx.from
    else
      values[1][1].relation

    um\table relation
    um\set values
    um\take @ast.limit.expr if @ast.limit
    um\order @ast.orders
    um\wheres @ctx.wheres
    um

Crud
