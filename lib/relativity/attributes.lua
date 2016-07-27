local Class = require('relativity.class')
local Attribute = require('relativity.attribute')
return {
  Attribute = Attribute,
  AttrString = Class('AttrString', Attribute),
  AttrTime = Class('AttrTime', Attribute),
  AttrBoolean = Class('AttrBoolean', Attribute),
  AttrDecimal = Class('AttrDecimal', Attribute),
  AttrFloat = Class('AttrFloat', Attribute),
  AttrInteger = Class('AttrInteger', Attribute),
  AttrUndefined = Class('AttrUndefined', Attribute)
}
