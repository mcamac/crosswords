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
		# console.log data

		if data.type == 'client chat message'
			# console.log (data.name + ':' + data.content)
			$('#chat_box').append "<p><b>#{data.name}</b>: #{data.content}</p>"

			# scroll to bottom of chatbox
			$('#chat_box').scrollTop $('#chat_box')[0].scrollHeight

		if data.type == 'room chat message'
			$('#chat_box').append "<p><i>#{data.content}</i></p>"

			# scroll to bottom of chatbox
			$('#chat_box').scrollTop $('#chat_box')[0].scrollHeight

		if data.type == 'new puzzle'
			make_puzzle data.content

		if data.type == 'existing puzzle'
			make_puzzle data.content.puzzle
			fill_existing_letters data.content.grid
			if data.content.complete
				greenBG()

		if data.type == 'change square'
			set_square_value data.content.i, data.content.j, data.content.char, false

		if data.type == 'room members'
			data.content.sort()
			$('#members_box').html data.content.join(', ')

		if data.type == 'puzzle finished'
			greenBG()

	sendChatMessage = (message) ->
		ws.send JSON.stringify {
			type: 'client chat message'
			content: message
		}

	greenBG = ->
		background.attr 'opacity', 0.2

	# Crossword SVG variables
	grid_lines = []
	grid_size = 540

	number_text = {}
	numbers = {}
	numbers_rev = {}

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
		# # console.log p[i][j]
		if p[i][j] == '_'
			return false
		if i == 0 or j == 0
			return true
		if p[i-1][j] == '_' or p[i][j-1] == '_'
			return true
		return false

	new_letter = (i, j, char) ->
		paper.text((j + 0.5) * square_size, (i + 0.55) * square_size, char)
			 .attr(
			 	'font-size': 20
			 	'text-anchor': 'middle'
			 	'font-family': 'Source Sans'
			 	'font-
			 	weight': 'normal'
			 )

	fill_existing_letters = (grid) ->
		for i in [0..puzzle_size-1]
			for j in [0..puzzle_size-1]
				if letters[i][j]
					letters[i][j].remove()
				letters[i][j] = new_letter i, j, grid[i][j]


	set_square_value = (i, j, char, broadcast) ->
		if letters[i][j]
			letters[i][j].remove()

		# console.log letters[i][j], i, j, char
		char = char.toUpperCase()

		letters[i][j] = paper.text((j + 0.5) * square_size, (i + 0.55) * square_size, char)
							 .attr(
							 	'font-size': 20
							 	'text-anchor': 'middle'
							 	'font-family': 'Source Sans'
							 	'font-
							 	weight': 'normal'
							 )
			

	send_set_square_value = (i, j, char) ->
		ws.send JSON.stringify {
			type: 'change square'
			content: {
				i: i
				j: j
				char: char
			}
		}

	valid = (p, i, j) ->
		if i < 0 or j < 0 or i >= puzzle_size or j >= puzzle_size or p[i][j] == '_'
			return false
		return true

	on_board = (i, j) ->
		return i >= 0 and j >= 0 and i < puzzle_size and j < puzzle_size

	get_clue_number = (p, i, j, d) ->
		# console.log p,i,j
		if not valid(p, i, j)
			return -1

		if d == 'A'
			while valid p, i, j - 1
				j--
		if d == 'D'
			while valid p, i - 1, j
				i--

		return numbers[i][j]

	other_dir = (d) ->
		if d == 'D' then 'A' else 'D'
	flip_dir = ->
		dir = other_dir dir
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
	alphanum = 'abcdefghijklmnopqrstuvwxyz0123456789'
	for letter in alphanum
		key letter, (e) ->
			send_set_square_value ci, cj, String.fromCharCode(e.keyCode)
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
		send_set_square_value ci, cj, ''
		if dir == 'A' then go_left() else go_up()

		
	rehighlight = ->
		# console.log square_highlight		

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
			fill: if dir == 'A' then '#4f7ec4' else '#ddd'
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
			fill: if dir == 'D' then '#4f7ec4' else '#ddd'
		}

		square_highlight.attr {
			x: cj * square_size + 0.5
			y: ci * square_size + 0.5
		}

		if letters[ci][cj]
			letters[ci][cj].attr 'fill', 'white'

		if numbers[ci][cj]
			number_text[ci][cj].attr 'fill', 'white'

	set_cursor = (i, j) ->
		if p[i][j] == '_'
			return
		if letters[ci][cj]
			letters[ci][cj].attr 'fill', 'black'

		if number_text[ci][cj]
			number_text[ci][cj].attr 'fill', 'black'
		ci = i
		cj = j
		# console.log 'set',ci,cj
		rehighlight()

		# change current clue
		update_current_clue()

	update_current_clue = ->
		number = get_clue_number(p, ci, cj, dir)
		other_number = get_clue_number(p, ci, cj, other_dir dir)

		$('.li-clue').removeClass 'active'
		$('.li-clue').removeClass 'semi-active'
		$(".li-clue[data-clue-id=#{dir}#{number}]").addClass 'active'
		$(".li-clue[data-clue-id=#{other_dir dir}#{other_number}]").addClass 'semi-active'
		$("##{dir}_clues").scrollTo ".li-clue[data-clue-id=#{dir}#{number}]", 75
		$("##{other_dir dir}_clues").scrollTo ".li-clue[data-clue-id=#{other_dir dir}#{other_number}]", 75
		
		# console.log clue, number, dir

		clue = clues[dir][number]
		$('#current_clue').html("#{number}#{dir} - #{clue}")

	make_puzzle = (contents) ->

		puzzle = contents
		p = puzzle.puzzle

		

		$('#puzzle_title').html puzzle.title

		# console.log JSON.stringify contents

		puzzle_size = puzzle.height
		square_size = grid_size / (1.0 * puzzle_size)

		clues['A'] = puzzle.clues.across
		clues['D'] = puzzle.clues.down
		reset_puzzle()
		
		for num, clue of contents.clues.across
			$('#A_clues').append "<li class='li-clue' data-clue-id=A#{num}><div class=\"num\"> #{num} </div> <div class=\"clue-text\"> #{clue} </div></li>"
		for num, clue of contents.clues.down
			$('#D_clues').append "<li class='li-clue' data-clue-id=D#{num}><div class=\"num\"> #{num} </div> <div class=\"clue-text\"> #{clue} </div></li>"

		# set up events for clicking
		$('.li-clue').on 'click', (e) ->
			clue_id = $(this).data('clue-id')
			ns = numbers_rev[clue_id]
			if clue_id[0] != dir
				flip_dir()
			set_cursor ns[0], ns[1]

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
					# console.log "#{i} #{j} #{current_number}"
					number_text[i][j] = paper.text(
						square_size * j + 2, 
						square_size * i + 8, 
						current_number)
						 .attr {
						 	'text-anchor': 'start'
						 }
					numbers[i][j] = current_number
					numbers_rev['A'+current_number] = [i, j]
					numbers_rev['D'+current_number] = [i, j]
					current_number += 1

		if background
			background.remove()

		background = paper.rect(0, 0, grid_size, grid_size)
					  .attr {
					  	stroke: 'none'
					  	fill: '#62cb62'
					  	opacity: 0.0
					  }

		background.click (e) ->
			ei = Math.floor e.layerY / square_size
			ej = Math.floor e.layerX / square_size
			if ei == ci and ej == cj
				flip_dir()
			set_cursor ei, ej

		fj = 0
		while p[0][fj] == '_'
			fj++
		set_cursor 0, fj


	# Chat functions
	$('#chat_input').on 'keyup', (e) ->
		if e.keyCode == 13
			sendChatMessage $(@).val()
			$(@).val ''

	# Room members box

	

	reset_puzzle = ->
		# clear gridlines
		for line in grid_lines
			line.remove()

		# Clear black squares
		for i,_ of letters
			for j, _ of letters[i]
				if black_squares[i] and black_squares[i][j]
					black_squares[i][j].remove()
				if letters[i] and letters[i][j]
					set_square_value i,j,'',false
				if number_text[i] and number_text[i][j]
					number_text[i][j].remove()

		# Initialize black squares
		for i in [0..puzzle_size - 1]
			black_squares[i] = {}
			letters[i] = {}
			numbers[i] = {}
			number_text[i] = {}
			for j in [0..puzzle_size - 1]
				black_squares[i][j] = null
				letters[i][j] = null
				numbers[i][j] = null
				number_text[i][j] = null

		# clear numbers
		numbers_rev = {}
		

		if across_highlight
			across_highlight.remove()
		across_highlight = paper.rect(-50,
									  -50,
									  square_size,
									  square_size)
								.attr {
									fill: '#233'
									stroke: 'none'
									opacity: 0.5
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
									opacity: 0.5
								}

		if square_highlight
			square_highlight.remove()
		square_highlight = paper.rect(-50,
									  -50,
									  square_size,
									  square_size)
								.attr {
									fill: '#141d3d'
									stroke: 'none'
									opacity: 0.7
								}

		$('#A_clues').empty()
		$('#D_clues').empty()

	# Handle uploads
	$('#fileupload').fileupload {
		dataType: 'json'
		add: (e, data) ->
			# console.log data
			data.submit()
		done: (e, data) ->
			# console.log 'done'
	}

	$('#upload_button').click (e) ->
		e.preventDefault()

	$.getJSON '/static/puzzle.json', (data) ->
		make_puzzle data
