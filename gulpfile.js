var gulp = require('gulp');
var plumber = require('gulp-plumber');
var rename = require('gulp-rename');
var coffee = require('gulp-coffee');
var coffeelint = require('gulp-coffeelint');
var browserSync = require('browser-sync');

var projectPath = "project.framer"
var htmlPath = 'HTML'

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
  return gulp.src(projectPath + '/app.coffee')
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
    .pipe(coffee({
      bare: true
    }))
    .pipe(gulp.dest(htmlPath))
    .pipe(browserSync.reload({
      stream: true
    }))
});

gulp.task('copy-files', function() {
  gulp.src(projectPath + '/framer/framer.js')
    .pipe(gulp.dest(htmlPath))
})

gulp.task('default', ['browser-sync', 'coffee', 'copy-files'], function() {
  gulp.watch(projectPath + '/app.coffee', ['coffee', 'bs-reload']);
  gulp.watch('index.html', ['bs-reload']);
});
