Class = require 'relativity.class'
Predications = require 'relativity.predications'
Expressions = require 'relativity.expressions'

Attribute = Class 'Attribute'
Attribute.initialize = (relation, name) =>
  @relation = relation
  @name = name
Attribute.includes Expressions
Attribute.includes Predications
Attribute
