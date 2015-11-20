'use strict'
jimp = require 'jimp'
dct = require './dct'
zigzag = require './zigzag'

module.exports.pHash = (path, scale, length, callback)->
	jimp.read path, (error, image)->
		callback(error, null) if error
		imageDct = dct.dct2(image.resize(scale, scale).greyscale().bitmap.data, scale, scale)
		imageHash = new Float64Array(length)

		zigzag scale, scale, length, (row, col, i)->
			imageHash[i] = imageDct[row * scale + col]

		callback(null, imageHash)

module.exports.distanceSquared = (x, y) ->
	diff = 0
	length = Math.min(x.length, y.length)
	for i in [0...length]
		diff += (x[i] - y[i]) ** 2
	return diff
