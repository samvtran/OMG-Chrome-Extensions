module.exports = function(config) {
  config.set({
    basePath: '',
    frameworks: ['mocha', 'sinon-chai'],
    files: [
      'src/test/js/**/*.spec.js'
    ],
    exclude: [],
    preprocessors: {
      'src/test/js/**/*.spec.js': ['webpack'],
      'blah.js': ['coverage'] // Just so IntelliJ reports coverage even though we're doing it through webpack
    },
    webpack: require('./webpack.config.test.js'),
    reporters: ['mocha', 'coverage', 'junit'],
    coverageReporter: {
      dir: 'coverage/',
      reporters: [
        { type: 'html', subdir: 'html' },
        { type: 'json', subdir: '.' }
      ]
    },
    junitReporter: {
      outputDir: (process.env['CIRCLE_TEST_REPORTS'] || 'coverage') + '/junit'
    },
    port: 9876,
    colors: true,
    logLevel: config.LOG_INFO,
    autoWatch: true,
    browsers: ['Chrome'],
    singleRun: false
  })
};