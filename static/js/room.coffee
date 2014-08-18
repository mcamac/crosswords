$ ->
	time_ping = undefined
	window.time_delta = 0
	window.client_start_time = undefined
	window.fake_start = +new Date(2010, 0, 1, 0, 0, 0);
	timer = undefined

	ws = new WebSocket("ws://#{location.hostname}:#{location.port}#{location.pathname}/sub")

	# localStorage namespace
	lsns = 'mcamac:'
	uuid = localStorage[lsns + 'uuid'] or= null # since JSON.stringify is broken wrt undefined
	ws.onopen = ->
		console.log uuid
		@send JSON.stringify
			type: 'recall uuid'
			uuid: uuid
		time_ping = +new Date

	# # send localstorage username, if exists
	# if localStorage.username
	# 	ws.send JSON.stringify {
	# 		type: 'change username'
	# 		content: localStorage.username
	# 	}


	ws.onmessage = (msg) ->
		data = JSON.parse msg.data
		console.log data.type, data

		if data.type == 'new uuid'
			localStorage[lsns + 'uuid'] = data.uuid

		if data.type == 'client chat message'
			add_chat_message "<b>#{data.name}</b>: #{data.content}"

		if data.type == 'room chat message'
			add_chat_message "<i>#{data.content}</i>"

		if data.type == 'new puzzle'
			server_start_time = +new Date data.start_time
			window.client_start_time = server_start_time + time_delta
			make_puzzle data.content

			do start_d3

		if data.type == 'existing puzzle'
			time_pong = +new Date
			time_roundtrip = time_pong - time_ping
			server_current_time = +new Date data.content.current_time
			window.time_delta = new Date - time_roundtrip / 2 - server_current_time

			server_start_time = +new Date data.content.start_time
			window.client_start_time = server_start_time + time_delta

			make_puzzle data.content.puzzle
			fill_existing_letters data.content.grid
			fill_existing_colors data.content.player_squares

			window.start = client_start_time
			do start_d3

			if data.content.complete
				greenBG()

		if data.type == 'change square'
			i = data.content.i
			j = data.content.j
			char = data.content.char
			set_square_value i, j, char, false
			if char != ''
				set_player_square i, j, data.color
			else
				if player_squares[i][j]
					remove player_squares[i][j]

			c = 0
			window.graph.series[c++] = {
				name: client_grid_changes.name
				stroke: "rgba(#{client_grid_changes.color.slice 4, -1}, 0.9)"
				color: "rgba(#{client_grid_changes.color.slice 4, -1}, 0.5)"
				data: ({
					x: (window.fake_start - window.client_start_time + d.server_time + window.time_delta) / 1e3
					y: d.correct
				} for d in client_grid_changes.data)
			} for own client_id, client_grid_changes of data.grid_changes
			window.graph.render()

		if data.type == 'room members'
			data.content.sort()
			$('#members_box').html $.map(data.content, (row) ->
				"<span class='member' style='border-color: #{row.color};'>#{row.name}</span>").join(', ')
			send_set_cursor ci, cj

			ids = $.map(data.content, (row) -> row.id)
			console.log ids
			for id, _ of cursors
				if $.inArray(id, ids) == -1 and cursors[id]
					remove cursors[id]
					cursors[id] = undefined

		if data.type == 'want cursors'
			send_set_cursor ci, cj

		if data.type == 'set cursor'
			place_cursor data.user.id, data.user.color, data.content[0], data.content[1]

		if data.type == 'puzzle finished'
			greenBG()
			clearInterval timer
			add_chat_message "<i>Puzzle finished in <b>#{timer_string false}</b>!</i>"

	send_chat_message = (message) ->
		ws.send JSON.stringify {
			type: 'client chat message'
			content: message
		}

	add_chat_message = (message) ->
		$('#chat_box').append "<p>#{message}</p>"

		# scroll to bottom of chatbox
		$('#chat_box').scrollTop $('#chat_box')[0].scrollHeight

	greenBG = ->
		background.classList.add 'green'

	# Crossword SVG variables
	grid_lines = []
	grid_size_max = 540
	grid_size = grid_size_max

	number_text = {}
	numbers = {}
	number_list = []
	numbers_rev = {}

	puzzle_size = 15

	background = null

	p = {}

	square_size = grid_size / puzzle_size

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
	STROKE_WIDTH_PLAYER = 5
	STROKE_WIDTH_OTHER = 3


	cursors = {}

	black_squares = {}
	player_squares = {}

	Render.setDims('crossword') grid_size + 2, grid_size + 2

	USER = 0
	dir = 'A'
	dir_arrows =
		A: '▶' # ▷
		D: '▼' # ▽

	## UI Code
	remove = (el) -> el.parentNode.removeChild(el)

	add_black_square = Render.rect 'black-squares'
	blacken_square = (i, j) ->
		if black_squares[i][j]
			remove black_squares[i][j]

		black_squares[i][j] =
			add_black_square j * square_size+0.5, i * square_size+0.5, square_size, square_size

	add_player_square = Render.rect 'filled-squares'
	set_player_square = (i, j, color) ->
		if player_squares[i][j]
			remove player_squares[i][j]

		xoffset = if puzzle_size >= 20 then 0.33 else 0.2

		X = 1 + ~~(j * square_size + square_size * xoffset)
		Y = 1 + ~~(i * square_size + 7 * square_size / 8)
		W = ~~(square_size * 0.6)
		H = ~~(square_size / 8)
		X = 1 + ~~(j * square_size)
		Y = 1 + ~~(i * square_size)
		W = -1 + square_size
		H = -1 + square_size
		player_squares[i][j] = 
			add_player_square X, Y, W, H, { fill: color || 'none' }

	has_number = (p, i, j) ->
		# # console.log p[i][j]
		if p[i][j] == '_'
			return false
		if i == 0 or j == 0
			return true
		if p[i-1][j] == '_' or p[i][j-1] == '_'
			return true
		return false

	add_letter = Render.text 'letters'
	new_letter = (i, j, char) ->
		xoffset = if puzzle_size >= 20 then 0.63 else 0.5
		add_letter (j + xoffset) * square_size, Math.round((i + 0.55) * square_size), char,
		 	'font-size': if puzzle_size >= 20 then 16 else 20

	fill_existing_letters = (grid) ->
		for i in [0..puzzle_size-1]
			for j in [0..puzzle_size-1]
				if letters[i][j]
					remove letters[i][j]
				letters[i][j] = new_letter i, j, grid[i][j]

	fill_existing_colors = (grid_colors) ->
		for i in [0..puzzle_size-1]
			for j in [0..puzzle_size-1]
				if player_squares[i][j]
					remove player_squares[i][j]
				set_player_square i, j, grid_colors[i][j]

	set_square_value = (i, j, char, broadcast) ->
		if letters[i][j]
			remove letters[i][j]

		# console.log letters[i][j], i, j, char
		char = char.toUpperCase()
		xoffset = if puzzle_size >= 20 then 0.63 else 0.5
		letters[i][j] = add_letter (j + xoffset) * square_size, Math.round((i + 0.55) * square_size), char,
						 	'font-size': if puzzle_size >= 20 then 16 else 20

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

	next_number = (n) ->
		for i in number_list
			if i >= n + 1 and $(".li-clue[data-clue-id=#{dir}#{i}]").length > 0
				return i
		return 1

	prev_number = (n) ->
		for i in [number_list.length-1..0]
			x = number_list[i]
			if x <= n - 1 and $(".li-clue[data-clue-id=#{dir}#{x}]").length > 0
				return x
		return number_list[number_list.length - 1]

	go_to_clue = (clue_id) ->
		ns = numbers_rev["#{dir+clue_id}"]
		set_cursor ns[0], ns[1]

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
			if dir == 'A' and valid(p, ci, cj + 1)
				go_right()
			else if dir == 'D' and valid(p, ci + 1, cj)
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


	######################## 
	## KEYBOARD SHORTCUTS ##
	########################
	key 'left', go_left
	key 'up', (e) ->
		e.preventDefault()
		go_up()

	key 'right', go_right
	key 'down', (e) ->
		e.preventDefault()
		go_down()

	key 'space', (e) ->
		e.preventDefault()
		flip_dir()

	key 'backspace', (e) ->
		e.preventDefault()
		send_set_square_value ci, cj, ''
		if dir == 'A' then go_left() else go_up()

	key 'tab', (e) ->
		e.preventDefault()
		go_to_clue next_number get_clue_number(p, ci, cj, dir) 

	key 'shift+tab', (e) ->
		e.preventDefault()
		go_to_clue prev_number get_clue_number(p, ci, cj, dir) 

	rehighlight = ->
		# console.log square_highlight	

		acr_sj = cj
		acr_ej = cj
		while valid(p, ci, acr_sj - 1)
			acr_sj--
		while valid(p, ci, acr_ej + 1)
			acr_ej++
		across_highlight.setAttribute 'width', ~~(square_size * (acr_ej - acr_sj + 1)) - STROKE_WIDTH_PLAYER - 1
		across_highlight.setAttribute 'x', acr_sj * square_size + 0.5 + (STROKE_WIDTH_PLAYER + 1) / 2
		across_highlight.setAttribute 'y', ci * square_size + 0.5 + (STROKE_WIDTH_PLAYER + 1) / 2
		across_highlight.classList[if dir == 'A' then 'add' else 'remove'] 'highlight-parallel'
		across_highlight.classList[if dir == 'A' then 'remove' else 'add'] 'highlight-perpendicular'

		down_si = ci
		down_ei = ci
		while valid(p, down_si - 1, cj)
			down_si--
		while valid(p, down_ei + 1, cj)
			down_ei++
		down_highlight.setAttribute 'height', ~~(square_size * (down_ei - down_si + 1)) - STROKE_WIDTH_PLAYER - 1
		down_highlight.setAttribute 'x', cj * square_size + 0.5 + (STROKE_WIDTH_PLAYER + 1) / 2
		down_highlight.setAttribute 'y', down_si * square_size + 0.5 + (STROKE_WIDTH_PLAYER + 1) / 2
		down_highlight.classList[if dir == 'D' then 'add' else 'remove'] 'highlight-parallel'
		down_highlight.classList[if dir == 'D' then 'remove' else 'add'] 'highlight-perpendicular'

		square_highlight.setAttribute 'x', cj * square_size + 0.5 + (STROKE_WIDTH_PLAYER + 1) / 2
		square_highlight.setAttribute 'y', ci * square_size + 0.5 + (STROKE_WIDTH_PLAYER + 1) / 2
 
		return


	set_cursor = (i, j) ->
		if p[i][j] == '_'
			return

		# console.log ci, cj, i, j
		ci = i
		cj = j
		# console.log 'set',ci,cj
		rehighlight()

		# change current clue
		update_current_clue()
		send_set_cursor(ci, cj)

	send_set_cursor = (i, j) ->
		ws.send JSON.stringify {
			type: 'set cursor'
			content: [i, j]
		}

	add_their_cursor = Render.rect 'their-cursors'
	place_cursor = (pid, color, i, j) ->
		if not cursors[pid]
			cursors[pid] = add_their_cursor -50, -50,
								  square_size - STROKE_WIDTH_OTHER - 1,
								  square_size - STROKE_WIDTH_OTHER - 1,
								  stroke: color
								  'stroke-width': STROKE_WIDTH_OTHER
		else
			cursors[pid].setAttribute 'stroke', color
			cursors[pid].setAttribute 'x', j * square_size + 0.5 + (STROKE_WIDTH_OTHER + 1) / 2
			cursors[pid].setAttribute 'y', i * square_size + 0.5 + (STROKE_WIDTH_OTHER + 1) / 2
		console.log cursors[pid]


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
		$('#current_clue').html("<strong class='current-clue-number'>" + dir_arrows[dir] + " #{number}</strong> #{clue}")

	make_puzzle = (contents) ->

		puzzle = contents
		p = puzzle.puzzle

		

		$('#puzzle_title').html puzzle.title

		# console.log JSON.stringify contents

		puzzle_size = +puzzle.height
		square_size = ~~(grid_size_max / puzzle_size)
		grid_size = square_size * puzzle_size

		clues['A'] = puzzle.clues.across
		clues['D'] = puzzle.clues.down
		reset_puzzle()
		
		for num, clue of contents.clues.across
			$('#A_clues').append "<li class='li-clue' data-clue-id=A#{num}><div class=\"num\">#{num}</div> <div class=\"clue-text\">#{clue}</div></li>"
		for num, clue of contents.clues.down
			$('#D_clues').append "<li class='li-clue' data-clue-id=D#{num}><div class=\"num\">#{num}</div> <div class=\"clue-text\">#{clue}</div></li>"

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
		add_gridline = Render.path 'gridlines'
		for offset in [0..puzzle_size]
			pxoff = square_size * offset + 0.5
			grid_lines.push add_gridline "M#{pxoff},0.5v#{grid_size}"
			grid_lines.push add_gridline "M0.5,#{pxoff}h#{grid_size}"

		# Draw and format puzzle numbers
		current_number = 1
		add_number = Render.text 'numbers'
		for i in [0..puzzle_size-1]
			for j in [0..puzzle_size-1]
				if has_number p,i,j 
					# console.log "#{i} #{j} #{current_number}"
					number_text[i][j] = add_number \
						square_size * j + 2, 
						square_size * i + 8, 
						current_number,
						'font-size': if puzzle_size >= 20 then '9px' else '11px'
					numbers[i][j] = current_number
					number_list.push(current_number)
					numbers_rev['A'+current_number] = [i, j]
					numbers_rev['D'+current_number] = [i, j]
					current_number += 1

		if background
			remove background

		background = Render.rect('background') 0, 0, grid_size, grid_size

		background.addEventListener 'click', (e) ->
			ei = Math.floor e.layerY / square_size
			ej = Math.floor e.layerX / square_size
			if ei == ci and ej == cj
				flip_dir()
			set_cursor ei, ej

		fj = 0
		while p[0][fj] == '_'
			fj++
		set_cursor 0, fj

		ws.send JSON.stringify {type: 'want cursors'}

		timer = setInterval tick_timer, tick_timer.delay


	# Chat functions
	$('#chat_input').on 'keyup', (e) ->
		if e.keyCode == 13
			send_chat_message $(@).val()
			$(@).val ''

	# Room members box

	

	reset_puzzle = ->
		# clear gridlines
		for line in grid_lines
			remove line

		# Clear black squares
		for i,_ of letters
			for j, _ of letters[i]
				if black_squares[i] and black_squares[i][j]
					remove black_squares[i][j]
				if letters[i] and letters[i][j]
					set_square_value i,j,'',false
				if number_text[i] and number_text[i][j]
					remove number_text[i][j]
				if player_squares[i] and player_squares[i][j]
					remove player_squares[i][j]

		# Initialize black squares
		for i in [0..puzzle_size - 1]
			black_squares[i] = {}
			letters[i] = {}
			numbers[i] = {}
			number_text[i] = {}
			player_squares[i] = {}
			for j in [0..puzzle_size - 1]
				black_squares[i][j] = null
				letters[i][j] = null
				numbers[i][j] = null
				number_text[i][j] = null
				player_squares[i][j] = null

		# clear numbers
		numbers_rev = {}
		

		add_cursor = Render.rect 'cursor'
		if across_highlight
			remove across_highlight
		across_highlight = add_cursor -50,
									  -50,
									  square_size,
									  square_size - STROKE_WIDTH_PLAYER - 1,
									  'stroke-width': STROKE_WIDTH_PLAYER
									  'class': 'highlight-across highlight-parallel'
		
		if down_highlight
			remove down_highlight
		down_highlight = add_cursor   -50,
									  -50,
									  square_size - STROKE_WIDTH_PLAYER - 1,
									  square_size,
									  'stroke-width': STROKE_WIDTH_PLAYER
									  'class': 'highlight-down highlight-perpendicular'

		if square_highlight
			remove square_highlight
		square_highlight = add_cursor -50,
									  -50,
									  square_size - STROKE_WIDTH_PLAYER - 1,
									  square_size - STROKE_WIDTH_PLAYER - 1,
									  'stroke-width': STROKE_WIDTH_PLAYER
									  'class': 'highlight-square'

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

	# $.getJSON '/static/puzzle.json', (data) ->
	# 	make_puzzle data

	pad_zero = (n) ->
		if n < 10 then "0" + n else n

	timer_string = (deci) -> window.timer_string_ +new Date, deci

	window.timer_string_ = (current_time, deci) ->
		total_seconds = (current_time - window.client_start_time) / 1e3

		if total_seconds < 0
			console.error "#{total_seconds} is negative"
			total_seconds = 0

		hours = ~~(total_seconds / 3600)
		minutes = ~~(total_seconds / 60) % 60
		seconds = ~~total_seconds % 60

		string = if hours > 0 then "#{hours}:#{pad_zero minutes}:" else "#{minutes}:"
		string += pad_zero ~~seconds

		if deci
			deciseconds = ~~(10 * total_seconds % 10)
			string += "<small class='deciseconds'>.#{deciseconds}</small>"
		string

	tick_timer = ->
		$('#timer').html timer_string true

	tick_timer.delay = 100

	
