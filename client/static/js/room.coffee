dir = 
  RIGHT: [0, 1]
  LEFT: [0, -1]
  DOWN: [1, 0]
  UP: [-1, 0]
  ACROSS: [0, 1]

class PuzzleManager
  constructor: (options) ->
    # an HTML element is required
    @el = options.elements.gridEl
    @$el = $(@el)

    socket = options.socket

    if options.title
      @title = options.title

    # puzzle object
    @p = {}
    if options.puzzle
      @p = options.puzzle

    # graphics object
    @g = {}

    # settings object (for constants)
    @c = {}

    @g.grid = {
      lines: []
      height: 600
      width: 600
      margin: 2
      squareSize: 600 / 15.0
      numbers:
        style:
          'font-size': '11px'
          'font-family': 'Source Sans'
          'text-anchor': 'start'
    }

    @g.highlights = {
      across: null
      down: null
      user: {}
      style:
        active:
          color: 'rgba(61,104,184,0.55)'
        perp:
          color: 'rgba(61,104,184,0.15)'
    }

    # initialize Raphael canvas
    @g.paper = Raphael 'crossword_canvas',
      @g.grid.width + @g.grid.margin, @g.grid.height + @g.grid.margin

    @g.overlay = null

  render: ->
    # Remove and reset everything
    for line in @g.grid.lines
      line.remove()
    @g.grid.lines = []

    # Draw and format puzzle numbers
    currentNumber = 1
    for r in [0...@p.height]
      for c in [0...@p.width]
        if @p.gridNumbers[r][c]
          @g.paper.text(
            @g.grid.squareSize * c + 3,
            @g.grid.squareSize * r + 8.5,
            @p.gridNumbers[r][c])
            .attr @g.grid.numbers.style
        if @p.grid[r][c] == '_'
          @g.paper.rect(
            @g.grid.squareSize * c + 0.5,
            @g.grid.squareSize * r + 0.5,
            @g.grid.squareSize,
            @g.grid.squareSize)
          .attr {
            fill: 'black'
          }

    @g.letters = {}    
    for r in [0...@p.height]
      @g.letters[r] = {}
      for c in [0...@p.width]
        @g.letters[r][c] = @g.paper.text(
          (c + 0.5) * @g.grid.squareSize,
          (r + 0.55) * @g.grid.squareSize,
          '',
        ).attr {
          'font-family': 'Source Sans'
          'font-size': 20
          'font-weight': 600
          'text-anchor': 'middle'
        }

    # add grid lines
    for offset in [0..@p.height]
      pxoff = @g.grid.squareSize * offset + 0.5   
      @g.grid.lines.push @g.paper.path "M#{pxoff},0.5v#{@g.grid.height}"
      @g.grid.lines.push @g.paper.path "M0.5,#{pxoff}h#{@g.grid.width}"

    for line in @g.grid.lines
      line.attr {
        stroke: '#dddddd'
        'stroke-width': 1
      }

    @g.overlay = @g.paper.rect(0, 0, @g.grid.width, @g.grid.height)
      .attr {
        stroke: 'none'
        fill: '#ffffff'
        opacity: 0.0
      }
    @g.overlay.toFront()
    @g.overlay.click (e) =>
      ei = ~~(e.layerY / @g.grid.squareSize)
      ej = ~~(e.layerX / @g.grid.squareSize)
      # flip directions if same square is clicked
      if ei == @g.ci and ej == @g.cj
        @flipDir()
      @_setHighlight 'user', [ei, ej]

    @g.ci = 0
    @g.cj = 0
    @g.dir = dir.ACROSS

    # load clue lists
    for num, clue of @p.clues.across
      $('#A_clues').append "<li>#{num} #{clue}</li>"
    for num, clue of @p.clues.down
      $('#D_clues').append "<li>#{num} #{clue}</li>"

    # initialize user highlights
    @g.highlights.user['user'] = @g.paper.rect(
      3, 3,
      @g.grid.squareSize - 5, @g.grid.squareSize - 5
    ).attr {
      stroke: 'rgb(61,104,184)' 
      'stroke-width': 4
      fill: 'none'
      opacity: 1
    }

    @g.highlights.down = @g.highlights.user['user'].clone()
    @g.highlights.across = @g.highlights.user['user'].clone() 

    console.log 'rendered'

  flipDir: ->
    @g.dir = if @g.dir == dir.ACROSS then dir.DOWN else dir.ACROSS
    @_reHighlight()

  loadPuzzle: (@p) ->  
    # load puzzle data into manager and render
    @render()

  setCurrentSquare: (value, move) ->
    @g.letters[@g.ci][@g.cj].attr
      text: value

    if move
      @move @g.dir

  currentClue: ->
    @p.clueNumberFor [@g.ci, @g.cj], @g.dir


  # move in direction
  move: (direction) ->
    @_setHighlight 'user', @p.nextSquare([@g.ci, @g.cj], direction)


  moveToClue: (clueNumber) ->
    @_setHighlight 'user', @p.gridNumbersRev[clueNumber]

  moveToNextClue: ->
    @moveToClue (@p.nextClueNumber @currentClue(), @g.dir, 1)

  moveToPreviousClue: ->   
    @moveToClue (@p.nextClueNumber @currentClue(), @g.dir, -1)

  _setHighlight: (id, [r, c]) ->
    @g.highlights.user[id]?.attr
      x: @g.grid.squareSize * c + 3
      y: @g.grid.squareSize * r + 3

    if id is 'user'
      [@g.ci, @g.cj] = [r, c]

    @_reHighlight()

  _reHighlight: ->
    [sr, er] = [@g.ci, @g.ci]
    while @p.validSquare [sr - 1, @g.cj]
      sr--
    while @p.validSquare [er + 1, @g.cj]
      er++

    [sc, ec] = [@g.cj, @g.cj]
    while @p.validSquare [@g.ci, sc - 1]
      sc--
    while @p.validSquare [@g.ci, ec + 1]
      ec++

    @g.highlights.down.attr
      x: @g.grid.squareSize * @g.cj + 3
      y: @g.grid.squareSize * sr + 3
      width: @g.grid.squareSize - 5
      height: @g.grid.squareSize * (er - sr + 1) - 5
      stroke: (if @g.dir == dir.DOWN then @g.highlights.style.active.color else @g.highlights.style.perp.color)

    @g.highlights.across.attr
      x: @g.grid.squareSize * sc + 3
      y: @g.grid.squareSize * @g.ci + 3
      width: @g.grid.squareSize * (ec - sc + 1) - 5
      height: @g.grid.squareSize - 5 
      stroke: (if @g.dir == dir.ACROSS then @g.highlights.style.active.color else @g.highlights.style.perp.color)



