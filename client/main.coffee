$ ->
  socket = io.connection 'http://localhost:5557'
  socket.on 'pulse', (data) ->
    console.log data
