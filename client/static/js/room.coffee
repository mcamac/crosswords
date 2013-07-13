$ ->
  socket = io.connect 'http://localhost:5558'

  urlFragments = window.location.href.split('/')
  roomName = urlFragments[urlFragments.length - 1]
  console.log roomName

  # after server acknowledges handshake, send room name to join
  socket.on 'connection acknowledged', (data) ->
    socket.emit 'join room', 
      roomName: roomName
      userId: 'foo'
