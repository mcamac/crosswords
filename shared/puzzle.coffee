@dir = 
  RIGHT: [0, 1]
  LEFT: [0, -1]
  DOWN: [1, 0]
  UP: [-1, 0]
  ACROSS: [0, 1]

class @Puzzle
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
      if @isValidSquare([r, c]) and (not @isValidSquare([r - 1, c]) or
                                 not @isValidSquare([r, c - 1]))
        @gridNumbersRev[currentNumber] = [r, c]
        @gridNumbers[r][c] = currentNumber++


  getNextClueNumber: (clueNumber, direction, offset) ->
    dirKey = if direction == dir.ACROSS then 'across' else 'down'
    dirClueNumbers = @clueNumbers[dirKey]

    currentClueIndex = dirClueNumbers.indexOf(clueNumber)
    nextClueIndex = (currentClueIndex + offset + dirClueNumbers.length) % dirClueNumbers.length

    return dirClueNumbers[nextClueIndex]


  isValidSquare: ([r, c]) ->
    @isInsideGrid([r, c]) and @grid[r][c] != '_'

  isInsideGrid: ([r, c]) ->
    0 <= r < @height and 0 <= c < @width

  getNextSquareInDirection: ([r, c], [roff, coff], remainOnThisClue) ->
    # Returns the next square in the given direction, if there is any.
    [nr, nc] = [r + roff, c + coff]
    while not @isValidSquare([nr, nc])
      if not @isInsideGrid([nr, nc]) or remainOnThisClue
        return [r, c]
      nr += roff
      nc += coff
    return [nr, nc]

  getClueNumberForCell: ([r, c], [roff, coff]) ->
    while @isValidSquare [r - roff, c - coff]
      r -= roff
      c -= coff
    return @gridNumbers[r][c]

  getCursorRanges: ([r, c]) ->
    [sr, er, sc, ec] = [r, r, c, c]

    while @isValidSquare [sr - 1, c]
      sr--
    while @isValidSquare [er + 1, c]
      er++
    while @isValidSquare [r, sc - 1]
      sc--
    while @isValidSquare [r, ec + 1]
      ec++

    return [sr, er, sc, ec]


  _loopGrid: (callback) ->
    for r in [0...@height]    
      for c in [0...@width]
        callback [r, c]
