import React, { Component } from 'react'
import {Router, Route, Link} from 'react-router'
import R from 'ramda'

import Grid from './Grid'
import P from './default-puzzle'

class ClueList extends Component {
  render() {
    let {clues} = this.props
    return (
      <div style={{minWidth: 200}}>
        <h4 style={{margin: '5px 0'}}>{this.props.title}</h4>
        <div style={{fontSize: '0.95em', margin: '2px 0', maxHeight: 500, overflowY: 'scroll'}}>
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
          <Grid puzzle={P}/>
        </div>

      </div>
    )
  }
}
