var gulp = require('gulp');
var Server = require('karma').Server;
var minimist = require('minimist');

var setupSingleFile = function(singleRun, done) {
  const params = minimist(process.argv.slice(2), { string: 'file', default: null });
  if (!params.file) throw new Error('You must pass a --file parameter with a relative link to a spec file');
  new Server({
    configFile: __dirname + '/karma.conf.js',
    singleRun: singleRun,
    files: [
      params.file
    ]
  }, done).start();
};

gulp.task('single', function(done) {
  setupSingleFile(true, done);
});

gulp.task('watch:single', function(done) {
  setupSingleFile(false, done);
});

gulp.task('test', function(done) {
  var config = {
    configFile: __dirname + '/karma.conf.js',
    singleRun: true
  };
  new Server(config, done).start();
});

gulp.task('watch', function(done) {
  new Server({
    configFile: __dirname + '/karma.conf.js'
  }, done).start();
});