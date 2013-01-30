self.onmessage = (event) ->
  [type, data] = [event.data.type, event.data.data]

  switch type

    when 'perform'
      string = data.string.toUpperCase()
      c = ->
        self.postMessage type: 'complete', data: { string: string }
      setTimeout c, Math.random() * 3000 + 500
