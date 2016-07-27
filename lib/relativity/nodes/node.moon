Class = require "relativity.class"
defer = require "relativity.defer"
ToSql = defer -> require "relativity.visitors.to_sql"
Not = defer -> require("relativity.nodes.nodes").Not
Grouping = defer -> require("relativity.nodes.nodes").Grouping
Or = defer -> require("relativity.nodes.nodes").Or
And = defer -> require("relativity.nodes.nodes").And

Node = Class "Node"
Node.Not = => Not.new @
Node.Or = (right) => Grouping.new Or.new(@, right)
Node.And = (right) => And.new {@, right}
Node.to_sql = => ToSql @
Node
