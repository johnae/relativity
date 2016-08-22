empty = (t) ->
  return true unless t
  return false if #t > 0
  if next t
    return false
  true

any = (t) -> not empty(t)

map = (list, fun) -> [fun(item) for item in *list]

merge = (t1, t2) ->
  res = {k, v for k, v in pairs t1}
  for k, v in pairs t2
    res[k] = v
  res

table.empty or= empty
table.any or= any
table.map or= map
table.merge or= merge

export *

object_type = (o) ->
  o_type = type o
  if o_type == 'table' and o.__type
    return o.__type
  o_type

copy_value = require'classy'.copy_value
