local empty
empty = function(t)
  if not (t) then
    return true
  end
  if #t > 0 then
    return false
  end
  if next(t) then
    return false
  end
  return true
end
local any
any = function(t)
  return not empty(t)
end
local map
map = function(list, fun)
  local _accum_0 = { }
  local _len_0 = 1
  for _index_0 = 1, #list do
    local item = list[_index_0]
    _accum_0[_len_0] = fun(item)
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
table.empty = empty
table.any = any
table.map = map
