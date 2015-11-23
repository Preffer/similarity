'use strict'

$ ->
	sliderConfig =
		'scale':
			'control': '#scale'
			'value': '#scaleValue'
		'length':
			'control': '#length'
			'value': '#lengthValue'

	$.each sliderConfig, (name, config)->
		$(config.control).slider().on 'slide', (slider)->
			$(config.value).text(slider.value)

	$('#target img').click ->
		$('#target input[type="file"]').click()

	$('#target input[type="file"]').change ->
		setTarget(@files[0]) if @files.length

	$('#add button').click ->
		$('#add input').click()

	$('#add input').change ->
		addCase(@files)

	$('.dropable').on 'dragenter', (event)->
		$(this).addClass 'dragover'

	$('.dropable').on 'dragover', (event)->
		event.preventDefault()

	$('#target').on 'drop', (event)->
		event.preventDefault()
		$(this).removeClass 'dragover'
		files = event.originalEvent.dataTransfer.files
		setTarget(files[0]) if files.length

	$('#case').on 'drop', (event)->
		event.preventDefault()
		$(this).removeClass 'dragover'
		addCase(event.originalEvent.dataTransfer.files)

	preview = (file, img)->
		reader = new FileReader()
		reader.onload = (event)->
			$(img).attr('src', event.target.result)
		reader.readAsDataURL(file)

	targetHash = ''
	rowCount = 0

	setTarget = (file)->
		preview(file, '#target img')

		form = new FormData()
		$.each sliderConfig, (name, config)->
			form.append(name, $(config.control).slider('getValue'))
		form.append('file', file)

		xhr = new XMLHttpRequest()
		xhr.open('post', '/run')
		xhr.onload = (event)->
			$('#add, #case').fadeIn()
			$('#case .list-group-item').not("#header").remove()
			targetHash = JSON.stringify(JSON.parse(@responseText).hash)
			rowCount = 0

		xhr.onerror = (event)->
			console.error(this, event)
			alert("Error: #{JSON.stringify(event)}")

		xhr.send(form)

	addCase = (files)->
		Array.prototype.forEach.call files, (file)->
			index = rowCount++
			rowData =
				'id': "case#{index}"
			$('#case').append(tmpl('tmpl-row', rowData))
			preview(file, "#case#{index} img")

			form = new FormData()
			$.each sliderConfig, (name, config)->
				form.append(name, $(config.control).slider('getValue'))
			form.append('target', targetHash)
			form.append('file', file)

			xhr = new XMLHttpRequest()
			xhr.open('post', '/run')
			xhr.onload = (event)->
				response = JSON.parse(@responseText)
				percentage = Math.round(response.similarity * 100)

				$("#case#{index} .caption").html(file.name)
				$("#case#{index} .percentage").text("#{percentage}%")
				$("#case#{index} .progress-bar-success").css('width', "#{percentage}%")
				$("#case#{index} .similarity").css('margin', "#{($("#case#{index} .image").height() - $("#case#{index} .similarity").height()) / 2}px auto")

			xhr.onerror = (event)->
				console.error(this, event)
				alert("Error: #{JSON.stringify(event)}")

			xhr.upload.addEventListener 'progress', (event)->
				if event.lengthComputable
					percentage = Math.round((event.loaded / event.total * 100))
					$("#case#{index} .progress-bar-primary").css('width', "#{percentage}%")

			xhr.send(form)
