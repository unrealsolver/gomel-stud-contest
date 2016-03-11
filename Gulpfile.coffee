gulp = require 'gulp'
jade = require 'gulp-jade'
sass = require 'gulp-sass'
coffee = require 'gulp-coffee'
server = require 'gulp-develop-server'

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

gulp.task 'server:start', ->
  server.listen {path: './server.coffee'}

gulp.task 'copy-libs', ->
  gulp.src './node_modules/jquery/dist/jquery.js'
    .pipe gulp.dest DEST + 'scripts/lib/'
  gulp.src './node_modules/lodash/**/*'
    .pipe gulp.dest DEST + 'scripts/lib/lodash/'

gulp.task 'copy-quiz', ->
  gulp.src './src/cssTests/**/*'
    .pipe gulp.dest DEST + '/cssTests/'

gulp.task 'copy-tasks', ->
  gulp.src './src/tasks/*'
    .pipe gulp.dest DEST + '/tasks/'

gulp.task 'watch', ->
  gulp.watch './src/**/*.jade', ['jade']
  gulp.watch './src/**/*.sass', ['sass']
  gulp.watch './src/**/*.coffee', ['coffee']
  gulp.watch './server.coffee', server.restart

gulp.task 'default', ['jade', 'sass', 'coffee', 'copy-libs', 'copy-quiz', 'copy-tasks', 'server:start', 'watch']
