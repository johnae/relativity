Node = require 'relativity.nodes.node'
Binary = require 'relativity.nodes.binary'
SelectStatement = require 'relativity.nodes.select_statement'
SqlLiteral = require 'relativity.nodes.sql_literal'
SelectCore = require 'relativity.nodes.select_core'
Unary = require 'relativity.nodes.unary'
And = require 'relativity.nodes.and'
FunctionNode = require 'relativity.nodes.function_node'
Attribute = require 'relativity.attribute'
InsertStatement = require 'relativity.nodes.insert_statement'
ConstLit = require 'relativity.nodes.const_lit'
Class = require 'relativity.class'

Join = Class 'Join', Binary
Equality = do
  klazz = Class 'Equality', Binary
  klazz.initialize = (left, right) =>
    Binary.initialize @, left, right
    @operator = '=='
    @operand1 = @left
    @operand2 = @right
  klazz

With = do
  klazz = Class 'With', Unary
  klazz.initialize = (expr) =>
    @children = expr
  klazz

{
  :SelectStatement
  :InsertStatement
  :SqlLiteral
  :SelectCore
  :Binary
  :And
  :ConstLit

  Null: Class 'Null', Node
  
  :Join
  InnerJoin: Class 'InnerJoin', Join
  LeftOuterJoin: Class 'LeftOuterJoin', Join
  RightOuterJoin: Class 'RightOuterJoin', Join
  FullOuterJoin: Class 'FullOuterJoin', Join
  StringJoin: Class 'StringJoin', Join
  TableAlias: do
    klazz = Class 'TableAlias', Binary
    klazz.initialize = (left, right) =>
      Binary.initialize @, left, right
      @name = @right
      @relation = @left
      @table_alias = @name
      @table_name = @relation.name
    klazz.__call = (name) =>
      Attribute.new @, name
    klazz

  :FunctionNode
  Sum: Class 'Sum', FunctionNode
  Exists: Class 'Exists', FunctionNode
  Max: Class 'Max', FunctionNode
  Min: Class 'Min', FunctionNode
  Avg: Class 'Avg', FunctionNode

  As: Class 'As', Binary
  Assignment: Class 'Assignment', Binary
  Between: Class 'Between', Binary
  DoesNotMatch: Class 'DoesNotMatch', Binary
  GreaterThan: Class 'GreaterThan', Binary
  GreaterThanOrEqual: Class 'GreaterThanOrEqual', Binary
  Like: Class 'Like', Binary
  ILike: Class 'ILike', Binary
  LessThan: Class 'LessThan', Binary
  LessThanOrEqual: Class 'LessThanOrEqual', Binary
  Matches: Class 'Matches', Binary
  NotEqual: Class 'NotEqual', Binary
  NotIn: Class 'NotIn', Binary
  Or: Class 'Or', Binary
  Union: Class 'Union', Binary
  UnionAll: Class 'UnionAll', Binary
  Intersect: Class 'Intersect', Binary
  Except: Class 'Except', Binary
  Ordering: Class 'Ordering', Binary
  IsNull: Class 'IsNull', Unary
  NotNull: Class 'NotNull', Unary
  Bin: Class 'Bin', Unary
  Group: Class 'Group', Unary
  Grouping: Class 'Grouping', Unary
  Having: Class 'Having', Unary
  Limit: Class 'Limit', Unary
  Not: Class 'Not', Unary
  Offset: Class 'Offset', Unary
  On: Class 'On', Unary
  Top: Class 'Top', Unary
  Lock: Class 'Lock', Unary

  :Equality

  In: Class 'In', Equality

  WithRecursive: Class 'WithRecursive', With
  TableStar: Class 'TableStar', Unary
  Values: do
    klazz = Class 'Values', Binary
    klazz.set_expressions = (e) =>
      @left = e
    klazz.get_expressions = =>
      @left
    klazz.set_columns = (c) =>
      @right = c
    klazz.get_columns = =>
      @right
    klazz

  UnqualifiedName: do
    klazz = Class 'UnqualifiedName', Unary
    klazz.get_attribute =  => @value
    klazz.set_attribute = (attr) => @value = attr
    klazz.get_relation = =>
      @value.relation
    klazz.get_column = =>
      @value.column
    klazz.get_name = =>
      @value
    klazz
}
