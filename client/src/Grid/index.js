import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import key from 'keymaster'
import R from 'ramda'
import {set} from 'lodash/fp'

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
    console.log(cursor)
    this.props.onClick(cursor)
  }

  render() {
    let [r, c] = this.props.cursor
    return (
      <g>
        <g>
          <Cursor c={c} r={r} squareSize={squareSize} />
          <rect
            stroke='blue'
            strokeWidth='6px'
            fill='none'
            opacity='0.2'
            x={3} y={3}
            width={squareSize * 5 - 4} height={squareSize - 4}
          />
          <rect
            stroke='gray'
            strokeWidth='6px'
            fill='none'
            opacity='0.2'
            x={3} y={3}
            height={squareSize * 5 - 4} width={squareSize - 4}
          />
        </g>
        <ClickOverlay width={width} height={height} onClick={this.onClick} />
      </g>
    )
  }
}

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
      this.setState({direction: direction === 'A' ? 'D' : 'A'})
    })

    key('tab', event => {
      console.log('tab')
      event.preventDefault()
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

  onLetterPress = letter => {
    console.log(letter)
    const {direction, cursor: [r, c]} = this.state
    const [dr, dc] = direction === 'A' ? [0, 1] : [1, 0]
    this.setState({
      fill: set([r, c], letter, this.state.fill),
      cursor: [r + dr, c + dc],
    })
  }

  onArrowPress = direction => {
    const [r, c] = this.state.cursor
    const [dr, dc] = ARROWS[direction]
    this.setCursor([r + dr, c + dc])
  }

  render() {
    let P = this.props.puzzle
    const {cursor, fill} = this.state
    console.log(P)
    return (
      <svg width={width + 2} height={height + 2}>
        <StaticGrid
          squareSize={squareSize}
          height={height}
          rows={rows}
          puzzle={P.puzzle}
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
        <GridI cursor={cursor} onClick={this.setCursor} />
      </svg>
    )
  }
}
