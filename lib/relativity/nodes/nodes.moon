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
define = require'classy'.define

Join = define 'Join', -> parent Binary
Equality = define 'Equality', ->
  parent Binary
  instance
    initialize: (left, right) =>
      super @, left, right
      @operator = '=='
      @operand1 = @left
      @operand2 = @right

With = define 'With', ->
  parent Unary
  instance
    initialize: (expr) =>
      @children = expr

UnqualifiedName = define 'UnqualifiedName', ->
  parent Unary
  properties
    attribute:
      get: => @value
      set: (attr) => @value = attr
    relation: => @value.relation
    column: => @value.column
    name: => @value

Matches = define 'Matches', ->
  parent Binary
  properties
    case_insensitive:
      get: => @_case_insensitive or false
      set: (ci) => @_case_insensitive = ci

As = define 'As', -> parent Binary

{
  :SelectStatement
  :InsertStatement
  :SqlLiteral
  :SelectCore
  :Binary
  :And
  :ConstLit

  :Join
  JoinLateral: define 'JoinLateral', -> parent Join
  InnerJoin: define 'InnerJoin', -> parent Join
  InnerJoinLateral: define 'InnerJoinLateral', -> parent Join
  LeftOuterJoin: define 'LeftOuterJoin', -> parent Join
  LeftOuterJoinLateral: define 'LeftOuterJoinLateral', -> parent Join
  RightOuterJoin: define 'RightOuterJoin', -> parent Join
  RightOuterJoinLateral: define 'RightOuterJoinLateral', -> parent Join
  FullOuterJoin: define 'FullOuterJoin', -> parent Join
  FullOuterJoinLateral: define 'FullOuterJoinLateral', -> parent Join
  StringJoin: define 'StringJoin', -> parent Join
  TableAlias: define 'TableAlias', ->
    parent Binary
    instance
      initialize: (left, right) =>
        super @, left, right
        @__cached_attributes = {}
        @name = right
        @relation = left
        @table_alias = @name
        @table_name = @relation.name
    meta
      __call: (name) =>
        attr = @__cached_attributes[name]
        return attr if attr
        attr = Attribute.new @, name
        @__cached_attributes[name] = attr
        attr

  :FunctionNode
  Sum: define 'Sum', -> parent FunctionNode
  Exists: define 'Exists', -> parent FunctionNode
  Max: define 'Max', -> parent FunctionNode
  Min: define 'Min', -> parent FunctionNode
  Avg: define 'Avg', -> parent FunctionNode
  Count: define 'Count', -> parent FunctionNode

  :As
  Assignment: define 'Assignment', -> parent Binary
  Between: define 'Between', -> parent Binary
  GreaterThan: define 'GreaterThan', -> parent Binary
  GreaterThanOrEqual: define 'GreaterThanOrEqual', -> parent Binary
  LessThan: define 'LessThan', -> parent Binary
  LessThanOrEqual: define 'LessThanOrEqual', -> parent Binary
  Search: define 'Search', -> parent Binary
  :Matches
  DoesNotMatch: define 'DoesNotMatch', -> parent Matches
  NotEqual: define 'NotEqual', -> parent Binary
  NotIn: define 'NotIn', -> parent Binary
  Or: define 'Or', -> parent Binary
  Union: define 'Union', -> parent Binary
  UnionAll: define 'UnionAll', -> parent Binary
  Intersect: define 'Intersect', -> parent Binary
  Except: define 'Except', -> parent Binary
  Ascending: define 'Ascending', -> parent Binary
  Descending: define 'Descending', -> parent Binary
  IsNull: define 'IsNull', -> parent Unary
  NotNull: define 'NotNull', -> parent Unary
  Bin: define 'Bin', -> parent Unary
  Group: define 'Group', -> parent Unary
  Grouping: define 'Grouping', -> parent Unary
  Having: define 'Having', -> parent Unary
  Limit: define 'Limit', -> parent Unary
  Not: define 'Not', -> parent Unary
  Offset: define 'Offset', -> parent Unary
  On: define 'On', -> parent Unary
  Top: define 'Top', -> parent Unary
  Lock: define 'Lock', -> parent Unary

  :Equality

  In: define 'In', -> parent Equality

  WithRecursive: define 'WithRecursive', -> parent With
  TableStar: define 'TableStar', -> parent Unary
  Values: define 'Values', ->
    parent Binary
    properties
      expressions:
        get: => @left
        set: (e) => @left = e
      columns:
        get: => @right
        set: (c) => @right = c

  :UnqualifiedName

}
