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
coffeeify = require 'coffeeify'
buffer = require 'vinyl-buffer'
rename = require 'gulp-rename'

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

gulp.task 'clean', (cb) ->
  rimraf('build/', cb)

getPrereqs = (scriptList) ->
  gulp.src(scriptList)

gulp.task 'staticScripts', ->
  for target in targets
    gulp.src('bower_components/react/react.js')
      .pipe rename 'react.min.js'
      .pipe gulp.dest "build/#{target}/scripts"

gulp.task 'reactScripts', ->
  for page in ['options', 'popup']
    for target in targets
      paths = pathsForFlavour(target)

      browserified = browserify("./src/main/coffee/#{page}.coffee").bundle()
        .pipe source("#{page}.js")
        .pipe buffer()

      es.merge(
        gulp.src(paths.scripts)
          .pipe gulpIf /[.]coffee$/, coffee()
        browserified
      ).pipe concat "#{page}.js"
      .pipe gulp.dest("build/#{target}/scripts")

gulp.task 'backgroundScript', ->
  for target in targets
    paths = pathsForFlavour(target)

    browserified = browserify('./src/main/coffee/background.coffee').bundle()
      .pipe source("background.js")
      .pipe buffer()

    es.merge(
      gulp.src(paths.scripts).pipe gulpIf(/[.]coffee$/, coffee())
      browserified
    ).pipe concat "background.js"
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

gulp.task 'test', ->
  # TODO

gulp.task 'watch', ->
  for target in targets
    paths = pathsForFlavour(target)
    gulp.watch paths.scripts, ['reactScripts', 'backgroundScript']
    gulp.watch 'src/main/coffee/**/*.coffee', ['reactScripts', 'backgroundScript']
    gulp.watch paths.styles, ['styles']
    gulp.watch 'src/main/sass/**/*.scss', ['styles']
    gulp.watch paths.assets, ['assets']

gulp.task 'dev', ['watch', 'build']

gulp.task 'build', ->
  sequence 'clean', ['staticScripts', 'reactScripts', 'backgroundScript', 'styles', 'assets']

gulp.task 'default', ->
  console.log """
    Tasks:
      dev:    build all targets and set to watch mode
      build:  build all targets (chrome, ubuntu, and opera)
      test:   test all targets
      clean:  cleans all build targets
  """