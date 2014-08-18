class Player
  constructor: (@id) ->
    @name = Math.random().toString(36).substr(2,5)

exports.Player = Player if exports?
