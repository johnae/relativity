require('relativity.globals')
local Range = require('relativity.range')
local defer = require('relativity.defer')
local SelectManager = defer(function()
  return require('relativity.select_manager')
end)
local Nodes = defer(function()
  return require('relativity.nodes.nodes')
end)
local object_type = _G.object_type
return {
  as = function(self, other)
    return Nodes.As.new(self, Nodes.UnqualifiedName.new(other))
  end,
  not_eq = function(self, other)
    return Nodes.NotEqual.new(self, other)
  end,
  not_eq_any = function(self, ...)
    return self:grouping_any('not_eq', {
      ...
    })
  end,
  not_eq_all = function(self, ...)
    return self:grouping_all('not_eq', {
      ...
    })
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
  eq_any = function(self, ...)
    return self:grouping_any('eq', {
      ...
    })
  end,
  eq_all = function(self, ...)
    return self:grouping_all('eq', {
      ...
    })
  end,
  In = function(self, ...)
    local other = {
      ...
    }
    if #other == 1 then
      other = other[1]
    end
    local t = object_type(other)
    if t == SelectManager.__type then
      return Nodes.In.new(self, other.ast)
    end
    if t == Range.__type then
      return Nodes.Between.new(self, Nodes.And.new(other.start, other.finish))
    end
    return Nodes.In.new(self, other)
  end,
  includes = function(self, ...)
    return self:In(...)
  end,
  in_any = function(self, ...)
    return self:grouping_any('In', {
      ...
    })
  end,
  in_all = function(self, ...)
    return self:grouping_all('In', {
      ...
    })
  end,
  not_in = function(self, ...)
    local other = {
      ...
    }
    if #other == 1 then
      other = other[1]
    end
    local _exp_0 = other
    if SelectManager == _exp_0 then
      return Nodes.NotIn.new(self, other.ast)
    else
      return Nodes.NotIn.new(self, other)
    end
  end,
  not_in_any = function(self, ...)
    return self:grouping_any('not_in', {
      ...
    })
  end,
  not_in_all = function(self, ...)
    return self:grouping_all('not_in', {
      ...
    })
  end,
  matches = function(self, other, opts)
    if opts == nil then
      opts = { }
    end
    local m = Nodes.Matches.new(self, other)
    if opts.case_insensitive then
      m.case_insensitive = opts.case_insensitive
    end
    return m
  end,
  matches_any = function(self, ...)
    return self:grouping_any('matches', {
      ...
    })
  end,
  matches_all = function(self, ...)
    return self:grouping_all('matches', {
      ...
    })
  end,
  does_not_match = function(self, other)
    return Nodes.DoesNotMatch.new(self, other)
  end,
  does_not_match_any = function(self, ...)
    return self:grouping_any('does_not_match', {
      ...
    })
  end,
  does_not_match_all = function(self, ...)
    return self:grouping_all('does_not_match', {
      ...
    })
  end,
  gteq = function(self, right)
    return Nodes.GreaterThanOrEqual.new(self, right)
  end,
  gteq_any = function(self, ...)
    return self:grouping_any('gteq', {
      ...
    })
  end,
  gteq_all = function(self, ...)
    return self:grouping_all('gteq', {
      ...
    })
  end,
  gt = function(self, right)
    return Nodes.GreaterThan.new(self, right)
  end,
  gt_any = function(self, ...)
    return self:grouping_any('gt', {
      ...
    })
  end,
  gt_all = function(self, ...)
    return self:grouping_all('gt', {
      ...
    })
  end,
  lteq = function(self, right)
    return Nodes.LessThanOrEqual.new(self, right)
  end,
  lteq_any = function(self, ...)
    return self:grouping_any('lteq', {
      ...
    })
  end,
  lteq_all = function(self, ...)
    return self:grouping_all('lteq', {
      ...
    })
  end,
  lt = function(self, right)
    return Nodes.LessThan.new(self, right)
  end,
  lt_any = function(self, ...)
    return self:grouping_any('lt', {
      ...
    })
  end,
  lt_all = function(self, ...)
    return self:grouping_all('lt', {
      ...
    })
  end,
  search = function(self, right)
    return Nodes.Search.new(self, right)
  end,
  grouping_any = function(self, method_id, others)
    local nodes
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #others do
        local expr = others[_index_0]
        _accum_0[_len_0] = self[method_id](self, expr)
        _len_0 = _len_0 + 1
      end
      nodes = _accum_0
    end
    local current = nodes[1]
    for i = 2, #nodes do
      local node = nodes[i]
      current = Nodes.Or.new(current, node)
    end
    return Nodes.Grouping.new(current)
  end,
  grouping_all = function(self, method_id, others)
    local nodes
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #others do
        local expr = others[_index_0]
        _accum_0[_len_0] = self[method_id](self, expr)
        _len_0 = _len_0 + 1
      end
      nodes = _accum_0
    end
    local current = nodes[1]
    for i = 2, #nodes do
      local node = nodes[i]
      current = Nodes.And.new(current, node)
    end
    return Nodes.Grouping.new(current)
  end
}
