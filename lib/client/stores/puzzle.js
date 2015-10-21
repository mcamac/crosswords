import Immutable from 'immutable'
import R from 'ramda'


var defaultPuzzle = require('json!../../../server/default-puzzle.json')
defaultPuzzle.grid = R.map(R.split(''), defaultPuzzle.puzzle)
defaultPuzzle.grid.width = puzzle.length;
delete defaultPuzzle.puzzle
console.log(defaultPuzzle)
defaultPuzzle.cursor = {r: 0, c: 0};

const initialState = defaultPuzzle;
// Immutable.fromJS({
//   grid: {
//     dimensions: { width: 15, height: 15 }
//   },
//   clues: {
//     across: {},
//     down: {}
//   },
//   title: '',
//   author: ''
// })

var DIR = {
  up: {r: -1, c: 0},
  down: {r: 1, c: 0},
  right: {r: 0, c: 1},
  left: {r: 0, c: -1}
};

function inBounds(grid, square) {
  return (0 <= square.r && square.r < grid.length) && (0 <= square.c && square.c < grid.length);
}

function valid(grid, square) {
  console.log(grid, square, grid[square.r][square.c])
  return inBounds(grid, square) && (grid[square.r][square.c] !== '_')
}

function nextSquare(grid, square, d) {
  var next = {r: square.r + d.r, c: square.c + d.c}
  var moved = next;
  while (inBounds(grid, next) && !valid(grid, next)) {
    next = {r: moved.r + d.r, c: moved.c + d.c}
    moved = next
  }
  if (!inBounds(grid, moved)) moved = square
  return moved
}


var arrowPress = (state, action) => {
  var dir = DIR[action.key]
  var cursor = nextSquare(state.grid, state.cursor, dir)
  return {
    ...state,
    cursor
  }
}

var letterPress = (state, action) => {
  var grid = R.clone(state.grid)
  grid[state.cursor.r][state.cursor.c] = action.key.toUpperCase()
  var cursor = nextSquare(state.grid, state.cursor, DIR.right)
  return {
    ...state,
    grid,
    cursor
  }
}

const actions = {
  NEW_PUZZLE: (state, action) => state,
  ARROW_PRESS: arrowPress,
  LETTER_PRESS: letterPress
}


export default function puzzle(state = initialState, action) {
  console.log(state, action)
  if (!actions[action.type]) return state
  return actions[action.type](state, action)
}
