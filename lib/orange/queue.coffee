window.Orange ?= {}

class Orange._Queue extends Orange.Eventable

  constructor: ->
    super()
    @jobs   = []
    @length = 0

  push: (job) ->
    @jobs.push job
    @length = @jobs.length
    job.on 'complete', => @trigger('job:completed')
    @trigger 'job:pushed'
    @jobs

  pop: ->
    job     = @jobs.shift()
    @length = @jobs.length
    job
