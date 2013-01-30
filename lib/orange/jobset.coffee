window.Orange ?= {}

class Orange.JobSet extends Orange.Eventable

  constructor: ->
    super()
    @_jobs          = []
    @_completeCount = 0

  push: (job) ->
    job.on 'complete', @_jobComplete
    @_jobs.push job

  #

  _jobComplete: =>
    if ++@_completeCount >= @_jobs.length
      @trigger 'complete', @_jobs
