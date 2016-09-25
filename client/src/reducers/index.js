import {combineReducers} from 'redux'
import socket from '../socket'

export default (state, action) => {
  console.log(action)
  if (action.type === 'ON_CHANGE') {
    return {
      ...state,
      grid: {...state.grid, ...action.payload},
    }
  } else if (action.type === 'NOTIFY_SERVER') {
    socket.emit('ACTION', action.payload)
    return state
  }
  return state
}
