define = require'classy'.define
Attribute = require 'relativity.attribute'

{
  :Attribute
  AttrString: define 'AttrString', -> parent Attribute
  AttrTime: define 'AttrTime', -> parent Attribute
  AttrBoolean: define 'AttrBoolean', -> parent Attribute
  AttrDecimal: define 'AttrDecimal', -> parent Attribute
  AttrFloat: define 'AttrFloat', -> parent Attribute
  AttrInteger: define 'AttrInteger', -> parent Attribute
  AttrUndefined: define 'AttrUndefined', -> parent Attribute
}
