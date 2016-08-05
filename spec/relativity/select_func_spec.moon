Relativity = require 'relativity'
{:sort} = table

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

  it 'a json_build_object function returns the expected sql', ->
    things = Relativity.table 'things'
    json_build_object = Relativity.func 'json_build_object'
    q = things\project json_build_object 'id', things'id', 'name', things'name'
    assert.equal tr[[
      SELECT json_build_object('id', "things"."id", 'name', "things"."name")
      FROM "things"
    ]], q\to_sql!

  it 'an options function generates the same function node as a vararg one', ->
    json_build_object_o = Relativity.opt_func 'json_build_object'
    json_build_object = Relativity.func 'json_build_object'
    a = json_build_object_o id: 'an_id', name: 'a_name'
    b = json_build_object 'id', 'an_id', 'name', 'a_name'
    sort a.expressions
    sort b.expressions
    assert.same a.expressions, b.expressions
