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
      if @isWhite [r, c]
        unless @isValidSquare([r - 1, c]) and
               @isValidSquare([r, c - 1])
          @gridNumbersRev[currentNumber] = [r, c]
          @gridNumbers[r][c] = currentNumber++
      return

    @cellNumbers = ({ across: null, down: null } for r in [0...@height] for c in [0...@width])
    cellNumberCallback = (dirName, [roff, coff]) ->
      currentNumber = null
      ([r, c]) ->
        currentNumber = @gridNumbers[r][c] if not @isValidSquare [r - roff, c - coff]
        @cellNumbers[r][c][dirName] = currentNumber if @isWhite [r, c]
        return
    @_loopGrid cellNumberCallback('across', dir.ACROSS)
    @_loopGrid cellNumberCallback('down', dir.DOWN), false, true

    @firstWhiteCell = @_loopGrid @isWhite, false
    @lastWhiteCell  = @_loopGrid @isWhite, true

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
    dirKey = if direction == dir.ACROSS then 'across' else 'down'
    return @cellNumbers[r][c][dirKey]

  # Careful! this may return an invalid cell
  getFarthestValidCellInDirection: ([r, c], [roff, coff], skipFirstBlackCells, f) ->
    allBlackSoFar = true
    loop
      if f
        try
          f [r, c]
        catch
          return [pr, pc]
      [pr, pc] = [r, c]

      nextCell = [r += roff, c += coff]
      nextCellIsInvalid = not @isValidSquare nextCell
      allBlackSoFar &= nextCellIsBlack = nextCellIsInvalid and @isInsideGrid nextCell

      break if nextCellIsInvalid and not (skipFirstBlackCells and allBlackSoFar)
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


  _loopGrid: (callback, reverse, transpose) ->
    rows = [0...@height]
    cols = [0...@width]

    if reverse
      rows = rows.reverse()
      cols = cols.reverse()

    if transpose
      [rows, cols] = [cols, rows]

    for r in rows
      for c in cols
        cell = unless transpose then [r, c] else [c, r]

        if callback.bind(@) cell
          return cell
