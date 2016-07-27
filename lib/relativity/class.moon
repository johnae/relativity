(name, parent) ->
  new_class = if parent
    nc = {k, v for k, v in pairs parent}
    nc.is_a = parent.is_a and {k, v for k, v in pairs parent.is_a} or {}
    nc
  else
    {is_a: {}}
  new_class.__index = (k) =>
    if v = rawget new_class, k
      return v
    if v = rawget new_class, "get_#{k}"
      return v @
  new_class.__newindex = (k, v) =>
    if setter = rawget new_class, "set_#{k}"
      setter @, v
    else
      rawset @, k, v
  new_class.is_a[new_class] = true
  new_class.__class = name
  new_class.__eq = (other) => @__class == other.__class
  if parent
    new_class.super = parent.initialize or (...) =>
  new_class.includes = (tbl) ->
    for k, v in pairs tbl
      new_class[k] = v
  new_class.new = (...) ->
    new_instance = setmetatable {}, new_class
    if initialize = new_instance.initialize
      initialize new_instance, ...
    new_instance
  setmetatable new_class, new_class
