local Range = require('relativity.range')
local defer = require('relativity.defer')
local SelectManager = defer(function()
  return require('relativity.select_manager')
end)
local Nodes = defer(function()
  return require('relativity.nodes.nodes')
end)
return {
  as = function(self, other)
    return Nodes.As.new(self, Nodes.UnqualifiedName.new(other))
  end,
  not_eq = function(self, other)
    return Nodes.NotEqual.new(self, other)
  end,
  not_eq_any = function(self, others)
    return self:grouping_any('not_eq', others)
  end,
  not_eq_all = function(self, others)
    return self:grouping_all('not_eq', others)
  end,
  is_null = function(self)
    return Nodes.IsNull.new(self)
  end,
  not_null = function(self)
    return Nodes.NotNull.new(self)
  end,
  eq = function(self, other)
    return Nodes.Equality.new(self, other)
  end,
  eq_any = function(self, others)
    return self:grouping_any('eq', others)
  end,
  eq_all = function(self, others)
    return self:grouping_all('eq', others)
  end,
  In = function(self, other)
    local _exp_0 = other
    if SelectManager == _exp_0 then
      return Nodes.In.new(self, other.ast)
    elseif Range == _exp_0 then
      return Nodes.Between.new(self, Nodes.And.new(other.start, other.finish))
    else
      return Nodes.In.new(self, other)
    end
  end,
  in_any = function(self, others)
    return self:grouping_any('in', others)
  end,
  in_all = function(self, others)
    return self:grouping_all('in', others)
  end,
  not_in = function(self, other)
    local _exp_0 = other
    if SelectManager == _exp_0 then
      return Nodes.NotIn.new(self, other.ast)
    else
      return Nodes.NotIn.new(self, other)
    end
  end,
  not_in_any = function(self, others)
    return self:grouping_any('not_in', others)
  end,
  not_in_all = function(self, others)
    return self:grouping_all('not_in', others)
  end,
  matches = function(self, other)
    return Nodes.Matches.new(self, other)
  end,
  matches_any = function(self, others)
    return self:grouping_any('matches', others)
  end,
  matches_all = function(self, others)
    return self:grouping_all('matches', others)
  end,
  does_not_match = function(self, other)
    return Nodes.DoesNotMatch.new(self, other)
  end,
  does_not_match_any = function(self, others)
    return self:grouping_any('does_not_match', others)
  end,
  does_not_match_all = function(self, others)
    return self:grouping_all('does_not_match', others)
  end,
  gteq = function(self, right)
    return Nodes.GreaterThanOrEqual.new(self, right)
  end,
  gteq_any = function(self, others)
    return self:grouping_any('gteq', others)
  end,
  gteq_all = function(self, others)
    return self:grouping_all('gteq', others)
  end,
  gt = function(self, right)
    return Nodes.GreaterThan.new(self, right)
  end,
  gt_any = function(self, others)
    return self:grouping_any('gt', others)
  end,
  gt_all = function(self, others)
    return self:grouping_all('gt', others)
  end,
  lteq = function(self, right)
    return Nodes.LessThanOrEqual.new(self, right)
  end,
  lteq_any = function(self, others)
    return self:grouping_any('lteq', others)
  end,
  lteq_all = function(self, others)
    return self:grouping_all('lteg', others)
  end,
  lt = function(self, right)
    return Nodes.LessThan.new(self, right)
  end,
  lt_any = function(self, others)
    return self:grouping_any('lt', others)
  end,
  lt_all = function(self, others)
    return self:grouping_all('lt', others)
  end,
  like = function(self, right)
    return Nodes.Like.new(self, right)
  end,
  ilike = function(self, right)
    return Nodes.ILike.new(self, right)
  end,
  asc = function(self)
    return Nodes.Ordering.new(self, 'asc')
  end,
  desc = function(self)
    return Nodes.Ordering.new(self, 'desc')
  end
}
