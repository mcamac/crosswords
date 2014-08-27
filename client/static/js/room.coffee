$ ->
  # Vue components

  membersBox = new Vue {
    el: '#players'
    data: {
      users: [{
        username: 'martin'
      }, {
        username: 'joseph'
      }]
    }
  }


  ClueList = Vue.extend
    template: '#clue-li'
    data: {
      dir: 'across',
      clues: { across: [], down: [] }
    }
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
    computed:
      currentClueDirection: ->
        @currentClue.direction
      currentClueNumber: ->
        @currentClue.clueNumber?[@currentClueDirection]
      currentClueText: ->
        @cluesObj?[@currentClueDirection]?[@currentClueNumber]
  })

  console.log 'UI components initialized'


  SOCKET_URL = location.origin.replace(/^http/, 'ws')

  CROSSWORD_CANVAS_EL = '#crossword-container'

  socket = io.connect SOCKET_URL

  roomName = window.location.pathname.substr 1 + window.location.pathname.lastIndexOf '/'
  console.log 'roomName', roomName

  # after server acknowledges handshake, send room name to join
  socket.on 'connection acknowledged', (data) ->
    socket.emit 'join room', 
      roomName: roomName
      userId: 'foo'

  puzzleManager = new PuzzleManager {
    elements:
      gridEl: CROSSWORD_CANVAS_EL
    puzzle:
      size: 15
    socket: socket
  }, uiState

  samplePuzzle = {"title": "NY Times, Mon, Jun 03, 2013", "puzzle": ["CEDAR_ZION_PHIL", "AMORE_IRAE_RONA", "PIGINAPOKE_EGGY", "ELIE_EON_DASHES", "SEETHRU_OSOLE__", "___TOOTAT_KEANU", "JIHADS_TOW_YVES", "USA_SOWSEAR_ERE", "DEMI_LIE_SOUNDS", "DEFOE_CARHOP___", "__ININK_ATTACHE", "ASSISI_GNU_TAIL", "RITZ_PORKBARREL", "ALEE_ARAL_DEERE", "BODS_TOBE_SEWON"], "author": "John Lampkin / Will Shortz", "height": 15, "width": 15, "clues": {"down": {"1": "Bullfighters wave them", "2": "Writer Zola", "3": "Cowherd's stray", "4": "Short operatic song", "5": "Stimpy's bud", "6": "Like some detachable linings", "7": "What bodybuilders pump", "8": "Wood for a chest", "9": "Essentials", "10": "\"Blue Suede Shoes\" singer", "11": "Ecstatic state, informally", "12": "\"Bus Stop\" playwright", "13": "Puts down, as tile", "18": "Spray can", "23": "Just fine", "25": "Mortar troughs", "26": "Great Plains tribe", "28": "Floundering", "30": "Stereotypical techie", "31": "Applications", "32": "Naomi or Wynonna of country music", "33": "\"Got it!\"", "34": "Clumsy", "36": "Laundry basin", "40": "Lighted part of a candle", "41": "Part of a plant or tooth", "44": "Becomes charged, as the atmosphere", "47": "Stuck, with no way to get down", "49": "Sue Grafton's \"___ for Evidence\"", "51": "Really bug", "53": "Barely bite, as someone's heels", "55": "Rod who was a seven-time A.L. batting champ", "56": "Prefix with -glyphics", "57": "\"The ___ DeGeneres Show\"", "58": "Many an Iraqi", "59": "Corn Belt tower", "60": "Seize", "64": "Spanish gold", "65": "What TV watchers often zap"}, "across": {"1": "Wood for a chest", "6": "Holy Land", "10": "TV's Dr. ___", "14": "Love, Italian-style", "15": "\"Dies ___\" (Latin hymn)", "16": "Gossipy Barrett", "17": "Unseen purchase", "19": "Like custard and meringue", "20": "Writer Wiesel", "21": "Long, long time", "22": "- - -", "24": "Transparent, informally", "26": "\"___ Mio\"", "27": "Greet with a honk", "29": "Reeves of \"The Matrix\"", "32": "Holy wars", "35": "Drag behind, as a trailer", "37": "Designer Saint Laurent", "38": "Made in ___ (garment label)", "39": "You can't make a silk purse out of it, they say", "42": "Before, poetically", "43": "Actress Moore of \"Ghost\"", "45": "Tell a whopper", "46": "Buzz and bleep", "48": "Daniel who wrote \"Robinson Crusoe\"", "50": "Drive-in server", "52": "How to sign a contract", "54": "Ambassador's helper", "58": "Birthplace of St. Francis", "60": "African antelope", "61": "Part that wags", "62": "Big name in crackers", "63": "Like some wasteful government spending", "66": "Toward shelter, nautically", "67": "Asia's diminished ___ Sea", "68": "John ___ (tractor maker)", "69": "Physiques", "70": "Words before and after \"or not\"", "71": "Attach, as a button"}}}
  puzzleManager.loadPuzzle new Puzzle samplePuzzle

  console.log puzzleManager


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
