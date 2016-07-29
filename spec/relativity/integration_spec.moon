-- This file doubles as spec and playground for some specific postgres functionality

Relativity = require 'relativity'
Nodes = require 'relativity.nodes.nodes'

describe 'Relativity', ->
  local users
  before_each ->
    users = Relativity.table 'users'

  describe 'README examples', ->

    it 'selects id from users', ->
      q = users\project users'id'
      assert.equal 'SELECT "users"."id" FROM "users"', q\to_sql!

    it 'selects all from users', ->
      q = users\project Relativity.star
      assert.equal 'SELECT * FROM "users"', q\to_sql!

    it 'performs a users find with restriction', ->
      q = users\where users'name'\eq'Einstein'
      q = q\project Relativity.star
      assert.equal tr[[
        SELECT * FROM "users"
        WHERE "users"."name" = 'Einstein'
      ]], q\to_sql!

    it 'performs an inner join', ->
      photos = Relativity.table 'photos'
      q = users\join(photos)\on users'id'\eq photos'user_id'
      q = q\project Relativity.star
      assert.equal tr[[
        SELECT *
        FROM "users"
        INNER JOIN "photos" ON "users"."id" = "photos"."user_id"
      ]], q\to_sql!

    it 'performs a limit', ->
      q = users\take 5
      q\project Relativity.star
      assert.equal tr[[
        SELECT *
        FROM "users"
        LIMIT 5
      ]], q\to_sql!

    it 'performs an offset', ->
      q = users\skip 4
      q\project Relativity.star
      assert.equal tr[[
        SELECT *
        FROM "users"
        OFFSET 4
      ]], q\to_sql!

    it 'performs a GROUP BY', ->
      q = users\group(users'name')\project Relativity.star
      assert.equal tr[[
        SELECT *
        FROM "users"
        GROUP BY "users"."name"
      ]], q\to_sql!

    it 'selects users where either condition is true', ->
      assert.equal tr[[
        SELECT FROM "users"
        WHERE ("users"."name" = 'bob' OR "users"."age" < 25)
      ]], users\where(users'name'\eq'bob'\Or users'age'\lt 25)\to_sql!

  describe 'advanced postgres queries', ->

    it 'selecting json objects', ->
      userinfo = users\json 'id', 'name'
      userinfo = Relativity.as userinfo, 'userinfo'
      user = users\project(userinfo)\where users('id')\eq(10)
      assert.equal tr[[
        SELECT json_build_object('id'::text, "users"."id", 'name'::text, "users"."name") AS "userinfo"
        FROM "users"
        WHERE "users"."id" = 10
      ]], user\to_sql!


    it 'lateral inner joined subquery with aggregated json objects', ->

      others = Relativity.table 'others'

      json_select = Relativity.select!
      json_select\project Relativity.as Relativity.array_agg(others\json 'id', 'name'), "list"
      json_select = Relativity.alias json_select, 'things'
      things = Relativity.as Nodes.ToJson.new(Relativity.table'things''list'), 'things'
      users_star = Nodes.TableStar.new users

      u = users\project users_star, things
      u\join(json_select, Nodes.InnerJoinLateral)\on(true)
      u\where users'name'\like '%berg%'

      assert.equal tr[[
        SELECT "users".*, to_json("things"."list") AS "things"
        FROM "users"
        INNER JOIN LATERAL
        (SELECT array_agg(json_build_object('id'::text, "others"."id", 'name'::text, "others"."name")) AS "list") "things" ON 't'
        WHERE "users"."name" LIKE '%berg%'
      ]], u\to_sql!
