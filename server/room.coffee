Puzzle = require '../shared/puzzle'

uuid = ->
  Math.random().toString(36).substr(2,9)


class MultiplayerRoom
  constructor: (@name) ->
    @users = {}
    @clients_exited = {}


    @start_time = null

    @letters = []

    @grid = []
    
    @competitive = false
    @diagramless = false

    @start_time = null


    @client_squares = {}


class MultiplayerCrosswordRoom extends MultiplayerRoom
  constructor: (@io, id) ->
    super id
    @puzzle = new Puzzle(require './default-puzzle.json')

    @grid = @puzzle.map -> ''
    @gridOwners = @puzzle.map -> ''
    @gridChanges = {}
    @gridCorrects = []
    @gridOwnerCounts = {}

  emit: (name, data) ->
    @io.sockets.in(@name).emit name, data

  setSquare: (user, [i, j], val) ->
    if @grid[i][j] != val
      @grid[i][j] = val
      @gridOwners[i][j] = user.id
      @emit 'square set', [user.id, [i, j], val]


exports.MultiplayerRoom = MultiplayerRoom if exports?
exports.MultiplayerCrosswordRoom = MultiplayerCrosswordRoom if exports?
