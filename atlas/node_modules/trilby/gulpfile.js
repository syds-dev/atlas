var gulp    = require('gulp'),
    uglify  = require('gulp-uglify'),
    rename  = require('gulp-rename'),
    mocha   = require('gulp-mocha'),
    jsdoc   = require('gulp-jsdoc');

gulp.task('scripts', function() {
    return gulp.src('trilby.js')
        .pipe(rename('trilby.min.js'))
        .pipe(uglify({
            outSourceMap: true,
            preserveComments: 'some'
        }))
        .pipe(gulp.dest('.'));
});

gulp.task('tests', function() {
    return gulp.src('tests/*.spec.js')
        .pipe(mocha({ reporter: 'spec' }));
});

gulp.task('docs', function() {
    gulp.src("./trilby.js")
        .pipe(jsdoc('./docs'));
});

gulp.task('default', ['tests', 'scripts', 'docs']);