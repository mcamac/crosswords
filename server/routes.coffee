module.exports = (app, Puzzle) ->
  app.get '/', (req, res) ->
    res.render 'room.jade', {}

  app.get '/api/puzzles', (req, res) ->
    Puzzle.find().select('title author _id').sort('title').exec (err, puzzles) ->
      res.json puzzles

  app.get '/api/puzzles/random', (req, res) ->
    Puzzle.find().exec (err, puzzles) ->
      res.json puzzles[Math.floor(Math.random() * puzzles.length)]

  app.get '/api/puzzles/random/:day', (req, res) ->
    Puzzle.find({ title: {$regex: req.params.day }}).exec (err, puzzles) ->
      res.json puzzles[Math.floor(Math.random() * puzzles.length)]

  app.get '/api/puzzles/:id', (req, res) ->
    Puzzle.findOne({_id: req.params.id}).exec (err, puzzle) ->
      res.json puzzle
