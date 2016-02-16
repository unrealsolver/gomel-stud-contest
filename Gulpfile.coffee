gulp = require 'gulp'
jade = require 'gulp-jade'

DEST = './dist/'

gulp.task 'jade', ->
  gulp.src './src/**/*.jade'
    .pipe jade()
    .pipe gulp.dest DEST

gulp.task 'watch', ->
  gulp.watch './src/**/*.jade', ['jade']

gulp.task 'default', ['jade', 'watch']
