import R from 'ramda'

const inBounds = (grid, [r, c]) => {
  return r >= 0 && c >= 0 && r < 15 && c < 15
}

const valid = (grid, [r, c]) => {
  return inBounds(grid, [r, c]) && grid[r][c] !== '_'
}

const DIR_MAP = {
  A: [0, 1],
  D: [1, 0],
}

export const nextSquare = (grid, [r, c], [dr, dc]) => {
  let [nr, nc] = [r + dr, c + dc]
  while (inBounds(grid, [nr, nc]) && !valid(grid, [nr, nc])) {
    nr += dr
    nc += dc
  }
  if (!inBounds(grid, [nr, nc])) return [r, c]
  return [nr, nc]
}

const clueBoundsForSquare = (grid, [r, c]) => {
  if (!valid(grid, [r, c])) return {}
  const bounds = {}
  R.keys(DIR_MAP).map(key => {
    const [dr, dc] = DIR_MAP[key]
    let [br, bc] = [r, c]
    while (valid(grid, [br - dr, bc - dc])) {
      br -= dr
      bc -= dc
    }
    let [nr, nc] = [r, c]
    while (valid(grid, [nr + dr, nc + dc])) {
      nr += dr
      nc += dc
    }
    bounds[key] = [[br, bc], [nr, nc]]
  })
  return bounds
}

const boundarySquares = grid => {
  const bounds = R.range(0, 15).map(() => ([]))
  let sqi = R.xprod(R.range(0, 15), R.range(0, 15))
  sqi.forEach(([r, c]) => {
    bounds[r][c] = clueBoundsForSquare(grid, [r, c])
  })
  return bounds
}

export const processPuzzle = puzzle => {
  let sqi = R.xprod(R.range(0, 15), R.range(0, 15))
  puzzle.grid = puzzle.puzzle
  puzzle.clueBounds = boundarySquares(puzzle.grid)
  puzzle.numbered = sqi.filter(([r, c]) =>
    valid(puzzle.grid, [r, c])
      && (!valid(puzzle.grid, [r - 1, c]) || !valid(puzzle.grid, [r, c - 1]))
  )
  return {
    nextSquare: (sq, dir) => nextSquare(puzzle.grid, sq, dir),
    ...puzzle,
  }
}
