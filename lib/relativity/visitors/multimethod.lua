local multi_method_mt = {
  __call = function(t, ...)
    local key = t.__dispatch(...)
    local meth = t[key]
    if not (meth) then
      error("No visitor defined for type '" .. tostring(key) .. "'")
    end
    return meth(t, ...)
  end
}
local MultiMethod = {
  new = function(dispatch)
    return setmetatable({
      __dispatch = dispatch
    }, multi_method_mt)
  end
}
return MultiMethod
