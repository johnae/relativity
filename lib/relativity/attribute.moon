require "relativity.globals"
copy_value = copy_value
Class = require 'relativity.class'
Predications = require 'relativity.predications'
Expressions = require 'relativity.expressions'
defer = require 'relativity.defer'
ToSql = defer -> require 'relativity.visitors.to_sql'

Attribute = Class 'Attribute'
Attribute.initialize = (relation, name) =>
  @relation = relation
  @name = name
Attribute.to_sql = => ToSql @
Attribute.includes Expressions
Attribute.includes Predications
Attribute.__tostring = => @to_sql!
Attribute.clone = => copy_value @
Attribute
