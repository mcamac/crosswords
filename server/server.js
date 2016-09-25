var io = require('socket.io')()
var ioJwt = require('socketio-jwt')
var jwt = require('jsonwebtoken')
const uuid = require('node-uuid')

const Room = require('./room')

const SECRET = 'nikhilisatomato'

const ROOMS = {
  foo: new Room()
}

io.on('connection', socket => {
  ioJwt.authorize({
    secret: SECRET,
    timeout: 15000,
  })(socket)

  socket.on('GET_JWT', name => {
    socket.emit('JWT', jwt.sign({name, id: name || uuid.v4()}, SECRET))
  })
}).on('authenticated', socket => {
  console.log('hello! ' + socket.decoded_token.name);
  socket.on('JOIN_ROOM', room => {
    ROOMS[room].onJoin(socket)

    socket.emit('INITIAL', ROOMS[room].toClient())
    socket.broadcast.emit('INITIAL', ROOMS[room].toClient())

    socket.on('ACTION', action => {
      ROOMS[room].onAction(socket, action)
      socket.broadcast.emit('INITIAL', ROOMS[room].toClient())
    })

    socket.on('disconnect', () => {
      ROOMS[room].onLeave(socket)
      socket.broadcast.emit('INITIAL', ROOMS[room].toClient())
    })
  })
})
io.listen(3000)
