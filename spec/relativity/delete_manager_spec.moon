Table = require 'relativity.table'
DeleteManager = require 'relativity.delete_manager'

describe 'DeleteManager', ->
  local users, dm
  before_each ->
    users = Table.new 'users'
    dm = DeleteManager.new!

  it 'from', ->
    dm\from users
    assert.equal 'DELETE FROM "users"', dm\to_sql!

  describe 'where', ->
    it 'uses where values', ->
      dm\from users
      dm\where users'id'\eq(10)
      assert.equal 'DELETE FROM "users" WHERE "users"."id" = 10', dm\to_sql!
