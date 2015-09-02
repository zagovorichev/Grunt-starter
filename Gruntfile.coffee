module.exports = (grunt) ->

  ###Force use of Unix newlines###
  grunt.util.linefeed = '\n'

  ### Load all dependencies ###
  ### npm install load-grunt-task --save-dev ###
  require('load-grunt-tasks')(grunt, { scope: 'devDependencies' })

  ### add compress filters ###
  ### i imagemin-pngquant ###
  pngquant = require('imagemin-pngquant')

  ###Time how long tasks take. Can help when optimizing build times###
  ### i time-grunt ###
  require('time-grunt')(grunt);

  ### like a gzip for web connections ###
  ### i compression ###
  compression = require('compression');

  grunt.initConfig

    pkg: grunt.file.readJSON('package.json')

    ### i grunt-banner ###
    banner: '/**!\n' +
      ' * RSW v<%= pkg.version %> (<%= pkg.homepage %>)\n' +
      ' * <%= pkg.description %>' +
      ' * Copyright <%= grunt.template.today("yyyy") %> <%= pkg.author %>\n' +
      ' * - <%= pkg.email %>\n' +
      ' */\n'

    ### i ###
    clean:
      dist: "release"
      build: "build"
      index: "index.html"

    ### copy files in build ###
    copy:
      favicon:
        expand: true
        cwd: 'src/img/'
        src: ['favicon.ico']
        dest: 'build/static/img'

    ### i grunt-contrib-jade ###
    jade:
      build:
        options:
          pretty: true
          namespace: "html.templates"
          data: () ->
            require "./src/data/dev/defines.json"
        files:
          "index.html": "src/jade/index.jade"

    ### i grunt-contrib-imagemin ###
    imagemin:
      static:
        options:
          optimizationLevel: 6
          progressive: true
          use: [pngquant()]
        files:[{
          expand: true,
          cwd: "src/",
          src: "img/**/*.{png,jpg,gif}",
          dest: "build/static/img"
        }]

    ### Create web server ###
    ### i grunt-contrib-connect ###
    connect:
      dev:
        options:
          port: 8000
          protocol: 'http'
          hostname: '*'
          base: './'
          open: true
          debug: true
          middleware: (connect, options, middlewares) ->
            middlewares.unshift(compression())
            middlewares


    ### Live reload watcher ###
    ### i grunt-contrib-watch ###
    watch:
      jade:
        files: ["src/jade/**/*.jade"]
        tasks: ['jade']
        options:
          livereload: true
      data:
        files: ["src/data/dev/**/*.*"]
        tasks: ['jade']
        options:
          livereload: true

  grunt.registerTask 'content', "Create DOM (HTML) + bower dependencies", ['newer:jade']
  grunt.registerTask 'images', "Compress images, create sprites", ['newer:imagemin']

  grunt.registerTask 'build', 'Build and RUN application', ['content', 'newer:copy', 'images']
  grunt.registerTask 'serve', 'Run web server for auto view results of the developments', ['build', 'connect:dev', 'watch']
  grunt.registerTask 'default', 'Just alias to main grunt compile [serve]', ['serve']
