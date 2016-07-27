Relativity = require 'relativity'

describe 'Relativity', ->
  local users
  before_each ->
    users = Relativity.table 'users'

  it 'performs a users find', ->
    assert.equal 'SELECT FROM "users" WHERE "users"."name" = \'Einstein\'', users\where(users('name')\eq('Einstein'))\to_sql!

  it 'selects all from users', ->
    assert.equal 'SELECT * FROM "users"', users\project(Relativity.star!)\to_sql!

  it 'selects users where either condition is true', ->
    assert.is_like [[
      SELECT FROM "users"
      WHERE ("users"."name" = \'bob\' OR "users"."age" < 25)'
    ]], users\where(users('name')\eq('bob')\Or(users('age')\lt(25)))\to_sql!

