Relativity = require 'relativity'

describe 'Relativity', ->

  it 'a sum function returns the expected sql', ->
    user = Relativity.table 'user'
    sum = Relativity.func 'SUM'
    q = user\where sum(sum(user('age'))\eq(1))
    assert.equal 'SELECT FROM "user" WHERE SUM(SUM("user"."age") = 1)', q\to_sql!

  it 'a coalesce function returns the expected sql', ->
    user = Relativity.table 'user'
    coalesce = Relativity.func 'COALESCE'
    q = user\project coalesce user'maybe', false
    assert.equal [[SELECT COALESCE("user"."maybe", 'f') FROM "user"]], q\to_sql!

  it 'an any function returns the expected sql', ->
    user = Relativity.table 'user'
    stuff = Relativity.table 'stuff'
    any = Relativity.func 'ANY'
    q = user\where user'stuff_id'\eq any stuff'id'
    assert.equal 'SELECT FROM "user" WHERE "user"."stuff_id" = ANY("stuff"."id")', q\to_sql!
