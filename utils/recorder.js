// Generated by CoffeeScript 1.3.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  HeartrateJS.Utils.Recorder = (function() {

    Recorder.prototype.settings = {
      duration: 20000,
      width: 640,
      height: 480
    };

    Recorder.prototype.localMediaStream = null;

    function Recorder(options) {
      this._capture = __bind(this._capture, this);
      _.extend(this, Backbone.Events);
      this.settings = _.extend(this.settings, options);
      this.ctx = $(this.settings.canvas).get(0).getContext('2d');
      this.preview = $(this.settings.preview).get(0);
      this.init();
    }

    Recorder.prototype.init = function() {
      var error, success,
        _this = this;
      success = function(stream) {
        _this.preview.src = window.URL.createObjectURL(stream);
        _this.localMediaStream = stream;
        return _this.preview.addEventListener('loadeddata', function(e) {
          _this._capture();
          return _this.trigger('start');
        });
      };
      error = function() {
        return console.error(arguments);
      };
      return navigator.getUserMedia({
        video: true
      }, success, error);
    };

    Recorder.prototype.start = function() {
      this.start = (new Date).getTime();
      return this.started = true;
    };

    Recorder.prototype.isStarted = function() {
      return (this.started != null) && this.started;
    };

    Recorder.prototype.stop = function() {
      return this.started = false;
    };

    Recorder.prototype.isStopped = function() {
      return this.started === false;
    };

    Recorder.prototype._capture = function() {
      var now, pixels, timestamp;
      if (this.localMediaStream != null) {
        this.ctx.drawImage(this.preview, 0, 0);
      }
      if (this.isStarted()) {
        now = (new Date).getTime();
        pixels = this.ctx.getImageData(0, 0, this.settings.width, this.settings.height).data;
        timestamp = now - this.start;
        this.trigger('capture', {
           pixels: pixels,
          timestamp: timestamp
        });
      }
      if (!this.isStopped()) {
        return requestAnimationFrame(this._capture);
      }
    };

    return Recorder;

  })();

}).call(this);
