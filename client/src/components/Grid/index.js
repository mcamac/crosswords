import React, {Component} from 'react'
import ReactDOM from 'react-dom'
import key from 'keymaster'
import R from 'ramda'
import {isEqual, set} from 'lodash/fp'

import Cursors from './Cursors'
import StaticGrid from './StaticGrid'

let width = 600
let height = 600
let rows = 15
let squareSize = width / rows

const LETTERS = 'abcdefghijklmnopqrstuvwxyz'.split('').join(',')

const flipD = direction => direction === 'A' ? 'D' : 'A'

const ARROWS = {
  Left: [0, -1],
  Right: [0, 1],
  Down: [1, 0],
  Up: [-1, 0],
}

let sqi = R.xprod(R.range(0, 15), R.range(0, 15))

export default class Grid extends Component {
  componentDidMount() {
    key(LETTERS, event => {
      this.onLetterPress(String.fromCharCode(event.which))
    })

    key('space', event => {
      event.preventDefault()
      const {direction} = this.props
      this.props.onChange({direction: flipD(direction)})
    })

    key('tab', event => {
      event.preventDefault()
      this.onTab(1)
    })

    key('backspace', event => {
      event.preventDefault()
      this.onBackspace()
    })

    key('shift+tab', event => {
      event.preventDefault()
      this.onTab(-1)
    })

    key('left,right,up,down', event => {
      event.preventDefault()
      this.onArrowPress(event.code.slice(5))
    })
  }

  setCursor = cursor => {
    this.props.onChange({cursor})
    this.props.notify({cursor})
  }

  onClick = ([nr, nc]) => {
    let {puzzle} = this.props
    if (!puzzle.valid([nr, nc])) return
    const {direction, cursor: [r, c]} = this.props
    this.props.onChange({
      direction: isEqual([r, c], [nr, nc]) ? flipD(direction) : direction,
      cursor: [nr, nc],
    })
    this.props.notify({cursor: [nr, nc]})
  }

  onBackspace = () => {
    let {puzzle} = this.props
    const {direction, cursor: [r, c]} = this.props
    const [dr, dc] = direction === 'A' ? [0, 1] : [1, 0]
    const [nr, nc] = puzzle.nextSquare([r, c], [-dr, -dc])
    this.props.onChange({
      fill: set([r, c], '', this.props.fill),
      cursor: [nr, nc],
    })
    this.props.notify({
      fillSquare: [r, c, ''],
      cursor: [nr, nc],
    })
  }

  onTab = offset => {
    let {puzzle, direction, cursor: [r, c]} = this.props
    const currentClue = puzzle.clueNums[r][c][direction]
    const dirClueNums = R.keys(puzzle.clues[direction === 'A' ? 'across' : 'down'])
    const nextClue = dirClueNums[(dirClueNums.length + offset + dirClueNums.indexOf("" + currentClue)) % dirClueNums.length]
    this.setCursor(puzzle.clueStarts[nextClue])
  }

  onLetterPress = letter => {
    const {puzzle, direction, cursor: [r, c]} = this.props
    const [dr, dc] = direction === 'A' ? [0, 1] : [1, 0]
    const [nr, nc] = puzzle.nextSquareSoft([r, c], [dr, dc])
    this.props.onChange({
      fill: set([r, c], letter, this.props.fill),
      cursor: [nr, nc],
    })
    this.props.notify({
      fillSquare: [r, c, letter],
      cursor: [nr, nc],
    })
  }

  onArrowPress = direction => {
    let {puzzle} = this.props
    const [r, c] = this.props.cursor
    const [dr, dc] = ARROWS[direction]
    this.setCursor(puzzle.nextSquare([r, c], [dr, dc]))
  }

  render() {
    const {puzzle: P, cursor, direction, fill} = this.props
    console.log('Grid', P)
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
        <Cursors direction={direction} puzzle={P} cursor={cursor} onClick={this.onClick} />
      </svg>
    )
  }
}
