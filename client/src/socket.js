import jwtDecode from 'jwt-decode'

const socket = io.connect('http://localhost:3000')
socket.on('connect', () => {
  socket.emit('GET_JWT', localStorage.cwId)
})
socket.on('authenticated', () => {
  console.log('authenticated')
  socket.emit('JOIN_ROOM', 'foo')
})

socket.attachStore = store => {
  socket.on('JWT', token => {
    console.log(jwtDecode(token))
    localStorage.cwId = jwtDecode(token).id
    socket.emit('authenticate', {token})
  })
  socket.on('USER', action => console.log('user change', action))
  socket.on('INITIAL', payload => store.dispatch({type: 'FROM_SERVER', payload}))
}

export default socket
