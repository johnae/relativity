Relativity = require 'relativity'

describe 'Relativity', ->

  it 'a sum function returns the expected sql', ->
    user = Relativity.table 'user'
    sum = Relativity.func 'sum'
    q = user\where sum(sum(user('age'))\eq(1))
    assert.equal 'SELECT FROM "user" WHERE sum(sum("user"."age") = 1)', q\to_sql!
