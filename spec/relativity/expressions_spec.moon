Relativity = require 'relativity'

describe 'Expressions', ->
  local users
  before_each ->
    users = Relativity.table 'users'

  it '#count', ->
    -- just counting records here
    count = Relativity.func'COUNT'
    q = users\project count Relativity.star
    assert.equal 'SELECT COUNT(*) FROM "users"', q\to_sql!
    
    q = users\project users'last_login'\count!\as 'users_ever_logged_in'
    assert.equal [[SELECT COUNT("users"."last_login") AS "users_ever_logged_in" FROM "users"]], q\to_sql!

  it '#sum', ->
    q = users\project users'years_experience'\sum!\as 'company_years_experience'
    assert.equal [[SELECT SUM("users"."years_experience") AS "company_years_experience" FROM "users"]], q\to_sql!

  it '#maximum', ->
    q = users\project users'years_experience'\maximum!\as 'most_senior_user_experience'
    assert.equal [[SELECT MAX("users"."years_experience") AS "most_senior_user_experience" FROM "users"]], q\to_sql!

  it '#minimum', ->
    q = users\project users'years_experience'\minimum!\as 'most_junior_user_experience'
    assert.equal [[SELECT MIN("users"."years_experience") AS "most_junior_user_experience" FROM "users"]], q\to_sql!

  it '#average', ->
    q = users\project users'years_experience'\average!\as 'average_user_experience'
    assert.equal [[SELECT AVG("users"."years_experience") AS "average_user_experience" FROM "users"]], q\to_sql!

    
    --q = users\project users'id'\as 'my_alias'
    --assert.equal 'SELECT "users"."id" AS "my_alias" FROM "users"', q\to_sql!

  --it '#not_eq', ->
  --  q = users\where users'name'\not_eq 'John'
  --  assert.equal [[SELECT FROM "users" WHERE "users"."name" <> 'John']], q\to_sql!

  --it '#not_eq_any', ->
  --  q = users\where users'name'\not_eq_any 'John', 'Nils'
  --  assert.equal tr[[
  --    SELECT FROM "users"
  --    WHERE ("users"."name" <> 'John' OR "users"."name" <> 'Nils')
  --  ]], q\to_sql!

