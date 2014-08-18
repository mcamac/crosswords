// server.js
var express = require('express');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var session = require('express-session');
var logfmt = require('logfmt');
var passport = require('passport');
var mongoose = require('mongoose');
var redis = require('redis');
var RedisStore = require('connect-redis')(session);


mongoose.connect(process.env.MONGOHQ_URL || 'mongodb://localhost');

if (process.env.REDISTOGO_URL) {
   // inside if statement
  var rtg   = require("url").parse(process.env.REDISTOGO_URL);
  var redis = require("redis").createClient(rtg.port, rtg.hostname);

  redis.auth(rtg.auth.split(":")[1]);
} else {
  var redis = require("redis").createClient();
}

// redis.sadd('guests', 'g1');

var sessionStore = new RedisStore({ client: redis });

var app = express();

app.set('views', __dirname + '/views');
app.engine('html', require('ejs').renderFile);
app.use('/static', express.static(__dirname + '/static'));

app.use(cookieParser());
app.use(bodyParser());
app.use(session({ store: sessionStore, secret: 'keyboard cat', name:'crosswords.sid' }));
app.use(passport.initialize());
// app.use(passport.session());
// app.use(logfmt.requestLogger());

// require('./auth')(passport, redis);

require('./routes')(app, passport);


var server = require('http').Server(app);
require('./sockets')(app, server, sessionStore);

var port = Number(process.env.PORT || 5000);
server.listen(port, function() {
  console.log('Listening on ' + port);
});
