var io = require('socket.io')()
var ioJwt = require('socketio-jwt')
var jwt = require('jsonwebtoken')

const SECRET = 'nikhilisatomato'

io.on('connection', socket => {
  ioJwt.authorize({
    secret: SECRET,
    timeout: 15000,
  })(socket)

  socket.on('GET_JWT', function (name) {
    socket.emit('JWT', jwt.sign({name}, SECRET))
  })
}).on('authenticated', function(socket) {
  console.log('hello! ' + socket.decoded_token.name);

  socket.on('ACTION', function (action) {
    console.log(socket.decoded_token.name, action)
    socket.broadcast.emit('USER', action)
  })
})
io.listen(3000)
