import React, {Component} from 'react'
import {browserHistory, Router, Route, Link} from 'react-router'

import Room from '../components/Room'

class Homepage extends Component {
  render() {
    return (
      <div>
        crosswords
      </div>
    )
  }
}

export class App extends Component {
  render() {
    return (
      <Router history={browserHistory}>
        <Route path='/' component={Homepage}></Route>
        <Route path='/room/:id' component={Room}></Route>
      </Router>
    )
  }
}
