local Node = require('relativity.nodes.node')
local Binary = require('relativity.nodes.binary')
local SelectStatement = require('relativity.nodes.select_statement')
local SqlLiteral = require('relativity.nodes.sql_literal')
local SelectCore = require('relativity.nodes.select_core')
local Unary = require('relativity.nodes.unary')
local And = require('relativity.nodes.and')
local FunctionNode = require('relativity.nodes.function_node')
local Attribute = require('relativity.attribute')
local InsertStatement = require('relativity.nodes.insert_statement')
local ConstLit = require('relativity.nodes.const_lit')
local Class = require('relativity.class')
local Join = Class('Join', Binary)
local Equality
do
  local klazz = Class('Equality', Binary)
  klazz.initialize = function(self, left, right)
    Binary.initialize(self, left, right)
    self.operator = '=='
    self.operand1 = self.left
    self.operand2 = self.right
  end
  Equality = klazz
end
local With
do
  local klazz = Class('With', Unary)
  klazz.initialize = function(self, expr)
    self.children = expr
  end
  With = klazz
end
return {
  SelectStatement = SelectStatement,
  InsertStatement = InsertStatement,
  SqlLiteral = SqlLiteral,
  SelectCore = SelectCore,
  Binary = Binary,
  And = And,
  ConstLit = ConstLit,
  Null = Class('Null', Node),
  Join = Join,
  InnerJoin = Class('InnerJoin', Join),
  LeftOuterJoin = Class('LeftOuterJoin', Join),
  RightOuterJoin = Class('RightOuterJoin', Join),
  FullOuterJoin = Class('FullOuterJoin', Join),
  StringJoin = Class('StringJoin', Join),
  TableAlias = (function()
    local klazz = Class('TableAlias', Binary)
    klazz.initialize = function(self, left, right)
      Binary.initialize(self, left, right)
      self.name = self.right
      self.relation = self.left
      self.table_alias = self.name
      self.table_name = self.relation.name
    end
    klazz.__call = function(self, name)
      return Attribute.new(self, name)
    end
    return klazz
  end)(),
  FunctionNode = FunctionNode,
  Sum = Class('Sum', FunctionNode),
  Exists = Class('Exists', FunctionNode),
  Max = Class('Max', FunctionNode),
  Min = Class('Min', FunctionNode),
  Avg = Class('Avg', FunctionNode),
  As = Class('As', Binary),
  Assignment = Class('Assignment', Binary),
  Between = Class('Between', Binary),
  DoesNotMatch = Class('DoesNotMatch', Binary),
  GreaterThan = Class('GreaterThan', Binary),
  GreaterThanOrEqual = Class('GreaterThanOrEqual', Binary),
  Like = Class('Like', Binary),
  ILike = Class('ILike', Binary),
  LessThan = Class('LessThan', Binary),
  LessThanOrEqual = Class('LessThanOrEqual', Binary),
  Matches = Class('Matches', Binary),
  NotEqual = Class('NotEqual', Binary),
  NotIn = Class('NotIn', Binary),
  Or = Class('Or', Binary),
  Union = Class('Union', Binary),
  UnionAll = Class('UnionAll', Binary),
  Intersect = Class('Intersect', Binary),
  Except = Class('Except', Binary),
  Ordering = Class('Ordering', Binary),
  IsNull = Class('IsNull', Unary),
  NotNull = Class('NotNull', Unary),
  Bin = Class('Bin', Unary),
  Group = Class('Group', Unary),
  Grouping = Class('Grouping', Unary),
  Having = Class('Having', Unary),
  Limit = Class('Limit', Unary),
  Not = Class('Not', Unary),
  Offset = Class('Offset', Unary),
  On = Class('On', Unary),
  Top = Class('Top', Unary),
  Lock = Class('Lock', Unary),
  Equality = Equality,
  In = Class('In', Equality),
  WithRecursive = Class('WithRecursive', With),
  TableStar = Class('TableStar', Unary),
  Values = (function()
    local klazz = Class('Values', Binary)
    klazz.set_expressions = function(self, e)
      self.left = e
    end
    klazz.get_expressions = function(self)
      return self.left
    end
    klazz.set_columns = function(self, c)
      self.right = c
    end
    klazz.get_columns = function(self)
      return self.right
    end
    return klazz
  end)(),
  UnqualifiedName = (function()
    local klazz = Class('UnqualifiedName', Unary)
    klazz.get_attribute = function(self)
      return self.value
    end
    klazz.set_attribute = function(self, attr)
      self.value = attr
    end
    klazz.get_relation = function(self)
      return self.value.relation
    end
    klazz.get_column = function(self)
      return self.value.column
    end
    klazz.get_name = function(self)
      return self.value
    end
    return klazz
  end)()
}
