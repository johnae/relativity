defer = require 'relativity.defer'
Nodes = defer -> require 'relativity.nodes.nodes'

{
  count: (distinct=false) =>
    Nodes.Count.new @, distinct
    
  sum: =>
    Nodes.Sum.new @
    
  maximum: =>
    Nodes.Max.new @
    
  minimum: =>
    Nodes.Min.new @
    
  average: =>
    Nodes.Avg.new @
}
