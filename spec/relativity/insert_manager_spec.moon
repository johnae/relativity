InsertManager = require 'relativity.insert_manager'
Relativity = require 'relativity'
Nodes = Relativity.Nodes
Table = Relativity.Table

describe 'InsertManager', ->
  local im, users
  before_each ->
    users = Table.new 'users'
    im = InsertManager.new!

  it 'creates Values nodes', ->
    values = im\create_values {'a', 'b'}, {'c', 'd'}
    assert.equal 2, #values.left
    assert.equal 2, #values.right

  it 'allows sql literals', ->
    im.values = im\create_values({Relativity.star}, {'a'})
    assert.equal 'INSERT INTO NULL VALUES (*)', im\to_sql!

  it 'inserts false', ->
    im\insert {{users('bool'), false}}
    assert.equal 'INSERT INTO "users" ("bool") VALUES (\'f\')', im\to_sql!

  it 'inserts null', ->
    im\insert {{users('id'), Relativity.null}}
    assert.equal 'INSERT INTO "users" ("id") VALUES (NULL)', im\to_sql!

  -- TODO: handle this properly somewhere
  it 'inserts time', ->
    t = 1469609970
    -- 2016-07-27T08:59:30Z
    time = os.date "!%Y-%m-%dT%TZ", t
    attribute = users 'created_at'

    im\insert {{attribute, time}}
    assert.equal "INSERT INTO \"users\" (\"created_at\") VALUES ('#{time}')", im\to_sql!

  it 'takes a list of lists', ->
    im\into users
    im\insert {{users('id'), 1}, {users('name'), 'ricky'}}
    assert.equal 'INSERT INTO "users" ("id", "name") VALUES (1, \'ricky\')', im\to_sql!

  it 'defaults the table', ->
    im\insert {{users('id'), 1}, {users('name'), 'ricky'}}
    assert.equal 'INSERT INTO "users" ("id", "name") VALUES (1, \'ricky\')', im\to_sql!

  it 'accepts an empty list', ->
    mgr = InsertManager.new!
    mgr\insert {}
    assert.is_nil mgr.ast.values

  describe 'into', ->
    it 'converts to sql', ->
      im\into users
      assert.equal 'INSERT INTO "users"', im\to_sql!

  describe 'columns', ->
    it 'converts to sql', ->
      im\into users
      cols = im.columns
      cols[#cols + 1] = users('id')
      assert.equal 'INSERT INTO "users" ("id")', im\to_sql!

  describe 'values', ->
    it 'converts to sql', ->
      im\into users
      im.values = Nodes.Values.new({1})
      assert.equal 'INSERT INTO "users" VALUES (1)', im\to_sql!

  describe 'combo', ->
    it 'puts it all together', ->
      im\into users
      im.values = Nodes.Values.new {1, 'ricky'}
      cols = im.columns
      cols[#cols + 1] = users('id')
      cols[#cols + 1] = users('name')
      assert.equal 'INSERT INTO "users" ("id", "name") VALUES (1, \'ricky\')', im\to_sql!
