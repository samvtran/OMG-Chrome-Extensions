var configFile = require('../config.js');
module.exports = function(file) {
  var configIdx;
  configFile.production.some(function(p, idx) {
    if (p.name === this.query.substr(1)) {
      configIdx = idx;
      return true;
    }
    return false;
  }.bind(this));
  if (typeof configIdx === 'undefined') return file;
  return "module.exports = " + JSON.stringify(configFile.production[configIdx]);
};