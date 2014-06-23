module.exports = function(config) {
  config.set({
    basePath: "..",
    frameworks: ['jasmine-ajax', 'jasmine', 'browserify'],
    preprocessors: {
      '/**/*.browserify': ['browserify', 'coverage']
    },
//    'test/**/*.coffee': ['browserify']
    browserify: {
      transform: ['coffeeify', 'reactify', 'rewireify'],
      files: ['test/**/*.coffee']
    },
    coffeePreprocessor: {
      options: {
        bare: true
      },
      sourceMap: true
    },
// TODO fix coverage
    coverageReporter: {
      reporters: [
//        { type: 'html', dir: 'coverage/' },
//        { type: 'teamcity' },
        { type: 'text-summary' }
      ]
    },
    files: [
      'test/phantomjs-shims.js',
//      'bower_components/es5-shim/es5-shim.js',
      'bower_components/react/react-with-addons.js',
      'test/testData.js',
//    'test/preflight.coffee'
//      'test/**/*.spec.coffee'
    ],
    reporters: [
      'progress',
      'junit',
//    'teamcity'
      'coverage',
      'story'
    ],
    browsers: ['PhantomJS'],
//    browsers: ['Chrome'],
    plugins: [
      'karma-jasmine',
      'karma-phantomjs-launcher',
      'karma-chrome-launcher',
      'karma-junit-reporter',
      'karma-teamcity-reporter',
      'karma-coverage',
      'karma-browserifast',
      'karma-story-reporter',
      'karma-jasmine-ajax'
    ],
    usePolling: true
  });
};