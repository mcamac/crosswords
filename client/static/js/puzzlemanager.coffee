
class @PuzzleManager
  constructor: (options, @ui) ->
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

    @keyManager = new KeyManager
    @keyManager.registerBindings @

    # graphics object
    @g = {}

    # settings object (for constants)
    @c = {}

    @g.grid =
      lines: []
      height: 600
      width: 600
      margin: 2
      squareSize: 600 / 15.0

    @g.highlights =
      across: null
      down: null
      user: {}

    # initialize Raphael canvas
    Render.setDims('crossword') \
      @g.grid.width + @g.grid.margin, @g.grid.height + @g.grid.margin

    @g.overlay = null

  render: ->
    # Remove and reset everything
    for line in @g.grid.lines
      line.remove()
    @g.grid.lines = []

    # Draw and format puzzle numbers
    @g.numbers = {}
    @g.blackSquares = {}
    currentNumber = 1

    addNumber = Render.text 'numbers'
    addBlackSquare = Render.rect 'black-squares'

    for r in [0...@p.height]
      @g.numbers[r] = {}
      @g.blackSquares[r] = {}
      for c in [0...@p.width]
        if @p.gridNumbers[r][c]
          @g.numbers[r][c] = addNumber \
            @g.grid.squareSize * c + 3,
            @g.grid.squareSize * r + 8.5,
            @p.gridNumbers[r][c]
        if @p.grid[r][c] == '_'
          @g.blackSquares[r][c] = addBlackSquare \
            @g.grid.squareSize * c + 0.5,
            @g.grid.squareSize * r + 0.5,
            @g.grid.squareSize,
            @g.grid.squareSize

    @g.letters = {}

    addLetter = Render.text 'letters'

    for r in [0...@p.height]
      @g.letters[r] = {}
      for c in [0...@p.width]
        @g.letters[r][c] = addLetter \
          (c + 0.5) * @g.grid.squareSize,
          (r + 0.55) * @g.grid.squareSize,
          ''

    # add grid lines
    addGridline = Render.path 'gridlines'

    for offset in [0..@p.height]
      pxoff = @g.grid.squareSize * offset + 0.5   
      @g.grid.lines.push \
        addGridline "M#{pxoff},0.5v#{@g.grid.height}",
        addGridline "M0.5,#{pxoff}h#{@g.grid.width}"

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

    # initialize user highlights
    addCursor = Render.rect 'cursor'

    @g.highlights.user['user'] = addCursor \
      3, 3,
      @g.grid.squareSize - 5, @g.grid.squareSize - 5,
      'class': 'highlight-square'
      'stroke-width': 4
    @g.highlights.down = addCursor 0, 0, 0, 0,
      'class': 'highlight-down'
      'stroke-width': 4
    @g.highlights.across = addCursor 0, 0, 0, 0,
      'class': 'highlight-across'
      'stroke-width': 4

    console.log 'rendered'

    @moveToClue 1

  resetGrid: ->
    for r in [0...@p.height]
      for c in [0...@p.width]
        @g.numbers?[r]?[c]?.remove()
        @g.blackSquares?[r]?[c]?.remove()

    # clear highlights
    @g.highlights.user['user']?.remove()
    @g.highlights.across?.remove()
    @g.highlights.down?.remove()

  loadPuzzle: (@p) ->  
    # load puzzle data into manager and render
    @resetGrid()
    @render()

  # FIXME don't store puzzle state in svg
  getSquare: ([r, c]) ->
    @g.letters[r][c].firstChild.textContent

  setSquare: ([r, c], value, moveForwards) ->
    @g.letters[r][c].firstChild.textContent = value

    if moveForwards
      @moveForwards true

  currentCell: ->
    [@g.ci, @g.cj]

  currentClue: ->
    @p.getClueNumberForCell @currentCell(), @g.dir

  currentClueObj: ->
    clueNum = @currentClue()
    if @g.dir == dir.DOWN
      dir: 'down'
      text: @p.clues.down[clueNum]
      num: clueNum
    else
      dir: 'across'
      text: @p.clues.across[clueNum]
      num: clueNum


  it = (desc, f) -> f.desc = desc; f


  setCurrentSquare: it 'writes the given letter in the current cell', (value, moveForwards) ->
    @setSquare @currentCell(), value, moveForwards

  flipDir: it 'switches direction', ->
    @g.dir = if @g.dir == dir.ACROSS then dir.DOWN else dir.ACROSS
    @_reHighlight()

  # move in direction
  moveToCell: (cell) ->
    @_setHighlight 'user', cell


  moveInDirection: it 'moves in the given direction', (direction, remainOnThisClue) ->
    @moveToCell @p.getNextSquareInDirection @currentCell(), direction, remainOnThisClue

  moveToFarthestValidCellInDirection: it 'moves to the boundary of the current clue in the given direction', (direction, skipFirstBlackCells) ->
    @moveToCell @p.getFarthestValidCellInDirection @currentCell(), direction, skipFirstBlackCells

  moveToClue: (clueNumber) ->
    @moveToCell @p.gridNumbersRev[clueNumber]


  moveForwards: (remainOnThisClue) ->
    @moveInDirection @g.dir, remainOnThisClue
  moveBackwards: (remainOnThisClue) ->
    @moveInDirection dir.reflect(@g.dir), remainOnThisClue

  moveToNextClue: it 'moves to the start of the next clue', ->
    @moveToClue (@p.getNextClueNumber @currentClue(), @g.dir, 1)
  moveToPreviousClue: it 'moves to the start of the previous clue', ->
    @moveToClue (@p.getNextClueNumber @currentClue(), @g.dir, -1)

  moveToStartOfCurrentClue: it 'moves to the start of the current clue', ->
    @moveToFarthestValidCellInDirection dir.reflect(@g.dir), false
  moveToEndOfCurrentClue: it 'moves to the end of the current clue', ->
    @moveToFarthestValidCellInDirection @g.dir, false

  moveToFirstWhiteCell: it 'moves to the first white cell', ->
    @moveToCell @p.firstWhiteCell
  moveToLastWhiteCell: it 'moves to the last white cell', ->
    @moveToCell @p.lastWhiteCell

  enterRebus: it 'allows writing multiple letters in a single cell', ->
    console.error "#{arguments.callee.name} not implemented"

  erase: (remainOnThisClue, moveBackwards) ->
    @setCurrentSquare '', false
    if moveBackwards
      @moveBackwards remainOnThisClue
  backspace: it 'erases the current cell, then moves backwards', ->
    @erase true, true
  delete: it 'erases the current cell, without moving backwards', ->
    @erase true, false

  eraseToStartOfCurrentClue: it 'erases to the start of the current clue;
    or, if the current cell is blank and at the start of a clue, erases to the start of the previous clue', ->
    skipFirstBlackCells = '' == @getSquare @currentCell()
    @moveToCell @p.getFarthestValidCellInDirection @currentCell(), dir.reflect(@g.dir), skipFirstBlackCells,
      (cell) => @setSquare cell, '', false
  eraseToEndOfCurrentClue: it 'erases to the end of the current clue, without moving', ->
    @p.getFarthestValidCellInDirection @currentCell(), @g.dir, false,
      (cell) => @setSquare cell, '', false

  _skipAllEmptySoFar: (erase) ->
    allEmptySoFar = first = true
    (cell) =>
      if not first
        allEmptySoFar &= currentIsEmpty = '' == @getSquare cell
        first = false
      throw true if currentIsEmpty and not allEmptySoFar
      if erase
        @setSquare cell, '', false

  moveToBoundaryOfCurrentLetterSequenceInDirection: it 'moves to the end of the sequence of letters in the given direction', (direction, skipFirstBlackCells) ->
    @moveToCell @p.getFarthestValidCellInDirection @currentCell(), direction, skipFirstBlackCells,
      @_skipAllEmptySoFar false

  eraseToStartOfCurrentLetterSequence: it 'erases to the start of the current sequence of letters;
    or, if the current cell is blank, erases to the start of the previous sequence of letters', ->
    skipFirstBlackCells = '' == @getSquare @currentCell()
    @moveToCell @p.getFarthestValidCellInDirection @currentCell(), dir.reflect(@g.dir), skipFirstBlackCells,
      @_skipAllEmptySoFar true
  eraseToEndOfCurrentLetterSequence: it 'erases to the end of the current sequence of letters, without moving', ->
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
    @g.highlights.down.classList[if @g.dir == dir.DOWN then 'add' else 'remove'] 'highlight-parallel'
    @g.highlights.down.classList[if @g.dir == dir.DOWN then 'remove' else 'add'] 'highlight-perpendicular'

    Render._setAttributes @g.highlights.across,
      x: @g.grid.squareSize * sc + 3
      y: @g.grid.squareSize * @g.ci + 3
      width: @g.grid.squareSize * (ec - sc + 1) - 5
      height: @g.grid.squareSize - 5 
    @g.highlights.across.classList[if @g.dir == dir.ACROSS then 'add' else 'remove'] 'highlight-parallel'
    @g.highlights.across.classList[if @g.dir == dir.ACROSS then 'remove' else 'add'] 'highlight-perpendicular'
