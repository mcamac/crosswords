class Player
  constructor: (@room, @id) ->
    @name = Math.random().toString(36).substr(2,5)
    @color = '#cccccc'


exports.Player = Player if exports?
