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
table.empty = table.empty or empty
table.any = table.any or any
table.map = table.map or map
table.merge = table.merge or merge
object_type = function(o)
  local o_type = type(o)
  if o_type == 'table' and o.__type then
    return o.__type
  end
  return o_type
end
copy_value = require('classy').copy_value
