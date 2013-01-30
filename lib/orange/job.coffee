window.Orange ?= {}

class Orange.Job extends Orange.Eventable

  constructor: (@type, @data = {}) ->
    super()

  perform: ->
    Orange.Queue.push @
