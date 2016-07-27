defer = require 'relativity.defer'
Nodes = defer -> require 'relativity.nodes.nodes'

{
  count: (distinct=false) =>
    Nodes.Count.new {@}, distinct
    
  sum: =>
    Nodes.Sum.new {@}, Nodes.SqlLiteral.new('sum_id')
    
  maximum: =>
    Nodes.Max.new {@}, Nodes.SqlLiteral.new('max_id')
    
  minimum: =>
    Nodes.Min.new {@}, Nodes.SqlLiteral.new('min_id')
    
  average: =>
    Nodes.Avg.new {@}, Nodes.SqlLiteral.new('avg_id')
}
