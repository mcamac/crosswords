import React from 'react'
import ReactDOM from 'react-dom'
import {Provider} from 'react-redux'
import {AppContainer} from 'react-hot-loader'
import {App} from './App'
import DevTools from './DevTools'

const Root = props =>
  <Provider store={props.store}>
    <div>
      <DevTools />
      <App />
    </div>
  </Provider>

export default Root
