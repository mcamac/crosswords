import R from 'ramda'

export const processPuzzle = puzzle => {
  let sqi = R.xprod(R.range(0, 15), R.range(0, 15))
  puzzle.grid = puzzle.puzzle
  puzzle.numbered = sqi.filter(([r, c]) =>
    puzzle.grid[r][c] !== '_'
      && (r === 0 || c === 0 || puzzle.grid[r - 1][c] === '_' || puzzle.grid[r][c - 1] === '_')
  )
  return puzzle
}
