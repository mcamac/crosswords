import React from 'react'
import ReactDOM from 'react-dom'
import {createStore} from 'redux'
import {Provider} from 'react-redux'
import {App} from './containers/App'
import DevTools from './containers/DevTools'

let store = createStore(() => ({}), {}, DevTools.instrument())

ReactDOM.render(
  <Provider store={store}>
    <div>
      <DevTools />
      <App />
    </div>
  </Provider>,
  document.getElementById('root')
)
