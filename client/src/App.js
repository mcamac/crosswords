import React, { Component } from 'react';
import {browserHistory, Router, Route, Link} from 'react-router'

import Room from './Room'

class Homepage extends Component {
  render() {
    return (
      <div>
        crosswords
      </div>
    )
  }
}

function routes() {
  return (
    <Router history={browserHistory}>
      <Route path='/' component={Homepage}></Route>
      <Route path='/room/:id' component={Room}></Route>
    </Router>
  )
}

export class App extends Component {
  render() {
    return routes()
  }
}
