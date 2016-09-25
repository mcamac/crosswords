import React from 'react'
import {render} from 'react-dom'
import {createStore} from 'redux'
import {AppContainer} from 'react-hot-loader'
import Root from './containers/Root'
import reducer from './reducers'
import socket from './socket'

import {processPuzzle} from './utils/puzzle'
import P from './utils/default-puzzle'
const INITIAL_STATE = {
  puzzle: processPuzzle(P),
  grid: {
    cursor: [0, 0],
    direction: 'A',
    fill: processPuzzle(P).puzzle.map(row => row.split('')),
  },
}

let store = createStore(reducer, INITIAL_STATE)

socket.on('USER', action => console.log('user change', action))

render(
  <AppContainer>
    <Root store={store} />
  </AppContainer>,
  document.getElementById('root')
)

if (module.hot) {
  module.hot.accept('./reducers', () => {
    const newReducer = require('./reducers').default
    store.replaceReducer(newReducer)
  })

  module.hot.accept('./containers/Root', () => {
    const Root = require('./containers/Root').default
    render(
      <AppContainer>
        <Root store={store} />
      </AppContainer>,
      document.getElementById('root')
    )
  })
}
