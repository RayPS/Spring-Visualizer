var gulp = require('gulp');
var plumber = require('gulp-plumber');
var rename = require('gulp-rename');
var coffee = require('gulp-coffee');
var sourcemaps = require('gulp-sourcemaps');
var coffeelint = require('gulp-coffeelint');
var jshint = require('gulp-jshint');
var browserSync = require('browser-sync');

var htmlPath = 'HTML/'

gulp.task('browser-sync', function() {
  browserSync({
    open: false,
    browser: "google chrome",
    ghostMode: false,
    server: {
      baseDir: htmlPath
        // routes: {"/url": "path"}
    }
  });
});

gulp.task('bs-reload', function() {
  browserSync.reload();
});

gulp.task('coffee', function() {
  console.log("\n ========================================\n")
  return gulp.src('spring-visualizer.framer/app.coffee')
    .pipe(plumber({
      errorHandler: function(error) {
        console.log(error.message);
        this.emit('end');
      }
    }))
    .pipe(coffeelint({
      opt: {
        no_tabs: { level: 'ignore' },
        max_line_length: { level: 'ignore' },
        indentation: { value: 1 }
      }
    }))
    .pipe(coffeelint.reporter())
    .pipe(sourcemaps.init())
    .pipe(coffee({
      bare: true
    }))
    // .pipe(sourcemaps.write())
    .pipe(gulp.dest(htmlPath))
    .pipe(browserSync.reload({
      stream: true
    }))
});

gulp.task('copy-files', function() {
  gulp.src('spring-visualizer.framer/framer/framer.js')
    .pipe(gulp.dest(htmlPath))
})

gulp.task('default', ['browser-sync', 'coffee', 'copy-files'], function() {
  gulp.watch('spring-visualizer.framer/app.coffee', ['coffee', 'bs-reload']);
  gulp.watch('index.html', ['bs-reload']);
});
