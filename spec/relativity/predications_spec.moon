Relativity = require 'relativity'
--Nodes = Relativity.Nodes

describe 'Predications', ->
  local users
  before_each ->
    users = Relativity.table 'users'

  it '#as', ->
    q = users\project users'id'\as 'my_alias'
    assert.equal 'SELECT "users"."id" AS "my_alias" FROM "users"', q\to_sql!

  it '#not_eq', ->
    q = users\where users'name'\not_eq 'John'
    assert.equal [[SELECT FROM "users" WHERE "users"."name" <> 'John']], q\to_sql!

  it '#not_eq_any', ->
    q = users\where users'name'\not_eq_any 'John', 'Nils'
    assert.equal tr[[
      SELECT FROM "users"
      WHERE ("users"."name" <> 'John' OR "users"."name" <> 'Nils')
    ]], q\to_sql!

  it '#not_eq_all', ->
    q = users\where users'name'\not_eq_all 'John', 'Nils'
    assert.equal tr[[
      SELECT FROM "users"
      WHERE ("users"."name" <> 'John' AND "users"."name" <> 'Nils')
    ]], q\to_sql!

  it '#is_null', ->
    q = users\where users'name'\is_null!
    assert.equal tr[[
      SELECT FROM "users"
      WHERE "users"."name" IS NULL
    ]], q\to_sql!

  it '#not_null', ->
    q = users\where users'name'\not_null!
    assert.equal tr[[
      SELECT FROM "users"
      WHERE "users"."name" IS NOT NULL
    ]], q\to_sql!

  it '#eq', ->
    q = users\where users'name'\eq 'John'
    assert.equal tr[[
      SELECT FROM "users"
      WHERE "users"."name" = 'John'
    ]], q\to_sql!

  it '#eq_any', ->
    q = users\where users'name'\eq_any 'John', 'Nils'
    assert.equal tr[[
      SELECT FROM "users"
      WHERE ("users"."name" = 'John' OR "users"."name" = 'Nils')
    ]], q\to_sql!

  it '#eq_all', ->
    q = users\where users'name'\eq_all 'John', 'Nils'
    assert.equal tr[[
      SELECT FROM "users"
      WHERE ("users"."name" = 'John' AND "users"."name" = 'Nils')
    ]], q\to_sql!

  it '#In', ->
    q = users\where users'name'\In 'John', 'Nils'
    assert.equal tr[[
      SELECT FROM "users"
      WHERE "users"."name" IN ('John', 'Nils')
    ]], q\to_sql!

  it '#In is also known as #includes', ->
    q = users\where users'name'\includes 'John', 'Nils'
    assert.equal tr[[
      SELECT FROM "users"
      WHERE "users"."name" IN ('John', 'Nils')
    ]], q\to_sql!

  it '#not_in', ->
    q = users\where users'name'\not_in 'John', 'Nils'
    assert.equal tr[[
      SELECT FROM "users"
      WHERE "users"."name" NOT IN ('John', 'Nils')
    ]], q\to_sql!

  it '#matches', ->
    q = users\where users'name'\matches '%berg'
    assert.equal tr[[
      SELECT FROM "users"
      WHERE "users"."name" LIKE '%berg'
    ]], q\to_sql!

  it '#matches_any', ->
    q = users\where users'name'\matches_any '%berg', '%borg'
    assert.equal tr[[
      SELECT FROM "users"
      WHERE ("users"."name" LIKE '%berg' OR "users"."name" LIKE '%borg')
    ]], q\to_sql!

  it '#matches_all', ->
    q = users\where users'name'\matches_all '%berg', 'Heisen%'
    assert.equal tr[[
      SELECT FROM "users"
      WHERE ("users"."name" LIKE '%berg' AND "users"."name" LIKE 'Heisen%')
    ]], q\to_sql!
