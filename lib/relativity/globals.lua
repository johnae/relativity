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
table.empty = empty
table.any = any
