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

config = require('./config.json')

gulp.task 'install', ->
  gulp.src(['package.json', 'bower.json'])
      .pipe(install())

gulp.task 'build-remove', ->
  gulp.src('build/**/*', read: false)
      .pipe(clean())

gulp.task 'build-bower-files', ->
  for component, files of config.bowerFiles
    for source, destination of files
      source = "bower_components/#{component}/#{source}"
      destination = "build/#{destination}"
      gulp.src(source)
          .pipe(gulp.dest(destination))

gulp.task 'build-copy-templates', ->
  gulp.src(config.paths.templates.watch)
      .pipe(gulp.dest('build'))

gulp.task 'build-copy-scripts', ->
  gulp.src(config.paths.scripts.watch)
      .pipe(gulp.dest('build'))

gulp.task 'build-copy-stylesheets', ->
  gulp.src(config.paths.stylesheets.watch)
      .pipe(gulp.dest('build'))

gulp.task 'build-compile-templates', ->
  gulp.src(config.paths.templates.compile)
      .pipe(connect.reload())
      .pipe(jade())
      .pipe(gulp.dest('build'))

gulp.task 'build-compile-scripts', ->
  gulp.src(config.paths.scripts.compile)
      .pipe(connect.reload())
      .pipe(coffee())
      .pipe(gulp.dest('build'))

gulp.task 'build-compile-stylesheets', ->
  gulp.src(config.paths.stylesheets.compile)
      .pipe(connect.reload())
      .pipe(stylus(use: [nib()]))
      .pipe(gulp.dest('build'))

gulp.task 'build-templates', (callback) ->
  runseq 'build-copy-templates',
         'build-compile-templates',
          callback

gulp.task 'build-scripts', (callback) ->
  runseq 'build-copy-scripts',
         'build-compile-scripts',
          callback

gulp.task 'build-stylesheets', (callback) ->
  runseq 'build-copy-stylesheets',
         'build-compile-stylesheets',
          callback

gulp.task 'build-clean', ->
  gulp.src([
    'build/**/*.jade'
    'build/**/*.coffee'
    'build/**/*.styl'
  ], read: false)
      .pipe(clean())

gulp.task 'dist-remove', ->
  gulp.src('dist/**/*', read: false)
      .pipe(clean())

gulp.task 'dist-copy-build', ->
  gulp.src('build/**/*')
      .pipe(gulp.dest('dist'))

gulp.task 'dist-cache-templates', ->
  gulp.src([
      'dist/*/**/*.html'
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
         'build-bower-files',
         ['build-templates', 'build-scripts', 'build-stylesheets'],
         'build-clean',
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
  gulp.watch(config.paths.templates.watch,   ['build-templates'])
  gulp.watch(config.paths.scripts.watch,     ['build-scripts'])
  gulp.watch(config.paths.stylesheets.watch, ['build-stylesheets'])

gulp.task 'default', (callback) ->
  runseq 'install',
         ['build', 'server'],
         'watch',
         callback
