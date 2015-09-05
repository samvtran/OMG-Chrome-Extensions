'use strict';

var gulp = require('gulp');
var plumber = require('gulp-plumber');
var webpack = require('webpack');
var gulpWebpack = require('gulp-webpack');
var watch = require('gulp-watch');

var svgmin = require('gulp-svgmin');
var sass = require('gulp-sass');
var template = require('gulp-template');

var gulpIf = require('gulp-if');
var es = require('event-stream');
var del = require('del');

var configs = [
  { flavor: 'chrome', opera: false },
  { flavor: 'ubuntu', opera: false },
  { flavor: 'ubuntu', opera: true }
];

var templateArgs = {
  chrome: require('./src/chrome/js/config'),
  ubuntu: require('./src/ubuntu/js/config')
};

var buildScripts = function(flavor, production, opera) {
  var conf = {
    context: __dirname + '/src/main/js',
    resolve: {
      alias: {
        flavor: __dirname + "/src/" + flavor + "/js"
      },
      extensions: ['', '.js', '.svg']
    },
    module: {
      loaders: [
        {
          test: /\.js$/,
          loader: 'babel-loader?experimental&optional=runtime',
          exclude: /node_modules/
        }
      ]
    },
    output: {
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
  };

  if (production && !opera) { // Opera doesn't accept extensions with minified JS :(
    conf.plugins = conf.plugins.concat(
      new webpack.DefinePlugin({
        "process.env": {
          "NODE_ENV": JSON.stringify('production')
        }
      }),
      new webpack.optimize.DedupePlugin(),
      new webpack.optimize.UglifyJsPlugin()
    );
  }

  return gulp.src('src/main/js/Background.js')
    .pipe(gulpWebpack(conf, webpack))
    .pipe(gulp.dest('dist/' + flavor + "-" + (opera ? 'opera' : 'chrome')));

};

var buildStyles = function(flavor, production, opera) {
  var config = {
    includePaths: ['src/' + flavor + '/sass', 'src/main/sass'],
    sourceComments: !production,
    style: (production ? 'compressed' : 'expanded')
  };

  return es.merge(
    gulp.src('src/' + flavor + '/sass/options.scss')
      .pipe(plumber())
      .pipe(sass(config))
      .pipe(gulp.dest('dist/' + flavor + "-" + (opera ? 'opera' : 'chrome') + '/styles')),
    gulp.src('src/' + flavor + '/sass/popup.scss')
      .pipe(plumber())
      .pipe(sass(config))
      .pipe(gulp.dest('dist/' + flavor + "-" + (opera ? 'opera' : 'chrome') + '/styles'))
  );
};

var buildAssets = function(flavor, opera) {
  return es.merge(
    gulp.src('src/main/assets/**/*').pipe(gulpIf( /.*\.svg$/, svgmin({
      plugins: [{ convertShapeToPath: false }]
    }))).pipe(gulp.dest('dist/' + flavor + "-" + (opera ? 'opera' : 'chrome'))),
    gulp.src('src/' + flavor + '/assets/**/*').pipe(gulpIf( /.*\.svg$/, svgmin({
      plugins: [{ convertShapeToPath: false }]
    }))).pipe(gulp.dest('dist/' + flavor + "-" + (opera ? 'opera' : 'chrome')))
  );
};

var buildHtml = function(flavor, opera) {
  var dest = 'dist/' + flavor + "-" + (opera ? 'opera' : 'chrome');
  return es.merge(
    gulp.src('src/main/background.html')
      .pipe(plumber())
      .pipe(template(templateArgs[flavor]))
      .pipe(gulp.dest(dest)),
    gulp.src('src/main/options.html')
      .pipe(plumber())
      .pipe(template(templateArgs[flavor]))
      .pipe(gulp.dest(dest)),
    gulp.src('src/main/popup.html')
      .pipe(plumber())
      .pipe(template(templateArgs[flavor]))
      .pipe(gulp.dest(dest))
  );
};

var buildAll = function(production) {
  return es.merge.apply(es, configs.map(function (args) {
    return es.merge(
      buildHtml(args.flavor, args.opera),
      buildScripts(args.flavor, production, args.opera),
      buildStyles(args.flavor, production, args.opera),
      buildAssets(args.flavor, args.opera)
    );
  }));
};

gulp.task('build', ['clean'], function() {
  return buildAll(true);
});

gulp.task('build:dev', ['clean'], function() {
  return buildAll(false);
});

gulp.task('dev', ['build:dev'], function() {
  configs.forEach(function(config) {
    watch('src/main/js/**/*', function() {
      return buildScripts(config.flavor, false, config.opera);
    });
    watch('src/main/*.html')
      .pipe(plumber())
      .pipe(template(templateArgs[config.flavor]))
      .pipe(gulp.dest('dist/' + config.flavor + "-" + (config.opera ? 'opera' : 'chrome')));
    watch(['src/main/assets/**/*', 'src/' + config.flavor + '/assets/**/*'])
      .pipe(gulpIf( /.*\.svg$/, svgmin({
        plugins: [{ convertShapeToPath: false }]
      }))).pipe(gulp.dest('dist/' + config.flavor + "-" + (config.opera ? 'opera' : 'chrome')));
    watch(['src/main/sass/**/*', 'src/' + config.flavor + '/sass/*'], function() {
      return buildStyles(config.flavor, false, config.opera);
    });
  });
});

gulp.task('clean', function(cb) {
  del('dist', cb);
});