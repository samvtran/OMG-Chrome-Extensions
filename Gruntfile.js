module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    coffee: {
      build: {
        files: {
          'production/scripts/main.js': 'coffee/main.coffee'
        }
      },
      dev: {
        files: {
          'dev/scripts/main.js': 'coffee/main.coffee'
        },
        options: {
          bare: true
        }
      },
    },
    coffeelint: {
      app: ['coffee/*.coffee'],
      options: {
        indentation: {
          level: 'ignore'
        },
        max_line_length: {
          value: 120,
          level: 'error'
        }
      }
    },
    compass: {
      dev: {
        options: {
          sassDir: 'sass',
          cssDir: 'dev/stylesheets',
          outputStyle: 'expanded'
        }
      },
      build: {
        options: {
          sassDir: 'sass',
          cssDir: 'production/stylesheets',
          outputStyle: 'compressed'
        }
      }
    },
    watch: {
      scripts: {
        files: 'coffee/*.coffee',
        tasks: ['coffeelint', 'coffee:dev']
      },
      styles: {
        files: 'sass/*.scss',
        tasks: ['compass:dev']
      },
      staticFiles: {
        files: 'public/**/*',
        tasks: ['copy:dev']
      }
    },
    copy: {
      dev: {
        files: [
          {
            expand: true,
            cwd: 'public/',
            src: ['**'],
            dest: 'dev/',
          }
        ]
      },
      build: {
        files: [
          {
            expand: true,
            cwd: 'public/',
            src: ['**'],
            dest: 'production/',
          }
        ]
      }
    },

    clean: {
      build: ['production'],
      dev: ['dev']
    },

    /*
      Folder setup:
      public => static files copied over
      production => production-ready
      dev => development
    */
    karma: {
      unit: {
        configFile: 'test/karma.conf.js',
        singleRun: true
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
    'clean:dev',
    'copy:dev',
    'compass:dev',
    'coffeelint',
    'coffee:dev',
    'watch'
  ]);

  grunt.registerTask('build', [
    'copy:build',
    'coffeelint',
    'coffee:build',
    'compass:build'
  ]);



// Need grunt-karma to update to support Karma ~0.9.0
  grunt.registerTask('test', [
    'karma:unit'
  ]);
};