express = require 'express'
http = require 'http'
mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/crosswords'

MultiplayerCrosswordRoom = require('./room').MultiplayerCrosswordRoom
Player = require '../shared/player'


puzzleSchema = new mongoose.Schema
  title: String
  puzzle: Array
  author: String
  clues: mongoose.Schema.Types.Mixed
  height: Number
  width: Number

Puzzle = mongoose.model 'Puzzle', puzzleSchema


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

server.listen 5557

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
  console.log 'user', id
  if not users[id]
    users[id] = new CrosswordUser(id)
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

  socket.on 'chat message', (message) ->
    socket.room.emit 'chat message',
      user: socket.user.name,
      text: message

  socket.on 'set square', ([[i, j], val]) ->
    socket.room.setSquare(socket.user, [i, j], val)

  socket.on 'disconnect', ->
    console.log 'disconn'
