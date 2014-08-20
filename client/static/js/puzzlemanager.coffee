
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
    @g.numbers = {}
    @g.blackSquares = {}
    currentNumber = 1
    for r in [0...@p.height]
      @g.numbers[r] = {}
      @g.blackSquares[r] = {}
      for c in [0...@p.width]
        if @p.gridNumbers[r][c]
          @g.numbers[r][c] = @g.paper.text(
            @g.grid.squareSize * c + 3,
            @g.grid.squareSize * r + 8.5,
            @p.gridNumbers[r][c])
            .attr @g.grid.numbers.style
        if @p.grid[r][c] == '_'
          @g.blackSquares[r][c] = @g.paper.rect(
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
          'font-size': 24
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

    # replace puzzle title
    $('.puzzle-title').html @p.title

    # load clue lists
    acrossClues = ({ num: parseInt(num), text: clue, dir: 'across' } for num, clue of @p.clues.across)
    downClues = ({ num: parseInt(num), text: clue, dir: 'down' } for num, clue of @p.clues.down)
    @ui.clues.across = acrossClues
    @ui.clues.down = downClues

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

  flipDir: ->
    @g.dir = if @g.dir == dir.ACROSS then dir.DOWN else dir.ACROSS
    @_reHighlight()

  loadPuzzle: (@p) ->  
    # load puzzle data into manager and render
    @resetGrid()
    @render()

  # FIXME don't store puzzle state in svg
  getSquare: ([r, c]) ->
    @g.letters[r][c].attr 'text'

  setSquare: ([r, c], value, moveForwards) ->
    @g.letters[r][c].attr
      text: value

    if moveForwards
      @moveForwards true

  setCurrentSquare: (value, moveForwards) ->
    @setSquare @currentCell(), value, moveForwards

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


  # move in direction
  moveToCell: (cell) ->
    @_setHighlight 'user', cell


  moveInDirection: (direction, remainOnThisClue) ->
    @moveToCell @p.getNextSquareInDirection @currentCell(), direction, remainOnThisClue

  moveToFarthestValidCellInDirection: (direction, skipFirstBlackCells) ->
    @moveToCell @p.getFarthestValidCellInDirection @currentCell(), direction, skipFirstBlackCells

  moveToClue: (clueNumber) ->
    @moveToCell @p.gridNumbersRev[clueNumber]


  moveForwards: (remainOnThisClue) ->
    @moveInDirection @g.dir, remainOnThisClue
  moveBackwards: (remainOnThisClue) ->
    @moveInDirection dir.reflect(@g.dir), remainOnThisClue

  moveToNextClue: ->
    @moveToClue (@p.getNextClueNumber @currentClue(), @g.dir, 1)
  moveToPreviousClue: ->   
    @moveToClue (@p.getNextClueNumber @currentClue(), @g.dir, -1)

  moveToStartOfCurrentClue: ->
    @moveToFarthestValidCellInDirection dir.reflect(@g.dir), false
  moveToEndOfCurrentClue: ->
    @moveToFarthestValidCellInDirection @g.dir, false

  moveToFirstWhiteCell: ->
    @moveToCell @p.firstWhiteCell
  moveToLastWhiteCell: ->
    @moveToCell @p.lastWhiteCell

  enterRebus: ->
    console.error "#{arguments.callee.name} not implemented"

  erase: (remainOnThisClue, moveBackwards) ->
    @setCurrentSquare '', false
    if moveBackwards
      @moveBackwards remainOnThisClue
  eraseToStartOfCurrentClue: ->
    skipFirstBlackCells = '' == @getSquare @currentCell()
    @moveToCell @p.getFarthestValidCellInDirection @currentCell(), dir.reflect(@g.dir), skipFirstBlackCells,
      (cell) => @setSquare cell, '', false
  eraseToEndOfCurrentClue: ->
    @p.getFarthestValidCellInDirection @currentCell(), @g.dir, false,
      (cell) => @setSquare cell, '', false

  _setHighlight: (id, [r, c]) ->
    if not @p.isValidSquare [r, c]
      return

    @g.highlights.user[id]?.attr
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
