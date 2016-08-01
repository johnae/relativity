-- This file doubles as spec and playground for some specific postgres functionality

Relativity = require 'relativity'
Nodes = Relativity.Nodes

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
      q = q\project users.star
      assert.equal tr[[
        SELECT "users".*
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
      q = users\where users'name'\eq'bob'\Or users'age'\lt 25
      assert.equal tr[[
        SELECT FROM "users"
        WHERE ("users"."name" = 'bob' OR "users"."age" < 25)
      ]], q\to_sql!

    it 'selects users where either condition is true using lpeg:ish syntax', ->
      q = users\where users'name'\eq'bob' + users'age'\lt 25
      assert.equal tr[[
        SELECT FROM "users"
        WHERE ("users"."name" = 'bob' OR "users"."age" < 25)
      ]], q\to_sql!

    it 'selects users where a condition is not true', ->
      q = users\where users'id'\eq(10)\Not!
      assert.equal tr[[
        SELECT FROM "users"
        WHERE NOT ("users"."id" = 10)
      ]], q\to_sql!

    it 'selects users where a condition is not true using lpeg:ish syntax', ->
      q = users\where -users'id'\eq 10
      assert.equal tr[[
        SELECT FROM "users"
        WHERE NOT ("users"."id" = 10)
      ]], q\to_sql!

  describe 'advanced postgres queries', ->
    local json_build_object
    before_each ->
      json_build_object = Relativity.func "json_build_object"

    it 'selecting json objects', ->
      userinfo = json_build_object 'id', users'id', 'name', users'name'
      userinfo = userinfo\as 'userinfo'
      user = users\project(userinfo)\where users'id'\eq 10
      assert.equal tr[[
        SELECT json_build_object('id', "users"."id", 'name', "users"."name") AS "userinfo"
        FROM "users"
        WHERE "users"."id" = 10
      ]], user\to_sql!


    it 'lateral inner joined subquery with aggregated json objects', ->

      others = Relativity.table 'others'

      any = Relativity.func "ANY"
      coalesce = Relativity.func "COALESCE"
      to_json = Relativity.func "to_json"
      array_agg = Relativity.func "array_agg"

      json_select = Relativity.select!
      json_select\from others
      json_object = json_build_object 'id', others'id', 'name', others'name'
      json_select\project array_agg(json_object)\as 'list'
      json_select\where others'id'\eq any users'things'
      json_select = Relativity.alias json_select, 'things'

      things = to_json(Relativity.table'things''list')\as 'things'
      user_employer = coalesce(users'employer', 'none')\as 'employer'

      u = users\project users.star, user_employer, things
      u\join(json_select, Nodes.InnerJoinLateral)\on true
      u\where users'name'\matches '%berg%'

      assert.equal tr[[
        SELECT "users".*, COALESCE("users"."employer", 'none') AS "employer", to_json("things"."list") AS "things"
        FROM "users"
        INNER JOIN LATERAL
        (SELECT array_agg(json_build_object('id', "others"."id", 'name', "others"."name")) AS "list"
        FROM "others" WHERE "others"."id" = ANY("users"."things")) "things" ON 't'
        WHERE "users"."name" LIKE '%berg%'
      ]], u\to_sql!
