'use strict'

request = require('request')

module.exports = (grunt) ->
	require('time-grunt')(grunt)
	require('load-grunt-tasks')(grunt)
	reloadPort = 35729

	jadeFiles =
		'app/views/index.html': 'app/views/index.jade'

	lessFiles =
		'public/css/style.css': 'public/css/style.less'

	coffeeFiles =
		'public/js/script.js': 'public/js/script.coffee'

	uglifyFiles =
		'public/js/script.js': 'public/js/script.js'

	grunt.initConfig
		pkg:
			grunt.file.readJSON('package.json')
		develop:
			server:
				file: 'app.js'
		jade:
			development:
				options:
					pretty: true
				files: jadeFiles
			production:
				options:
					pretty: false
				files: jadeFiles
		less:
			development:
				options:
					compress: false
					ieCompat: false
				files: lessFiles
			production:
				options:
					compress: true
					ieCompat: false
				files: lessFiles
		coffee:
			development:
				files: coffeeFiles
			production:
				files: coffeeFiles
		watch:
			options:
				spawn: false
				livereload: reloadPort
			server:
				files: ['app.js', 'app/**/*.coffee', 'config/*.coffee']
				tasks: ['develop', 'delayed-livereload']
			jade:
				files: ['app/views/*.jade']
				tasks: ['jade:development']
			css:
				files: ['public/css/*.less']
				tasks: ['less:development']
			js:
				files: ['public/js/*.coffee']
				tasks: ['coffee:development']

		uglify:
			production:
				options:
					screwIE8: true
				files: uglifyFiles

	grunt.config.requires 'watch.server.files'
	files = grunt.config('watch.server.files')
	files = grunt.file.expand(files)

	grunt.registerTask 'delayed-livereload', 'Live reload after the node server has restarted.', ->
		done = @async()
		setTimeout ->
			request.get "http://localhost:#{reloadPort}/changed?files=#{files.join(',')}", (err, res) ->
				reloaded = !err and res.statusCode == 200
				if reloaded
					grunt.log.ok 'Delayed live reload successful.'
				else
					grunt.log.error 'Unable to make a delayed live reload.'
				done reloaded
		, 500

	grunt.registerTask 'default', ['jade:development', 'less:development', 'coffee:development', 'develop', 'watch']
	grunt.registerTask 'release', ['jade:production', 'less:production', 'coffee:production', 'uglify']
