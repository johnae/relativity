defer = {
  __index: (k) =>
    loaded = rawget @, 'loaded'
    unless loaded
      loaded = @loader!
      loaded = {__nil: true} unless loaded
      rawset @, 'loaded', loaded
    loaded[k]

  __call: (...) =>
    loaded = rawget @, 'loaded'
    unless loaded
      loaded = @loader!
      loaded = {__nil: true} unless loaded
      rawset @, 'loaded', loaded
    loaded ...
}
(func) ->
  deferred = setmetatable {__deferred: true}, defer
  rawset deferred, 'loader', func
  deferred
