// Authentication redirection middleware
function isLoggedIn(req, res, next) {
  if (req.isAuthenticated())
    return next();

  res.redirect('/login');
}

module.exports = function (app, passport) {

  app.get('/', function(req, res) {
    res.render('lobby.html');
  });


  // app.get('/login', function (req, res) {
  //   res.render('login.jade', { user: req.user });
  // });

  // app.post('/login', passport.authenticate('local', { successRedirect: '/',
  //                                    failureRedirect: '/login'}));

  // app.post('/guest-login', passport.authenticate('local-guest', { successRedirect: '/',
  //                                    failureRedirect: '/login'}));

  // app.get('/logout', function(req, res){
  //   req.logout();
  //   res.redirect('/login');
  // });

  app.get('/play/:room', function(req, res) {
    res.render('game.html', {
      room: { id : req.params.room }
    });
  });

};
