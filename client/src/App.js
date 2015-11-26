import React, { Component } from 'react';
import {Router, Route, Link} from 'react-router'
import createBrowserHistory from 'history/lib/createBrowserHistory'

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
    <Router history={createBrowserHistory()}>
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
