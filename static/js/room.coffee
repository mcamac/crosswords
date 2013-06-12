$ ->
	ws = new WebSocket("ws://#{location.hostname}:#{location.port}#{location.pathname}/sub")

	# # send localstorage username, if exists
	# if localStorage.username
	# 	ws.send JSON.stringify {
	# 		type: 'change username'
	# 		content: localStorage.username
	# 	}

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

	blacken_square = (i, j) ->
		if black_squares[i][j]
			black_squares[i][j].remove()

		black_squares[i][j] = 
			paper.rect(j * square_size+0.5, i * square_size+0.5, square_size, square_size)
				 .attr(
				 	fill: '#333'
				 )

	has_number = (p, i, j) ->
		# console.log p[i][j]
		if p[i][j] == '_'
			return false
		if i == 0 or j == 0
			return true
		if p[i-1][j] == '_' or p[i][j-1] == '_'
			return true
		return false

	make_puzzle = (contents) ->

		puzzle = contents
		p = puzzle.puzzle

		console.log JSON.stringify contents

		puzzle_size = puzzle.height
		square_size = grid_size / (1.0 * puzzle_size)

		reset_puzzle()
		
		for num, clue of contents.clues.across
			$('#across_clues').append "<li><div class=\"num\"> #{num} </div> <div class=\"clue-text\"> #{clue} </div></li>"
		for num, clue of contents.clues.down
			$('#down_clues').append "<li><div class=\"num\"> #{num} </div> <div class=\"clue-text\"> #{clue} </div></li>"

		for i in [0..puzzle_size-1]
			for j in [0..puzzle_size-1]
				if puzzle.puzzle[i][j] == '_'
					blacken_square i, j

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
		current_number = 1
		for i in [0..puzzle_size-1]
			for j in [0..puzzle_size-1]
				if has_number p,i,j 
					# console.log "#{i} #{j} #{p[i][j]}"
					numbers.push paper.text(
						square_size * j + 2, 
						square_size * i + 8, 
						current_number)
						 .attr {
						 	'text-anchor': 'start'
						 }
					current_number += 1

	# Chat functions
	$('#chat_input').on 'keyup', (e) ->
		if e.keyCode == 13
			sendChatMessage $(@).val()
			$(@).val ''

	# Room members box

	# Crossword SVG variables
	grid_lines = []
	grid_size = 540

	numbers = []

	puzzle_size = 15

	p = {}

	square_size = grid_size / (1.0 * puzzle_size)

	letters = {}

	clues = {
		down: {}
		across: {}
	}

	cursors = []

	black_squares = {}

	paper = Raphael "crossword_canvas", grid_size + 2, grid_size + 2
	# background = paper.rect 0, 0, grid_size, grid_size

	reset_puzzle = ->
		# Initialize black squares
		for i in [0..puzzle_size - 1]
			black_squares[i] = {}
			for j in [0..puzzle_size - 1]
				black_squares[i][j] = null

		
		
		

		$('#across_clues').empty()
		$('#down_clues').empty()

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

	$.getJSON '/static/puzzle.json', (data) ->
		make_puzzle data
