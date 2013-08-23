module.exports = function(config) {
  config.set({
    autoWatch: true,
    basePath: '..',
    frameworks: ['jasmine'],
    preprocessors: {
      'test/**/*.coffee': ['coffee'],
      'test/build/main.js': ['coverage']
    },
    coffeePreprocessor: {
      options: {
        bare: true,
        sourceMap: true
      }
    },
    files: [
    'test/lib/angular.js',
    'test/lib/angular-resource.js',
    'test/lib/angular-mocks.js',
    'test/unit.preflight.coffee',
    'test/build/main.js',
    'test/testData.js',
    'test/unit/*.spec.coffee'
    ],
    reporters: ['progress', 'junit', 'teamcity', 'coverage'],
    browsers: ['PhantomJS'],
    plugins: [
      'karma-jasmine',
      'karma-phantomjs-launcher',
      'karma-coffee-preprocessor',
      'karma-junit-reporter',
      'karma-teamcity-reporter',
      'karma-coverage'
    ]
  });
};