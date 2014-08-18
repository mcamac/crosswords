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

var R = require('ramda');

// TODO: don't hardcode
var colorScheme = [
    'rgb(86, 103, 159)', 'rgb(153, 139, 61)', 'rgb(219, 2, 2)', 'rgb(255, 68, 0)',
    'rgb(22, 36, 73)', 'rgb(255, 224, 129)', 'rgb(53, 61, 82)', 'rgb(179, 190, 210)'

    // #'white', 'rgb(123, 48, 9)', 'rgb(61, 153, 86)', 'rgb(255, 116, 65)', 'rgb(153, 61, 113)', 'rgb(63, 61, 153)'

    // #'rgb(61, 90, 153)', 'rgb(153, 61, 144)', 'rgb(153, 109, 61)', 'rgb(67, 153, 61)',
    // #'rgb(61, 121, 153)', 'rgb(132, 61, 153)', 'rgb(153, 78, 61)', 'rgb(98, 153, 61)',
    // #'rgb(61, 151, 153)', 'rgb(101, 61, 153)', 'rgb(153, 61, 75)'
];


var io;


var users = {};

var User = function (id) {
  this.id = id;
  this.name = Math.random().toString(36).substr(2, 5).toUpperCase();
  this.color = colorScheme[0];
};

User.prototype.metadata = function () {
  return {
    name: this.name,
    id: this.id,
    color: this.color
  };
};

var mapOverGrid = function (grid, fn) {
  var ret = [];
  for (var i = 0; i < grid.length; i++) {
    var row = [];
    for (var j = 0; j < grid[i].length; j++) {
      row.push(fn(grid[i][j], i, j));
    }
    ret.push(row);
  }
  return ret;
};


var Room = function (name) {
  this.puzzle = {"title": "NY Times, Mon, Jun 03, 2013", "puzzle": ["CEDAR_ZION_PHIL", "AMORE_IRAE_RONA", "PIGINAPOKE_EGGY", "ELIE_EON_DASHES", "SEETHRU_OSOLE__", "___TOOTAT_KEANU", "JIHADS_TOW_YVES", "USA_SOWSEAR_ERE", "DEMI_LIE_SOUNDS", "DEFOE_CARHOP___", "__ININK_ATTACHE", "ASSISI_GNU_TAIL", "RITZ_PORKBARREL", "ALEE_ARAL_DEERE", "BODS_TOBE_SEWON"], "author": "John Lampkin / Will Shortz", "height": 15, "width": 15, "clues": {"down": {"1": "Bullfighters wave them", "2": "Writer Zola", "3": "Cowherd's stray", "4": "Short operatic song", "5": "Stimpy's bud", "6": "Like some detachable linings", "7": "What bodybuilders pump", "8": "Wood for a chest", "9": "Essentials", "10": "\"Blue Suede Shoes\" singer", "11": "Ecstatic state, informally", "12": "\"Bus Stop\" playwright", "13": "Puts down, as tile", "18": "Spray can", "23": "Just fine", "25": "Mortar troughs", "26": "Great Plains tribe", "28": "Floundering", "30": "Stereotypical techie", "31": "Applications", "32": "Naomi or Wynonna of country music", "33": "\"Got it!\"", "34": "Clumsy", "36": "Laundry basin", "40": "Lighted part of a candle", "41": "Part of a plant or tooth", "44": "Becomes charged, as the atmosphere", "47": "Stuck, with no way to get down", "49": "Sue Grafton's \"___ for Evidence\"", "51": "Really bug", "53": "Barely bite, as someone's heels", "55": "Rod who was a seven-time A.L. batting champ", "56": "Prefix with -glyphics", "57": "\"The ___ DeGeneres Show\"", "58": "Many an Iraqi", "59": "Corn Belt tower", "60": "Seize", "64": "Spanish gold", "65": "What TV watchers often zap"}, "across": {"1": "Wood for a chest", "6": "Holy Land", "10": "TV's Dr. ___", "14": "Love, Italian-style", "15": "\"Dies ___\" (Latin hymn)", "16": "Gossipy Barrett", "17": "Unseen purchase", "19": "Like custard and meringue", "20": "Writer Wiesel", "21": "Long, long time", "22": "- - -", "24": "Transparent, informally", "26": "\"___ Mio\"", "27": "Greet with a honk", "29": "Reeves of \"The Matrix\"", "32": "Holy wars", "35": "Drag behind, as a trailer", "37": "Designer Saint Laurent", "38": "Made in ___ (garment label)", "39": "You can't make a silk purse out of it, they say", "42": "Before, poetically", "43": "Actress Moore of \"Ghost\"", "45": "Tell a whopper", "46": "Buzz and bleep", "48": "Daniel who wrote \"Robinson Crusoe\"", "50": "Drive-in server", "52": "How to sign a contract", "54": "Ambassador's helper", "58": "Birthplace of St. Francis", "60": "African antelope", "61": "Part that wags", "62": "Big name in crackers", "63": "Like some wasteful government spending", "66": "Toward shelter, nautically", "67": "Asia's diminished ___ Sea", "68": "John ___ (tractor maker)", "69": "Physiques", "70": "Words before and after \"or not\"", "71": "Attach, as a button"}}};
  this.name = name;
  this.grid = [];
  for (var i = 0; i < 15; i++) {
    var row = [];
    for (var j = 0; j < 15; j++) {
      row.push('');
    }
    this.grid.push(row);
  }

  this.gridOwners = [];
  for (var i = 0; i < 15; i++) {
    var row = [];
    for (var j = 0; j < 15; j++) {
      row.push(null);
    }
    this.gridOwners.push(row);
  }

  this.users = {};
  this.userColors = {};
  this.colorsUsed = 0;
};

