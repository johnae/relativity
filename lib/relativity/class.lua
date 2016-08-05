return function(name, parent)
  local new_class
  if parent then
    local nc
    do
      local _tbl_0 = { }
      for k, v in pairs(parent) do
        _tbl_0[k] = v
      end
      nc = _tbl_0
    end
    nc.is_a = parent.is_a and (function()
      local _tbl_0 = { }
      for k, v in pairs(parent.is_a) do
        _tbl_0[k] = v
      end
      return _tbl_0
    end)() or { }
    new_class = nc
  else
    new_class = {
      is_a = { }
    }
  end
  new_class.__index = function(self, k)
    do
      local v = rawget(new_class, k)
      if v then
        return v
      end
    end
    do
      local v = rawget(new_class, "get_" .. tostring(k))
      if v then
        return v(self)
      end
    end
  end
  new_class.__newindex = function(self, k, v)
    do
      local setter = rawget(new_class, "set_" .. tostring(k))
      if setter then
        return setter(self, v)
      else
        return rawset(self, k, v)
      end
    end
  end
  new_class.is_a[new_class] = true
  new_class.__class = name
  new_class.__eq = function(self, other)
    return self.__class == other.__class
  end
  if parent then
    new_class.super = parent.initialize or function(self, ...) end
  end
  new_class.includes = function(tbl)
    for k, v in pairs(tbl) do
      new_class[k] = v
    end
  end
  new_class.new = function(...)
    local new_instance = setmetatable({
      class = new_class
    }, new_class)
    do
      local initialize = new_instance.initialize
      if initialize then
        initialize(new_instance, ...)
      end
    end
    return new_instance
  end
  return setmetatable(new_class, new_class)
end
