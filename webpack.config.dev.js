var webpack = require('webpack');
var config = require('./config.js');
var base = Object.create(require('./webpack.config.base')(config.dev.directory));

base.devtool = 'eval';
base.plugins.push(new webpack.HotModuleReplacementPlugin());

Object.keys(base.entry).forEach(function(k) {
  base.entry[k] = [
    'webpack-dev-server/client?http://localhost:3000',
    'webpack/hot/dev-server',
    base.entry[k]
  ];
});

module.exports = base;