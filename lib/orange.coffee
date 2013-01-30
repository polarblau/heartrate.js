# job = new Orange.Job 'calculateIntensity', { channel: 'red', data: […] }
# job.on 'complete', (data) ->
# #
# job.perform()
#
# set = new Orange.JobSet
# set.on 'complete', (completeJobs) ->
# #
# set.push job
#
# Orange.settings.maxSize     = 4
# Orange.settings.workersPath = '/lib/workers/'

window.Orange    ?= {}

Orange.settings =
  maxThreadPoolSize  : 4
  workersPath        : '/lib/workers/'

Orange.Queue         = new Orange._Queue
Orange.ThreadManager = new Orange._ThreadManager
