import React from 'react';
import {createRedux} from 'redux';
import {Provider} from 'redux/react';
import {Router, Route} from 'react-router';
import HashHistory from 'react-router/lib/HashHistory';

import CrosswordsApp from './CrosswordsApp';
import puzzle from './stores/puzzle'

const redux = createRedux({puzzle})
const history = new HashHistory();

function routes() {
  return (<Router history={history}>
    <Route path='/' component={CrosswordsApp}></Route>
  </Router>);
}

export default class Root extends React.Component {
  render() {
    return <Provider redux={redux}>
      {routes}
    </Provider>
  }
}
