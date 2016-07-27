empty = (t) ->
  return true unless t
  return false if #t > 0
  if next t
    return false
  true

any = (t) -> not empty(t)

table.empty = empty
table.any = any
