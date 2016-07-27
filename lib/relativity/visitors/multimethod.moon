multi_method_mt = {
  __call: (t, ...) ->
    key = t.__dispatch ...
    meth = t[key]
    unless meth
      error "No visitor defined for type '#{key}'"
    meth t, ...
}

MultiMethod = {
  new: (dispatch) ->
    setmetatable __dispatch: dispatch, multi_method_mt
}

MultiMethod
