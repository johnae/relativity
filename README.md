[![CircleCI](https://circleci.com/gh/johnae/relativity.svg?style=svg)](https://circleci.com/gh/johnae/relativity)

# Relativity

https://github.com/johnae/relativity

## Description

Please first note that this is incredibly __raw__, far from completed and will probably need a bit of redesign (I'd like to use more Luaisms in places if possible). There are some missing pieces still. It should be usable however.

Relativity is sort of arel (https://github.com/rails/arel) but for moonscript/lua. As far as I know there is nothing like it (other than this) for Lua/MoonScript. This project owes alot to Rubys Arel and also to the nodejs project called rel (https://github.com/yang/rel). It also shares some caveats with that project, namely:

* No database connections, it only builds queries.
* Where ruby can do funky stuff, lua sometimes can. When possible
  Lua-isms are used, otherwise it's a method of some sort.

The point of this (as with arel) is to ease the generation of complex SQL queries. This does NOT adapt to different RDBMS systems (yet at least). I only care about Postgres. Shouldn't be that difficult to extend though.

## Lua compatibility

To be honest, I'm only sure that this works properly with LuaJIT 2.x+. It should work with other Lua implementations too however - but I haven't tried. The CircleCI tests run on LuaJIT. The reason is that I'm only interested in LuaJIT (and OpenResty). Please test and help out if you feel like it.

## Performance

Query generation hasn't been benchmarked __at all__. I don't know whether there's a bottleneck, memory issue or something else hiding. I think there may be performance gains in increasing the amount of local use - a well known optimization for Lua. I'll hold off on any such optimizations until it's clear that they'd help.

## Usage

See spec/relativity/integration_spec.moon for more examples.

```moonscript
    users = Relativity.table 'users'
    users\project(Relativity.star)\to_sql!
```

Generates

```sql
    SELECT * FROM "users"
```

### More advanced queries
```moonscript
    users\where(users'name'\eq'Einstein')\to_sql!
```

Generates
```sql
    SELECT * FROM "users"
    WHERE "users"."name" = 'Einstein'
```

The selection in SQL contains what you want from the database, this is called
a __projection__.

```moonscript
    users\project users'id' -- => SELECT "users"."id" FROM "users"
```

Joins look like this:

```moonscript
    users\join(photos)\on users'id'\eq photos'user_id'
    -- => SELECT * FROM "users" INNER JOIN "photos" ON "users"."id" = "photos"."user_id"
```

Note that some of the above is taking advantage of MoonScript/Lua allowing to skip the parentheses in certain instances. Eg. this:

```moonscript
users'id'\eq photos'user_id'
```

Can also be written like:

```moonscript
users('id')\eq(photos('user_id'))
```

It doesn't matter but I just figured I'd point out that these are function calls.


Limit and offset are called __take__ and __skip__:

```moonscript
    users\take 5 -- => SELECT * FROM "users" LIMIT 5
    users\skip 4 -- => SELECT * FROM "users" OFFSET 4
```

GROUP BY is called __group__:

```moonscript
    users\group users'name' -- => SELECT * FROM "users" GROUP BY "users"."name"
```

All operators are chainable:

```moonscript
    users\where(users'name'\eq'ricky')\project users'id'
    -- => SELECT "users"."id" FROM "users" WHERE "users"."name" = 'ricky'
```

```moonscript
    users\where(users'name'\eq'linus')\where users'age'\lt 25
```

Multiple arguments can be given too:

```moonscript
    users\where users'name'\eq'linus', users'age'\lt 25
```

OR works like this:

```moonscript
    users\where users'name'\eq'linus'\Or users'age'\lt 25
```

Unfortunately 'or' is a reserved keyword in MoonScript/Lua and cannot be used. For now I've resorted to title case for these. It's ugly i.m.o. Therefore I've (for now) also added LPeg:ish operators. If you don't know LPeg, you can read more about it here: http://www.inf.puc-rio.br/~roberto/lpeg/.

So OR can also be written like this:

```moonscript
    users\where users'name'\eq'linus' + users'age'\lt 25
```

AS works in a similar fashion, but is lowercased since it isn't reserved. AND has the same problem as OR and must be written in title case or, as above, using an LPeg:ish operator - like this:

```moonscript
    users\where users'name'\eq'linus' * users'age'\lt 25
```

And is less often used since it's assumed in a where.

There's also Not which is a reserved keyword. For now both of the below do the same thing.

Using title case:

```moonscript
users\where users'id'\eq(10)\Not!
```

Or lpeg:ish

```moonscript
users\where -users'id'\eq 10
```

Both generate this:

```SQL
SELECT FROM "users"
WHERE NOT ("users"."id" = 10)
```


Since I mostly care about Postgres, more advanced queries (Postgres specific) are possible, such as:

```moonscript
Relativity = require 'relativity'
Nodes = Relativity.Nodes
users = Relativity.table 'users'
others = Relativity.table 'others'

any = Relativity.func 'ANY'
coalesce = Relativity.func 'COALESCE'

json_select = Relativity.select!
json_select\from others
json_select\project Relativity.as Relativity.array_agg(others\json 'id', 'name'), 'list'
json_select\where others'id'\eq any users'things'
json_select = Relativity.alias json_select, 'things'

things = Relativity.as Nodes.ToJson.new(Relativity.table'things''list'), 'things'
user_employer = coalesce(users'employer', 'none')\as 'employer'

u = users\project users.star, user_employer, things
u\join(json_select, Nodes.InnerJoinLateral)\on true
u\where users'name'\like '%berg%'
```

Generates (via calling \to_sql! on the relation of course):

```SQL
SELECT "users".*,
       COALESCE("users"."employer", 'none') AS "employer",
       to_json("things"."list") AS "things"
FROM "users"
INNER JOIN LATERAL (
  SELECT array_agg(json_build_object('id'::text, "others"."id", 'name'::text, "others"."name")) AS "list"
  FROM "others"
  WHERE "others"."id" = ANY("users"."things")
) "things" ON 't'
WHERE "users"."name" LIKE '%berg%'
```

I'd like to extend this even further for supporting most of the advanced Postgres functionality.

## Development

Running the tests requires busted https://github.com/Olivine-Labs/busted and luassert https://github.com/Olivine-Labs/luassert.
Since luassert comes with busted, only busted needs to be installed really. It also requires that moonscript is installed.

On Ubuntu you might go about it like this:

```shell
sudo apt-get install luarocks luajit
sudo luarocks install busted
sudo luarocks install moonscript
```

To run the specs, run `busted spec`.


## Contributing

I appreciate all feedback and help. If there's a problem, create an issue or pull request. Thanks!
