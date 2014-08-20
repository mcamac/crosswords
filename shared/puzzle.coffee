@dir = 
  RIGHT: [0, 1]
  LEFT: [0, -1]
  DOWN: [1, 0]
  UP: [-1, 0]
  ACROSS: [0, 1]
  reflect: ([r, c]) -> [-r, -c]

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

    # compute where numbers are
    @gridNumbers = (null for r in [0...@height] for c in [0...@width])
    @gridNumbersRev = {}

    currentNumber = 1
    @_loopGrid ([r, c]) ->
      if @isValidSquare([r, c]) and (not @isValidSquare([r - 1, c]) or
                                 not @isValidSquare([r, c - 1]))
        @gridNumbersRev[currentNumber] = [r, c]
        @gridNumbers[r][c] = currentNumber++
      return

    @firstWhiteCell = @_loopGrid @isValidSquare, false
    @lastWhiteCell = @_loopGrid @isValidSquare, true

  getNextClueNumber: (clueNumber, direction, offset) ->
    dirKey = if direction == dir.ACROSS then 'across' else 'down'
    dirClueNumbers = @clueNumbers[dirKey]

    currentClueIndex = dirClueNumbers.indexOf(clueNumber)
    nextClueIndex = (currentClueIndex + offset + dirClueNumbers.length) % dirClueNumbers.length

    return dirClueNumbers[nextClueIndex]


  isValidSquare: (cell) ->
    @isInsideGrid(cell) and @isWhite(cell)

  isWhite: ([r, c]) ->
    @grid[r][c] != '_'

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

  getClueNumberForCell: ([r, c], direction) ->
    [sr, sc] = @getFarthestValidCellInDirection [r, c], dir.reflect(direction)
    return @gridNumbers[sr][sc]

  getFarthestValidCellInDirection: ([r, c], [roff, coff], f) ->
    allBlackSoFar = true
    loop
      [pr, pc] = [r, c]
      if f
        f [r, c]

      nextCell = [r += roff, c += coff]
      nextCellIsInvalid = not @isValidSquare nextCell
      allBlackSoFar &= nextCellIsBlack = nextCellIsInvalid and @isInsideGrid nextCell

      break if nextCellIsInvalid
    return [pr, pc]

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


  _loopGrid: (callback, reverse) ->
    rows = [0...@height]
    cols = [0...@width]

    if reverse
      rows = rows.reverse()
      cols = cols.reverse()

    for r in rows
      for c in cols
        if callback.bind(@) [r, c]
          return [r, c]
