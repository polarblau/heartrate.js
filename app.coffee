# TODO: Use window.performance.now
# to do some benchmarking:
# http://jspro.com/apis/discovering-the-high-resolution-time-api/

Orange = require 'orange'

window.URL                   = window.URL || window.webkitURL
window.requestAnimationFrame = window.webkitRequestAnimationFrame
# TMP:
window.requestFileSystem     = window.requestFileSystem || window.webkitRequestFileSystem

navigator.getUserMedia       = navigator.getUserMedia || navigator.webkitGetUserMedia

$ ->

  [WIDTH, HEIGHT]    = [640, 480]
  video              = $('video').get(0)
  $canvas            = $('canvas')
  $button            = $('button')
  ctx                = $canvas.get(0).getContext('2d')
  localMediaStream   = null
  startTime          = null
  intensities        = []
  timestamps         = []
  captureDuration    = 10000

  set = new Orange.JobSet

  set.on 'complete', (jobs) ->
    console.log "Processing frames complete."
    points     = []
    for job in jobs
      points.push [job.data.timestamp, job.data.calculated.intensity]

    write = openAndWriteFile('series.json', JSON.stringify(points))
    window.requestFileSystem window.TEMPORARY, 1024*1024, write, fileError

    render points

  capture = ->

    unless startTime?
      $('#counter')
        .css('color', 'green')
        .countdown(captureDuration)

    # get timestamp for capture
    now        = (new Date).getTime()
    startTime ?= now
    timestamp  = now - startTime

    # draw the image to the canvas
    ctx.drawImage(video, 0, 0) if localMediaStream

    # get the date from the canvas
    pixels = ctx.getImageData(0, 0, WIDTH, HEIGHT)

    job = new Orange.Job 'calculate_intensity', { pixels: pixels.data, timestamp: timestamp }
    set.push job

    # schedule next capture unless over capture duration
    if timestamp < captureDuration
      requestAnimationFrame(capture)
    else
      set.perform()

  # display video while capturing
  showVideoStream = (stream) ->
    video.src = window.URL.createObjectURL(stream)
    localMediaStream = stream
    $('#counter').countdown 5000, capture

  error = -> console.error arguments

  $('#capture').on 'click', ->
    navigator.getUserMedia video: true, showVideoStream, error

  $('#render').on 'click', ->
    callback = (content) ->
      points = JSON.parse content

      timestamps = _.map points, (point) -> point[0]
      values     = _.map points, (point) -> point[1]

      sum        = _.reduce values, ((memo, value) -> memo + value), 0
      mean       = sum / values.length

      indexed    = _.map values, (value, index) -> [index, value]
      smoothed   = smooth indexed, 4, 5, ((e)->e[1]), ((s, e)->[e[0], s])

      minPeaks   = findPeaksForSet indexed, 3, 3.5, ((e)->e[1]), ((e)->e[0]), 'min'
      maxPeaks   = findPeaksForSet indexed, 3, 3.5, ((e)->e[1]), ((e)->e[0]), 'max'

      chart      = render _.zip timestamps, values

      # calculate heart rate based on peaks

      meanDurationMin = averageDistance(minPeaks)
      meanDurationMax = averageDistance(maxPeaks)

      console.log "Heartrate:", 60000 / ((meanDurationMin + meanDurationMax) / 2)

      for peak in minPeaks
        chart.series[0].points[peak[0]].update
          marker:
            enabled: true
            symbol: 'circle'
            fillColor: "#ff0000"
            lineColor: "#ff0000"
            radius: 7

      for peak in maxPeaks
        chart.series[0].points[peak[0]].update
          marker:
            enabled: true
            symbol: 'circle'
            fillColor: "#00ff00"
            lineColor: "#00ff00"
            radius: 7

    read = openAndReadFile('series.json', callback)
    window.requestFileSystem window.TEMPORARY, 1024*1024, read, fileError

  averageDistance = (peaks) ->
    sumDuration = 0
    for peak, i in peaks
      index           = peak[0]
      nextPeak        = peaks[i + 1]

      if !!nextPeak
        timestamp     = timestamps[index]
        nextTimestamp = timestamps[nextPeak[0]]

        sumDuration  += (nextTimestamp - timestamp) if nextTimestamp

    sumDuration / (peaks.length - 1)


  render = (points) ->
    series = [
      { name: "Intensities", data: points },
      { name: "Intensities (smooth)", data: smooth(points, 4, 5, ((e)->e[1]), ((s, e)->[e[0], s])) }
    ]

    new Highcharts.Chart
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

# moving average
smooth = (set, runs = 1, span = 3, selector, builder) ->
  [buffer, smoothData] = [[], []]

  for point in set
    buffer.push if selector? then selector(point) else point
    buffer.splice(0, 1) if buffer.length > span
    sum = 0
    sum += p for p in buffer # TODO: use _.reduce
    div = if buffer.length < span then buffer.length else span
    smoothData.push if builder? then builder(sum / div, point) else sum / div

  if runs > 1 then smooth(smoothData, --runs, span, selector, builder) else smoothData

# TODO wrapper data type for sets [[ts, value], [ts, …]] with accessors
# for timestamps, values, etc.

findPeaksForSet = (list, runs = 1, span = 3, compare, selector, method = 'min') ->
  peaks = []
  for item, i in list by span
    slice     = list.slice(i, span + i)
    threshold = slice[0]

    comp  = (a, b) -> if method is 'min' then a < b else a > b

    for sliceItem, j in slice
      if compare?
        threshold = sliceItem if comp(compare(sliceItem), compare(threshold))
      else
        threshold = sliceItem if comp(sliceItem, threshold)

    peaks.push threshold

  if runs > 1
    findPeaksForSet(peaks, --runs, span, compare, selector, method)
  else peaks


# TMP
fileError = (e) ->
  console.error switch (e.code)
    when FileError.QUOTA_EXCEEDED_ERR       then 'QUOTA_EXCEEDED_ERR'
    when FileError.NOT_FOUND_ERR            then 'NOT_FOUND_ERR'
    when FileError.SECURITY_ERR             then 'SECURITY_ERR'
    when FileError.INVALID_MODIFICATION_ERR then 'INVALID_MODIFICATION_ERR'
    when FileError.INVALID_STATE_ERR        then 'INVALID_STATE_ERR'
    else                                         'Unknown Error'

openAndWriteFile = (file, contents) ->
  (fs) ->
    openFile(fs, file, ((entry) -> writeFile(entry, contents)), fileError)

openAndReadFile = (file, callback) ->
  (fs) ->
    openFile(fs, file, ((entry) -> readFile(entry, callback)), fileError, false)

readFile = (file, callback) ->
  fileReader = (entry) ->
    reader = new FileReader()
    reader.onloadend = -> callback(this.result)

    reader.readAsText entry

  file.file fileReader, fileError

writeFile = (file, contents) ->
  fileWriter = (writer) ->
    writer.onwriteend =     -> console.log 'Write completed.'
    writer.onerror    = (e) -> console.error "Write failed: #{e.toString()}"

    blob              = new Blob [contents], type: 'text/plain'

    writer.write blob

  file.createWriter fileWriter, fileError

openFile = (fs, file, callback, create = true) ->
  fs.root.getFile file, create: create, callback, fileError

$.fn.countdown = (duration, callback) ->
  start = (new Date).getTime()
  interval = null
  $el = @
  count = ->
    now = (new Date).getTime()
    diff = now - start
    $el.text Math.round (duration - diff) / 1000
    if diff >= duration
      callback() if callback?
      clearInterval interval

  interval = setInterval count, 50
