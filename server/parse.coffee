iconv = require('iconv-lite')

parse = (buf) ->
    width = buf[44]
    height = buf[45]
    console.log width, height
    s = iconv.decode(buf, 'iso-8859-1')
    console.log s
    puzzle = s[52...52 + width * height]
    puzzle = (puzzle[i * width...(i + 1) * width].replace(/\./g, '_') for i in [0...height])
    console.log puzzle
    a = 52 + 2 * width * height

    clueArray = s[a..].split('\x00')
    title = clueArray[0].trim()
    author = clueArray[1].trim()
    clueNumber = 1
    clueArrayPos = 3  # Skip copyright

    clues = {across: {}, down: {}}
    for r in [0...height]
        for c in [0...width]
            used = false
            if puzzle[r][c] == '_'
                continue
            if c == 0 or puzzle[r][c - 1] == '_'
                clues.across[clueNumber] = clueArray[clueArrayPos]
                clueArrayPos += 1
                used = true
            if r == 0 or puzzle[r - 1][c] == '_'
                clues.down[clueNumber] = clueArray[clueArrayPos]
                clueArrayPos += 1
                used = true

            clueNumber += if used then 1 else 0


    return {
        width: width
        height: height
        title: title
        author: author
        puzzle: puzzle
        clues: clues
    }

fs = require 'fs'
parseFile = (filename) ->
    contents = fs.readFileSync filename
    return parse contents


Puzzle = (require './db.coffee').Puzzle

saveFile = (puzzle) ->
    Puzzle.findOne({title: puzzle.title}).exec((err, found) ->
        if not found
            console.log 'created', puzzle.title
            p = new Puzzle(puzzle)
            p.save()
        else
            console.log 'updated', puzzle.title
            found.update puzzle
    )

glob = require 'glob'
glob '/Users/martin/Documents/puz/*.puz', (er, files) ->
    for file in files
        saveFile (parseFile file)
    setTimeout (-> console.log files.length, 'puzzles'), 2000




# mongoose.disconnect()
