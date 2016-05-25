import {combineReducers} from 'redux'

export default (state, action) => {
  console.log(action)
  if (action.type === 'ON_CHANGE') {
    return {
      ...state,
      grid: {...state.grid, ...action.payload},
    }
  }
  return state
}
