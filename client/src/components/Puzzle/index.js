import {Component} from 'react'
import ClueList from './ClueList'
import Grid from '../Grid'

export default class Puzzle extends Component {
  render() {
    const {puzzle} = this.props
    return (
      <div style={{display: 'flex'}}>
        <div style={{display: 'flex', flexFlow: 'row'}}>
          <ClueList title='Across' clues={puzzle.clues.across}/>
          <ClueList title='Down' clues={puzzle.clues.down}/>
        </div>
        <div>
          <p><span>1</span> Wood for a chest</p>
          <Grid puzzle={puzzle} />
        </div>
      </div>
    )
  }
}
