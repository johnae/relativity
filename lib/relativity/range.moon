define = require'classy'.define

define 'Range', ->
  instance
    initialize: (start, finish) =>
      @start, @finish = start, finish
