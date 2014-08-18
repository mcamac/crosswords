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
app.get '/', (req, res) ->
  res.redirect '/lobby'

app.get '/lobby', (req, res) ->
  res.send 'hello world'

app.get '/play/:room_name', (req, res) ->
  # res.send req.params.room_name
  res.render 'room.jade', {}

app.get '/puzzles', (req, res) ->
  Puzzle.find().select('title author _id')
        .skip(100).limit(50).exec (err, puzzles) ->
    res.json puzzles

app.get '/puzzle/:id', (req, res) ->
  Puzzle.findOne({_id: req.params.id}).exec (err, puzzle) ->
    res.json puzzle

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
    @puzzle = {"title": "NY Times, Mon, Jun 03, 2013", "puzzle": ["CEDAR_ZION_PHIL", "AMORE_IRAE_RONA", "PIGINAPOKE_EGGY", "ELIE_EON_DASHES", "SEETHRU_OSOLE__", "___TOOTAT_KEANU", "JIHADS_TOW_YVES", "USA_SOWSEAR_ERE", "DEMI_LIE_SOUNDS", "DEFOE_CARHOP___", "__ININK_ATTACHE", "ASSISI_GNU_TAIL", "RITZ_PORKBARREL", "ALEE_ARAL_DEERE", "BODS_TOBE_SEWON"], "author": "John Lampkin / Will Shortz", "height": 15, "width": 15, "clues": {"down": {"1": "Bullfighters wave them", "2": "Writer Zola", "3": "Cowherd's stray", "4": "Short operatic song", "5": "Stimpy's bud", "6": "Like some detachable linings", "7": "What bodybuilders pump", "8": "Wood for a chest", "9": "Essentials", "10": "\"Blue Suede Shoes\" singer", "11": "Ecstatic state, informally", "12": "\"Bus Stop\" playwright", "13": "Puts down, as tile", "18": "Spray can", "23": "Just fine", "25": "Mortar troughs", "26": "Great Plains tribe", "28": "Floundering", "30": "Stereotypical techie", "31": "Applications", "32": "Naomi or Wynonna of country music", "33": "\"Got it!\"", "34": "Clumsy", "36": "Laundry basin", "40": "Lighted part of a candle", "41": "Part of a plant or tooth", "44": "Becomes charged, as the atmosphere", "47": "Stuck, with no way to get down", "49": "Sue Grafton's \"___ for Evidence\"", "51": "Really bug", "53": "Barely bite, as someone's heels", "55": "Rod who was a seven-time A.L. batting champ", "56": "Prefix with -glyphics", "57": "\"The ___ DeGeneres Show\"", "58": "Many an Iraqi", "59": "Corn Belt tower", "60": "Seize", "64": "Spanish gold", "65": "What TV watchers often zap"}, "across": {"1": "Wood for a chest", "6": "Holy Land", "10": "TV's Dr. ___", "14": "Love, Italian-style", "15": "\"Dies ___\" (Latin hymn)", "16": "Gossipy Barrett", "17": "Unseen purchase", "19": "Like custard and meringue", "20": "Writer Wiesel", "21": "Long, long time", "22": "- - -", "24": "Transparent, informally", "26": "\"___ Mio\"", "27": "Greet with a honk", "29": "Reeves of \"The Matrix\"", "32": "Holy wars", "35": "Drag behind, as a trailer", "37": "Designer Saint Laurent", "38": "Made in ___ (garment label)", "39": "You can't make a silk purse out of it, they say", "42": "Before, poetically", "43": "Actress Moore of \"Ghost\"", "45": "Tell a whopper", "46": "Buzz and bleep", "48": "Daniel who wrote \"Robinson Crusoe\"", "50": "Drive-in server", "52": "How to sign a contract", "54": "Ambassador's helper", "58": "Birthplace of St. Francis", "60": "African antelope", "61": "Part that wags", "62": "Big name in crackers", "63": "Like some wasteful government spending", "66": "Toward shelter, nautically", "67": "Asia's diminished ___ Sea", "68": "John ___ (tractor maker)", "69": "Physiques", "70": "Words before and after \"or not\"", "71": "Attach, as a button"}}}
    

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
