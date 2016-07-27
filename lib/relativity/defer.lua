local defer = {
  __index = function(self, k)
    local loaded = rawget(self, 'loaded')
    if not (loaded) then
      loaded = self:loader()
      if not (loaded) then
        loaded = {
          __nil = true
        }
      end
      rawset(self, 'loaded', loaded)
    end
    return loaded[k]
  end,
  __call = function(self, ...)
    local loaded = rawget(self, 'loaded')
    if not (loaded) then
      loaded = self:loader()
      if not (loaded) then
        loaded = {
          __nil = true
        }
      end
      rawset(self, 'loaded', loaded)
    end
    return loaded(...)
  end
}
return function(func)
  local deferred = setmetatable({
    __deferred = true
  }, defer)
  rawset(deferred, 'loader', func)
  return deferred
end
