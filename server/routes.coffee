module.exports = (app, Puzzle) ->
  app.get '/', (req, res) ->
    res.render 'room.jade', {}

  # app.get '/lobby', (req, res) ->
  #   res.send 'hello world'

  # app.get '/play/:room_name', (req, res) ->
  #   # res.send req.params.room_name
  #   res.render 'room.jade', {}

  app.get '/api/puzzles', (req, res) ->
    Puzzle.find().select('title author _id')
          .skip(100).limit(50).exec (err, puzzles) ->
      res.json puzzles

  app.get '/api/puzzles/:id', (req, res) ->
    Puzzle.findOne({_id: req.params.id}).exec (err, puzzle) ->
      res.json puzzle
