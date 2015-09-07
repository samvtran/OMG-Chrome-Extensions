'use strict';
var path = require('path');
var webpack = require('webpack');

module.exports = {
  devtool: 'eval',
  resolve: {
    extensions: ['', '.js', '.svg'],
    alias: {
      js: __dirname + "/src/main/js",
      Helpers: __dirname + "/src/test/js/Helpers"
    }
  },
  resolveLoader: {
    alias: {
      'config': path.resolve('./etc/config-loader.js')
    }
  },
  plugins: [
    new webpack.DefinePlugin({
      "__DEV__": true
    })
  ],
  module: {
    preLoaders: [
      {
        test: /\.js$/,
        loader: 'babel?optional[]=es7.classProperties&optional[]=es7.objectRestSpread',
        exclude: [/node_modules/, /bower_components/]
      },
      {
        test: /\.js$/,
        loader: 'isparta',
        exclude: [/node_modules/, /bower_components/, /\.spec\.js(x)?$/]
      }
    ]
  },
  output: {
    filename: '[name].js'
  }
};