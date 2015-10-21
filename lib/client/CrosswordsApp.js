import React from 'react'
import { bindActionCreators } from 'redux';
import {connect} from 'redux/react'

import Puzzle from './components/puzzle/Puzzle'
import * as PuzzleActions from './actions/puzzle'

console.log('actions', PuzzleActions)

@connect(state => ({
  puzzle: state.puzzle
}))
export default class CrosswordsApp extends React.Component {
  render() {
    return <Puzzle puzzle={this.props.puzzle}
                   {...bindActionCreators(PuzzleActions, this.props.dispatch)}/>
  }
}
