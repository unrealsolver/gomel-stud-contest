gulp = require 'gulp'
jade = require 'gulp-jade'
sass = require 'gulp-sass'
coffee = require 'gulp-coffee'

DEST = './dist/'

gulp.task 'jade', ->
  gulp.src './src/**/*.jade'
    .pipe jade()
    .pipe gulp.dest DEST

gulp.task 'sass', ->
  gulp.src './src/**/*.sass'
    .pipe sass()
    .pipe gulp.dest DEST

gulp.task 'coffee', ->
  gulp.src './src/**/*.coffee'
    .pipe coffee()
    .pipe gulp.dest DEST
  gulp.src './server.coffee'
    .pipe coffee()
    .pipe gulp.dest './'

gulp.task 'copy-libs', ->
  gulp.src './node_modules/jquery/dist/jquery.js'
    .pipe gulp.dest DEST + 'scripts/lib/'

gulp.task 'watch', ->
  gulp.watch './src/**/*.jade', ['jade']
  gulp.watch './src/**/*.sass', ['sass']
  gulp.watch './src/**/*.coffee', ['coffee']
  gulp.watch './server.coffee', ['coffee']

gulp.task 'default', ['jade', 'sass', 'coffee', 'copy-libs', 'watch']
