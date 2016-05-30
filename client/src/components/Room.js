import {Component} from 'react'
import {connect} from 'react-redux'
import R from 'ramda'

import Puzzle from './Puzzle'

class Room extends Component {
  render() {
    return (
      <div style={{fontFamily: 'Source Sans Pro'}}>
        <div>
          <h2 style={{fontWeight: 600}}>crosswords</h2>
        </div>
        <Puzzle
          puzzle={this.props.puzzle}
          grid={this.props.grid}
          clue={this.props.clue}
          onChange={this.props.onChange}
        />
      </div>
    )
  }
}

const actions = {
  onChange: p => ({type: 'ON_CHANGE', payload: p}),
}

const mapStateToProps = state => {
  const [r, c] = state.grid.cursor
  const {direction} = state.grid
  const activeClueNum = state.puzzle.clueNums[r][c][direction]
  const inactiveClueNum = state.puzzle.clueNums[r][c][direction === 'A' ? 'D' : 'A']
  return {
    ...state,
    clue: {
      active: {
        n: activeClueNum,
        direction,
        clue: state.puzzle.clues[direction === 'A' ? 'across' : 'down'][activeClueNum],
      },
      inactive: {
        n: inactiveClueNum,
        direction: direction === 'A' ? 'D' : 'A',
        clue: state.puzzle.clues[direction === 'A' ? 'down' : 'across'][inactiveClueNum],
      },
    },
  }
}

export default connect(mapStateToProps, actions)(Room)
