var passportSocketIo = require('passport.socketio');
var uuid = require('node-uuid');
var logger = require('tracer').colorConsole();
var colors = require('colors');
var logger = require('tracer').colorConsole({
    filters : [
               colors.cyan, //default filter
               //the last item can be custom filter. here is "warn" and "error" filter
               {
                 warn : colors.yellow,
                 error : [colors.red, colors.bold ]
               }
    ]
});


var io;


var users = {};

var rooms = {};

var User = function (id) {
  this.id = id;
  this.name = Math.random().toString(36).substr(2, 5).toUpperCase();
};

var Room = function (name) {
  this.name = name;
};

Room.prototype.sendChat = function (user, message) {
  console.log(this.name, user, message);
  io.to(this.name).emit('client chat message', {
    name: user.name,
    message: message
  });
};


var RoomHandler = {};


var cookie = require('cookie');
var cookieParser = require('cookie-parser');

module.exports = function (app, server, sessionStore) {
  io = require('socket.io')(server);
  // io.use(passportSocketIo.authorize({
  //   cookieParser: require('cookie-parser'),
  //   key:         'express.sid',       // the name of the cookie where express/connect stores its session_id
  //   secret:      'keyboard cat',    // the session_secret to parse the cookie
  //   store:       sessionStore        // we NEED to use a sessionstore. no memorystore please
  // }));

  io.use(function (socket, next) {
    // console.log(socket.request.headers.cookies);
    console.log(socket.request.headers);
    var sid = cookie.parse(socket.request.headers.cookie)['crosswords.sid'];
    var id = cookieParser.signedCookie(sid, 'keyboard cat');
    if (!users[id]) {
      users[id] = new User(id);
    }
    socket.user = users[id];
    if (socket.user.room) {
      logger.log('room', socket.user.room.name);
      socket.join(socket.user.room.name);
    }
    console.log('connection', socket.user);

    next();
  });

  io.on('connection', function (socket) {
    var id = uuid.v1();
    logger.log('socket id', id);
    socket.on('initialize', function (info) {
      logger.log('intialize', info);
      if (!rooms[info.room]) {
        rooms[info.room] = new Room(info.room);
      }
      socket.user.room = rooms[info.room];
      socket.join(info.room);
    });

    socket.on('chat message', function (message) {
      logger.log(message);
      socket.user.room.sendChat(socket.user, message);
      // socket.emit('client chat message', { message: message, name: 'dasdf' })
    });

    
  });

  return io;
};
