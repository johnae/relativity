local Nodes = require('relativity.nodes.nodes')
local TableAlias, InnerJoin, StringJoin, And, On, Grouping
TableAlias, InnerJoin, StringJoin, And, On, Grouping = Nodes.TableAlias, Nodes.InnerJoin, Nodes.StringJoin, Nodes.And, Nodes.On, Nodes.Grouping
return {
  create_table_alias = function(self, relation, name)
    return TableAlias.new(relation, name)
  end,
  create_join = function(self, to, constraint, klass)
    klass = klass or InnerJoin
    return klass.new(to, constraint)
  end,
  create_string_join = function(self, to)
    return self:create_join(to, nil, StringJoin)
  end,
  create_and = function(self, clauses)
    return And.new(clauses)
  end,
  create_on = function(self, expr)
    return On.new(expr)
  end,
  grouping = function(self, expr)
    return Grouping.new(expr)
  end
}
