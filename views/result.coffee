class HeartrateJS.Views.Result extends Backbone.View

  el: '#container'
  events:
    'change .span'       : '_updateViaSlider'
    'change .repetitions': '_updateViaSlider'

  initialize: ->
    @template    = _.template $('#tmpl-result').text()
    @span        = 5
    @repetitions = 5

  render: ->
    @$el.html @template(@_templateData())
    @_renderChart [@collection.toHighchartsSeries('Intensity')]
    #@_highlightPeaks @collection.peaks('min', @repetitions, @span), '#ff0000'
    @_highlightPeaks @collection.peaks('max', @repetitions, @span), '#00ff00'
    @

  #

  _templateData: ->
    rate       : @collection.toNumber()
    span       : @span
    repetitions: @repetitions

  _updateViaSlider: (e) =>
    $input      = $(e.currentTarget)
    property    = $input.attr('name')
    value       = $input.val()
    @[property] = value
    $input.parent('label').find('span').text value
    @render()

  _renderChart: (series) ->
    @chart = new Highcharts.Chart
      chart:
        renderTo: 'graph'
      yAxis:
        title:
          text: 'Intensity'
      xAxis:
        title:
          text: 'Timestamp (ms)'
      plotOptions:
        series:
          marker:
            enabled: false
      series: series

  _highlightPeaks: (peaks, color) ->
    if peaks.length > 100
      console.log "Too many peaks. Won't render."
      return
    peakTimestamps = peaks.map (peak) -> peak.get('timestamp')
    points         = _.filter @chart.series[0].points, (point) =>
      _.contains peakTimestamps, point.x

    _.forEach points, (point) ->
      point.update
        marker:
          enabled: true
          symbol: 'circle'
          fillColor: color
          lineColor: color
          radius: 7


