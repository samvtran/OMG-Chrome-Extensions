'use strict';

var gulp = require('gulp');
var del = require('del');
var webpack = require('webpack');
var gulpWebpack = require('gulp-webpack');
var devServer = require('webpack-dev-server');
var plumber = require('gulp-plumber');
var watch = require('gulp-watch');
var sass = require('gulp-sass');
var autoprefixer = require('gulp-autoprefixer');
var replace = require('gulp-replace');
var template = require('gulp-template');
var gulpIf = require('gulp-if');
var file = require('gulp-file');
var merge = require('merge-stream');
var stripDebug = require('gulp-strip-debug');

var baseBuild = require('./webpack.config.base');
var prodBuild = require('./webpack.config.prod');
var devBuild = require('./webpack.config.dev');

var config = require('./config.js');

// SVG dependencies
var svgstore = require('gulp-svgstore');
var svgmin = require('gulp-svgmin');
var insert = require('gulp-insert');
var cheerio = require('gulp-cheerio');
var rename = require('gulp-rename');

//=========================
// COMMON
//=========================

function installBootstrap(filename) {
  return gulp.src('bootstrap-dev.js')
    .pipe(rename(filename))
    .pipe(replace('<!-- FILENAME -->', filename))
    .pipe(gulp.dest('dist/' + config.dev.name));
}

function buildSass(production, configObj) {
  return gulp.src(['flavors/' + configObj.directory + '/style.scss'])
    .pipe(plumber())
    .pipe(sass({
      sourceComments: !production,
      sourceMapEmbed: !production,
      includePaths: ["src/main"]
    }))
    .pipe(autoprefixer({
      browsers: ['last 2 Chrome versions', 'last 2 Opera versions']
    }))
    .pipe(gulp.dest('./dist/' + configObj.name));
}

function getStatics(configObj) {
  return gulp.src(['src/main/*.html', 'src/main/assets/**/*', 'flavors/' + configObj.directory + "/assets/**/*"])
    .pipe(gulpIf('*.html', template(configObj)))
    .pipe(file('manifest.json', JSON.stringify(config.manifests[configObj.manifest], null, 2)))
    .pipe(gulp.dest('./dist/' + configObj.name))
}


//=========================
// GULP TASKS
//=========================

gulp.task('default', function() {
  console.log("===== Gulp Tasks =====");
  console.log("clean - Removes the dist folder");
  console.log("dev - Watches for file changes against the dev flavor specified in config.js");
});

gulp.task('clean', function() {
  return del.sync(['dist']);
});

gulp.task('sass:dev', function() {
  return buildSass(false, config.dev);
});

gulp.task('dev', ['clean', 'sass:dev'], function() {
  // Bootstraps
  installBootstrap('Options.js');
  installBootstrap('Background.js');
  installBootstrap('Popup.js');
  getStatics(config.dev);

  watch(['flavors/' + config.dev.directory + '/sass/*.scss', 'src/main/sass/*.scss'], function() {
    console.log("Rebuilding Sass...");
    return buildSass(false, config.dev);
  });

  watch(['src/main/*.html', 'src/main/assets/**/*', 'flavors/' + config.dev.directory + "/assets/**/*"], function() {
    return getStatics(config.dev);
  });

  new devServer(webpack(devBuild), { publicPath: 'http://localhost:3000/', hot: true }).listen(3000, 'localhost');
});

gulp.task('build', ['clean'], function() {
  var merges = merge();

  config.production.forEach(function(conf) {
    merges.add(getStatics(conf));
    merges.add(buildSass(true, conf));
    merges.add(
      gulp.src(['src/main/js/Popup.js'])
        .pipe(gulpWebpack(prodBuild(conf.minify, conf.name), webpack))
        .pipe(stripDebug())
        .pipe(gulp.dest('dist/' + conf.name))
    );
  });

  return merges;
});