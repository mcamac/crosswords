uuid = ->
  Math.random().toString(36).substr(2,9)


class MultiplayerRoom
  constructor: (@name) ->
    @clients = {}
    @clients_exited = {}


    @start_time = null

    @letters = []

    @grid = []
    
    @competitive = false
    @diagramless = false

    @start_time = null


    @client_squares = {}


  

exports.MultiplayerRoom = MultiplayerRoom if exports?