class Puzzle
  constructor: (puzzle) ->
    @title = puzzle.title
    @grid = puzzle.puzzle
    @height = puzzle.height
    @width = puzzle.width
    @clues = puzzle.clues

    @clueNumbers = {}
    for d, dClues of @clues
      @clueNumbers[d] = (parseInt(num) for num, clue of dClues)
    console.log @clueNumbers

    # compute where numbers are
    @gridNumbers = (null for r in [0...@height] for c in [0...@width])
    @gridNumbersRev = {}

    currentNumber = 1
    @_loopGrid ([r, c]) =>
      if @validSquare([r, c]) and (not @validSquare([r - 1, c]) or
                                 not @validSquare([r, c - 1]))
        @gridNumbersRev[currentNumber] = [r, c]
        @gridNumbers[r][c] = currentNumber++

  validSquare: ([r, c]) ->
    @inGrid([r, c]) and @grid[r][c] != '_'

  inGrid: ([r, c]) ->
    0 <= r < @height and 0 <= c < @width

  nextSquare: ([r, c], [roff, coff]) ->
    # Returns the next square in the given direction, if there is any.
    [nr, nc] = [r + roff, c + coff]
    while not @validSquare([nr, nc])
      if not @inGrid([nr, nc])
        return [r, c]
      nr += roff
      nc += coff
    return [nr, nc]

  nextClueNumber: (num, d, offset) ->
    dirClueNumbers = if d == dir.ACROSS then @clueNumbers.across else @clueNumbers.down
    nextClueIndex = (dirClueNumbers.indexOf(num) + offset + dirClueNumbers.length) % dirClueNumbers.length
    return dirClueNumbers[nextClueIndex]

  clueNumberFor: ([r, c], [roff, coff]) ->
    while @validSquare [r - roff, c - coff]
      r -= roff
      c -= coff
    return @gridNumbers[r][c]


  _loopGrid: (callback) ->
    for r in [0...@height]    
      for c in [0...@width]
        callback [r, c]

