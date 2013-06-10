import sys

import tornado
import tornado.websocket
import tornado.httpserver
import tornado.ioloop
import tornado.template
import tornado.autoreload
import random, string
import uuid

import json
import re
import os
import traceback


loader = tornado.template.Loader(os.path.join(os.path.join(os.path.realpath(__file__) + '/../'), 'templates'))

users = {}
rooms = {'lobby' : set()}
sockets = {}

class BaseHandler(tornado.web.RequestHandler):
	def get_current_user(self):
		return self.get_secure_cookie("user")


class NewGameHandler(BaseHandler):
	@tornado.web.authenticated
	def get(self):
		rooms[5] = set()
		rooms[4] = set()
		print rooms
		self.write('new game')

class GameHandler(BaseHandler):
	def get(self, id):
		print 'Game %s' % id

		self.write(loader.load('game.html').generate(id=id))

		

class PlayerWebSocket(tornado.websocket.WebSocketHandler):
	clients = []

	def __init__(self, *args, **kwargs):
		super(PlayerWebSocket, self).__init__(*args, **kwargs)

	def open(self):
		print 'herp'
		self.id = uuid.uuid4()
		sockets[self.id] = self
		self.name = ''.join(random.choice(string.ascii_uppercase + string.digits) for x in range(5))
		print 'Opening', self.name
		self.clients.append(self)

		for id in sockets:
			message = {
				'type': 'room chat message',
				'content': self.name + ' joined.'
			}
			sockets[id].write_message(json.dumps(message))
		
	def on_close(self):
		print 'Closing:', self.name, self.id
		del sockets[self.id]

		for id in sockets:
			message = {
				'type': 'room chat message',
				'content': self.name + ' left.'
			}
			sockets[id].write_message(json.dumps(message))

	def on_message(self, message):
		print self.name, json.loads(message)
		message = json.loads(message)
		# username = self.get_secure_cookie("user")
		# roommates = [users[name].socket for name in rooms[users[username].room]]
		# print username, message, users[username].room, roommates
		# for client in roommates:
		# 	client.write_message('%s %s' % (username, message))

		if message['type'] == 'client chat message':
			message['name'] = self.name	
			for id in sockets:
				sockets[id].write_message(json.dumps(message))



################### Tornado server settings ####################
settings = {
	'debug' : True,
	'static_path'  : os.path.join(os.path.realpath(__file__ + '/../'), 'static'),
	'template_path'  : os.path.join(os.path.realpath(__file__ + '/../'), 'templates'),
	'cookie_secret' : "Ol7xSC1zQ09SXnESNi3L",
	'login_url' : '/login'
}

application = tornado.web.Application(**settings)
application.add_handlers('.*$',[#(r'/', LobbyHandler),
								(r'/new', NewGameHandler),
								(r'/play/(?P<id>[^\/]+)', GameHandler),
								(r'/play/[^\/]+/sub', PlayerWebSocket)])

if __name__ == '__main__':
	for (path, dirs, files) in os.walk(settings["template_path"]):
		for item in files:
			tornado.autoreload.watch(os.path.join(path, item))

	http_server = tornado.httpserver.HTTPServer(application)
	http_server.listen(5557)
	tornado.ioloop.IOLoop.instance().start()