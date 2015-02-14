isd = (a, b) ->
  (a[0] == b[0]) and (a[1] == b[1])


class @PuzzleManager
  constructor: (options, @ui) ->
    # an HTML element is required
    @el = options.elements.gridEl
    @$el = $(@el)

    @socket = options.socket

    if options.title
      @title = options.title

    # puzzle object
    @p = {}
    if options.puzzle
      @p = options.puzzle

    @keyManager = new KeyManager @

    # graphics object
    @g = {}

    # settings object (for constants)
    @c = {}

    @user =
      color: 'rgb(232,157, 52)'

    defaultSquareSize = 36
    defaultWidth = defaultSquareSize * 15
    @g.grid =
      lines: []
      squareSize: defaultSquareSize
      height: defaultWidth
      width: defaultWidth
      margin: 2

    @g.highlights =
      across: null
      down: null
      user: {}

    # initialize Raphael canvas
    Render.setDims('crossword') \
      @g.grid.width + @g.grid.margin, @g.grid.height + @g.grid.margin

    @g.overlay = null

    @setUpEvents()

  setUpEvents: ->
    @socket.on 'square set', ([id, [i, j], val]) =>
      @_setUserSquare (@ui.users.filter (user) => user.id == id)[0], [i, j], val, true

    @socket.on 'users', (users) =>
      @ui.users = users
      self = (users.filter (user) => user.id == @ui.id)[0]
      @user.color = self.color

    @socket.on 'existing puzzle', (room) =>
      console.log 'existing', room
      @loadPuzzle new Puzzle room.puzzle
      @eachSquare ([r, c]) =>
        if room.grid[r][c]
          @_setUserSquare (@ui.users.filter (user) => user.id == room.gridOwners[r][c])[0], [r, c], room.grid[r][c], true

  eachSquare: (fn) ->
    for r in [0...@p.height]
      for c in [0...@p.width]
        fn [r, c]

  render: ->
    # Draw and format puzzle numbers
    @g.numbers = {}
    @g.blackSquares = {}
    @g.filledSquares = {}
    @g.letters = {}

    addNumber = Render.text 'numbers'
    addBlackSquare = Render.rect 'black-squares'
    addFilledSquare = Render.rect 'filled-squares'
    addLetter = Render.text 'letters'

    for r in [0...@p.height]
      @g.numbers[r] = {}
      @g.blackSquares[r] = {}
      @g.filledSquares[r] = {}
      @g.letters[r] = {}

      for c in [0...@p.width]
        if @p.gridNumbers[r][c]
          @g.numbers[r][c] = addNumber \
            @g.grid.squareSize * c + 3,
            @g.grid.squareSize * r + 8.5,
            @p.gridNumbers[r][c]

        if @p.grid[r][c] == '_'
          @g.blackSquares[r][c] = addBlackSquare \
            @g.grid.squareSize * c + 1,
            @g.grid.squareSize * r + 1,
            @g.grid.squareSize - 1,
            @g.grid.squareSize - 1

        @g.filledSquares[r][c] = addFilledSquare \
          @g.grid.squareSize * c + 1,
          @g.grid.squareSize * r + 1,
          @g.grid.squareSize - 1,
          @g.grid.squareSize - 1

        @g.letters[r][c] = addLetter \
          (c + 0.5) * @g.grid.squareSize,
          (r + 0.55) * @g.grid.squareSize,
          ''

    # add grid lines
    addGridline = Render.path 'gridlines'

    for offset in [0..@p.height]
      pxoff = @g.grid.squareSize * offset + 0.5
      @g.grid.lines.push \
        addGridline("M#{pxoff},0.5v#{@g.grid.height}"),
        addGridline("M0.5,#{pxoff}h#{@g.grid.width}")

    @g.overlay = Render.rect('background') 0, 0, @g.grid.width, @g.grid.height
    @g.overlay.addEventListener 'click', (e) =>
      ei = ~~(e.layerY / @g.grid.squareSize)
      ej = ~~(e.layerX / @g.grid.squareSize)
      # flip directions if same square is clicked
      if ei == @g.ci and ej == @g.cj
        @flipDir()
      @_setHighlight 'user', [ei, ej]

    @g.ci = 0
    @g.cj = 0
    @g.dir = dir.ACROSS

    # replace puzzle title
    $('.puzzle-title').html @p.title

    # load clue lists
    acrossClues = ({ num: parseInt(num), text: clue, dir: 'across' } for num, clue of @p.clues.across)
    downClues = ({ num: parseInt(num), text: clue, dir: 'down' } for num, clue of @p.clues.down)
    @ui.clues.across = acrossClues
    @ui.clues.down = downClues
    @ui.cluesObj = @p.clues

    # initialize user highlights
    addCursor = Render.rect 'cursor'

    @g.highlights.user['user'] = addCursor \
      3, 3,
      @g.grid.squareSize - 5, @g.grid.squareSize - 5,
      'id': 'highlight-square'
      'stroke-width': 4
    @g.highlights.down = addCursor 0, 0, 0, 0,
      'id': 'highlight-down'
      'stroke-width': 4
    @g.highlights.across = addCursor 0, 0, 0, 0,
      'id': 'highlight-across'
      'stroke-width': 4

    console.log 'rendered'

    @moveToFirstWhiteCell()

  renderKeyBindings: (bindings) ->
    html = ''

    categories = {}
    categoryOrder = ['basic', 'cell', 'misc', 'clue', 'word', 'puzzle']
    for category in categoryOrder
      categories[category] = []

    for seq, [fName, ...] of bindings
      f = @[fName]
      seqAndF = [seq, f]
      categories[f.category].push seqAndF
      categories['basic'].push seqAndF if f.basic

    for category in categoryOrder
      html += '<h5>' + category + '</h5><table>'
      html += '<tr><th class="c1">Shortcut</th><th class="c3">Description</th></tr>'
      for [seq, f] in categories[category]
        kbd = '<kbd>' + seq + '</kbd>'
        html += '<tr><td class="c1">' + kbd + '</td><td class="c3">' + f.desc + '</td></tr>'
      html += '</table>'

    el = document.getElementById 'key-bindings'
    el.innerHTML = html

  resetGrid: ->
    for r in [0...@p.height]
      for c in [0...@p.width]
        @g.numbers?[r]?[c]?.remove()
        @g.letters?[r]?[c]?.remove()
        @g.blackSquares?[r]?[c]?.remove()
        if @g.filledSquares
          @_setSquareColor(null, [r, c])

    # clear highlights
    @g.highlights.user['user']?.remove()
    @g.highlights.across?.remove()
    @g.highlights.down?.remove()

    for line in @g.grid.lines
      line.remove()
    @g.grid.lines = []

  loadPuzzle: (@p) ->
    # load puzzle data into manager and render
    @resetGrid()
    @render()

  # FIXME don't store puzzle state in svg
  getSquare: ([r, c]) ->
    @g.letters[r][c].firstChild.textContent

  setSquare: (cell, value, moveForwards) ->
    @_setUserSquare @user, cell, value
    @socket.emit 'set square', [cell, value]
    if moveForwards
      @moveForwards true

  _setUserSquare: (user, [r, c], value, server) ->
    oldValue = @getSquare([r, c])
    @g.letters[r][c].firstChild.textContent = value
    color = if value then user.color else 'none'
    if oldValue != value or server
      @_setSquareColor color, [r, c]

  _setSquareColor: (color, [r, c]) ->
    @g.filledSquares[r][c].setAttribute 'fill', color

  currentCell: ->
    [@g.ci, @g.cj]

  currentClue: (direction = @g.dir) ->
    @p.getClueNumberForCell @currentCell(), direction

  currentClueObj: ->
    direction: if isd(@g.dir, dir.DOWN) then 'down' else 'across'
    clueNumber:
      down: @currentClue dir.DOWN
      across: @currentClue dir.ACROSS

  it = -> new Action arguments... # probably a bad idea
  class Action # suit
    constructor: (desc, category, basic, f) ->
      f.desc = desc
      f.category = category
      f.basic = basic
      return f


  help: it 'shows this list of keyboard shortcuts', 'misc', false, ->
    $('#key-bindings-dialog').foundation 'reveal', 'open'

  setCurrentSquare: it 'writes the given letter in the current cell', 'cell', true, (value, moveForwards) ->
    @setSquare @currentCell(), value, moveForwards

  flipDir: it 'switches direction', 'misc', true, ->
    @g.dir = if isd(@g.dir, dir.ACROSS) then dir.DOWN else dir.ACROSS
    @_reHighlight()

  # move in direction
  moveToCell: (cell, d) ->
    @_setHighlight 'user', cell


  moveInDirection: it 'moves in the given direction', 'cell', true, (direction, remainOnThisClue) ->
    @moveToCell @p.getNextSquareInDirection @currentCell(), direction, remainOnThisClue

  moveToFarthestValidCellInDirection: it 'moves to the boundary of the current clue in the given direction', 'clue', false, (direction, skipFirstBlackCells) ->
    @moveToCell @p.getFarthestValidCellInDirection @currentCell(), direction, skipFirstBlackCells

  moveToClue: (clueNumber, d) ->
    @g.dir = if d then d else @g.dir
    @moveToCell @p.gridNumbersRev[clueNumber]

  moveForwards: (remainOnThisClue) ->
    @moveInDirection @g.dir, remainOnThisClue
  moveBackwards: (remainOnThisClue) ->
    @moveInDirection dir.reflect(@g.dir), remainOnThisClue

  moveToNextClue: it 'moves to the start of the next clue', 'clue', true, ->
    @moveToClue (@p.getNextClueNumber @currentClue(), @g.dir, 1)
  moveToPreviousClue: it 'moves to the start of the previous clue', 'clue', false, ->
    @moveToClue (@p.getNextClueNumber @currentClue(), @g.dir, -1)

  moveToStartOfCurrentClue: it 'moves to the start of the current clue', 'clue', false, ->
    @moveToFarthestValidCellInDirection dir.reflect(@g.dir), false
  moveToEndOfCurrentClue: it 'moves to the end of the current clue', 'clue', false, ->
    @moveToFarthestValidCellInDirection @g.dir, false

  moveToFirstWhiteCell: it 'moves to the first white cell', 'puzzle', false, ->
    @moveToCell @p.firstWhiteCell
  moveToLastWhiteCell: it 'moves to the last white cell', 'puzzle', false, ->
    @moveToCell @p.lastWhiteCell

  enterRebus: it 'allows writing multiple letters in a single cell', 'misc', false, ->
    console.error "#{arguments.callee.name} not implemented"

  erase: (remainOnThisClue, moveBackwards) ->
    @setCurrentSquare '', false
    if moveBackwards
      @moveBackwards remainOnThisClue
  backspace: it 'erases the current cell, then moves backwards', 'cell', true, ->
    @erase true, true
  delete: it 'erases the current cell, without moving backwards', 'cell', false, ->
    @erase true, false

  eraseToStartOfCurrentClue: it 'erases to the start of the current clue;
    or, if the current cell is blank and at the start of a clue, erases to the start of the previous clue', 'clue', false, ->
    skipFirstBlackCells = '' == @getSquare @currentCell()
    @moveToCell @p.getFarthestValidCellInDirection @currentCell(), dir.reflect(@g.dir), skipFirstBlackCells,
      (cell) => @setSquare cell, '', false
  eraseToEndOfCurrentClue: it 'erases to the end of the current clue, without moving', 'clue', false, ->
    @p.getFarthestValidCellInDirection @currentCell(), @g.dir, false,
      (cell) => @setSquare cell, '', false

  _skipAllEmptySoFar: (erase) ->
    allEmptySoFar = first = true
    (cell) =>
      if not first or erase
        allEmptySoFar &= currentIsEmpty = '' == @getSquare cell
      else
        first = false
      throw true if currentIsEmpty and not allEmptySoFar
      if erase
        @setSquare cell, '', false

  moveToBoundaryOfCurrentLetterSequenceInDirection: it 'moves to the end of the sequence of letters in the given direction', 'word', false, (direction, skipFirstBlackCells) ->
    @moveToCell @p.getFarthestValidCellInDirection @currentCell(), direction, skipFirstBlackCells,
      @_skipAllEmptySoFar false

  eraseToStartOfCurrentLetterSequence: it 'erases to the start of the current sequence of letters;
    or, if the current cell is blank, erases to the start of the previous sequence of letters', 'word', false, ->
    skipFirstBlackCells = '' == @getSquare @currentCell()
    @moveToCell @p.getFarthestValidCellInDirection @currentCell(), dir.reflect(@g.dir), skipFirstBlackCells,
      @_skipAllEmptySoFar true
  eraseToEndOfCurrentLetterSequence: it 'erases to the end of the current sequence of letters, without moving', 'word', false, ->
    @p.getFarthestValidCellInDirection @currentCell(), @g.dir, false,
      @_skipAllEmptySoFar true


  _setHighlight: (id, [r, c]) ->
    if not @p.isValidSquare [r, c]
      return

    Render._setAttributes @g.highlights.user[id],
      x: @g.grid.squareSize * c + 3
      y: @g.grid.squareSize * r + 3

    if id is 'user'
      [@g.ci, @g.cj] = [r, c]

    @_reHighlight()

  _highlightClass: (direction) ->
    if isd(@g.dir, direction) then 'highlight-parallel' else 'highlight-perpendicular'

  _reHighlight: ->
    # update clue text
    @ui.currentClue = @currentClueObj()

    # update highlights
    [sr, er, sc, ec] = @p.getCursorRanges @currentCell()

    Render._setAttributes @g.highlights.down,
      x: @g.grid.squareSize * @g.cj + 3
      y: @g.grid.squareSize * sr + 3
      width: @g.grid.squareSize - 5
      height: @g.grid.squareSize * (er - sr + 1) - 5
    @g.highlights.down.className.baseVal = @_highlightClass dir.DOWN

    Render._setAttributes @g.highlights.across,
      x: @g.grid.squareSize * sc + 3
      y: @g.grid.squareSize * @g.ci + 3
      width: @g.grid.squareSize * (ec - sc + 1) - 5
      height: @g.grid.squareSize - 5
    @g.highlights.across.className.baseVal = @_highlightClass dir.ACROSS
