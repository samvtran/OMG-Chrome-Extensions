module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    coffee: {
      chrome: {
        files: {
          'dist-chrome/scripts/main.js': [
            'src/main/coffee/config.coffee',
            'src/chrome/coffee/config.coffee',
            'src/main/coffee/common.coffee',
            'src/chrome/coffee/main.coffee'
          ]
        }
      },
      ubuntu: {
        files: {
          'dist-ubuntu/scripts/main.js': [
            'src/main/coffee/config.coffee',
            'src/ubuntu/coffee/config.coffee',
            'src/main/coffee/common.coffee',
            'src/ubuntu/coffee/main.coffee'
          ]
        }
      },
      test: {
        files: {
          'test/build/main.js': [
            'src/main/coffee/config.coffee',
            'test/config.coffee',
            'src/main/coffee/common.coffee'
          ]
        },
        options: {
          bare: true
        }
      }
    },
    coffeelint: {
      app: ['src/main/coffee/**/*.coffee'],
      chrome: {
        files: { src: ['src/chrome/coffee/**/*.coffee'] }
      },
      ubuntu: {
        files: { src: ['src/ubuntu/coffee/**/*.coffee'] }
      },
      options: {
        indentation: {
          level: 'ignore'
        },
        max_line_length: { level: 'ignore' }
      }
    },
    compass: {
      chrome: {
        options: {
          sassDir: 'src/chrome/sass',
          cssDir: 'dist-chrome/stylesheets',
          outputStyle: 'compressed'
        }
      },
      ubuntu: {
        options: {
          sassDir: 'src/ubuntu/sass',
          cssDir: 'dist-ubuntu/stylesheets',
          outputStyle: 'compressed'
        }
      }
    },
    watch: {
      mainScripts: {
        files: ['src/main/coffee/**/*'],
        tasks: ['coffeelint', 'coffee']
      },
      mainStyles: {
        files: ['src/main/sass/**/*'],
        tasks: ['compass']
      },
      mainAssets: {
        files: ['src/main/assets/**/*'],
        tasks: ['copy']
      },
      mainHtml: {
        files: ['src/main/*.html'],
        tasks: ['copy']
      },
      bower: {
        files: ['bower_components/**/*'],
        tasks: ['copy']
      },

      chromeScripts: {
        files: ['src/chrome/coffee/**/*'],
        tasks: ['coffeelint:chrome', 'coffee:chrome']
      },
      chromeStyles: {
        files: ['src/chrome/sass/**/*'],
        tasks: ['compass:chrome']
      },
      chromeAssets: {
        files: ['src/chrome/assets/**/*'],
        tasks: ['copy:chrome']
      },

      ubuntuScripts: {
        files: ['src/ubuntu/coffee/**/*'],
        tasks: ['coffeelint:ubuntu', 'coffee:ubuntu']
      },
      ubuntuStyles: {
        files: ['src/ubuntu/sass/**/*'],
        tasks: ['compass:ubuntu']
      },
      ubuntuAssets: {
        files: ['src/ubuntu/assets/**/*'],
        tasks: ['copy:ubuntu']
      }
    },
    copy: {
      chrome: {
        files: [
          {
            expand: true,
            cwd: 'src/main/assets',
            src: ['**'],
            dest: 'dist-chrome'
          },
          {
            expand: true,
            cwd: 'src/main',
            src: ['*.html'],
            dest: 'dist-chrome'
          },
          {
            expand: true,
            flatten: true,
            cwd: 'bower_components',
            src: ['angular/angular.min.js', 'angular-resource/angular-resource.min.js'],
            dest: 'dist-chrome/scripts'
          },
          {
            expand: true,
            cwd: 'src/chrome/assets',
            src: ['**'],
            dest: 'dist-chrome'
          }
        ]
      },
      ubuntu: {
        files: [
          {
            expand: true,
            cwd: 'src/main/assets',
            src: ['**'],
            dest: 'dist-ubuntu'
          },
          {
            expand: true,
            cwd: 'src/main',
            src: ['*.html'],
            dest: 'dist-ubuntu'
          },
          {
            expand: true,
            flatten: true,
            cwd: 'bower_components',
            src: ['angular/angular.min.js', 'angular-resource/angular-resource.min.js'],
            dest: 'dist-ubuntu/scripts'
          },
          {
            expand: true,
            cwd: 'src/ubuntu/assets',
            src: ['**'],
            dest: 'dist-ubuntu'
          }
        ]
      },
      tests: {
        files: [
          {
            expand: true,
            flatten: true,
            cwd: 'bower_components',
            src: ['angular-mocks/angular-mocks.js', 'angular/angular.js', 'angular-resource/angular-resource.js'],
            dest: 'test/lib'
          }
        ]
      }
    },
    clean: {
      chrome: ['dist-chrome'],
      ubuntu: ['dist-ubuntu'],
      test: ['test/lib', 'coverage', 'test/build']
    },
    karma: {
      unit: {
        configFile: 'test/karma.conf.js',
        singleRun: true
      },
      "unit-watch": {
        configFile: 'test/karma.conf.js'
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-coffeelint');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-compass');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-karma');

  grunt.registerTask('default', []);

  grunt.registerTask('dev', [
    'dist',
    'watch'
  ]);

  grunt.registerTask('dist', [
    'clean',
    'copy',
    'compass',
    'coffee'
  ]);

  grunt.registerTask('test', ['coffee:test', 'copy:tests', 'karma:unit']);
  grunt.registerTask('test-watch', ['coffee:test', 'copy:tests', 'karma:unit-watch']);
};