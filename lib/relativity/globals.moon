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
