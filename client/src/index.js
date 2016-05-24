import React from 'react'
import {render} from 'react-dom'
import {createStore} from 'redux'
import {AppContainer} from 'react-hot-loader'
import Root from './containers/Root'
import DevTools from './containers/DevTools'

let store = createStore(() => ({}), {}, DevTools.instrument())

render(
  <AppContainer>
    <Root store={store} />
  </AppContainer>,
  document.getElementById('root')
)

if (module.hot) {
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
