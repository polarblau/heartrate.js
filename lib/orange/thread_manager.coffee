window.Orange ?= {}

class Orange._ThreadManager

  constructor: ->
    @maxSize     = 4
    @workersPath = '/lib/workers/'

    @_threads    = []

    Orange.Queue.on 'job:pushed',    @_update
    Orange.Queue.on 'job:completed', @_update

  #

  _update: =>
    if Orange.Queue.length > 0
      # still room in pool, add thread
      if @_threads.length < Orange.settings.maxThreadPoolSize
        job = Orange.Queue.pop()
        thread = @_addThread()
        thread.perform job

      # pool full, but has idle threads
      else if (idleThreads = @_idleThreads()).length > 0
        job = Orange.Queue.pop()
        idleThreads[0].perform job

  _addThread: ->
    thread = new Orange.Thread
    @_threads.push thread
    thread

  _idleThreads: ->
    (t for t in @_threads when t.idle == true)


