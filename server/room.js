const R = require('ramda')
const P = require('./default-puzzle.json')

class Room {
  constructor() {
    this.state = {
      solving: true,
      startTime: new Date(),
      puzzle: P,
      fill: P.puzzle.map(r => r.split('').map(c => c === '_' ? '' : c)),
      fillOwners: P.puzzle.map(r => r.split('').map(c => null)),
      cursors: {},
      players: {},
    }
  }

  onJoin(socket) {
    this.state.cursors[socket.decoded_token.id] = [0, 0]
    this.state.players[socket.decoded_token.id] = socket.decoded_token
  }

  onLeave(socket) {
    delete this.state.cursors[socket.decoded_token.id]
    delete this.state.players[socket.decoded_token.id]
  }

  onAction(socket, action) {
    console.log('action', socket.decoded_token.id, action)
    if (action.fillSquare) {
      const [r, c, val] = action.fillSquare
      this.state.fill[r][c] = val
      this.state.fillOwners[r][c] = socket.decoded_token.id
    }
  }

  fromJson() {
    return this
  }

  toJson() {
    return this.state
  }

  toClient() {
    return R.pick(['solving', 'startTime', 'fill', 'cursors', 'players', 'puzzle'], this.state)
  }
}

module.exports = Room
