import {Component} from 'react'
import Clue from './Clue'
import ClueList from './ClueList'
import Grid from '../Grid'

export default class Puzzle extends Component {
  render() {
    const {puzzle} = this.props
    return (
      <div style={{display: 'flex'}}>
        <div style={{columnCount: 3, columnWidth: 250, columnGap: 10, marginTop: 20}}>
          <ClueList clues={puzzle.clues}/>
        </div>
        <div>
          <Clue n={1} clue='Wood for a chest' style={{marginBottom: 5}} />
          <Grid puzzle={puzzle} />
        </div>
      </div>
    )
  }
}
