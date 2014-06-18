'use strict'
gulp = require 'gulp'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
rimraf = require 'rimraf'
gulpIf = require 'gulp-if'
sass = require 'gulp-ruby-sass'
sequence = require 'run-sequence'

targets = ['chrome', 'ubuntu']

pathsForFlavour = (name) ->
  scripts: [
    'bower_components/angular/angular.min.js'
    'bower_components/angular-resource/angular-resource.min.js'
    'src/main/coffee/config.coffee'
    "src/#{name}/coffee/config.coffee"
    'src/main/coffee/common.coffee'
  ]
  styles: [
    "src/#{name}/sass/options.scss"
    "src/#{name}/sass/popup.scss"
  ]
  assets: [
    "src/main/*.html"
    "src/main/assets/**"
    "src/#{name}/assets/**"
  ]

gulp.task 'clean', (cb) ->
  rimraf('build/', cb)

gulp.task 'scripts', ->
  for target in targets
    paths = pathsForFlavour(target)
    gulp.src(paths.scripts)
      .pipe gulpIf /[.]coffee$/, coffee()
      .pipe concat('main.js')
      .pipe gulp.dest("build/#{target}/scripts")

gulp.task 'styles', ->
  for target in targets
    paths = pathsForFlavour(target)
    gulp.src(paths.styles)
      .pipe sass style: 'compressed'
      .pipe gulp.dest("build/#{target}/stylesheets")

gulp.task 'assets', ->
  for target in targets
    paths = pathsForFlavour(target)
    gulp.src(paths.assets)
      .pipe gulp.dest "build/#{target}"


gulp.task 'watch', ->
  for target in targets
    paths = pathsForFlavour(target)
    gulp.watch paths.scripts, ['scripts']
    gulp.watch paths.styles, ['styles']
    gulp.watch paths.assets, ['assets']

gulp.task 'dev', ['watch', 'build']

gulp.task 'build', ->
  sequence 'clean', ['scripts', 'styles', 'assets']

gulp.task 'default', ->
  console.log """
    Tasks:
      dev:    build all targets and set to watch mode
      build:  build all targets (chrome, ubuntu, and opera)
      test:   test all targets
      clean:  cleans all build targets
  """