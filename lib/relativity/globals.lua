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
local merge
merge = function(t1, t2)
  local res
  do
    local _tbl_0 = { }
    for k, v in pairs(t1) do
      _tbl_0[k] = v
    end
    res = _tbl_0
  end
  for k, v in pairs(t2) do
    res[k] = v
  end
  return res
end
table.empty = empty
table.any = any
table.map = map
table.merge = merge
copy_value = function(self, copies)
  if not (type(self) == 'table') then
    return self
  end
  if copies and copies[self] then
    return copies[self]
  end
  copies = copies or { }
  local copy = setmetatable({ }, getmetatable(self))
  copies[self] = copy
  for k, v in pairs(self) do
    copy[copy_value(k, copies)] = copy_value(v, copies)
  end
  return copy
end
