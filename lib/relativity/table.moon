SelectManager = require 'relativity.select_manager'
InsertManager = require 'relativity.insert_manager'
defer = require 'relativity.defer'
Attributes = require 'relativity.attributes'
Nodes = defer -> require 'relativity.nodes.nodes'
FactoryMethods = require 'relativity.factory_methods'
Crud = require 'relativity.crud'
define = require'classy'.define

Attribute = Attributes.Attribute

define 'Table', ->
  include FactoryMethods
  include Crud
  properties
    star: => Nodes.TableStar.new @
  -- it could, in theory, be a missing_property
  -- but that wouldn't allow all names (like name
  -- for example which is an instance variable)
  meta
    __call: (name) =>
      attr = @__cached_attributes[name]
      return attr if attr
      attr = Attribute.new @, name
      @__cached_attributes[name] = attr
      attr
  instance
    initialize: (name, opts={}) =>
      @__cached_attributes = {}
      @name = name
      @columns = nil
      @aliases = {}
      @table_alias = opts.as

    from: (table) =>
      SelectManager.new table

    project: (...) =>
      @from(@)\project ...

    alias: (name) =>
      name = "#{@name}_2" unless name
      aliases = @aliases
      aliases[#aliases + 1] = Nodes.TableAlias.new @, name
      aliases[#aliases]

    json: (...) =>
      opts = {}
      for attr in *{...}
        opts[attr] = @ attr
      Nodes.JsonBuildObject.new opts

    join: (relation, klazz) =>
      klazz or= Nodes.InnerJoin
      return @from @ unless relation

      klazz = if relation == Nodes.StringJoin or type(relation) == 'string'
        Nodes.StringJoin
      else
        klazz

      @from(@)\join relation, klazz

    insert_manager: =>
      InsertManager.new!

    skip: (amount) =>
      @from(@)\skip amount

    select_manager: =>
      SelectManager.new!

    having: (expr) =>
      @from(@)\having expr

    group: (...) =>
      @from(@)\group ...

    asc: (...) =>
      @from(@)\asc ...

    desc: (...) =>
      @from(@)\desc ...

    take: (amount) =>
      @from(@)\take amount

    where: (condition) =>
      @from(@)\where condition
