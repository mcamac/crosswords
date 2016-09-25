import {combineReducers} from 'redux'
import socket from '../socket'
import {processPuzzle} from '../utils/puzzle'

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
  } else if (action.type === 'FROM_SERVER') {
    const puzzle = processPuzzle(action.payload.puzzle)
    return {
      ...state,
      players: action.payload.players,
      puzzle,
      grid: {
        ...state.grid,
        fill: action.payload.fill,
      },
    }
  }
  return state
}
