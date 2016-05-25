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
        <Puzzle puzzle={this.props.puzzle} grid={this.props.grid} onChange={this.props.onChange}/>
      </div>
    )
  }
}

const actions = {
  onChange: p => ({type: 'ON_CHANGE', payload: p}),
}

const mapStateToProps = state => {
  return state
}

export default connect(mapStateToProps, actions)(Room)
