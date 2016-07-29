SelectManager = require 'relativity.select_manager'
InsertManager = require 'relativity.insert_manager'
defer = require 'relativity.defer'
Attributes = require 'relativity.attributes'
Nodes = defer -> require 'relativity.nodes.nodes'
FactoryMethods = require 'relativity.factory_methods'
Crud = require 'relativity.crud'
Class = require 'relativity.class'

Attribute = Attributes.Attribute

Table = Class 'Table'
Table.includes FactoryMethods
Table.includes Crud
Table.initialize = (name, opts={}) =>
  @name = name
  @columns = nil
  @aliases = {}
  @table_alias = opts.as if opts.as

Table.from = (table) =>
  SelectManager.new table

Table.project = (...) =>
  @from(@)\project ...

Table.attribute = (name) =>
  Attribute.new @, name

Table.alias = (name) =>
  name = "#{@name}_2" unless name
  aliases = @aliases
  aliases[#aliases + 1] = Nodes.TableAlias.new @, name
  aliases[#aliases]

Table.__call = (name) =>
  Attribute.new @, name

Table.json = (...) =>
  opts = {}
  for attr in *{...}
    opts[attr] = @(attr)
  Nodes.JsonBuildObject.new opts

Table.join = (relation, klazz) =>
  klazz or= Nodes.InnerJoin
  return @from @ unless relation

  klazz = if relation == Nodes.StringJoin or type(relation) == 'string'
    Nodes.StringJoin
  else
    klazz

  @from(@)\join relation, klazz

Table.insert_manager = =>
  InsertManager.new!

Table.skip = (amount) =>
  @from(@)\skip amount

Table.select_manager = =>
  SelectManager.new!

Table.having = (expr) =>
  @from(@)\having expr

Table.group = (...) =>
  @from(@)\group ...

Table.order = (...) =>
  @from(@)\order ...

Table.take = (amount) =>
  @from(@)\take amount

Table.where = (condition) =>
  @from(@)\where condition

Table.get_star = => Nodes.TableStar.new @

Table
