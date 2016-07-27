Nodes = require 'relativity.nodes.nodes'
UpdateManager = require 'relativity.update_manager'
Table = require 'relativity.table'
Relativity = require 'relativity'

describe 'UpdateManager', ->
  local users, um
  before_each ->
    users = Table.new 'users'
    um = UpdateManager.new!

  describe 'set', ->
    it 'updates with null', ->
      um\table users
      um\set {{users('name'), Relativity.null!}}
      assert.equal 'UPDATE "users" SET "name" = NULL', um\to_sql!

    it 'takes a string', ->
      um\table users
      um\set Nodes.SqlLiteral.new 'foo = bar'
      assert.equal 'UPDATE "users" SET foo = bar', um\to_sql!

    it 'takes a list of lists', ->
      um\table users
      um\set {{users('id'), 1}, {users('name'), 'hello'}}
      assert.equal 'UPDATE "users" SET "id" = 1, "name" = \'hello\'', um\to_sql!

  it '#table generates an update statement', ->
    um\table users
    assert.equal 'UPDATE "users"', um\to_sql!

  it '#where generates a where clause', ->
    um\table users
    um\where users('id')\eq(1)
    assert.equal 'UPDATE "users" WHERE "users"."id" = 1', um\to_sql!
