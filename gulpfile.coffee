'use strict'

gulp = require 'gulp'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
rimraf = require 'rimraf'
gulpIf = require 'gulp-if'
sass = require 'gulp-ruby-sass'
sequence = require 'run-sequence'
react = require 'gulp-react'
source = require 'vinyl-source-stream'
browserify = require 'browserify'
es = require 'event-stream'
buffer = require 'vinyl-buffer'
rename = require 'gulp-rename'
coffeeify = require 'coffeeify'
reactify = require 'reactify'
karma = require('karma').server
_ = require 'lodash'

targets = ['chrome', 'ubuntu']

pathsForFlavour = (name) ->
  scripts: [
    'src/main/coffee/config.coffee'
    "src/#{name}/coffee/config.coffee"
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


buildBrowserify = (entry) ->
  b = browserify entry
  b.transform coffeeify
  b.transform reactify
  b.bundle()

###

  Scripts

###


gulp.task 'staticScripts', ->
  for target in targets
    gulp.src('bower_components/react/react.min.js')
    .pipe rename 'react.min.js'
    .pipe gulp.dest "build/#{target}/scripts"

gulp.task 'reactScripts', ->
  for page in ['options', 'popup', 'background']
    for target in targets
      paths = pathsForFlavour(target)

      browserified = buildBrowserify("./src/main/coffee/#{page}.coffee")
      .pipe source("#{page}.js")
      .pipe buffer()

      es.merge(
        gulp.src(paths.scripts)
        .pipe gulpIf /[.]coffee$/, coffee()
        browserified
      ).pipe concat "#{page}.js"
      .pipe gulp.dest("build/#{target}/scripts")


###

  Assets

###


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


###

  Testing

###


karmaConfig = require './test/karma.conf.js'
karmaConf = {}
karmaConfig
  set: (config) -> karmaConf = config

gulp.task 'test', (done) ->
  karma.start _.assign({}, karmaConf, singleRun: true, basePath: '.', autoWatch: true), (code) ->
    done()
    process.exit(code)

gulp.task 'tdd', (done) ->
  karma.start _.assign({}, karmaConf, basePath: '.'), ->
    done()

###

  Run Tasks

###


gulp.task 'clean', (cb) ->
  rimraf('build/', cb)

gulp.task 'watch', ->
  for target in targets
    paths = pathsForFlavour(target)
    gulp.watch paths.scripts, ['reactScripts']
    gulp.watch 'src/main/coffee/**/*.coffee', ['reactScripts']
    gulp.watch paths.styles, ['styles']
    gulp.watch 'src/main/sass/**/*.scss', ['styles']
    gulp.watch paths.assets, ['assets']

gulp.task 'dev', ['watch', 'build']

gulp.task 'build', ->
  sequence 'clean', ['staticScripts', 'reactScripts', 'styles', 'assets']

gulp.task 'default', ->
  console.log """
    Tasks:
      dev:    build all targets and set to watch mode
      build:  build all targets (chrome, ubuntu, and opera)
      test:   test
      clean:  cleans all build targets
  """