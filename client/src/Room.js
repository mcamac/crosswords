import React, {Component} from 'react'
import R from 'ramda'

import Grid from './Grid'
import P from './default-puzzle'
import {processPuzzle} from './puzzle'

const ClueList = ({clues, title}) => {
  return (
    <div style={{minWidth: 200, margin: '0 5px'}}>
      <h4 style={{margin: '5px 0'}}>{title}</h4>
      <div style={{fontSize: '0.95em', margin: '2px 0', maxHeight: 800}}>
        {R.keys(clues).map(n => (
          <div key={n}>
            <div style={{fontFamily: 'Inconsolata', display: 'inline-block', marginRight: 5, width: 20, textAlign: 'right'}}>
              {n}
            </div>
            <span style={{fontFamily: 'Source Sans Pro'}}>{clues[n]}</span>
          </div>
        ))}
      </div>
    </div>
  )
}

export default class Room extends Component {
  render() {
    return (
      <div style={{fontFamily: 'Proxima Nova'}}>
        <div>
          <h2>crosswords.io</h2>
        </div>
        <div style={{display: 'flex'}}>
          <div style={{display: 'flex', flexFlow: 'row'}}>
            <ClueList title='Across' clues={P.clues.across}/>
            <ClueList title='Down' clues={P.clues.down}/>
          </div>
          <div>
            <p><span>1</span> Wood for a chest</p>
            <Grid puzzle={processPuzzle(P)}/>
          </div>
        </div>

      </div>
    )
  }
}
