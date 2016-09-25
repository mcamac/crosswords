import {Component} from 'react'
import Clue from './Clue'
import ClueList from './ClueList'
import Grid from '../Grid'

export default class Puzzle extends Component {
  render() {
    const {puzzle, grid, clue, notify, onChange} = this.props
    return (
      <div style={{display: 'flex'}}>
        <div style={{breakInside: 'avoid', columnCount: 3, columnWidth: 250, columnGap: 5, marginTop: 20}}>
          <ClueList clues={puzzle.clues} clue={clue} />
        </div>
        <div style={{marginLeft: 20}}>
          <Clue fixed={30} style={{marginBottom: 5}} {...clue.active} />
          <Grid puzzle={puzzle} {...grid} onChange={onChange} notify={notify} />
        </div>
      </div>
    )
  }
}
