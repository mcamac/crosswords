express = require 'express'
http = require 'http'
mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/crosswords'

MultiplayerRoom = require '../shared/room'
Player = require '../shared/player'


puzzleSchema = new mongoose.Schema
  title: String
  puzzle: Array
  author: String
  clues: mongoose.Schema.Types.Mixed
  height: Number
  width: Number

Puzzle = mongoose.model 'Puzzle', puzzleSchema


## Global rooms object
rooms = {}

## Application configuration
app = express()
server = http.Server(app)

io = require('socket.io') server


app.set 'views', __dirname + '/../client/views'
app.use '/static', express.static(__dirname + '/../client/static')

cookieParser = require 'cookie-parser'
session = require 'express-session'
app.use cookieParser()
app.use session({ secret: 'keyboard cat', resave: true, saveUninitialized: true })

## Routes
require('./routes') app, Puzzle

server.listen 5557

####
class CrosswordPlayer extends Player
  constructor: (room, id) ->
    super room, id


  emit: (event, data) ->
    io.sockets.socket(sock).emit(event, data)


class MultiplayerCrosswordRoom extends MultiplayerRoom
  constructor: (id) ->
    super id
    @puzzle = require './default-puzzle.json'

    @grid_changes = {}
    @grid_corrects = []
    @grid_owner_counts = {}
    @grid_owners = {}

  emit: (name, data) ->
    io.sockets.in(@name).emit name, data




# Load a room 


io.sockets.on 'connection', (socket) ->
  socket.emit 'connection acknowledged', ''

  socket.on 'join room', ({roomName, userId}) ->
    console.log roomName, userId

  socket.on 'disconnect', ->
    console.log 'disconn'
