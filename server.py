import sys

import tornado
import tornado.websocket
import tornado.httpserver
import tornado.ioloop
import tornado.template
import tornado.autoreload
import random, string
import uuid
import logging

import json
import re
import os
import traceback

logger = logging.getLogger(__name__)

loader = tornado.template.Loader(os.path.join(os.path.join(os.path.realpath(__file__) + '/../'), 'templates'))

users = {}
rooms = {}
room_hash = {}
sockets = {}

class Puzzle:
    pass

class Room:
    def __init__(self):
        self.clients = set()
        self.puzzle = Puzzle()
        self.grid = [['' for j in range(15)] for i in range(15)]
        self.id = uuid.uuid4()
        room_hash[str(self.id)] = self

    def broadcast(self, message):
        for id in self.clients:
            sockets[id].write_message(message)

    def room_chat(self, content):
        message = {
            'type': 'room chat message',
            'content': content
        }
        self.broadcast(json.dumps(message))

    def print_grid(self):
        for i in range(self.puzzle['height']):
            print ''.join([self.grid[i][j] if self.grid[i][j] != '' else ' ' 
                           for j in range(self.puzzle['width'])])

    def get_errors(self):
        pass

# parse puz files
# TODO: refactor this
def parse(s):
    # ACROSS&DOWN watermark
    if ''.join(s[2:13]) != 'ACROSS&DOWN':
        return
    
    width, height = ord(s[44]), ord(s[45])
    # print width, height
    #print unpack('s',s[46] + s[47])
    puzzle = s[52:52 + width*height]
    p = [puzzle[i*width:i*width+width] for i in range(0,height)]
    a = 52 + 2 * width * height
    info = ''.join(s[a:]).split('\x00')
    title = info[0]
    author = info[1]
    clue_array = info[3:]
    # print clue_array
    clues = {}
    clues['across'] = {}
    clues['down'] = {}
    #print len(clue_array)
    #print p
    clue_number = 1
    i = 0
    for row in range(height):
        for col in range(width):
            #across
            used = False
            if p[row][col] == '.': continue
            if col == 0 or p[row][col-1] == '.':
                clues['across'][clue_number] = clue_array[i].decode('iso-8859-1').encode('utf-8')
                i += 1
                used = True
            # down clue
            if row == 0 or p[row-1][col] == '.':
                clues['down'][clue_number] = clue_array[i].decode('iso-8859-1').encode('utf-8')
                i += 1
                used = True

            if used:
                clue_number += 1


    data = {}
    data['width'] = width
    data['height'] = height
    data['title'] = title
    data['author'] = author
    data['puzzle'] = [''.join(x).replace('.','_') for x in p]
    # data['puzzle'] = [''.join([x[i] for x in data['puzzle']]) for i in range(len(data['puzzle'][0]))]
    data['clues'] = clues

    return data

class BaseHandler(tornado.web.RequestHandler):
    def get_current_user(self):
        return self.get_secure_cookie("user")

class GameHandler(BaseHandler):
    def get(self, room_name):
        # create room if necessary
        if room_name not in rooms:
            rooms[room_name] = Room()
        print 'Game' + room_name + ' ' + str(rooms[room_name].id)

        self.write(loader.load('game.html').generate(id=room_name,room=rooms[room_name]))

class UploadHandler(tornado.web.RequestHandler):
    def post(self, room_id):
        if room_id in room_hash:
            raw_puzzle = self.request.files['puzzle'][0]['body']
            room = room_hash[room_id]
            room.puzzle = parse(raw_puzzle)

            message = {}
            message['content'] = room.puzzle
            message['type'] = 'new puzzle'

            # set up room grid
            room.grid = {}
            for i in range(room.puzzle['height']):
                room.grid[i] = {}
                for j in range(room.puzzle['width']):
                    room.grid[i][j] = ''
            
            room.broadcast(json.dumps(message))
            room.room_chat('Puzzle changed to %s.' % room.puzzle['title'])
            self.write('Success!')
        else:
            self.write('Failure...')
        

class PlayerWebSocket(tornado.websocket.WebSocketHandler):
    clients = []

    def __init__(self, *args, **kwargs):
        super(PlayerWebSocket, self).__init__(*args, **kwargs)

    def open(self, room):
        print room
        self.room = room
        self.id = uuid.uuid4()
        sockets[self.id] = self
        self.name = ''.join(random.choice(string.ascii_uppercase + string.digits) for x in range(5))
        print 'Opening', self.name

        
        rooms[room].clients.add(self.id)
        print rooms


        message = {
            'type': 'room chat message',
            'content': self.name + ' joined.'
        }
        rooms[self.room].broadcast(json.dumps(message))
        
    def on_close(self):
        print 'Closing:', self.name, self.id
        print rooms[self.room].clients
        

        # leave the room
        rooms[self.room].clients.remove(self.id)

        # notify the room that the player has left
        message = {
            'type': 'room chat message',
            'content': self.name + ' left.'
        }
        rooms[self.room].broadcast(json.dumps(message))

        del sockets[self.id]
    
    # some shorthand
    def send(self, message):
        self.write_message(json.dumps(message))

    def on_message(self, message):
        print self.name, json.loads(message)
        message = json.loads(message)
        # username = self.get_secure_cookie("user")
        # roommates = [users[name].socket for name in rooms[users[username].room]]
        # print username, message, users[username].room, roommates
        # for client in roommates:
        #   client.write_message('%s %s' % (username, message))

        if message['type'] == 'client chat message':
            # like the NSA, read the message to check for commands
            if message['content'][0] != '/':
                message['name'] = self.name
                rooms[self.room].broadcast(json.dumps(message))
            else:
                message['type'] = 'room chat message'
                if '/u' in message['content']:
                    new_username = ' '.join(message['content'].split()[1:])
                    if new_username.isalpha():
                        alert = '%s changed their name to %s' % (self.name, new_username)
                        self.name = new_username
                        rooms[self.room].room_chat(alert)
                    else:
                        message['content'] = 'Invalid username.'
                        self.send(message)
                else:
                    message['content'] = 'Invalid command.'
                    self.send(message)

        if message['type'] == 'change square':
            # update state of puzzle
            data = message['content']
            rooms[self.room].grid[data['i']][data['j']] = data['char']
            rooms[self.room].broadcast(json.dumps(message))
            rooms[self.room].print_grid()


################### Tornado server settings ####################
settings = {
    'debug' : True,
    'static_path'  : os.path.join(os.path.realpath(__file__ + '/../'), 'static'),
    'template_path'  : os.path.join(os.path.realpath(__file__ + '/../'), 'templates'),
    'cookie_secret' : "Ol7xSC1zQ09SXnESNi3L",
    'login_url' : '/login'
}

application = tornado.web.Application(**settings)
application.add_handlers('.*$',
    [#(r'/', LobbyHandler),
    (r'/play/(?P<room_name>[^\/]+)', GameHandler),
    (r'/play/(?P<room>[^\/]+)/sub', PlayerWebSocket),
    (r'/uploads\/([^\/]+)', UploadHandler),])

if __name__ == '__main__':
    for (path, dirs, files) in os.walk(settings["template_path"]):
        for item in files:
            tornado.autoreload.watch(os.path.join(path, item))

    http_server = tornado.httpserver.HTTPServer(application)
    http_server.listen(5557)
    tornado.ioloop.IOLoop.instance().start()
