self.onmessage = (event) ->
  [type, data] = [event.data.type, event.data.data]

  switch type

    when 'perform'
      sum = data.numbers.reduce (t, s) -> t + s
      c = ->
        self.postMessage type: 'complete', data: { sum: sum }
      setTimeout c, Math.random() * 5000 + 500
