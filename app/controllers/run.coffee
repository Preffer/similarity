'use strict'

multipart = require 'connect-multiparty'
pHash = require '../models/pHash'
fs = require 'fs'

module.exports = (app) ->
	app.post '/run', multipart(), (req, res)->
		if req.files.file and req.body.scale and req.body.length
			pHash.pHash req.files.file.path, parseInt(req.body.scale), parseInt(req.body.length), (error, hash)->
				if error
					res.status(500)
					res.json(error)
					cleanup()
				else
					response = {hash: Array.prototype.slice.call(hash)}
					if req.body.target
						response.distance = pHash.distance(JSON.parse(req.body.target), hash)
					res.json(response)
					cleanup()
		else
			res.status(500).end()
			cleanup()

		cleanup = ->
			fs.unlink(file.path) for file in req.files
