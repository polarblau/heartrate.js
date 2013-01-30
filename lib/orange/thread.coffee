window.Orange ?= {}

class Orange.Thread

  constructor: ->
    @idle = true

  perform: (@job) ->
    if @_worker?
      @_reassign() if @_worker.type != @job.type
    else
      @_createWorker()
    @idle = false
    @_worker.postMessage type: 'perform', data: @job.data

  #

  _reassign: ->
    @_worker.terminate()
    @_createWorker()
    @

  _createWorker: ->
    @_worker           = new Worker @_workerPathForType(@job.type)
    @_worker.onmessage = @_workerResponse
    @_worker.onerror   = @_workerError

  _workerResponse: (event) =>
    [type, data] = [event.data.type, event.data.data]

    switch type
      when 'complete'
        @job.trigger 'complete', data
        @job  = null
        @idle = true

      when 'log'
        console.log data.data

      else
        console.log "Received worker message: #{type}.", data

  _workerError: (e) ->
    throw new Error("Worker error: Line #{e.lineno} in #{e.filename}: #{e.message}")

  _workerPathForType: (type) ->
    [
      Orange.settings.workersPath
      "#{type.replace(/([A-Z])/g, ($1) -> "_" + $1.toLowerCase())}.js"
    ].join('/').replace(/\/{2,}/, '/')
