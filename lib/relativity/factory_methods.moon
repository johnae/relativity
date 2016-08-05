require "relativity.globals"
copy_value = copy_value
Nodes = require 'relativity.nodes.nodes'
{:TableAlias, :InnerJoin, :StringJoin, :And, :On, :Grouping} = Nodes

{
  create_table_alias: (relation, name) =>
    TableAlias.new relation, name

  create_join: (to, constraint, klass) =>
    klass or= InnerJoin
    klass.new to, constraint

  create_string_join: (to) =>
    @create_join to, nil, StringJoin

  create_and: (clauses) =>
    And.new clauses

  create_on: (expr) =>
    On.new expr

  grouping: (expr) =>
    Grouping.new expr

  clone: => copy_value @
}
