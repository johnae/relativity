Binary = require 'relativity.nodes.binary'
Class = require 'relativity.class'

DeleteStatement = Class 'DeleteStatement', Binary
DeleteStatement.initialize = (relation, wheres) =>
  Binary.initialize @, relation, wheres
DeleteStatement
