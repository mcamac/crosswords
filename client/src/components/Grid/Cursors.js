import React, {Component} from 'react'
import ReactDOM from 'react-dom'
import key from 'keymaster'
import R from 'ramda'
import {isEqual, set} from 'lodash/fp'

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

export default class Cursors extends Component {
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
