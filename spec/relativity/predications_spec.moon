Relativity = require 'relativity'

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

  it '#matches case insensitive', ->
    q = users\where users'name'\matches '%berg', case_insensitive: true
    assert.equal tr[[
      SELECT FROM "users"
      WHERE "users"."name" ILIKE '%berg'
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

  it '#does_not_match', ->
    q = users\where users'name'\does_not_match '%berg'
    assert.equal tr[[
      SELECT FROM "users"
      WHERE "users"."name" NOT LIKE '%berg'
    ]], q\to_sql!

  it '#does_not_match_any', ->
    q = users\where users'name'\does_not_match_any '%berg', '%borg'
    assert.equal tr[[
      SELECT FROM "users"
      WHERE ("users"."name" NOT LIKE '%berg' OR "users"."name" NOT LIKE '%borg')
    ]], q\to_sql!

  it '#does_not_match_all', ->
    q = users\where users'name'\does_not_match_all '%berg', '%borg'
    assert.equal tr[[
      SELECT FROM "users"
      WHERE ("users"."name" NOT LIKE '%berg' AND "users"."name" NOT LIKE '%borg')
    ]], q\to_sql!

  it '#gt', ->
    q = users\where users'age'\gt 18
    assert.equal tr[[
      SELECT FROM "users"
      WHERE "users"."age" > 18
    ]], q\to_sql!

  it '#gteq', ->
    q = users\where users'age'\gteq 18
    assert.equal tr[[
      SELECT FROM "users"
      WHERE "users"."age" >= 18
    ]], q\to_sql!

  it '#gt_any', ->
    allowed = Relativity.table'allowed'
    allowed_currently = allowed\project(allowed'age'\minimum!)\where allowed'hour'\eq 23
    q = users\where users'age'\gt_any 18, allowed_currently
    assert.equal tr[[
      SELECT FROM "users"
      WHERE ("users"."age" > 18 OR "users"."age" > (SELECT MIN("allowed"."age")
                                                      FROM "allowed"
                                                      WHERE "allowed"."hour" = 23))
    ]], q\to_sql!

  it '#gt_all', ->
    allowed = Relativity.table'allowed'
    allowed_currently = allowed\project(allowed'age'\minimum!)\where allowed'hour'\eq 23
    q = users\where users'age'\gt_all 18, allowed_currently
    assert.equal tr[[
      SELECT FROM "users"
      WHERE ("users"."age" > 18 AND "users"."age" > (SELECT MIN("allowed"."age")
                                                      FROM "allowed"
                                                      WHERE "allowed"."hour" = 23))
    ]], q\to_sql!

  it '#gteq_any', ->
    allowed = Relativity.table'allowed'
    allowed_currently = allowed\project(allowed'age'\minimum!)\where allowed'hour'\eq 23
    q = users\where users'age'\gteq_any 18, allowed_currently
    assert.equal tr[[
      SELECT FROM "users"
      WHERE ("users"."age" >= 18 OR "users"."age" >= (SELECT MIN("allowed"."age")
                                                      FROM "allowed"
                                                      WHERE "allowed"."hour" = 23))
    ]], q\to_sql!

  it '#gteq_all', ->
    allowed = Relativity.table'allowed'
    allowed_currently = allowed\project(allowed'age'\minimum!)\where allowed'hour'\eq 23
    q = users\where users'age'\gteq_all 18, allowed_currently
    assert.equal tr[[
      SELECT FROM "users"
      WHERE ("users"."age" >= 18 AND "users"."age" >= (SELECT MIN("allowed"."age")
                                                      FROM "allowed"
                                                      WHERE "allowed"."hour" = 23))
    ]], q\to_sql!

  it '#lt', ->
    q = users\where users'age'\lt 18
    assert.equal tr[[
      SELECT FROM "users"
      WHERE "users"."age" < 18
    ]], q\to_sql!

  it '#lteq', ->
    q = users\where users'age'\lteq 18
    assert.equal tr[[
      SELECT FROM "users"
      WHERE "users"."age" <= 18
    ]], q\to_sql!

  it '#lt_any', ->
    allowed = Relativity.table'allowed'
    allowed_currently = allowed\project(allowed'age'\maximum!)\where allowed'hour'\eq 23
    q = users\where users'age'\lt_any 18, allowed_currently
    assert.equal tr[[
      SELECT FROM "users"
      WHERE ("users"."age" < 18 OR "users"."age" < (SELECT MAX("allowed"."age")
                                                      FROM "allowed"
                                                      WHERE "allowed"."hour" = 23))
    ]], q\to_sql!

  it '#lt_all', ->
    allowed = Relativity.table'allowed'
    allowed_currently = allowed\project(allowed'age'\maximum!)\where allowed'hour'\eq 23
    q = users\where users'age'\lt_any 18, allowed_currently
    assert.equal tr[[
      SELECT FROM "users"
      WHERE ("users"."age" < 18 OR "users"."age" < (SELECT MAX("allowed"."age")
                                                      FROM "allowed"
                                                      WHERE "allowed"."hour" = 23))
    ]], q\to_sql!

  it '#lteq_any', ->
    allowed = Relativity.table'allowed'
    allowed_currently = allowed\project(allowed'age'\maximum!)\where allowed'hour'\eq 23
    q = users\where users'age'\lteq_any 18, allowed_currently
    assert.equal tr[[
      SELECT FROM "users"
      WHERE ("users"."age" <= 18 OR "users"."age" <= (SELECT MAX("allowed"."age")
                                                      FROM "allowed"
                                                      WHERE "allowed"."hour" = 23))
    ]], q\to_sql!

  it '#lteq_all', ->
    allowed = Relativity.table'allowed'
    allowed_currently = allowed\project(allowed'age'\maximum!)\where allowed'hour'\eq 23
    q = users\where users'age'\lteq_any 18, allowed_currently
    assert.equal tr[[
      SELECT FROM "users"
      WHERE ("users"."age" <= 18 OR "users"."age" <= (SELECT MAX("allowed"."age")
                                                      FROM "allowed"
                                                      WHERE "allowed"."hour" = 23))
    ]], q\to_sql!

  it '#asc, #desc', ->
    a = users\asc users'name'
    d = users\desc users'name'
    assert.equal 'SELECT FROM "users" ORDER BY "users"."name" ASC', a\to_sql!
    assert.equal 'SELECT FROM "users" ORDER BY "users"."name" DESC', d\to_sql!

  it '#search', ->
    rank = Relativity.func'ts_rank'
    to_tsquery = Relativity.func'to_tsquery'
    tsquery = to_tsquery'abc | cde'
    search = users\where users'document'\search tsquery
    search\desc rank users'document', tsquery
    assert.equal tr[[
      SELECT FROM "users"
      WHERE "users"."document" @@ to_tsquery('abc | cde')
      ORDER BY ts_rank("users"."document", to_tsquery('abc | cde')) DESC
    ]], search\to_sql!
