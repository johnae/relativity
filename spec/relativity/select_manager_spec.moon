SelectManager = require 'relativity.select_manager'
Table = require 'relativity.table'
Nodes = require 'relativity.nodes.nodes'
Relativity = require 'relativity'

describe 'Querying', ->
  describe 'SelectManager', ->
    local sm
    before_each ->
      sm = SelectManager.new Table.new('users')

    describe '#project', ->
      it 'accepts sql literals', ->
        sm\project Relativity.sql 'id'
        assert.equal sm\to_sql!, "SELECT id FROM \"users\""

      it 'accepts string constants', ->
        sm\project 'foo'
        assert.equal 'SELECT foo FROM "users"', sm\to_sql!

    describe '#order', ->

      it 'accepts strings', ->
        sm\project Nodes.SqlLiteral.new('*')
        sm\order 'foo'
        assert.equal 'SELECT * FROM "users" ORDER BY foo', sm\to_sql!

    describe '#group', ->

      it 'accepts strings', ->
        sm\project Nodes.SqlLiteral.new('*')
        sm\group 'foo'
        assert.equal 'SELECT * FROM "users" GROUP BY foo', sm\to_sql!

    describe '#as', ->

      it 'makes an AS node by grouping the AST', ->
        as = sm\as Relativity.sql('foo')
        assert.equal Nodes.Grouping, as.left
        assert.equal sm.ast, as.left.value
        assert.equal 'foo', tostring(as.right)

      it 'converts right to SqlLiteral if string', ->
        as = sm\as 'foo'
        assert.equal Nodes.SqlLiteral, as.right

      it 'converting to sql returns proper AS sql', ->
        sub = Relativity.select!\project(1)
        outer = Relativity.select!\from(sub\as('x'))\project(Relativity.star)
        assert.equal 'SELECT * FROM (SELECT 1) "x"', outer\to_sql!

      describe 'As', ->
        it 'supports SqlLiteral', ->
          sel = Relativity.select!\project(Nodes.As.new(1, Nodes.SqlLiteral.new('x')))
          assert.equal 'SELECT 1 AS x', sel\to_sql!

        it 'supports UnqualifiedName', ->
          sel = Relativity.select!\project(Nodes.As.new(1, Nodes.UnqualifiedName.new('x')))
          assert.equal 'SELECT 1 AS "x"', sel\to_sql!

    describe 'from', ->
      
      it 'ignores string when table of same name exists', ->
        table = Table.new 'users'
        mgr = SelectManager.new table
        mgr\from table
        mgr\from 'users'
        mgr\project table\attribute 'id'
        assert.equal 'SELECT "users"."id" FROM users', mgr\to_sql!

      it 'can filter by multiple items', ->
        table = Table.new 'users'
        mgr = table\from table
        mgr\having 'foo', 'bar'
        assert.equal 'SELECT FROM "users" HAVING foo AND bar', mgr\to_sql!

    describe 'on', ->

      it 'converts to sql literals', ->
        table = Table.new 'users'
        right = table\alias!
        mgr = table\from table
        mgr\join(right)\on 'omg'
        assert.equal 'SELECT FROM "users" INNER JOIN "users" "users_2" ON omg', mgr\to_sql!

      it 'accepts multiple conditions', ->
        table = Table.new 'users'
        right = table\alias!
        mgr = table\from table
        mgr\join(right)\on 'omg', '123'
        assert.equal 'SELECT FROM "users" INNER JOIN "users" "users_2" ON omg AND 123', mgr\to_sql!


