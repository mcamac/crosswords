$ ->
	ws = new WebSocket("ws://#{location.hostname}:#{location.port}#{location.pathname}/sub")


	ws.onmessage = (msg) ->
		data = JSON.parse msg.data
		console.log data

		if data.type == 'client chat message'
			console.log (data.name + ':' + data.content)
			$('#chat_box').append "<p><b>#{data.name}</b>: #{data.content}</p>"

			# scroll to bottom of chatbox
			el = $('#chat_box')[0]
			el.scrollTop = el.scrollHeight - $(el).height

		if data.type == 'room chat message'
			$('#chat_box').append "<p><i>#{data.content}</i></p>"

		if data.type == 'new puzzle'
			make_puzzle data.content

	sendChatMessage = (message) ->
		ws.send JSON.stringify {
			type: 'client chat message'
			content: message
		}

	make_puzzle = (contents) ->
		$('#across_clues').empty()
		$('#down_clues').empty()
		for num, clue of contents.clues.across
			$('#across_clues').append "<li><div class=\"num\"> #{num} </div> <div class=\"clue-text\"> #{clue} </div></li>"
		for num, clue of contents.clues.down
			$('#down_clues').append "<li><div class=\"num\"> #{num} </div> <div class=\"clue-text\"> #{clue} </div></li>"

	# Chat functions
	$('#chat_input').on 'keyup', (e) ->
		if e.keyCode == 13
			sendChatMessage $(@).val()
			$(@).val ''


	# Crossword SVG variables
	grid_lines = []
	grid_size = 540

	numbers = []

	puzzle_size = 15

	square_size = grid_size / (1.0 * puzzle_size)

	letters = {}

	clues = {
		down: {}
		across: {}
	}

	cursors = []

	paper = Raphael "crossword_canvas", grid_size + 2, grid_size + 2
	# background = paper.rect 0, 0, grid_size, grid_size

	# Draw and format grid lines
	for offset in [0..puzzle_size]
		pxoff = square_size * offset + 0.5
		grid_lines.push paper.path "M#{pxoff},0.5v#{grid_size}"
		grid_lines.push paper.path "M0.5,#{pxoff}h#{grid_size}"

	for line in grid_lines
		line.attr {
			stroke: '#ddd'
			'stroke-width': 1
		}
	
	# Draw and format puzzle numbers
	for i in [0..puzzle_size-1]
		for j in [0..puzzle_size-1]
			paper.text(square_size * j + 2, square_size * i + 8, i * j)
				 .attr {
				 	'text-anchor': 'start'
				 }

	# Handle uploads
	$('#fileupload').fileupload {
		dataType: 'json'
		add: (e, data) ->
			console.log data
			data.submit()
		done: (e, data) ->
			console.log 'done'
	}

	$('#upload_button').click (e) ->
		e.preventDefault()
