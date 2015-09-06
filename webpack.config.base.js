var webpack = require('webpack');
var path = require('path');
var config = require('./etc/config-loader');

module.exports = function(flavor) {
  return {
    context: __dirname + '/src/main/js',
    resolve: {
      extensions: ['', '.js', '.svg']
    },
    resolveLoader: {
      alias: {
        'config': path.resolve('./etc/config-loader.js?' + flavor)
      }
    },
    module: {
      loaders: [
        {
          test: /\.js$/,
          loader: 'babel-loader?optional[]=es7.classProperties&optional[]=es7.objectRestSpread&loose[]=es6.modules',
          exclude: /node_modules/
        }
      ]
    },
    output: {
      path: path.resolve('./flavor/' + flavor),
      filename: '[name].js'
    },
    entry: {
      Background: "./Background.js",
      Options: "./Options.js",
      Popup: "./Popup.js"
    },
    plugins: [
      new webpack.NoErrorsPlugin()
    ]
  }
};