var rooms = { 'foo': new Room('foo') };

Room.prototype.sendChat = function (user, message) {
  console.log(this.name, user.name, message);
  io.to(this.name).emit('client chat message', {
    name: user.name,
    message: message.replace(/</g, '')  // Strip opening script tags... make better
  });
};

Room.prototype.userMetadata = function (user) {
  var metadata = user.metadata();
  metadata.color = this.userColors[user.id];
  return metadata;
};

Room.prototype.sendUsers = function () {
  io.to(this.name).emit('room members', R.map(this.userMetadata.bind(this))(R.values(this.users)));
};


Room.prototype.gridColors = function () {
  var room = this;
  return mapOverGrid(this.gridOwners, function (userId) {
    if (userId) {
      return room.userColors[userId];
    }
    return null;
  });
};

var RoomHandler = {};


var cookie = require('cookie');
var cookieParser = require('cookie-parser');
var fs = require('fs');
var Transform = require('stream').Transform;
var parser = new Transform({objectMode: true});
parser._transform = function(data, encoding, done) {
  console.log(data);
  this.push(data);
  done();
};

module.exports = function (app, server, sessionStore) {

  app.post('/uploads/:room', function (req, res) {
    console.log(req.busboy);
    req.busboy.on('file', function(fieldname, file, filename, encoding, mimetype) {
      console.log('File [' + fieldname + ']: filename: ' + filename + ', encoding: ' + encoding + ', mimetype: ' + mimetype);
      file.on('data', function(data) {
        console.log(data.toString());
        console.log('File [' + fieldname + '] got ' + data.length + ' bytes');
      });
      file.on('end', function() {
        console.log('File [' + fieldname + '] Finished');
      });
    });
    req.pipe(req.busboy);
  });



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
    socket.user.room = rooms['foo'];
    socket.user.room.users[socket.user.id] = socket.user;
    if (socket.user.room) {
      logger.log('room', socket.user.room.name);
      socket.join(socket.user.room.name);
    }
    socket.room = socket.user.room;
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
      if (!socket.room.userColors[socket.user.id]) {
        socket.room.userColors[socket.user.id] = colorScheme[socket.room.colorsUsed++];
        logger.info(socket.room.userColors);
      }

      socket.room.sendUsers();
      socket.emit('self metadata', socket.room.userMetadata(socket.user));
    });

    socket.on('chat message', function (message) {
      socket.user.room.sendChat(socket.user, message);
      // socket.emit('client chat message', { message: message, name: 'dasdf' })
    });

    socket.emit('existing puzzle', {
      puzzle: socket.room.puzzle,
      grid: socket.room.grid,
      player_squares: socket.room.gridColors()
    });

    socket.on('change square', function (data) {
      socket.room.grid[data.i][data.j] = data.char;
      socket.room.gridOwners[data.i][data.j] = socket.user.id;
      console.log('change square', data);
      data.color = socket.room.userColors[socket.user.id];
      io.to(socket.room.name).emit('change square', data);
    });

    socket.on('disconnect', function(){
      delete socket.room.users[socket.user.id];
      socket.room.sendUsers();
    });

    socket.on('set cursor', function (data) {
      data.user = socket.room.userMetadata(socket.user);
      io.to(socket.room.name).emit('set cursor', data);
    });

    socket.on('want cursor', function (data) {
      socket.broadcast.to(socket.room.name).emit('want cursors', {});
    });
  });

  return io;
};