$ ->
  SOCKET_URL = 'http://localhost:5558' 

  CROSSWORD_CANVAS_EL = '#crossword_canvas'

  socket = io.connect SOCKET_URL

  urlFragments = window.location.href.split('/')
  roomName = urlFragments[urlFragments.length - 1]
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
  }

  samplePuzzle = {"title": "NY Times, Mon, Jun 03, 2013", "puzzle": ["CEDAR_ZION_PHIL", "AMORE_IRAE_RONA", "PIGINAPOKE_EGGY", "ELIE_EON_DASHES", "SEETHRU_OSOLE__", "___TOOTAT_KEANU", "JIHADS_TOW_YVES", "USA_SOWSEAR_ERE", "DEMI_LIE_SOUNDS", "DEFOE_CARHOP___", "__ININK_ATTACHE", "ASSISI_GNU_TAIL", "RITZ_PORKBARREL", "ALEE_ARAL_DEERE", "BODS_TOBE_SEWON"], "author": "John Lampkin / Will Shortz", "height": 15, "width": 15, "clues": {"down": {"1": "Bullfighters wave them", "2": "Writer Zola", "3": "Cowherd's stray", "4": "Short operatic song", "5": "Stimpy's bud", "6": "Like some detachable linings", "7": "What bodybuilders pump", "8": "Wood for a chest", "9": "Essentials", "10": "\"Blue Suede Shoes\" singer", "11": "Ecstatic state, informally", "12": "\"Bus Stop\" playwright", "13": "Puts down, as tile", "18": "Spray can", "23": "Just fine", "25": "Mortar troughs", "26": "Great Plains tribe", "28": "Floundering", "30": "Stereotypical techie", "31": "Applications", "32": "Naomi or Wynonna of country music", "33": "\"Got it!\"", "34": "Clumsy", "36": "Laundry basin", "40": "Lighted part of a candle", "41": "Part of a plant or tooth", "44": "Becomes charged, as the atmosphere", "47": "Stuck, with no way to get down", "49": "Sue Grafton's \"___ for Evidence\"", "51": "Really bug", "53": "Barely bite, as someone's heels", "55": "Rod who was a seven-time A.L. batting champ", "56": "Prefix with -glyphics", "57": "\"The ___ DeGeneres Show\"", "58": "Many an Iraqi", "59": "Corn Belt tower", "60": "Seize", "64": "Spanish gold", "65": "What TV watchers often zap"}, "across": {"1": "Wood for a chest", "6": "Holy Land", "10": "TV's Dr. ___", "14": "Love, Italian-style", "15": "\"Dies ___\" (Latin hymn)", "16": "Gossipy Barrett", "17": "Unseen purchase", "19": "Like custard and meringue", "20": "Writer Wiesel", "21": "Long, long time", "22": "- - -", "24": "Transparent, informally", "26": "\"___ Mio\"", "27": "Greet with a honk", "29": "Reeves of \"The Matrix\"", "32": "Holy wars", "35": "Drag behind, as a trailer", "37": "Designer Saint Laurent", "38": "Made in ___ (garment label)", "39": "You can't make a silk purse out of it, they say", "42": "Before, poetically", "43": "Actress Moore of \"Ghost\"", "45": "Tell a whopper", "46": "Buzz and bleep", "48": "Daniel who wrote \"Robinson Crusoe\"", "50": "Drive-in server", "52": "How to sign a contract", "54": "Ambassador's helper", "58": "Birthplace of St. Francis", "60": "African antelope", "61": "Part that wags", "62": "Big name in crackers", "63": "Like some wasteful government spending", "66": "Toward shelter, nautically", "67": "Asia's diminished ___ Sea", "68": "John ___ (tractor maker)", "69": "Physiques", "70": "Words before and after \"or not\"", "71": "Attach, as a button"}}}
  puzzleManager.loadPuzzle new Puzzle samplePuzzle

  for k in ['right', 'left', 'up', 'down']
    do (k) ->
      key k, ->
        puzzleManager.move dir[k.toUpperCase()]

  key 'tab', (e) ->
    e.preventDefault()
    puzzleManager.moveToNextClue()

  key 'shift+tab', (e) ->
    e.preventDefault()
    puzzleManager.moveToPreviousClue()

  key 'space', (e) ->
    e.preventDefault()
    puzzleManager.flipDir()

  key 'shift+enter', (e) ->
    # rebus cells
    console.log 'shift+enter'
    0

  key 'backspace', (e) ->
    e.preventDefault()

  alphanum = "abcdefghijklmnopqrstuvwxyz1234567890"
  for char in alphanum
    do (char) ->
      key char, (e) ->
        puzzleManager.setCurrentSquare char.toUpperCase(), true

  console.log puzzleManager
