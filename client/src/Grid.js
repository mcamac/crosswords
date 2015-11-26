import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import R from 'ramda'

let width = 600
let height = 600
let rows = 15
let squareSize = width / rows

class GridI extends Component {
  state = {
    cursor: [0, 0]
  }
  render() {
    let [r, c] = this.state.cursor
    return (
      <g>
        <g>
          <rect
            fill='blue'
            opacity='0.2'
            x={c * squareSize}
            y={r * squareSize} width={squareSize} height={squareSize}/>
          <rect
            stroke='blue'
            strokeWidth='6px'
            fill='none'
            opacity='0.2'
            x={3} y={3} width={squareSize * 5 - 4} height={squareSize - 4}/>
          <rect stroke='gray' strokeWidth='6px' fill='none' opacity='0.2' x={3} y={3} height={squareSize * 5 - 4} width={squareSize - 4}/>
        </g>
        <g>
          <rect onClick={::this.onClick} fill='black' opacity='0.0' x={0} y={0} width={width} height={height}/>
        </g>
      </g>
    )
  }
  onClick(event) {
    let node = ReactDOM.findDOMNode(this).parentElement
    console.log(node.offsetTop, event.clientY)
    let cursor = [Math.floor((event.clientY - node.offsetTop) / squareSize), Math.floor((event.clientX - node.offsetLeft) / squareSize)]
    console.log(cursor)
    this.setState({cursor})
  }
}

export default class Grid extends Component {
  render() {
    let P = this.props.puzzle
    console.log(P)

    let sqi = R.xprod(R.range(0, rows), R.range(0, rows))
    let numbered = sqi.filter(([r, c]) => (
      P.puzzle[r][c] !== '_' && (r === 0 || c === 0 || P.puzzle[r - 1][c] === '_' || P.puzzle[r][c - 1] === '_')
    ))
    return (
      <svg width={width + 2} height={height + 2}>
        <g>
          {R.times(i => (
            <line key={`r${i}`} stroke='#bbb' x1={i * squareSize + 0.5} x2={i * squareSize + 0.5} y1={0} y2={height}/>
          ), rows + 1)}
          {R.times(i => (
            <line key={`c${i}`} stroke='#bbb' y1={i * squareSize + 0.5} y2={i * squareSize + 0.5} x1={0} x2={height}/>
          ), rows + 1)}
        </g>
        <g>
          {sqi.filter(([r, c]) => P.puzzle[r][c] === '_').map(([r, c]) => (
            <rect
              key={`${r}_${c}`}
              x={c * squareSize}
              y={r * squareSize}
              width={squareSize}
              height={squareSize}
              fill='black'/>
          ))}
        </g>
        <g>
          {sqi.map(([r, c]) => (
            <text
              key={`${r}_${c}`}
              style={{fontSize: '19px', fontFamily: 'Source Code Pro'}}
              x={(c + 0.5) * squareSize}
              y={(r + 0.5) * squareSize + 8}
              textAnchor='middle'
              >
              {P.puzzle[r][c]}
            </text>
          ))}
        </g>
        <g>
          {numbered.map(([r, c], i) => (
            <text
              key={`${r}_${c}`}
              style={{fontSize: '10px', fontFamily: 'Inconsolata'}}
              x={c * squareSize + 2}
              y={(r + 0.1) * squareSize + 8}
              textAnchor='start'
              >
              {i + 1}
            </text>
          ))}
        </g>
        <GridI/>
      </svg>
    )
  }

  onKeyPress(event) {
    console.log(event)
  }
}
