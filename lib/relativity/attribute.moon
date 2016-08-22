require "relativity.globals"
copy_value = copy_value
define = require'classy'.define
Predications = require 'relativity.predications'
Expressions = require 'relativity.expressions'
defer = require 'relativity.defer'
ToSql = defer -> require 'relativity.visitors.to_sql'

define 'Attribute', ->
  include Expressions
  include Predications
  instance
    initialize: (relation, name) =>
      @relation = relation
      @name = name
    to_sql: => ToSql @
  meta
    __tostring: => @name
