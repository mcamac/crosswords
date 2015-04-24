/* global require, __dirname, module */
var path = require('path');
var webpack = require('webpack');

/* eslint no-single-line-objects:0 */
module.exports = {
  entry: [
    './shared/puzzle.coffee',
    './shared/player.coffee',
    './client/static/css/room.sass',
    './client/static/css/svg.sass',
    './client/static/js/keymanager.coffee',
    './client/static/js/puzzlemanager.coffee',
    './client/static/js/room.coffee',
    './client/static/js/svg.coffee'
  ],
  output: {
    path: __dirname + '/client/static/js/',
    filename: 'crosswords.js',
    publicPath: '/scripts/'
  },
  plugins: [
    new webpack.NoErrorsPlugin()
  ],
  resolve: {
    extensions: ['', '.js', '.coffee']
  },
  module: {
    loaders: [
      { test: /\.coffee$/, loaders: ['imports?this=>window', 'coffee'], exclude: /node_modules/ },
      { test: /\.js$/, loaders: ['babel'], exclude: /node_modules/ },
      { test: /\.sass?$/, loaders: ['style', 'css', 'sass?indentedSyntax'], exclude: /node_modules/ },
      { test: /\.jade$/, loaders: ['html', 'jade-html']}
    ]
  }
};
