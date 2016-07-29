Table = require 'relativity.table'
SelectManager = require 'relativity.select_manager'
InsertManager = require 'relativity.insert_manager'
Nodes = require 'relativity.nodes.nodes'

describe 'Table', ->
  local table
  before_each ->
    table = Table.new 'users'

  it 'has a from method', ->
    assert.not_nil table.from('user')

  it 'can project things', ->
    assert.not_nil 'SELECT * FROM "users"', table\project(Nodes.SqlLiteral.new('*'))

  it 'returns sql', ->
    assert.equal 'SELECT * FROM "users"', table\project(Nodes.SqlLiteral.new('*'))\to_sql!

  it 'creates string join nodes', ->
    join = table\create_string_join 'foo'
    assert.equal join, Nodes.StringJoin

  it 'creates join nodes', ->
    join = table\create_join 'foo', 'bar'
    assert.equal join, Nodes.InnerJoin
    assert.equal join.left, 'foo'
    assert.equal join.right, 'bar'

  it 'creates join nodes with a class', ->
    join = table\create_join 'foo', 'bar', Nodes.LeftOuterJoin
    assert.equal join, Nodes.LeftOuterJoin
    assert.equal join.left, 'foo'
    assert.equal join.right, 'bar'

  it 'returns an insert manager', ->
    im = table\compile_insert 'VALUES(NULL)'
    assert.equal InsertManager, im
    assert.equal 'INSERT INTO NULL VALUES(NULL)', im\to_sql!

  it '#insert_manager returns an InsertManager', ->
    im = table\insert_manager!
    assert.equal InsertManager, im

  it '#skip adds an offset', ->
    sm = table\skip 2
    assert.equal 'SELECT FROM "users" OFFSET 2', sm\to_sql!

  it '#select_manager returns a select manager', ->
    sm = table\select_manager!
    assert.equal SelectManager, sm
    assert.equal 'SELECT', sm\to_sql!

  it '#having adds a having clause', ->
    mgr = table\having table('id')\eq(10)
    assert.equal 'SELECT FROM "users" HAVING "users"."id" = 10', mgr\to_sql!

  it '#group should create a group', ->
    mgr = table\group table('id')
    assert.equal 'SELECT FROM "users" GROUP BY "users"."id"', mgr\to_sql!

  it '#alias creates a node that proxies a table', ->
    assert.equal 0, #table.aliases
    node = table\alias!
    assert.equal 1, #table.aliases
    assert.equal 'users_2', node.name
    assert.equal node, node('id').relation

  it '#new takes options', ->
    rel = Table.new 'users', as: 'users'
    assert.not_nil rel.table_alias

  it '#order takes an order', ->
    mgr = table\order 'foo'
    assert.equal 'SELECT FROM "users" ORDER BY foo', mgr\to_sql!

  it '#take adds a limit', ->
    mgr = table\take 1
    mgr\project Nodes.SqlLiteral.new('*')
    assert.equal 'SELECT * FROM "users" LIMIT 1', mgr\to_sql!

  it '#project can project', ->
    mgr = table\project Nodes.SqlLiteral.new('*')
    assert.equal 'SELECT * FROM "users"', mgr\to_sql!

  it '#project takes multiple parameters', ->
    mgr = table\project Nodes.SqlLiteral.new('*'), Nodes.SqlLiteral.new('*')
    assert.equal 'SELECT *, * FROM "users"', mgr\to_sql!

  it '#where returns a tree manager', ->
    mgr = table\where table('id')\eq(1)
    mgr\project table('id')
    assert.equal 'SELECT "users"."id" FROM "users" WHERE "users"."id" = 1', mgr\to_sql!

  it 'has a name', ->
    assert.equal 'users', table.name

  it 'calling a table returns a column', ->
    column = table 'id'
    assert.equal 'id', column.name

  it '#star returns table.*', ->
    assert.equal 'SELECT "users".* FROM "users"', table\project(table.star)\to_sql!
