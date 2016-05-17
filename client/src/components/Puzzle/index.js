import {Component} from 'react'
import Clue from './Clue'
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
          <Clue n={1} clue='Wood for a chest' />
          <Grid puzzle={puzzle} />
        </div>
      </div>
    )
  }
}
