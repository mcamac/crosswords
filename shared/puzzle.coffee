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

  isValidSquare: ([r, c]) ->
    @isInsideGrid([r, c]) and @grid[r][c] != '_'

  isInsideGrid: ([r, c]) ->
    0 <= r < @height and 0 <= c < @width

  getNextSquareInDirection: ([r, c], [roff, coff]) ->
    # Returns the next square in the given direction, if there is any.
    [nr, nc] = [r + roff, c + coff]
    while not @isValidSquare([nr, nc])
      if not @isInsideGrid([nr, nc])
        return [r, c]
      nr += roff
      nc += coff
    return [nr, nc]

  getNextClueNumber: (num, d, offset) ->
    dirClueNumbers = if d == dir.ACROSS then @clueNumbers.across else @clueNumbers.down
    nextClueIndex = (dirClueNumbers.indexOf(num) + offset + dirClueNumbers.length) % dirClueNumbers.length
    return dirClueNumbers[nextClueIndex]

  getClueNumberForCell: ([r, c], [roff, coff]) ->
    while @isValidSquare [r - roff, c - coff]
      r -= roff
      c -= coff
    return @gridNumbers[r][c]


  _loopGrid: (callback) ->
    for r in [0...@height]    
      for c in [0...@width]
        callback [r, c]
