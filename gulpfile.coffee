gulp    = require('gulp')
runseq  = require('run-sequence')
install = require('gulp-install')
debug   = require('gulp-debug')
jade    = require('gulp-jade')
coffee  = require('gulp-coffee')
stylus  = require('gulp-stylus')
nib     = require('nib')
ngtmpl  = require('gulp-angular-templatecache')
ngmin   = require('gulp-ngmin')
jsmin   = require('gulp-uglify')
cssmin  = require('gulp-minify-css')
concat  = require('gulp-concat')
usemin  = require('gulp-usemin')
rev     = require('gulp-rev')
clean   = require('gulp-clean')
connect = require('gulp-connect')

paths =
  templates:   ['app/**/*.jade',   '!app/bower_components/**/*.jade']
  scripts:     ['app/**/*.coffee', '!app/bower_components/**/*.coffee']
  stylesheets: ['app/app.styl']

gulp.task 'install', ->
  gulp.src(['package.json', 'bower.json'])
      .pipe(install())

gulp.task 'build-remove', ->
  gulp.src('build/**/*', read: false)
      .pipe(clean())

gulp.task 'build-bower-components', ->
  gulp.src('app/bower_components/**/*')
      .pipe(gulp.dest('build/bower_components'))

gulp.task 'build-templates', ->
  gulp.src(paths.templates)
      .pipe(connect.reload())
      .pipe(jade())
      .pipe(gulp.dest('build'))

gulp.task 'build-scripts', ->
  gulp.src(paths.scripts)
      .pipe(connect.reload())
      .pipe(coffee())
      .pipe(gulp.dest('build'))

gulp.task 'build-stylesheets', ->
  gulp.src(paths.stylesheets)
      .pipe(connect.reload())
      .pipe(stylus(use: [nib()]))
      .pipe(gulp.dest('build'))

gulp.task 'dist-remove', ->
  gulp.src('dist/**/*', read: false)
      .pipe(clean())

gulp.task 'dist-copy-build', ->
  gulp.src('build/**/*')
      .pipe(gulp.dest('dist'))

gulp.task 'dist-cache-templates', ->
  gulp.src([
      'dist/*/**/*.html'
      '!dist/bower_components/**/*.html'
    ])
      .pipe(ngtmpl(module: 'AngularApplicationBoilerplate'))
      .pipe(gulp.dest('dist'))

gulp.task 'dist-concat-templates', ->
  gulp.src([
      'dist/app.js'
      'dist/templates.js'
    ])
      .pipe(concat('app.js'))
      .pipe(gulp.dest('dist'))

gulp.task 'dist-min', ->
  gulp.src('dist/index.html')
      .pipe(usemin(
        css: [cssmin(), rev()]
        js: [ngmin(), jsmin(), rev()]
      ))
      .pipe(gulp.dest('dist'))

gulp.task 'dist-clean', ->
  gulp.src([
    'dist/bower_components/**/*'
    'dist/*/**/*.html'
    'dist/*/**/*.js'
    'dist/*/**/*.css'
    'dist/app.js'
    'dist/templates.js'
    'dist/app.css'
  ], read: false)
      .pipe(clean())

gulp.task 'build', (callback) ->
  runseq 'build-remove',
         ['build-bower-components', 'build-templates', 'build-stylesheets', 'build-scripts'],
         callback

gulp.task 'dist', (callback) ->
  runseq 'dist-remove',
         'build',
         'dist-copy-build',
         'dist-cache-templates',
         'dist-concat-templates',
         'dist-min',
         'dist-clean',
         callback

gulp.task 'server', ->
  connect.server
    root: 'build'
    port: 3001
    livereload: true

gulp.task 'watch', ->
  gulp.watch(paths.templates,   ['build-templates'])
  gulp.watch(paths.scripts,     ['build-scripts'])
  gulp.watch(paths.stylesheets, ['build-stylesheets'])

gulp.task 'default', ['install', 'build', 'server', 'watch']
