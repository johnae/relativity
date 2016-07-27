[![CircleCI](https://circleci.com/gh/johnae/relativity.svg?style=svg)](https://circleci.com/gh/johnae/relativity)

# Relativity

https://github.com/johnae/relativity

## Description

Please first note that this is incredibly __raw__, far from completed and will probably need a bit of redesign (I'd like to use more Luaisms in places if possible). There are
some missing pieces still. It should be usable however.

Relativity is sort of arel (https://github.com/rails/arel) but for moonscript/lua. As far as I know there is nothing like it (other than this) for Lua/MoonScript. This
owes alot to the nodejs project called rel (https://github.com/yang/rel). It also shares some caveats with that project, namely:

* No database connections, it only builds queries.
* Where ruby can do funky stuff, lua sometimes can. When possible
  Lua-isms are used, otherwise it's a method of some sort.

The point of this (as with arel) is to ease the generation of complex SQL queries. This does NOT adapt to different RDBMS systems (yet at least). I only care about
Postgres. Shouldn't be that difficult to extend though.

## Lua compatibility

To be honest, I'm only sure that this works properly with LuaJIT 2.x+. It should work with other Lua implementations too however - but I haven't tried. The CircleCI
tests run on LuaJIT. The reason is that I'm only interested in LuaJIT (and OpenResty). Please test and help out if you feel like it.


## Usage

```moonscript
    users = Relativity.table 'users'
    users\project(Relativity.star!).to_sql!
```

Generates

```sql
    SELECT * FROM "users"
```

### More advanced queries
```moonscript
    users\where(users('name')\eq('ricky'))
```

Generates
```sql
    SELECT * FROM "users" WHERE "users"."name" = 'ricky'
```

The selection in SQL contains what you want from the database, this is called
a __projection__.

```moonscript
    users\project(users('id')) -- => SELECT "users"."id" FROM "users"
```

Joins look like this:

```moonscript
    users\join(photos)\on(users('id')\eq(photos('user_id')))
    -- => SELECT * FROM "users" INNER JOIN "photos" ON "users"."id" = "photos"."user_id"
```

Limit and offset are called __take__ and __skip__:

```moonscript
    users\take 5 -- => SELECT * FROM "users" LIMIT 5
    users\skip 4 -- => SELECT * FROM "users" OFFSET 4
```

GROUP BY is called __group__:

```moonscript
    users\group users('name') -- => SELECT * FROM "users" GROUP BY "users"."name"
```

All operators are chainable:

```moonscript
    users\where(users('name')\eq('ricky'))\project users('id')
    -- => SELECT "users"."id" FROM "users" WHERE "users"."name" = 'ricky'
```

```moonscript
    users\where(users('name')\eq('linus'))\where(users('age')\lt(25))
```

Multiple arguments can be given too:

```moonscript
    users\where(users('name')\eq('linus'), users('age')\lt(25))
```

OR works like this:

```moonscript
    users\where(users('name')\eq('linus')\or(users('age')\lt(25)))
```

AS works in a similar fashion.

## Development

Running the tests requires busted https://github.com/Olivine-Labs/busted and luassert https://github.com/Olivine-Labs/luassert.
It also requires that moonscript has been installed - see http://moonscript.org/.

To run the specs, run `busted spec`.


## Contributing

I appreciate all feedback and help. If there's a problem, create an issue or pull request. Thanks!
