require "relativity.globals"
copy_value = copy_value
define = require'classy'.define
defer = require "relativity.defer"
ToSql = defer -> require "relativity.visitors.to_sql"
Not = defer -> require("relativity.nodes.nodes").Not
Grouping = defer -> require("relativity.nodes.nodes").Grouping
Or = defer -> require("relativity.nodes.nodes").Or
And = defer -> require("relativity.nodes.nodes").And

define 'Node', ->
  properties
    not: => Not.new @
  instance
    Or: (right) => Grouping.new Or.new(@, right)
    And: (right) => And.new {@, right}
    to_sql: => ToSql @
  meta
    __unm: => Not.new @
    __add: (right) => @Or right
    __mul: (right) => @And right
