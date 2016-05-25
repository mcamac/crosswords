import {Component} from 'react'
import Clue from './Clue'
import ClueList from './ClueList'
import Grid from '../Grid'

export default class Puzzle extends Component {
  render() {
    const {puzzle, grid, onChange} = this.props
    return (
      <div style={{display: 'flex'}}>
        <div style={{columnCount: 3, columnWidth: 250, columnGap: 5, marginTop: 20}}>
          <ClueList clues={puzzle.clues}/>
        </div>
        <div style={{marginLeft: 20}}>
          <Clue n={1} clue='Wood for a chest' style={{marginBottom: 5}} />
          <Grid puzzle={puzzle} {...grid} onChange={onChange} />
        </div>
      </div>
    )
  }
}
