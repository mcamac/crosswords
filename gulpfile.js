var gulp = require('gulp');
var coffee = require('gulp-coffee');
var concat = require('gulp-concat');

var paths = {
  scripts: ['client/static/js/**/*.coffee', 'shared/**/*.coffee']
};

gulp.task('scripts', function () {
  return gulp.src(paths.scripts)
    .pipe(concat('all.coffee'))
    .pipe(coffee())
    .pipe(gulp.dest('client/static/js'))
});


gulp.task('watch', function () {
  gulp.watch(paths.scripts, ['scripts']);
});
