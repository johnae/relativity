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
local define = require('classy').define
local Join = define('Join', function()
  return parent(Binary)
end)
local Equality = define('Equality', function()
  parent(Binary)
  return instance({
    initialize = function(self, left, right)
      super(self, left, right)
      self.operator = '=='
      self.operand1 = self.left
      self.operand2 = self.right
    end
  })
end)
local With = define('With', function()
  parent(Unary)
  return instance({
    initialize = function(self, expr)
      self.children = expr
    end
  })
end)
local UnqualifiedName = define('UnqualifiedName', function()
  parent(Unary)
  return properties({
    attribute = {
      get = function(self)
        return self.value
      end,
      set = function(self, attr)
        self.value = attr
      end
    },
    relation = function(self)
      return self.value.relation
    end,
    column = function(self)
      return self.value.column
    end,
    name = function(self)
      return self.value
    end
  })
end)
local Matches = define('Matches', function()
  parent(Binary)
  return properties({
    case_insensitive = {
      get = function(self)
        return self._case_insensitive or false
      end,
      set = function(self, ci)
        self._case_insensitive = ci
      end
    }
  })
end)
local As = define('As', function()
  return parent(Binary)
end)
return {
  SelectStatement = SelectStatement,
  InsertStatement = InsertStatement,
  SqlLiteral = SqlLiteral,
  SelectCore = SelectCore,
  Binary = Binary,
  And = And,
  ConstLit = ConstLit,
  Join = Join,
  JoinLateral = define('JoinLateral', function()
    return parent(Join)
  end),
  InnerJoin = define('InnerJoin', function()
    return parent(Join)
  end),
  InnerJoinLateral = define('InnerJoinLateral', function()
    return parent(Join)
  end),
  LeftOuterJoin = define('LeftOuterJoin', function()
    return parent(Join)
  end),
  LeftOuterJoinLateral = define('LeftOuterJoinLateral', function()
    return parent(Join)
  end),
  RightOuterJoin = define('RightOuterJoin', function()
    return parent(Join)
  end),
  RightOuterJoinLateral = define('RightOuterJoinLateral', function()
    return parent(Join)
  end),
  FullOuterJoin = define('FullOuterJoin', function()
    return parent(Join)
  end),
  FullOuterJoinLateral = define('FullOuterJoinLateral', function()
    return parent(Join)
  end),
  StringJoin = define('StringJoin', function()
    return parent(Join)
  end),
  TableAlias = define('TableAlias', function()
    parent(Binary)
    instance({
      initialize = function(self, left, right)
        super(self, left, right)
        self.__cached_attributes = { }
        self.name = right
        self.relation = left
        self.table_alias = self.name
        self.table_name = self.relation.name
      end
    })
    return meta({
      __call = function(self, name)
        local attr = self.__cached_attributes[name]
        if attr then
          return attr
        end
        attr = Attribute.new(self, name)
        self.__cached_attributes[name] = attr
        return attr
      end
    })
  end),
  FunctionNode = FunctionNode,
  Sum = define('Sum', function()
    return parent(FunctionNode)
  end),
  Exists = define('Exists', function()
    return parent(FunctionNode)
  end),
  Max = define('Max', function()
    return parent(FunctionNode)
  end),
  Min = define('Min', function()
    return parent(FunctionNode)
  end),
  Avg = define('Avg', function()
    return parent(FunctionNode)
  end),
  Count = define('Count', function()
    return parent(FunctionNode)
  end),
  As = As,
  Assignment = define('Assignment', function()
    return parent(Binary)
  end),
  Between = define('Between', function()
    return parent(Binary)
  end),
  GreaterThan = define('GreaterThan', function()
    return parent(Binary)
  end),
  GreaterThanOrEqual = define('GreaterThanOrEqual', function()
    return parent(Binary)
  end),
  LessThan = define('LessThan', function()
    return parent(Binary)
  end),
  LessThanOrEqual = define('LessThanOrEqual', function()
    return parent(Binary)
  end),
  Search = define('Search', function()
    return parent(Binary)
  end),
  Matches = Matches,
  DoesNotMatch = define('DoesNotMatch', function()
    return parent(Matches)
  end),
  NotEqual = define('NotEqual', function()
    return parent(Binary)
  end),
  NotIn = define('NotIn', function()
    return parent(Binary)
  end),
  Or = define('Or', function()
    return parent(Binary)
  end),
  Union = define('Union', function()
    return parent(Binary)
  end),
  UnionAll = define('UnionAll', function()
    return parent(Binary)
  end),
  Intersect = define('Intersect', function()
    return parent(Binary)
  end),
  Except = define('Except', function()
    return parent(Binary)
  end),
  Ascending = define('Ascending', function()
    return parent(Binary)
  end),
  Descending = define('Descending', function()
    return parent(Binary)
  end),
  IsNull = define('IsNull', function()
    return parent(Unary)
  end),
  NotNull = define('NotNull', function()
    return parent(Unary)
  end),
  Bin = define('Bin', function()
    return parent(Unary)
  end),
  Group = define('Group', function()
    return parent(Unary)
  end),
  Grouping = define('Grouping', function()
    return parent(Unary)
  end),
  Having = define('Having', function()
    return parent(Unary)
  end),
  Limit = define('Limit', function()
    return parent(Unary)
  end),
  Not = define('Not', function()
    return parent(Unary)
  end),
  Offset = define('Offset', function()
    return parent(Unary)
  end),
  On = define('On', function()
    return parent(Unary)
  end),
  Top = define('Top', function()
    return parent(Unary)
  end),
  Lock = define('Lock', function()
    return parent(Unary)
  end),
  Equality = Equality,
  In = define('In', function()
    return parent(Equality)
  end),
  WithRecursive = define('WithRecursive', function()
    return parent(With)
  end),
  TableStar = define('TableStar', function()
    return parent(Unary)
  end),
  Values = define('Values', function()
    parent(Binary)
    return properties({
      expressions = {
        get = function(self)
          return self.left
        end,
        set = function(self, e)
          self.left = e
        end
      },
      columns = {
        get = function(self)
          return self.right
        end,
        set = function(self, c)
          self.right = c
        end
      }
    })
  end),
  UnqualifiedName = UnqualifiedName
}
