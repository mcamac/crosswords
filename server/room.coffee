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
  constructor: (id) ->
    super id
    @puzzle = require './default-puzzle.json'

    @grid_changes = {}
    @grid_corrects = []
    @grid_owner_counts = {}
    @grid_owners = {}

  emit: (name, data) ->
    io.sockets.in(@name).emit name, data

  

exports.MultiplayerRoom = MultiplayerRoom if exports?
exports.MultiplayerCrosswordRoom = MultiplayerCrosswordRoom if exports?
