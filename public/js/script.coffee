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
		if $(config.control).length
			$(config.control).slider().on 'slide', (slider)->
				$(config.value).text(slider.value)

	$('.dropable').on 'dragenter', (event)->
		$(this).addClass 'dragover'

	$('.dropable').on 'dragleave', (event)->
		$(this).removeClass 'dragover'

	$('.dropable').on 'dragover', (event)->
		event.preventDefault()

	preview = (file, img)->
		reader = new FileReader()
		reader.onload = (event)->
			$(img).attr('src', event.target.result)
		reader.readAsDataURL(file)

	$('#target img').click ->
		$('#target input[type="file"]').click()

	targetHash = ''
	indexCount = 0
	$('#target input[type="file"]').change ->
		if @files.length
			preview(@files[0], '#target img')

			form = new FormData()
			$.each sliderConfig, (name, config)->
				if $(config.control).length
					form.append(name, $(config.control).slider('getValue'))
			form.append('file', @files[0])

			xhr = new XMLHttpRequest()
			xhr.open('post', '/run')

			xhr.onload = (event)->
				targetHash = JSON.stringify(JSON.parse(@responseText).hash)
				$('#add-image').fadeIn()
				$('#case .list-group-item').not("#header").remove()
				indexCount = 0
			xhr.onerror = (event)->
				console.error(this, event)
			xhr.send(form)

	$('#add-image').click ->
		$('#add-file').click()

	$('#add-file').change ->
		$.each @files, (_, file)->
			index = indexCount++
			rowData =
				'id': "case#{index}"
			$('#case').append(tmpl('tmpl-row', rowData))
			preview(file, "#case#{index} img")

			form = new FormData()
			$.each sliderConfig, (name, config)->
				if $(config.control).length
					form.append(name, $(config.control).slider('getValue'))
			form.append('target', targetHash)
			form.append('file', file)

			xhr = new XMLHttpRequest()
			xhr.open('post', '/run')

			xhr.onload = (event)->
				console.log(this, event)
				response = JSON.parse(@responseText)
				percentage = Math.round(response.similarity * 100)
				$("#case#{index} .below-image").html(file.name)
				$("#case#{index} .similarity").text("#{percentage}%")
				$("#case#{index} .progress-bar-success").css('width', "#{percentage}%")
				console.log(index, $("#case#{index} .part1").height())
				$("#case#{index} .part2").css('margin-top', "#{($("#case#{index} .part1").height() - $("#case#{index} .part2").height()) / 2}px")
			xhr.onerror = (event)->
				console.error(this, event)

			xhr.upload.addEventListener 'progress', (event)->
				if event.lengthComputable
					percentage = Math.round((event.loaded / event.total * 100))
					$("#case#{index} .progress-bar-primary").css('width', "#{percentage}%")

			xhr.send(form)

	'''
	previewConfig =
		'color':
			'selector': '#color'
			'img': '#color img'
			'input': '#color input'
		'watermark':
			'selector': '#watermark'
			'img': '#watermark img'
			'input': '#watermark input'
		'watermarked':
			'selector': '#watermarked'
			'img': '#watermarked img'
			'input': '#watermarked input'

	$.each previewConfig, (name, config)->
		if $(config.selector).length
			$(config.img).click ->
				$(config.input).click()

			$(config.input).change ->
				preview(@files[0], name) if @files.length

			$(config.selector).on 'drop', (event)->
				event.preventDefault()
				$(this).removeClass('dragover')
				files = event.originalEvent.dataTransfer.files
				preview(files[0], name) if files.length

	$('#run').on 'click', (event)->
		button = $(this)
		buttonText = button.text()
		button.attr('disabled', true).text('Running 0s')
		$('#result').slideUp()

		elapsed = 0
		handle = setInterval ->
			button.text("Running #{++elapsed}s")
		, 1000

		form = new FormData()
		$.each sliderConfig, (name, config)->
			if $(config.control).length
				form.append(name, $(config.control).slider('getValue'))

		$.each previewConfig, (name, config)->
			if $(config.selector).length
				form.append(name, config.file)

		xhr = new XMLHttpRequest()
		xhr.open('post', "#{path}/run")

		xhr.onload = (event)->
			clearInterval(handle)
			console.log(this, event)

			location = JSON.parse(@responseText).location
			$('#result img').attr('src', location)
			$('#result a').attr('href', location)
			$('#result').slideDown()
			button.removeAttr('disabled').text(buttonText)

		xhr.onerror = (event)->
			clearInterval(handle)
			console.error(this, event)

			alert("Error: #{JSON.stringify(event)}")
			button.removeAttr('disabled').text(buttonText)

		xhr.send(form)
		'''
