pHash = require './pHash'

hashes = new Array(10)
similarity = new Array(9)

done = 0

[0...10].forEach (i)->
	pHash.pHash "10images/#{i}.jpg", 64, 64, (error, hash)->
		hashes[i] = hash
		if ++done == 10
			[1...10].forEach (i)->
				similarity[i - 1] = pHash.distanceSquared(hashes[0], hashes[i])
			console.log(similarity)