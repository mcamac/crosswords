import sys

from bjord.player import Player

import tornado
import tornado.websocket
import tornado.httpserver
import tornado.ioloop
import tornado.template

import re
import os
import traceback


loader = tornado.template.Loader(os.path.join(os.path.join(os.path.realpath(__file__) + '/../'), 'templates'))

users = {}
rooms = {'lobby' : set()}

class BaseHandler(tornado.web.RequestHandler):
	def get_current_user(self):
		return self.get_secure_cookie("user")

class LoginHandler(BaseHandler):
	def get(self):
		self.write('<html><body><form action="/login" method="post">'
				   'Name: <input type="text" name="name">'
				   '<input type="submit" value="Sign in">'
				   '</form></body></html>')
	def post(self):
		self.set_secure_cookie("user", self.get_argument("name"))
		if not users.has_key(self.get_argument('name')):
			users[self.get_argument('name')] = {}
		self.redirect("/")

class LogoutHandler(BaseHandler):
	def get(self):
		self.set_secure_cookie("user", "")
		self.redirect('/')

class LobbyHandler(BaseHandler):
	@tornado.web.authenticated
	def get(self):
		# kick old user
		if self.get_current_user() not in users:
			self.redirect('/logout')
			return
		print users
		print self.get_current_user()
		username = self.get_current_user()
		player = Player(username)
		users[username] = player
		users[username].room = 'lobby'
		rooms['lobby'].add(username)
		print rooms['lobby']

		application.add_handlers(r'.*$',
			[(self.request.uri + 'sub',
				PlayerWebSocket)])

		self.write(loader.load('lobby.html').generate(user=self.get_current_user()))

class NewGameHandler(BaseHandler):
	@tornado.web.authenticated
	def get(self):
		rooms[5] = set()
		rooms[4] = set()
		print rooms
		self.write('new game')

class GameHandler(BaseHandler):
	@tornado.web.authenticated
	def get(self, id):
		print 'Game %s' % id
		username = self.get_current_user()

		print 'Coming from room:', users[username].room, rooms[users[username].room], rooms
		if username in rooms[users[username].room]:
			rooms[users[username].room].remove(username)
		rooms[id].add(username)

		users[username].room = id
		self.write(loader.load('game.html').generate(user=username,id=id))

		

class PlayerWebSocket(tornado.websocket.WebSocketHandler):
	clients = []

	def __init__(self, *args, **kwargs):
		super(PlayerWebSocket, self).__init__(*args, **kwargs)

	def open(self):
		username = self.get_secure_cookie("user")
		users[username].socket = self
		print "Opening:", username
		self.clients.append(self)
		

	def on_close(self):
		username = self.get_secure_cookie("user")
		print 'Closing:', username
		self.clients.remove(self)

	def on_message(self, message):
		username = self.get_secure_cookie("user")
		roommates = [users[name].socket for name in rooms[users[username].room]]
		print username, message, users[username].room, roommates
		for client in roommates:
			client.write_message('%s %s' % (username, message))



################### Tornado server settings ####################
settings = {
	'debug' : True,
	'static_path'  : os.path.join(os.path.realpath(__file__ + '/../'), 'static'),
	'cookie_secret' : "Ol7xSC1zQ09SXnESNi3L",
	'login_url' : '/login'
}

application = tornado.web.Application(**settings)
application.add_handlers('.*$',[(r'/', LobbyHandler),
								(r'/login', LoginHandler),
								(r'/logout', LogoutHandler),
								(r'/new', NewGameHandler),
								(r'/play/(?P<id>[^\/]+)', GameHandler),
								(r'/play/[^\/]+/sub', PlayerWebSocket)])

if __name__ == '__main__':
	http_server = tornado.httpserver.HTTPServer(application)
	http_server.listen(5557)
	tornado.ioloop.IOLoop.instance().start()