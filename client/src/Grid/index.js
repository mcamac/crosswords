import React, {Component} from 'react'
import ReactDOM from 'react-dom'
import key from 'keymaster'
import R from 'ramda'
import {isEqual, set} from 'lodash/fp'

import StaticGrid from './StaticGrid'

let width = 600
let height = 600
let rows = 15
let squareSize = width / rows

const ClickOverlay = ({width, height, onClick}) =>
<g>
  <rect onClick={onClick} fill='black' opacity='0.0' x={0} y={0} width={width} height={height}/>
</g>

const Cursor = ({c, r, squareSize}) =>
  <rect
    fill='blue'
    opacity='0.2'
    x={c * squareSize}
    y={r * squareSize} width={squareSize} height={squareSize}
  />

const LETTERS = 'abcdefghijklmnopqrstuvwxyz'.split('').join(',')

class GridI extends Component {
  onClick = event => {
    let node = ReactDOM.findDOMNode(this).parentElement
    const {top: nodeTop, left: nodeLeft} = node.getBoundingClientRect()
    let cursor = [
      Math.floor((event.clientY - nodeTop) / squareSize),
      Math.floor((event.clientX - nodeLeft) / squareSize),
    ]
    this.props.onClick(cursor)
  }

  render() {
    let {puzzle, direction, cursor: [r, c]} = this.props
    const {A, D} = puzzle.clueBounds[r][c]
    return (
      <g>
        <g>
          <Cursor c={c} r={r} squareSize={squareSize} />
          <rect
            stroke={direction === 'A' ? 'blue' : 'gray'}
            strokeWidth='6px'
            fill='none'
            opacity='0.2'
            x={squareSize * A[0][1] + 3}
            y={squareSize * A[0][0] + 3}
            width={squareSize * (A[1][1] - A[0][1] + 1) - 4}
            height={squareSize - 4}
          />
          <rect
            stroke={direction === 'D' ? 'blue' : 'gray'}
            strokeWidth='6px'
            fill='none'
            opacity='0.2'
            x={squareSize * D[0][1] + 3}
            y={squareSize * D[0][0] + 3}
            height={squareSize * (D[1][0] - D[0][0] + 1) - 4}
            width={squareSize - 4}
          />
        </g>
        <ClickOverlay width={width} height={height} onClick={this.onClick} />
      </g>
    )
  }
}

const flipD = direction => direction === 'A' ? 'D' : 'A'

const ARROWS = {
  Left: [0, -1],
  Right: [0, 1],
  Down: [1, 0],
  Up: [-1, 0],
}

let sqi = R.xprod(R.range(0, 15), R.range(0, 15))

export default class Grid extends Component {
  state = {
    cursor: [0, 0],
    direction: 'A',
    fill: this.props.puzzle.puzzle.map(row => row.split('')),
  }

  componentDidMount() {
    key(LETTERS, event => {
      this.onLetterPress(String.fromCharCode(event.which))
    })

    key('space', event => {
      event.preventDefault()
      const {direction} = this.state
      this.setState({direction: flipD(direction)})
    })

    key('tab', event => {
      console.log('tab')
      event.preventDefault()
    })

    key('backspace', event => {
      event.preventDefault()
      this.onBackspace()
    })

    key('shift+tab', event => {
      console.log('shift tab')
      event.preventDefault()
    })

    key('left,right,up,down', event => {
      event.preventDefault()
      this.onArrowPress(event.code.slice(5))
    })
  }

  setCursor = cursor => this.setState({cursor})

  onClick = ([nr, nc]) => {
    let {puzzle} = this.props
    if (!puzzle.valid([nr, nc])) return
    const {direction, cursor: [r, c]} = this.state
    this.setState({
      direction: isEqual([r, c], [nr, nc]) ? flipD(direction) : direction,
      cursor: [nr, nc],
    })
  }

  onBackspace = () => {
    let {puzzle} = this.props
    const {direction, cursor: [r, c]} = this.state
    const [dr, dc] = direction === 'A' ? [0, 1] : [1, 0]
    this.setState({
      fill: set([r, c], '', this.state.fill),
      cursor: puzzle.nextSquare([r, c], [-dr, -dc]),
    })
  }

  onLetterPress = letter => {
    let {puzzle} = this.props
    const {direction, cursor: [r, c]} = this.state
    const [dr, dc] = direction === 'A' ? [0, 1] : [1, 0]
    this.setState({
      fill: set([r, c], letter, this.state.fill),
      cursor: puzzle.nextSquareSoft([r, c], [dr, dc]),
    })
  }

  onArrowPress = direction => {
    let {puzzle} = this.props
    const [r, c] = this.state.cursor
    const [dr, dc] = ARROWS[direction]
    this.setCursor(puzzle.nextSquare([r, c], [dr, dc]))
  }

  render() {
    let P = this.props.puzzle
    const {cursor, direction, fill} = this.state
    console.log(P)
    return (
      <svg width={width + 2} height={height + 2}>
        <StaticGrid
          squareSize={squareSize}
          height={height}
          rows={rows}
          puzzle={P}
        />
        <g>
          {sqi.map(([r, c]) => (
            <text
              key={`${r}_${c}`}
              style={{fontSize: '19px', fontFamily: 'Source Code Pro'}}
              x={(c + 0.5) * squareSize}
              y={(r + 0.5) * squareSize + 8}
              textAnchor='middle'
              >
              {fill[r][c]}
            </text>
          ))}
        </g>
        <GridI direction={direction} puzzle={P} cursor={cursor} onClick={this.onClick} />
      </svg>
    )
  }
}
