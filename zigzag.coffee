'use strict'

module.exports = (width, height, count, callback)->
	angle = 45
	row = 0
	col = 0

	move = (angle)->
		switch angle
			when 45
				row--
				col++
			when 0
				col++
			when -90
				row++
			when -135
				row++
				col--

	for i in [0...count]
		callback(row, col, i)

		switch angle
			when 45
				if row - 1 < 0
					angle = 0
				if col + 1 >= width
					angle = -90
			when 0
				if row == 0
					angle = -135
				else
					if row == height - 1
						angle = 45
			when -90
				if col == 0
					angle = 45
				else
					if col == width - 1
						angle = -135
			when -135
				if col - 1 < 0
					angle = -90
				if row + 1 >= height
					angle = 0

		move(angle)
