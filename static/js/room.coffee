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

	# Crossword SVG variables
	grid_lines = []
	grid_size = 540

	number_text = []
	numbers = {}

	puzzle_size = 15

	background = null

	p = {}

	square_size = grid_size / (1.0 * puzzle_size)

	letters = {}

	ci = 0
	cj = 0

	clues = {
		A: {}
		D: {}
	}

	square_highlight = null
	across_highlight = null
	down_highlight = null


	cursors = []

	black_squares = {}

	paper = Raphael "crossword_canvas", grid_size + 2, grid_size + 2

	USER = 0
	dir = 'A'

	## UI Code
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

	set_square_value = (i, j, char) ->
		if letters[i][j]
			letters[i][j].remove()

		char = char.toUpperCase()

		letters[i][j] = paper.text((j + 0.5) * square_size, (i + 0.55) * square_size, char)
							 .attr(
							 	'font-size': 20
							 	'text-anchor': 'middle'
							 	'font-family': 'Source Sans'
							 	'font-weight': 'normal'
							 )
	valid = (p, i, j) ->
		if i < 0 or j < 0 or i >= puzzle_size or j >= puzzle_size or p[i][j] == '_'
			return false
		return true

	on_board = (i, j) ->
		return i >= 0 and j >= 0 and i < puzzle_size and j < puzzle_size

	get_clue_number = (p, i, j, d) ->
		console.log p,i,j
		if not valid(p, i, j)
			return -1

		if d == 'A'
			while valid p, i, j - 1
				j--
		if d == 'D'
			while valid p, i - 1, j
				i--

		return numbers[i][j]

	flip_dir = ->
		dir = if dir == 'D' then 'A' else 'D'
		rehighlight()
		update_current_clue()

	next_square = (i, j, oi, oj) ->
		tryi = i + oi
		tryj = j + oj
		while not valid(p, tryi, tryj) and on_board(tryi, tryj)
			tryi += oi
			tryj += oj

		if on_board(tryi, tryj)
			return [tryi, tryj]
		return [i, j]


	# keyboard shortcuts
	alpha = 'abcdefghijklmnopqrstuvwxyz'
	for letter in alpha
		key letter, (e) ->
			set_square_value ci, cj, String.fromCharCode(e.keyCode)
			if dir == 'A'
				go_right()
			else
				go_down()

	go_left = ->
		ns = next_square ci, cj, 0, -1
		set_cursor ns[0], ns[1]

	go_right = ->
		ns = next_square ci, cj, 0, 1
		set_cursor ns[0], ns[1]

	go_up = ->
		ns = next_square ci, cj, -1, 0
		set_cursor ns[0], ns[1]

	go_down = ->
		ns = next_square ci, cj, 1, 0
		set_cursor ns[0], ns[1]


	key 'left', go_left
	key 'up', go_up
	key 'right', go_right
	key 'down', go_down

	key 'space', flip_dir

	key 'backspace', (e) ->
		e.preventDefault()
		set_square_value ci, cj, ''
		if dir == 'A' then go_left() else go_up()

		
	rehighlight = ->
		console.log square_highlight		

		acr_sj = cj
		acr_ej = cj
		while valid(p, ci, acr_sj - 1)
			acr_sj--
		while valid(p, ci, acr_ej + 1)
			acr_ej++
		across_highlight.attr {
			width: square_size * (acr_ej - acr_sj + 1)
			x: acr_sj * square_size + 0.5
			y: ci * square_size + 0.5
			fill: if dir == 'A' then '#4f7ec4' else '#eee'
		}

		down_si = ci
		down_ei = ci
		while valid(p, down_si - 1, cj)
			down_si--
		while valid(p, down_ei + 1, cj)
			down_ei++
		down_highlight.attr {
			height: square_size * (down_ei - down_si + 1)
			x: cj * square_size + 0.5
			y: down_si * square_size + 0.5
			fill: if dir == 'D' then '#4f7ec4' else '#eee'
		}

		square_highlight.attr {
			x: cj * square_size + 0.5
			y: ci * square_size + 0.5
		}

	set_cursor = (i, j) ->
		if p[i][j] == '_'
			return
		ci = i
		cj = j
		console.log 'set',ci,cj
		rehighlight()

		# change current clue
		update_current_clue()

	update_current_clue = ->
		number = get_clue_number(p, ci, cj, dir)
		clue = clues[dir][number]
		console.log clue, number, dir
		$('#current_clue').html("#{number}#{dir} - #{clue}")

	make_puzzle = (contents) ->

		puzzle = contents
		p = puzzle.puzzle

		

		$('#puzzle_title').html puzzle.title

		console.log JSON.stringify contents

		puzzle_size = puzzle.height
		square_size = grid_size / (1.0 * puzzle_size)

		clues['A'] = puzzle.clues.across
		clues['D'] = puzzle.clues.down
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
					console.log "#{i} #{j} #{current_number}"
					number_text.push paper.text(
						square_size * j + 2, 
						square_size * i + 8, 
						current_number)
						 .attr {
						 	'text-anchor': 'start'
						 }
					numbers[i][j] = current_number
					current_number += 1

		if background
			background.remove()

		background = paper.rect(0, 0, grid_size, grid_size)
					  .attr {
					  	stroke: 'none'
					  	fill: '#000'
					  	opacity: 0.0
					  }

		background.click (e) ->
			ei = Math.floor e.layerY / square_size
			ej = Math.floor e.layerX / square_size
			if ei == ci and ej == cj
				flip_dir()
			set_cursor ei, ej

		set_cursor 0, 0


	# Chat functions
	$('#chat_input').on 'keyup', (e) ->
		if e.keyCode == 13
			sendChatMessage $(@).val()
			$(@).val ''

	# Room members box

	

	reset_puzzle = ->
		# Initialize black squares
		for i in [0..puzzle_size - 1]
			black_squares[i] = {}
			letters[i] = {}
			numbers[i] = {}
			for j in [0..puzzle_size - 1]
				black_squares[i][j] = null
				letters[i][j] = null
				numbers[i][j] = null

		
		

		if across_highlight
			across_highlight.remove()
		across_highlight = paper.rect(-50,
									  -50,
									  square_size,
									  square_size)
								.attr {
									fill: '#233'
									stroke: 'none'
									opacity: 0.7
								}
		
		if down_highlight
			down_highlight.remove()
		down_highlight = paper.rect(-50,
									  -50,
									  square_size,
									  square_size)
								.attr {
									fill: '#233'
									stroke: 'none'
									opacity: 0.7
								}

		if square_highlight
			square_highlight.remove()
		square_highlight = paper.rect(-50,
									  -50,
									  square_size,
									  square_size)
								.attr {
									fill: '#852'
									stroke: 'none'
									opacity: 0.9
								}

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
