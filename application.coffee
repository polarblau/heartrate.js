# thread manager for job handling
window.Orange                = require 'orange'

# shims for HTML5 functionality in Chrome & Safari
# TODO: warn if current browser not supported
window.URL                   = window.URL || window.webkitURL
window.requestAnimationFrame = window.webkitRequestAnimationFrame
navigator.getUserMedia       = navigator.getUserMedia || navigator.webkitGetUserMedia

window.HeartrateJS =
  Models     : {}
  Collections: {}
  Views      : {}
  Utils      : {}
  Settings   :
    waitingDuration    : 5000
    measurementDuration: 10000

  initialize : ->
    new HeartrateJS.Router()
    Backbone.history.start()

$ -> HeartrateJS.initialize()
