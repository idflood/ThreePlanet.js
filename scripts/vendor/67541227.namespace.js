(function() {
  var namespace;

  namespace = function(name, values) {
    var key, subpackage, target, value, _i, _len, _ref;
    target = typeof exports !== "undefined" && exports !== null ? exports : window;
    if (name.length > 0) {
      _ref = name.split('.');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        subpackage = _ref[_i];
        target = target[subpackage] || (target[subpackage] = {});
      }
    }
    for (key in values) {
      value = values[key];
      target[key] = value;
    }
    return target;
  };

  namespace('', {
    namespace: namespace
  });

}).call(this);
