class HeartrateJS.Models.DataPoint extends Backbone.Model

  enqueue: ->
    job = new Orange.Job 'calculate_intensity',
      pixels   : @get('pixels')
      timestamp: @get('timestamp')

    job.on 'complete', (data) =>
      @set('intensity', data.intensity)

    job


