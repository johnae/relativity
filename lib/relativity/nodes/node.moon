require "relativity.globals"
copy_value = copy_value
Class = require "relativity.class"
defer = require "relativity.defer"
ToSql = defer -> require "relativity.visitors.to_sql"
Not = defer -> require("relativity.nodes.nodes").Not
Grouping = defer -> require("relativity.nodes.nodes").Grouping
Or = defer -> require("relativity.nodes.nodes").Or
And = defer -> require("relativity.nodes.nodes").And

Node = Class "Node"
Node.Not = => Not.new @
Node.__unm = (right) => @Not!
Node.Or = (right) => Grouping.new Or.new(@, right)
Node.__add = (right) => @Or right
Node.And = (right) => And.new {@, right}
Node.__mul = (right) => @And right
Node.to_sql = => ToSql @
Node.clone = => copy_value @
Node
