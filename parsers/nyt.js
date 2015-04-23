var casper = require('casper').create();

var date = casper.cli.args[0];
var url = 'https://myaccount.nytimes.com/auth/login';
var target = 'http://www.nytimes.com/svc/crosswords/v2/puzzle/daily-' + date + '.puz';

casper.start(url);
casper.wait(2000, function () {});

casper.waitForSelector('input#userid', function () {
  this.fill('form.loginForm', require('./nyt-creds.json'), true);
  console.log('Logging in.');
});

casper.wait(3000, function () {
   this.download(target, date + '.puz');
});

casper.run();
