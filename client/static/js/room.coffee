PuzzleManager = require './puzzlemanager'

$ ->
  SOCKET_URL = location.origin.replace(/^http/, 'ws')

  CROSSWORD_CANVAS_EL = '#crossword-container'

  socket = io.connect SOCKET_URL
  # Vue components

  # Timing
  startDate = new Date()

  setTimer = () ->
    seconds = Math.floor((new Date() - startDate) / 1000)
    minutes = Math.floor(seconds / 60)
    seconds = seconds % 60
    if seconds < 10
      seconds = '0' + seconds
    $('#timer').html("#{minutes}:#{seconds}")

  timer = undefined


  MembersBox = Vue.extend
    template: '#members-box'
    data:
      users: []

  Vue.component 'members-box', MembersBox

  ChatBox = new Vue
    el: '#chat_box'
    data:
      messages: []
      text: ""
    methods:
      onEnter: ->
        socket.emit 'chat message', @text
        @text = ''


  ClueList = Vue.extend
    template: '#clue-li'
    data:
      dir: 'across',
      clues: { across: [], down: [] }
    ready: ->
      @$watch 'current', (current) ->
        clueNumber = current.clueNumber[@.str]
        listOffset = $(@$el).scrollTop()
        activeCluePosition = $(@$el).find("li[value=#{clueNumber}]").position().top
        $(@$el).stop().animate(scrollTop: activeCluePosition + listOffset, 50)
    methods:
      onClick: (str, num) ->
        puzzleManager.moveToClue num, dir[str]

  clueSymbols =
    down: '▼'
    across: '▶'
  Vue.filter 'dir-symbol', (dir) ->
    clueSymbols[dir]

  Vue.component 'clue-list', ClueList

  uiState = new Vue({
    el: '#content',
    data:
      clues: { across: [], down: [] }
      cluesObj: {}
      currentClue: {}
      users: []
      id: ''
    computed:
      currentClueDirection: ->
        @currentClue.direction
      currentClueNumber: ->
        @currentClue.clueNumber?[@currentClueDirection]
      currentClueText: ->
        @cluesObj?[@currentClueDirection]?[@currentClueNumber]
  })

  console.log 'UI components initialized'

  roomName = window.location.pathname.substr 1 + window.location.pathname.lastIndexOf '/'
  console.log 'roomName', roomName

  # after server acknowledges handshake, send room name to join
  socket.on 'user id', (id) ->
    uiState.id = id
    socket.emit 'join room',
      roomName: roomName
      userId: 'foo'

  socket.on 'chat message', (message) ->
    message.isServer = message.user == '__server'
    ChatBox.messages.push message
    setTimeout (-> $('#chat').scrollTop($('#chat')[0].scrollHeight)), 20

  puzzleManager = new PuzzleManager {
    elements:
      gridEl: CROSSWORD_CANVAS_EL
    puzzle: {}
    socket: socket
  }, uiState

  socket.on 'existing puzzle', (room) =>
    console.log 'existing', room
    startDate = new Date(room.startTime)
    setTimer
    if room.isDone
      clearInterval timer
    else
      timer = setInterval setTimer, 500
    puzzleManager.existingPuzzle room

  socket.on 'done', (room) =>
    console.log 'done', room
    puzzleManager.markDone()
    clearInterval timer

  key 'shift+o', (e) ->
    $('#browse_puzzles_a').trigger 'click'

  $.getJSON(
    '/api/puzzles',
    (data) ->
      for puzzle in data
        $('#browse_puzzles_modal ul').append(
          """
          <li>
            #{puzzle.title} -
            <a class='load-puzzle-a'
               data-puzzle-id='#{puzzle._id}' href='#'>
              Load
            </a>
          </li>
          """
        )
  )

  $('#random_a').on 'click', (e) ->
    $.getJSON(
      "/api/puzzles/random",
      (puzzle) =>
        socket.emit 'new puzzle',
          id: puzzle._id
    )

  $('.random-day').on 'click', (e) ->
    day = $(this).html().trim()
    $.getJSON(
      "/api/puzzles/random/#{day}",
      (puzzle) =>
        socket.emit 'new puzzle',
          id: puzzle._id
    )



  $('#browse_puzzles_modal').on 'click', '.load-puzzle-a', (e) ->
    $.getJSON(
      "/api/puzzles/#{$(this).data('puzzle-id')}",
      (puzzle) =>
        socket.emit 'new puzzle',
          id: $(this).data('puzzle-id')
    )

  $(document).foundation()
