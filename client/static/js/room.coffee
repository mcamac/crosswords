$ ->
  SOCKET_URL = location.origin.replace(/^http/, 'ws')

  CROSSWORD_CANVAS_EL = '#crossword-container'

  socket = io.connect SOCKET_URL
  # Vue components

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
    ChatBox.messages.push message

  puzzleManager = new PuzzleManager {
    elements:
      gridEl: CROSSWORD_CANVAS_EL
    puzzle:
      size: 15
    socket: socket
  }, uiState


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

  $('#browse_puzzles_modal').on 'click', '.load-puzzle-a', (e) ->
    $.getJSON(
      "/api/puzzles/#{$(this).data('puzzle-id')}",
      (puzzle) ->
        puzzleManager.loadPuzzle new Puzzle puzzle
    )

  $(document).foundation()
