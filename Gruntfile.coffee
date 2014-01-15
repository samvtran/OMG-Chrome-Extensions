module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffee:
      chrome:
        files: 'tmp/chrome/scripts/main.js': [
          'src/main/coffee/config.coffee'
          'src/chrome/coffee/config.coffee'
          'src/main/coffee/common.coffee'
          'src/chrome/coffee/main.coffee'
        ]
      ubuntu:
        files: 'tmp/ubuntu/scripts/main.js': [
          'src/main/coffee/config.coffee'
          'src/ubuntu/coffee/config.coffee'
          'src/main/coffee/common.coffee'
          'src/ubuntu/coffee/main.coffee'
        ]
      test:
        files: 'test/build/main.js': [
          'src/main/coffee/config.coffee'
          'test/config.coffee'
          'src/main/coffee/common.coffee'
        ]
        options: bare: true
    uglify:
      chrome:
        files: 'dist-chrome/scripts/main.js': [
          'bower_components/angular/angular.min.js'
          'bower_components/angular-resource/angular-resource.min.js'
          'tmp/chrome/scripts/main.js'
        ]
        options:
          sourceMap: 'dist-chrome/scripts/main.map.js'
          sourceMappingURL: 'main.map.js'
      ubuntu:
        files: 'dist-ubuntu/scripts/main.js': [
          'bower_components/angular/angular.min.js'
          'bower_components/angular-resource/angular-resource.min.js'
          'tmp/ubuntu/scripts/main.js'
        ]
        options:
          sourceMap: 'dist-ubuntu/scripts/main.map.js'
          sourceMappingURL: 'main.map.js'
    sass:
      chrome:
        options:
          style: 'compressed'
          loadPath: 'bourbon'
        files: [
          'dist-chrome/stylesheets/options.css': 'src/chrome/sass/options.scss'
          'dist-chrome/stylesheets/popup.css': 'src/chrome/sass/popup.scss'
        ]
      ubuntu:
        options:
          style: 'compressed'
          loadPath: 'bourbon'
        files: [
          'dist-ubuntu/stylesheets/popup.css': 'src/ubuntu/sass/popup.scss'
          'dist-ubuntu/stylesheets/options.css': 'src/ubuntu/sass/options.scss'
          ]
    copy:
      chrome:
        files: [
          {
            expand: true
            cwd: 'src/main/assets'
            src: ['**']
            dest: 'dist-chrome'
          }
          {
            expand: true
            cwd: 'src/main'
            src: ['*.html']
            dest: 'dist-chrome'
          }
          {
            expand: true
            cwd: 'src/chrome/assets'
            src: ['**']
            dest: 'dist-chrome'
          }
        ]
      ubuntu:
        files: [
          {
            expand: true
            cwd: 'src/main/assets'
            src: ['**']
            dest: 'dist-ubuntu'
          }
          {
            expand: true
            cwd: 'src/main'
            src: ['*.html']
            dest: 'dist-ubuntu'
          }
          {
            expand: true
            cwd: 'src/ubuntu/assets'
            src: ['**']
            dest: 'dist-ubuntu'
          }
        ]
      tests:
        files: [
          {
            expand: true
            flatten: true
            cwd: 'bower_components'
            src: ['angular-mocks/angular-mocks.js', 'angular/angular.js', 'angular-resource/angular-resource.js']
            dest: 'test/lib'
          }
        ]
    coffeelint:
      app: ['src/main/coffee/**/*.coffee']
      chrome:
        files: src: ['src/chrome/coffee/**/*.coffee']
      ubuntu:
        files: src: ['src/ubuntu/coffee/**/*.coffee']
      options:
        indentation:
          level: 'ignore'
        max_line_length: level: 'ignore'
    clean:
      chrome: ['dist-chrome', 'tmp/chrome']
      ubuntu: ['dist-ubuntu', 'tmp/ubuntu']
      test: ['test/lib', 'coverage', 'test/build']
    karma:
      unit:
        configFile: 'test/karma.conf.js'
        singleRun: true
      'unit-watch': configFile: 'test/karma.conf.js'
    watch:
      mainScripts:
        files: ['src/main/coffee/**/*']
        tasks: ['coffeelint', 'coffee', 'uglify']
      mainStyles:
        files: ['src/main/sass/**/*']
        tasks: ['sass']
      mainAssets:
        files: ['src/main/assets/**/*', 'src/main/*.html']
        tasks: ['copy']
      bower:
        files: ['bower_components/**/*']
        tasks: ['uglify']
      chromeScripts:
        files: ['src/chrome/coffee/**/*']
        tasks: ['coffeelint:chrome', 'coffee:chrome', 'uglify:chrome']
      chromeStyles:
        files: ['src/chrome/sass/**/*']
        tasks: ['sass:chrome']
      chromeAssets:
        files: ['src/chrome/assets/**/*', 'src/chrome/*.html']
        tasks: ['copy:chrome']
      ubuntuScripts:
        files: ['src/ubuntu/coffee/**/*']
        tasks: ['coffeelint:ubuntu', 'coffee:ubuntu', 'uglify:ubuntu']
      ubuntuStyles:
        files: ['src/ubuntu/sass/**/*']
        tasks: ['sass:ubuntu']
      ubuntuAssets:
        files: ['src/ubuntu/assets/**/*', 'src/ubuntu/*.html']
        tasks: ['copy:ubuntu']


  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-uglify'

  # TODO replace with Bourbon
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-karma'

  grunt.registerTask 'default', []

  grunt.registerTask 'dev', ['dist', 'watch']

  grunt.registerTask 'dist', ['clean', 'copy', 'sass', 'coffeelint', 'coffee', 'uglify']

  grunt.registerTask 'test', ['coffee:test', 'copy:tests', 'karma:unit']
  grunt.registerTask 'test-watch', ['coffee:test', 'copy:tests': 'karma:unit-watch']