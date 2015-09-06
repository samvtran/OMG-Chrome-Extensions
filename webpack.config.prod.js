var baseConfig = require('./webpack.config.base');
var webpack = require('webpack');
var path = require('path');

module.exports = function(minify, flavor) {
  var base = baseConfig(flavor);

  var plugins = [
    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: JSON.stringify('production')
      }
    }),
    new webpack.optimize.DedupePlugin()
  ];
  if (minify) plugins.push(new webpack.optimize.UglifyJsPlugin({
    compressor: {
      screw_ie8: true
    }
  }));

  base.resolve.alias['Config.js'] = path.resolve('./flavors/' + flavor + "")

  base.plugins.push(plugins);

  return base;
};