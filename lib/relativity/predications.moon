require 'relativity.globals'
Range = require 'relativity.range'
defer = require 'relativity.defer'
SelectManager = defer -> require 'relativity.select_manager'
Nodes = defer -> require 'relativity.nodes.nodes'
object_type = _G.object_type

{
  as: (other) =>
    Nodes.As.new @, Nodes.UnqualifiedName.new(other)

  not_eq: (other) =>
    Nodes.NotEqual.new @, other

  not_eq_any: (...) =>
    @grouping_any 'not_eq', {...}

  not_eq_all: (...) =>
    @grouping_all 'not_eq', {...}

  is_null: => Nodes.IsNull.new @
  not_null: => Nodes.NotNull.new @

  eq: (other) =>
    Nodes.Equality.new @, other

  eq_any: (...) =>
    @grouping_any 'eq', {...}

  eq_all: (...) =>
    @grouping_all 'eq', {...}

  In: (...) =>
    other = {...}
    other = other[1] if #other==1
    t = object_type other
    if t == SelectManager.__type
      return Nodes.In.new @, other.ast
    if t == Range.__type
      return Nodes.Between.new @, Nodes.And.new(other.start, other.finish)
    Nodes.In.new @, other
  
  includes: (...) => @In ...

  in_any: (...) =>
    @grouping_any 'In', {...}

  in_all: (...) =>
    @grouping_all 'In', {...}

  not_in: (...) =>
    other = {...}
    other = other[1] if #other==1
    switch other
      when SelectManager
        Nodes.NotIn.new @, other.ast
      else
        Nodes.NotIn.new @, other

  not_in_any: (...) =>
    @grouping_any 'not_in', {...}

  not_in_all: (...) =>
    @grouping_all 'not_in', {...}

  matches: (other, opts={}) =>
    m = Nodes.Matches.new @, other
    if opts.case_insensitive
      m.case_insensitive = opts.case_insensitive
    m

  matches_any: (...) =>
    @grouping_any 'matches', {...}

  matches_all: (...) =>
    @grouping_all 'matches', {...}

  does_not_match: (other) =>
    Nodes.DoesNotMatch.new @, other

  does_not_match_any: (...) =>
    @grouping_any 'does_not_match', {...}

  does_not_match_all: (...) =>
    @grouping_all 'does_not_match', {...}

  gteq: (right) =>
    Nodes.GreaterThanOrEqual.new @, right

  gteq_any: (...) =>
    @grouping_any 'gteq', {...}

  gteq_all: (...) =>
    @grouping_all 'gteq', {...}

  gt: (right) =>
    Nodes.GreaterThan.new @, right

  gt_any: (...) =>
    @grouping_any 'gt', {...}

  gt_all: (...) =>
    @grouping_all 'gt', {...}

  lteq: (right) =>
    Nodes.LessThanOrEqual.new @, right

  lteq_any: (...) =>
    @grouping_any 'lteq', {...}

  lteq_all: (...) =>
    @grouping_all 'lteq', {...}

  lt: (right) =>
    Nodes.LessThan.new @, right

  lt_any: (...) =>
    @grouping_any 'lt', {...}

  lt_all: (...) =>
    @grouping_all 'lt', {...}

  search: (right) =>
    Nodes.Search.new @, right

  grouping_any: (method_id, others) =>
    nodes = [@[method_id](@, expr) for expr in *others]
    current = nodes[1]
    for i=2,#nodes
      node = nodes[i]
      current = Nodes.Or.new current, node
    Nodes.Grouping.new current

  grouping_all: (method_id, others) =>
    nodes = [@[method_id](@, expr) for expr in *others]
    current = nodes[1]
    for i=2,#nodes
      node = nodes[i]
      current = Nodes.And.new current, node
    Nodes.Grouping.new current

}
