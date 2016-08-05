empty = (t) ->
  return true unless t
  return false if #t > 0
  if next t
    return false
  true

any = (t) -> not empty(t)

map = (list, fun) -> [fun(item) for item in *list]

table.empty = empty
table.any = any
table.map = map

export *

copy_value = (copies) =>
  return @ unless type(@) == 'table'
  return copies[@] if copies and copies[@]
  copies or= {}
  copy = setmetatable {}, getmetatable @
  copies[@] = copy
  for k, v in pairs @
    copy[copy_value(k, copies)] = copy_value v, copies
  copy
