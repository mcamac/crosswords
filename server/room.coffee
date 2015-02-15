Puzzle = require '../shared/puzzle'

uuid = ->
  Math.random().toString(36).substr(2,9)

COLORS = [
  'rgb(86, 103, 159)', 'rgb(153, 139, 61)', 'rgb(219, 2, 2)', 'rgb(255, 68, 0)',
  'rgb(22, 36, 73)', 'rgb(255, 224, 129)', 'rgb(53, 61, 82)', 'rgb(179, 190, 210)']

class MultiplayerRoom
  constructor: (@name) ->
    @users = {}
    @clients_exited = {}

    @startTime = null

    @competitive = false
    @diagramless = false

  emit: (name, data) ->
    @io.sockets.in(@name).emit name, data

  serverChat: (msg) ->
    @emit 'chat message',
      name: 'server'
      text: msg

class MultiplayerCrosswordRoom extends MultiplayerRoom
  constructor: (@io, id) ->
    super id
    @userColors = {}
    @assignedColors = 0
    @newPuzzle (require './default-puzzle.json')

  newPuzzle: (puzzle) ->
    @puzzle = new Puzzle(puzzle)
    @startTime = new Date()

    @grid = @puzzle.map -> ''
    @gridOwners = @puzzle.map -> ''
    @gridChanges = {}
    @gridCorrects = []
    @gridOwnerCounts = {}

  addUser: (user) ->
    if not @users[user.id]
      @users[user.id] = user
      @userColors[user.id] = COLORS[@assignedColors++]
      @sendUsers()

  sendUsers: ->
    @emit 'users', ({ id: id, color: @userColors[id], username: @users[id].name } for id of @users)

  setSquare: (user, [i, j], val) ->
    if @grid[i][j] != val
      @grid[i][j] = val
      @gridOwners[i][j] = user.id
      @emit 'square set', [user.id, [i, j], val]
    # Check if done
    console.log 'puzzle is done', @isdone

  isDone: ->
    for r in [0...@grid.height]
      for c in [0...@grid.col]
        if @puzzle.grid[r][c] != '_' and @puzzle.grid[r][c] != @grid[r][c]
          return false
    return true

  serialize: ->
    puzzle: @puzzle.json
    grid: @grid
    gridOwners: @gridOwners
    startTime: @startTime


exports.MultiplayerRoom = MultiplayerRoom if exports?
exports.MultiplayerCrosswordRoom = MultiplayerCrosswordRoom if exports?
