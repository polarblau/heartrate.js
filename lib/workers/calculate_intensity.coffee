self.onmessage = (event) ->
  [type, data] = [event.data.type, event.data.data]

  switch type
    when 'perform'

      intensity = 0
      intensity += pixel for pixel in data.pixels by 4 when pixel?

      self.postMessage
        type: 'complete'
        data:
          intensity: intensity
          timestamp: data.timestamp