--    # TODO Clone not implemented
--    describe 'clone', ->
--
--      it 'returns a clone', ->
--        table = Table.new 'users'
--        table\as 'foo'
--        mgr = table\from table
--        mgr2 = mgr\clone!
--        mgr2\project 'foo'
--        assert.not_equal mgr\to_sql!, mgr2\to_sql!

    describe 'skip', ->

      it 'adds an offset', ->
        table = Table.new 'users'
        mgr = table\from table
        mgr\skip 10
        assert.equal 'SELECT FROM "users" OFFSET 10', mgr\to_sql!

      it 'chains', ->
        table = Table.new 'users'
        mgr = table\from table
        assert.equal 'SELECT FROM "users" OFFSET 10', mgr\skip(10)\to_sql!

      it 'handles removing the skip', ->
        table = Table.new 'users'
        mgr = table\from table
        assert.equal mgr\skip(10)\to_sql!, 'SELECT FROM "users" OFFSET 10'
        assert.equal mgr\skip(nil)\to_sql!, 'SELECT FROM "users"'

    describe 'exists', ->

      it 'creates an exists clause', ->
        table = Table.new 'users'
        mgr = SelectManager.new table
        mgr\project Nodes.SqlLiteral.new('*')
        m2 = SelectManager.new!
        m2\project mgr\exists!
        assert.equal "SELECT EXISTS (#{mgr\to_sql!})", m2\to_sql!

      it 'can be aliased', ->
        table = Table.new 'users'
        mgr = SelectManager.new table
        mgr\project Nodes.SqlLiteral.new('*')
        m2 = SelectManager.new!
        m2\project mgr\exists!\as 'foo'
        assert.equal "SELECT EXISTS (#{mgr\to_sql!}) AS \"foo\"", m2\to_sql!

    describe 'union', ->
      local m1, m2
      before_each ->
        table = Table.new 'users'
        m1 = SelectManager.new table
        m1\project Relativity.star
        m1\where table('age')\lt 18

        m2 = SelectManager.new table
        m2\project Relativity.star
        m2\where table('age')\gt 99

      it 'unions two managers', ->
        node = m1\union m2
        assert.equal '(SELECT * FROM "users" WHERE "users"."age" < 18) UNION (SELECT * FROM "users" WHERE "users"."age" > 99)', node\to_sql!

      it 'unions all two managers', ->
        node = m1\union 'all', m2
        assert.equal '(SELECT * FROM "users" WHERE "users"."age" < 18) UNION ALL (SELECT * FROM "users" WHERE "users"."age" > 99)', node\to_sql!

    describe 'except', ->
      local m1, m2
      before_each ->
        table = Table.new 'users'
        m1 = SelectManager.new table
        m1\project Relativity.star
        m1\where table('age')\In(Relativity.range(18,60))

        m2 = SelectManager.new table
        m2\project Relativity.star
        m2\where table('age')\In(Relativity.range(40,99))

      it 'excepts two managers', ->
        node = m1\except m2
        assert.equal '(SELECT * FROM "users" WHERE "users"."age" BETWEEN (18 AND 60)) EXCEPT (SELECT * FROM "users" WHERE "users"."age" BETWEEN (40 AND 99))', node\to_sql!

    describe 'intersect', ->
      local m1, m2

      before_each ->
        table = Table.new 'users'
        m1 = SelectManager.new table
        m1\project Relativity.star
        m1\where table('age')\gt 18

        m2 = SelectManager.new table
        m2\project Relativity.star
        m2\where table('age')\lt 99

      it 'intersects two managers', ->
        node = m1\intersect m2
        assert.equal '(SELECT * FROM "users" WHERE "users"."age" > 18) INTERSECT (SELECT * FROM "users" WHERE "users"."age" < 99)', node\to_sql!

    describe 'with', ->

      it 'supports WITH RECURSIVE', ->
        comments = Table.new 'comments'
        comments_id = comments 'id'
        comments_pid = comments 'parent_id'

        replies = Table.new 'replies'
        reply_id = replies 'id'

        recursive_term = SelectManager.new!
        recursive_term\from(comments)\project(comments_id, comments_pid)\where(comments_id\eq(42))

        non_recursive_term = SelectManager.new!
        non_recursive_term\from(comments)\project(comments_id, comments_pid)\join(replies)\on(comments_pid\eq(reply_id))

        union = recursive_term\union non_recursive_term
        as_statement = Nodes.As.new replies, union

        mgr = SelectManager.new!
        mgr\With('recursive', as_statement)\from(replies)\project(Relativity.star)

        assert.equal 'WITH RECURSIVE "replies" AS ((SELECT "comments"."id", "comments"."parent_id" FROM "comments" WHERE "comments"."id" = 42) UNION (SELECT "comments"."id", "comments"."parent_id" FROM "comments" INNER JOIN "replies" ON "comments"."parent_id" = "replies"."id")) SELECT * FROM "replies"', mgr\to_sql!

    describe 'ast', ->

      it 'returns the ast', ->
        table = Table.new 'users'
        mgr = table\from table
        ast = mgr.ast
        assert.not_nil ast

    describe 'taken', ->

      it 'returns the limit', ->
        mgr = SelectManager.new!
        mgr\take 10
        assert.equal mgr.taken, 10

    --describe 'lock', ->
    --  it 'adds a lock', ->
    --    table = Table.new 'users'
    --    mgr = table\from table
    --    assert.equal 'SELECT FROM "users"', mgr\to_sql!

    describe 'orders', ->

      it 'returns the order clauses', ->
        table = Table.new 'users'
        mgr = SelectManager.new!
        order = table 'id'
        mgr\order table('id')
        assert.equal order.name, mgr.orders[1].name

    describe 'order', ->

      it 'generates order clauses', ->
        table = Table.new 'users'
        mgr = SelectManager.new!
        mgr\project Relativity.star
        mgr\from table
        mgr\order table('id')
        assert.equal 'SELECT * FROM "users" ORDER BY "users"."id"', mgr\to_sql!

      it 'takes variable number of arguments', ->
        table = Table.new 'users'
        mgr = SelectManager.new!
        mgr\project Relativity.star
        mgr\from table
        mgr\order table('id'), table('name')
        assert.equal 'SELECT * FROM "users" ORDER BY "users"."id", "users"."name"', mgr\to_sql!

      it 'chains', ->
        table = Table.new 'users'
        mgr = SelectManager.new!
        assert.equal mgr, mgr\order(table('id'))

      it 'supports order direction', ->
        table = Table.new 'users'
        mgr = SelectManager.new!
        mgr\project Relativity.star
        mgr\from table
        mgr\order table('id')\asc!, table('name')\desc!
        assert.equal 'SELECT * FROM "users" ORDER BY "users"."id" ASC, "users"."name" DESC', mgr\to_sql!

    describe 'on', ->

      it 'takes two arguments', ->
        left = Table.new 'users'
        right = left\alias!
        predicate = left('id')\eq right('id')
        mgr = SelectManager.new!

        mgr\from left
        mgr\join(right)\on predicate, predicate
        assert.equal 'SELECT FROM "users" INNER JOIN "users" "users_2" ON "users"."id" = "users_2"."id" AND "users"."id" = "users_2"."id"', mgr\to_sql!

      it 'it takes variable number of arguments', ->
        left = Table.new 'users'
        right = left\alias!
        predicate = left('id')\eq right('id')
        mgr = SelectManager.new!

        mgr\from left
        mgr\join(right)\on predicate, predicate, left('name')\eq right('name')
        assert.equal 'SELECT FROM "users" INNER JOIN "users" "users_2" ON "users"."id" = "users_2"."id" AND "users"."id" = "users_2"."id" AND "users"."name" = "users_2"."name"', mgr\to_sql!

    describe 'froms', ->

      it 'returns the from clauses', ->
        table = Table.new 'users'
        relation = SelectManager.new!
        assert.equal 0, #relation.froms

        relation\from table
        relation\project table('id')
        assert.equal 1, #relation.froms

    describe 'nodes', ->

      it 'creates AND nodes', ->
        relation = SelectManager.new!
        children = {'foo', 'bar', 'baz'}
        clause = relation\create_and children
        assert.equal Nodes.And, clause
        assert.equal children, clause.children

      it 'creates JOIN nodes', ->
        relation = SelectManager.new!
        join = relation\create_join 'foo', 'bar'
        assert.equal Nodes.InnerJoin, join
        assert.equal 'foo', join.left
        assert.equal 'bar', join.right

      it 'creates JOIN nodes of specific class', ->
        relation = SelectManager.new!
        join = relation\create_join 'foo', 'bar', Nodes.LeftOuterJoin
        assert.equal Nodes.LeftOuterJoin, join
        assert.equal 'foo', join.left
        assert.equal 'bar', join.right

    describe 'join', ->

      it 'responds to join', ->
        left = Table.new 'users'
        right = left\alias!
        predicate = left('id')\eq right('id')
        mgr = SelectManager.new!

        mgr\from left
        mgr\join(right)\on predicate
        assert.equal 'SELECT FROM "users" INNER JOIN "users" "users_2" ON "users"."id" = "users_2"."id"', mgr\to_sql!

      it 'takes a class', ->
        left = Table.new 'users'
        right = left\alias!
        predicate = left('id')\eq right('id')
        mgr = SelectManager.new!

        mgr\from left
        mgr\join(right, Nodes.LeftOuterJoin)\on predicate
        assert.equal 'SELECT FROM "users" LEFT OUTER JOIN "users" "users_2" ON "users"."id" = "users_2"."id"', mgr\to_sql!

      it 'noops on nil', ->
        mgr = SelectManager.new!
        assert.equal mgr, mgr\join(nil)
        assert.equal 'SELECT', mgr\to_sql!

    describe 'joins', ->

      it 'returns join sql', ->
        table = Table.new 'users'
        alias = table\alias!
        mgr = SelectManager.new!
        mgr\from Nodes.InnerJoin.new(alias, table('id')\eq(alias('id')))
        assert.equal 'INNER JOIN "users" "users_2" "users"."id" = "users_2"."id"', tostring(mgr\join_sql!)

      it 'return outer join sql', ->
        table = Table.new 'users'
        alias = table\alias!
        mgr = SelectManager.new!
        mgr\from Nodes.LeftOuterJoin.new(alias, table('id')\eq(alias('id')))
        assert.equal 'LEFT OUTER JOIN "users" "users_2" "users"."id" = "users_2"."id"', tostring(mgr\join_sql!)

      it 'returns string join sql', ->
        mgr = SelectManager.new!
        mgr\from Nodes.StringJoin.new('hello')
        assert.equal "'hello'", tostring(mgr\join_sql!) -- TODO: probably shouldn't be quoted

      it 'returns nil join sql', ->
        mgr = SelectManager.new!
        assert.is_nil mgr\join_sql!

    describe 'order clauses', ->

      it 'returns order clauses as a list', ->
        table = Table.new 'users'
        mgr = SelectManager.new!
        mgr\from table
        mgr\order table('id')
        assert.equal '"users"."id"', tostring(mgr.order_clauses[1])

    describe 'group', ->
      it 'takes an attribute', ->
        table = Table.new 'users'
        mgr = SelectManager.new!
        mgr\from table
        mgr\group table('id')
        assert.equal 'SELECT FROM "users" GROUP BY "users"."id"', mgr\to_sql!

      it 'takes multiple args', ->
        table = Table.new 'users'
        mgr = SelectManager.new!
        mgr\from table
        mgr\group table('id'), table('name')
        assert.equal 'SELECT FROM "users" GROUP BY "users"."id", "users"."name"', mgr\to_sql!

      it 'makes string literals', ->
        table = Table.new 'users'
        mgr = SelectManager.new!
        mgr\from table
        mgr\group 'foo'
        assert.equal 'SELECT FROM "users" GROUP BY foo', mgr\to_sql!
