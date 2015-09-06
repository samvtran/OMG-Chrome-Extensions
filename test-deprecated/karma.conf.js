module.exports = function(config) {
  config.set({
    basePath: "..",
    frameworks: ['jasmine-ajax', 'jasmine', 'browserify'],
    preprocessors: {
      '/**/*.browserify': ['browserify']
    },
    browserify: {
      transform: ['coffeeify', 'reactify', 'rewireify', 'browserify-istanbul'],
      files: ['test-deprecated/**/*.coffee']
    },
// TODO fix HTML coverage
    coverageReporter: {
      reporters: [
//        { type: 'html', dir: 'coverage/' },
        { type: 'lcovonly', dir: 'coverage/' },
        { type: 'teamcity' },
        { type: 'text-summary' }
      ],
      instrumenter: {
        'src/main/**/*.coffee': 'istanbul'
      }
    },
    files: [
      'test-deprecated/phantomjs-shims.js',
      'bower_components/react/react-with-addons.js',
      'test-deprecated/testData.js'
    ],
    reporters: [
      'progress',
      'teamcity',
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