window.Orange ?= {}

class Orange.Eventable

  constructor: ->
    @_subscriptions = {}

  on: (event, callback) =>
    @_subscriptions[event] = [] unless @_subscriptions[event]?
    @_subscriptions[event].push callback

  off: (event, callback) =>
    if @_subscriptions[event]?
      if callback?
        @_subscriptions[event] = (cb for cb in @_subscriptions[event] when cb != callback)
      else
        subscriptions = []
        subscriptions[e] = cb for e, cb of @_subscriptions when e != event
        @_subscriptions = subscriptions

  trigger: (event, data) =>
    if @_subscriptions[event]?
      event.call(@, data) for event in @_subscriptions[event]