--
--    # TODO Implement delete
    
    describe 'where sql', ->
      local table, mgr
      before_each ->
        table = Table.new 'users'
        mgr = SelectManager.new!
        mgr\from table

      it 'returns the where sql', ->
        mgr\where table('id')\eq 10
        assert.equal 'WHERE "users"."id" = 10', tostring(mgr\where_sql!)

      it 'returns nil when there are no wheres', ->
        assert.is_nil mgr\where_sql!

--
--    # TODO Implement Update
    describe 'project', ->
      local mgr
      before_each ->
        mgr = SelectManager.new!

      it 'takes sql literals', ->
        mgr\project Nodes.SqlLiteral.new('*')
        assert.equal 'SELECT *', mgr\to_sql!

      it 'takes string args', ->
        mgr\project '*'
        assert.equal 'SELECT *', mgr\to_sql!

      it 'takes multiple args', ->
        mgr\project Nodes.SqlLiteral.new('foo'), 'bar'
        assert.equal 'SELECT foo, bar', mgr\to_sql!

    describe 'take', ->

      it 'understands #take', ->
        table = Table.new 'users'
        mgr = SelectManager.new!
        mgr\from table
        mgr\project table('id')
        mgr\where table('id')\eq(1)
        mgr\take 1
        assert.equal 'SELECT "users"."id" FROM "users" WHERE "users"."id" = 1 LIMIT 1', mgr\to_sql!

      it 'removes limit when nil is passed to take', ->
        mgr = SelectManager.new!
        mgr\take 10
        assert.equal 'SELECT LIMIT 10', mgr\to_sql!
        mgr\take nil
        assert.equal 'SELECT', mgr\to_sql!

    describe 'join', ->

      it 'joins itself', ->
        left = Table.new 'users'
        right = left\alias!
        predicate = left('id')\eq right('id')

        mgr = left\join right
        mgr\project Relativity.sql('*')
        assert.equal SelectManager, mgr\on(predicate)

        assert.equal 'SELECT * FROM "users" INNER JOIN "users" "users_2" ON "users"."id" = "users_2"."id"', mgr\to_sql!

    it 'responds to #from', ->
      table = Table.new 'users'
      mgr = SelectManager.new!
      mgr\from table
      mgr\project table('id')
      assert.equal 'SELECT "users"."id" FROM "users"', mgr\to_sql!
        
    describe 'booleans', ->
      local table, mgr
      before_each ->
        table = Table.new 'users'
        mgr = SelectManager.new!
        mgr\from table
        mgr\project table('id')

      it 'true', ->
        mgr\where table('underage')\eq(true)
        assert.equal 'SELECT "users"."id" FROM "users" WHERE "users"."underage" = \'t\'', mgr\to_sql!

      it 'not', ->
        mgr\where table('age')\gt(18)\Not!
        assert.equal 'SELECT "users"."id" FROM "users" WHERE NOT ("users"."age" > 18)', mgr\to_sql!

    describe 'subqueries', ->

      it 'work in from', ->
        a = Relativity.select!\project(Nodes.As.new(1, Nodes.UnqualifiedName.new('x')))\as('a')
        b = Relativity.select!\project(Nodes.As.new(1, Nodes.UnqualifiedName.new('x')))\as('b')
        q = Relativity.select!\from(a)\join(b, Nodes.LeftOuterJoin)\on(a('x')\eq(b 'x'))\project Relativity.star
        assert.equal 'SELECT * FROM (SELECT 1 AS "x") "a" LEFT OUTER JOIN (SELECT 1 AS "x") "b" ON "a"."x" = "b"."x"', q\to_sql!

      it 'work in project', ->
        a = Relativity.select!\project 1
        b = Relativity.select!\project 1
        q = Relativity.select!\project a\eq(b)
        assert.equal 'SELECT (SELECT 1) = (SELECT 1)', q\to_sql!

    it 'comparators all work', ->
      t = Relativity.table 'x'
      q = Relativity.select!\project t('x')\lt(2), t('x')\lteq(2), t('x')\gt(2), t('x')\gteq(2), t('x')\not_eq(2), t('x')\is_null!, t('x')\not_null!, t('x')\like('%John%'), t('x')\ilike('%john%')
      assert.equal 'SELECT "x"."x" < 2, "x"."x" <= 2, "x"."x" > 2, "x"."x" >= 2, "x"."x" <> 2, "x"."x" IS NULL, "x"."x" IS NOT NULL, "x"."x" LIKE \'%John%\', "x"."x" ILIKE \'%john%\'', q\to_sql!

    it 'nulls', ->
      assert.equal 'SELECT NULL', Relativity.select!\project(Nodes.SqlLiteral.new('NULL'))\to_sql!

    describe 'case', ->

      it 'creates a case statement', ->
        t = Relativity.table 'users'
        q = Relativity.select!\from t
        q\project Relativity.case!\When(t('age')\lt(18), 'underage')\When(t('age')\gteq(18), 'OK')\Else(Nodes.SqlLiteral.new('NULL'))\End!
        q\project Relativity.case(t('projection'))\When('private', true)\When('public', false)\End!\as('private')
        assert.equal tr[[
          SELECT
          CASE
          WHEN "users"."age" < 18 THEN 'underage'
          WHEN "users"."age" >= 18 THEN 'OK'
          ELSE NULL
          END,
          CASE "users"."projection"
          WHEN 'private' THEN 't'
          WHEN 'public' THEN 'f'
          END AS "private"
          FROM "users"
        ]], q\to_sql!

    it 'constant literals', ->
      assert.equal "SELECT NOT ('f')", Relativity.select!\project(Relativity.lit(false)\Not!)\to_sql!
      assert.equal "SELECT 3 = 3", Relativity.select!\project(Relativity.lit(3)\eq(Relativity.lit(3)))\to_sql!
      assert.equal "SELECT 'a' IN ('a')", Relativity.select!\project(Relativity.lit('a')\In(Relativity.lit({'a'})))\to_sql!

    it 'cast', ->
      assert.equal 'SELECT CAST(3 AS "int")', Relativity.select!\project(Relativity.cast(3, 'int'))\to_sql!
