import jwtDecode from 'jwt-decode'

const socket = io.connect('http://localhost:3000')
socket.on('connect', () => {
  socket.on('JWT', token => {
    console.log(jwtDecode(token))
    socket.emit('authenticate', {token})
  })
  socket.emit('GET_JWT', 'nik')
})
socket.on('authenticated', () => {
  console.log('authenticated')
})

export default socket
