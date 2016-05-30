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

export const nextSquareSoft = (grid, [r, c], [dr, dc]) => {
  let [nr, nc] = [r + dr, c + dc]
  if (!inBounds(grid, [nr, nc]) || !valid(grid, [nr, nc])) return [r, c]
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

const gridMap = (N, fn) => {
  return R.range(0, N).map(r => R.range(0, N).map(c => fn([r, c])))
}

export const processPuzzle = puzzle => {
  let sqi = R.xprod(R.range(0, 15), R.range(0, 15))
  puzzle.grid = puzzle.puzzle
  puzzle.clueBounds = boundarySquares(puzzle.grid)
  puzzle.numbered = sqi.filter(([r, c]) =>
    valid(puzzle.grid, [r, c])
      && (!valid(puzzle.grid, [r - 1, c]) || !valid(puzzle.grid, [r, c - 1]))
  )
  puzzle.numbers = R.range(0, 15).map(() => [])
  puzzle.clueStarts = {}
  puzzle.numbered.forEach(([r, c], n) => {
    puzzle.numbers[r][c] = n + 1
    puzzle.clueStarts[n + 1] = [r, c]
  })
  puzzle.clueNums = gridMap(15, ([r, c]) => {
    if (puzzle.grid[r][c] === '_') return {}
    const {A: [A], D: [D]} = clueBoundsForSquare(puzzle.grid, [r, c])
    return {
      A: puzzle.numbers[A[0]][A[1]],
      D: puzzle.numbers[D[0]][D[1]],
    }
  })
  return {
    nextSquare: (sq, dir) => nextSquare(puzzle.grid, sq, dir),
    nextSquareSoft: (sq, dir) => nextSquareSoft(puzzle.grid, sq, dir),
    valid: sq => valid(puzzle.grid, sq),
    ...puzzle,
  }
}
