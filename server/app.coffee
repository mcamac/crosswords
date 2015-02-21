express = require 'express'
http = require 'http'
MultiplayerCrosswordRoom = require('./room').MultiplayerCrosswordRoom
Player = require '../shared/player'

Puzzle = (require './db').Puzzle


## Application configuration
app = express()
server = http.Server(app)

io = require('socket.io') server


app.set 'views', __dirname + '/../client/views'
app.use '/static', express.static(__dirname + '/../client/static')

cookieParser = require 'cookie-parser'
session = require 'express-session'
app.use cookieParser()
app.use session({
  name: 'crosswords.sid'
  secret: 'keyboard cat'
  resave: true
  saveUninitialized: true })

## Routes
require('./routes') app, Puzzle

server.listen (process.env.PORT or 5557)

####
class CrosswordUser
  constructor: (@id) ->
    @name = Math.random().toString(36).substr(2,5)
  emit: (event, data) ->
    io.sockets.socket(sock).emit(event, data)

  metadata: ->
    name: @name
    id: @id

rooms = { foo: new MultiplayerCrosswordRoom(io, 'foo') }

users = {}


# Load a room

cookie = require 'cookie'
io.use (socket, next) ->
  sid = cookie.parse(socket.request.headers.cookie)['crosswords.sid']
  id = cookieParser.signedCookie sid, 'keyboard cat'
  if not users[id]
    users[id] = new CrosswordUser(id)
    console.log 'new user', id
  socket.user = users[id]
  socket.user.socket = socket
  socket.room = rooms.foo
  socket.room.addUser socket.user
  socket.join socket.room.name

  next()


io.sockets.on 'connection', (socket) ->
  socket.emit 'user id', socket.user.id

  socket.on 'join room', ({roomName, userId}) ->
    console.log roomName, userId
    socket.room.sendUsers()
    socket.emit 'existing puzzle', socket.room.serialize()

  socket.on 'chat message', (message) ->
    if not message.indexOf('/u') == 0
      socket.room.emit 'chat message',
        user: socket.user.name,
        text: message
    else
      console.log 'username change', socket.user.name, message[3..]
      if message[3..] and message[3..] != '__server' # LOLOLOLOL
        socket.user.name = message[3..18]
        console.log 'sending username change,,,'
        socket.room.sendUsers()

  socket.on 'new puzzle', (params) ->
    console.log 'new', params.id
    Puzzle.findOne({_id: params.id}).exec (err, puzzle) ->
      console.log puzzle
      socket.room.newPuzzle puzzle
      socket.room.emit 'existing puzzle', socket.room.serialize()
      socket.room.serverChat "New puzzle! #{puzzle.title}"

  socket.on 'set square', ([[i, j], val]) ->
    socket.room.setSquare(socket.user, [i, j], val)

  socket.on 'disconnect', ->
    console.log 'disconnect'
    socket.room.disconnectUser socket.user
