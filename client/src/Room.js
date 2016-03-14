import React, {Component} from 'react'
import R from 'ramda'

import P from './default-puzzle'
import {processPuzzle} from './utils/puzzle'
import Puzzle from './Puzzle'

export default class Room extends Component {
  render() {
    return (
      <div style={{fontFamily: 'Source Sans Pro'}}>
        <div>
          <h2>crosswords.io</h2>
        </div>
        <Puzzle puzzle={processPuzzle(P)} />
      </div>
    )
  }
}
