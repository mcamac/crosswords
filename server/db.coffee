mongoose = require 'mongoose'
mongo_url = 'mongodb://localhost/crosswords'

if process.env.MONGO_URL
  mongo_url = process.env.MONGO_URL
mongoose.connect mongo_url

puzzleSchema = new mongoose.Schema
  title: String
  puzzle: Array
  circled: mongoose.Schema.Types.Mixed
  notes: String
  author: String
  clues: mongoose.Schema.Types.Mixed
  height: Number
  width: Number

Puzzle = mongoose.model 'Puzzle', puzzleSchema

module.exports =
	Puzzle: Puzzle
