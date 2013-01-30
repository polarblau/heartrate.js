// Generated by CoffeeScript 1.3.3
(function() {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  if ((_ref = window.Orange) == null) {
    window.Orange = {};
  }

  Orange.Job = (function(_super) {

    __extends(Job, _super);

    function Job(type, data) {
      this.type = type;
      this.data = data != null ? data : {};
      Job.__super__.constructor.call(this);
    }

    Job.prototype.perform = function() {
      return Orange.Queue.push(this);
    };

    return Job;

  })(Orange.Eventable);

}).call(this);