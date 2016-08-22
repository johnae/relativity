local define = require('classy').define
local Attribute = require('relativity.attribute')
return {
  Attribute = Attribute,
  AttrString = define('AttrString', function()
    return parent(Attribute)
  end),
  AttrTime = define('AttrTime', function()
    return parent(Attribute)
  end),
  AttrBoolean = define('AttrBoolean', function()
    return parent(Attribute)
  end),
  AttrDecimal = define('AttrDecimal', function()
    return parent(Attribute)
  end),
  AttrFloat = define('AttrFloat', function()
    return parent(Attribute)
  end),
  AttrInteger = define('AttrInteger', function()
    return parent(Attribute)
  end),
  AttrUndefined = define('AttrUndefined', function()
    return parent(Attribute)
  end)
}
