import React from 'react'
import R from 'ramda'
import Mousetrap from 'mousetrap'

var gridLineProps = {
  stroke: '#888888',
  strokeWidth: '0.5'
}

export default class Puzzle extends React.Component {
  componentDidMount() {
    ['up', 'left', 'right', 'down'].forEach(
      (key) => Mousetrap.bind(key, R.partial(this.props.arrowPress, key)))
    'abcdefghijklmnopqrstuvwxyz'.split('').forEach(
      (key) => Mousetrap.bind(key, R.partial(this.props.letterPress, key)))
  }
  render() {
    // console.log(this.props)
    var puzzle = this.props.puzzle
    var width = this.props.puzzle.width
    // console.log(puzzle.grid)
    var squares = R.xprod(R.range(0, 15), R.range(0, 15))
    // console.log(squares)
    return <div>
      <h3>{puzzle.title}</h3>
      <svg height={602} width={602}>
        <g transform="translate(1,1)">
          <g>
            {R.map((r) => <line key={'r' + r} x1={0.5} x2={600.5} y1={40 * r + 0.5} y2={40 * r + 0.5} {...gridLineProps}/>, R.range(0, width + 1))}
            {R.map((r) => <line key={'c' + r} y1={0.5} y2={600.5} x1={40 * r + 0.5} x2={40 * r + 0.5} {...gridLineProps}/>, R.range(0, width + 1))}
          </g>
          <g>
          </g>
          <g>
            {R.map(([r, c]) => <text x={40 * c + 15} y={40 * r + 25}>{puzzle.grid[r][c]}</text>, squares)}
          </g>
          <g>
            {R.map(([r, c]) => puzzle.grid[r][c] === '_' ? <rect x={40 * c} y={40 * r} width={40} height={40} fill='black'/> : null, squares)}
          </g>
          <g>
            <rect x={40 * puzzle.cursor.c} y={40 * puzzle.cursor.r} width={40} height={40} stroke='steelblue' fill='none'/>
          </g>
        </g>
      </svg>
    </div>
  }
}
