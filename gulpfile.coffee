gulp   = require 'gulp'
coffee = require 'gulp-coffee'
bump   = require 'gulp-bump'

gulp.task 'coffee', ->
    gulp.src 'index.coffee'
        .pipe coffee bare: true
        .pipe gulp.dest '.'

gulp.task 'bump', ->
    gulp.src 'package.json'
        .pipe bump()
        .pipe gulp.dest '.'

gulp.task 'default', ->            
    gulp.watch 'index.coffee', ['coffee']                
