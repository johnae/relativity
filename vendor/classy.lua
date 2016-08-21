local merge
merge = function(t1, t2)
  local res
  do
    local _tbl_0 = { }
    for k, v in pairs(t1) do
      _tbl_0[k] = v
    end
    res = _tbl_0
  end
  for k, v in pairs(t2) do
    res[k] = v
  end
  return res
end
local copy_value
copy_value = function(self, copies)
  if not (type(self) == 'table') then
    return self
  end
  if copies and copies[self] then
    return copies[self]
  end
  copies = copies or { }
  local copy = setmetatable({ }, getmetatable(self))
  copies[self] = copy
  for k, v in pairs(self) do
    copy[copy_value(k, copies)] = copy_value(v, copies)
  end
  return copy
end
return {
  copy_value = copy_value,
  define = function(name, class_initializer)
    local parent_class
    local __instance = { }
    local __properties = { }
    local is_a = { }
    local __meta = { }
    local new_class = {
      __type = name,
      __properties = __properties,
      is_a = is_a,
      __instance = __instance,
      __meta = __meta
    }
    local static
    static = function(opts)
      for name, def in pairs(opts) do
        new_class[name] = def
      end
    end
    local instance
    instance = function(opts)
      for name, def in pairs(opts) do
        __instance[name] = def
      end
    end
    local parent
    parent = function(parent)
      parent_class = parent
    end
    local missing_prop = {
      get = function(self, k)
        return rawget(self, k)
      end,
      set = function(self, k, v)
        return rawset(self, k, v)
      end
    }
    local missing_property
    missing_property = function(def)
      missing_prop = merge(missing_prop, def)
    end
    local properties
    properties = function(opts)
      if opts == nil then
        opts = { }
      end
      for k, v in pairs(opts) do
        if type(v) == 'function' then
          v = {
            get = v
          }
        end
        do
          local old_prop = __properties[k]
          if old_prop then
            v = merge(old_prop, v)
          end
        end
        __properties[k] = v
      end
    end
    local accessors
    accessors = function(opts)
      if opts == nil then
        opts = { }
      end
      for field, keys in pairs(opts) do
        for _index_0 = 1, #keys do
          local key = keys[_index_0]
          __properties[key] = {
            get = function(self)
              return self[field][key]
            end,
            set = function(self, v)
              self[field][key] = v
            end
          }
        end
      end
    end
    local include
    include = function(tbl)
      for k, v in pairs(tbl) do
        __instance[k] = v
      end
    end
    local meta
    meta = function(opts)
      if opts == nil then
        opts = { }
      end
      for name, def in pairs(opts) do
        __meta[name] = def
      end
    end
    local class_initializer_env = setmetatable({
      include = include,
      parent = parent,
      instance = instance,
      properties = properties,
      accessors = accessors,
      meta = meta,
      static = static,
      missing_property = missing_property,
      self = new_class
    }, {
      __index = _G
    })
    setfenv(class_initializer, class_initializer_env)
    class_initializer(new_class)
    is_a[new_class] = true
    __instance.is_a = is_a
    __instance.__type = name
    __instance.dup = copy_value
    if parent_class then
      for k, v in pairs(parent_class.is_a) do
        is_a[k] = v
      end
      for name, def in pairs(parent_class) do
        if not (new_class[name]) then
          new_class[name] = def
        end
      end
      for name, def in pairs(parent_class.__properties) do
        if not (__properties[name]) then
          __properties[name] = def
        end
      end
      for name, def in pairs(parent_class.__instance) do
        do
          local new_def = __instance[name]
          if new_def then
            if type(new_def) == 'function' then
              local env = setmetatable({
                super = def
              }, {
                __index = _G
              })
              setfenv(new_def, env)
            end
          else
            __instance[name] = def
          end
        end
        if not (__instance[name]) then
          __instance[name] = def
        end
      end
      for name, def in pairs(parent_class.__meta) do
        if not (__meta[name]) then
          __meta[name] = def
        end
      end
    end
    __meta.__index = function(self, k)
      do
        local v = rawget(__instance, k)
        if v then
          return v
        end
      end
      do
        local prop = rawget(__properties, k)
        if prop then
          if type(prop) == 'table' then
            if prop.get then
              return prop.get(self, k)
            end
          end
          return prop
        end
      end
      if missing_prop.get then
        return missing_prop.get(self, k)
      end
    end
    __meta.__newindex = function(self, k, v)
      do
        local prop = rawget(__properties, k)
        if prop then
          if type(prop) == 'table' then
            if prop.set then
              return prop.set(self, v)
            end
          end
          __properties[k] = v
          return 
        end
      end
      if missing_prop.set then
        return missing_prop.set(self, k, v)
      end
      return rawset(self, k, v)
    end
    __instance.initialize = __instance.initialize or function(self) end
    local new
    new = function(...)
      local new_instance = setmetatable({
        new = new
      }, __meta)
      new_instance.initialize(new_instance, ...)
      return new_instance
    end
    new_class.new = new
    return new_class
  end
}
