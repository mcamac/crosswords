import React, {Component} from 'react'
import R from 'ramda'

import P from '../utils/default-puzzle'
import {processPuzzle} from '../utils/puzzle'
import Puzzle from './Puzzle'

export default class Room extends Component {
  render() {
    return (
      <div style={{fontFamily: 'Source Sans Pro'}}>
        <div>
          <h2 style={{fontWeight: 600}}>crosswords</h2>
        </div>
        <Puzzle puzzle={processPuzzle(P)} />
      </div>
    )
  }
}
