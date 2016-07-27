Range = require 'relativity.range'
defer = require 'relativity.defer'
SelectManager = defer -> require 'relativity.select_manager'
Nodes = defer -> require 'relativity.nodes.nodes'

{
  as: (other) =>
    Nodes.As.new @, Nodes.UnqualifiedName.new(other)

  not_eq: (other) =>
    Nodes.NotEqual.new @, other

  not_eq_any: (others) =>
    @grouping_any 'not_eq', others

  not_eq_all: (others) =>
    @grouping_all 'not_eq', others

  is_null: => Nodes.IsNull.new @
  not_null: => Nodes.NotNull.new @

  eq: (other) =>
    Nodes.Equality.new @, other

  eq_any: (others) =>
    @grouping_any 'eq', others

  eq_all: (others) =>
    @grouping_all 'eq', others

  In: (other) =>
    switch other
      when SelectManager
        Nodes.In.new @, other.ast
      when Range
        Nodes.Between.new @, Nodes.And.new(other.start, other.finish) 
      else
        Nodes.In.new @, other

  in_any: (others) =>
    @grouping_any 'in', others

  in_all: (others) =>
    @grouping_all 'in', others

  not_in: (other) =>
    switch other
      when SelectManager
        Nodes.NotIn.new @, other.ast
      else
        Nodes.NotIn.new @, other

  not_in_any: (others) =>
    @grouping_any 'not_in', others

  not_in_all: (others) =>
    @grouping_all 'not_in', others

  matches: (other) =>
    Nodes.Matches.new @, other

  matches_any: (others) =>
    @grouping_any 'matches', others

  matches_all: (others) =>
    @grouping_all 'matches', others

  does_not_match: (other) =>
    Nodes.DoesNotMatch.new @, other

  does_not_match_any: (others) =>
    @grouping_any 'does_not_match', others

  does_not_match_all: (others) =>
    @grouping_all 'does_not_match', others

  gteq: (right) =>
    Nodes.GreaterThanOrEqual.new @, right

  gteq_any: (others) =>
    @grouping_any 'gteq', others

  gteq_all: (others) =>
    @grouping_all 'gteq', others

  gt: (right) =>
    Nodes.GreaterThan.new @, right

  gt_any: (others) =>
    @grouping_any 'gt', others

  gt_all: (others) =>
    @grouping_all 'gt', others

  lteq: (right) =>
    Nodes.LessThanOrEqual.new @, right

  lteq_any: (others) =>
    @grouping_any 'lteq', others

  lteq_all: (others) =>
    @grouping_all 'lteg', others

  lt: (right) =>
    Nodes.LessThan.new @, right

  lt_any: (others) =>
    @grouping_any 'lt', others

  lt_all: (others) =>
    @grouping_all 'lt', others

  like: (right) => Nodes.Like.new @, right
  ilike: (right) => Nodes.ILike.new @, right

  asc: =>
    Nodes.Ordering.new @, 'asc'

  desc: =>
    Nodes.Ordering.new @, 'desc'

-- TODO: fix this
  --grouping_any: (method_id, others) =>
  --  print "Needs clone"
  --  --others = u(others).clone()
  --  --first = others[methodId](others.shift())
  --  first = others[1]
  --  others_copy = {}
  --  for i, other in ipairs others
  --    next if i==1
  --    others_copy[#others_copy + 1] = other

  --  first = others[method_id](first)

  --  Grouping.new 

  --  n = @nodes()
  --  new n.Grouping u(others).reduce first, (memo, expr) ->
  --    new n.Or([memo, @[methodId](expr)])
  --  
  --groupingAll: (methodId, others) ->
  --  others = u(others).clone()
  --  first = others[methodId](others.shift())
  --  
  --  n = @nodes()
  --  new n.Grouping u(others).reduce first, (memo, expr) ->
  --    new n.And([memo, @[methodId](expr)])
}
