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

import time
import json
import re
import os
import traceback
from collections import OrderedDict

from utils import *

logger = logging.getLogger(__name__)
current_time = lambda: int(time.time() * 1000)

loader = tornado.template.Loader(os.path.join(os.path.join(os.path.realpath(__file__) + '/../'), 'templates'))

users = {}
rooms = {}
room_hash = {}
sockets = {}

class Puzzle:
    pass

class Room:
    def __init__(self):
        self.clients = OrderedDict()
        self.clients_exited = set()
        self.puzzle = {"title": "NY Times, Mon, Jun 03, 2013", "puzzle": ["CEDAR_ZION_PHIL", "AMORE_IRAE_RONA", "PIGINAPOKE_EGGY", "ELIE_EON_DASHES", "SEETHRU_OSOLE__", "___TOOTAT_KEANU", "JIHADS_TOW_YVES", "USA_SOWSEAR_ERE", "DEMI_LIE_SOUNDS", "DEFOE_CARHOP___", "__ININK_ATTACHE", "ASSISI_GNU_TAIL", "RITZ_PORKBARREL", "ALEE_ARAL_DEERE", "BODS_TOBE_SEWON"], "author": "John Lampkin / Will Shortz", "height": 15, "width": 15, "clues": {"down": {"1": "Bullfighters wave them", "2": "Writer Zola", "3": "Cowherd's stray", "4": "Short operatic song", "5": "Stimpy's bud", "6": "Like some detachable linings", "7": "What bodybuilders pump", "8": "Wood for a chest", "9": "Essentials", "10": "\"Blue Suede Shoes\" singer", "11": "Ecstatic state, informally", "12": "\"Bus Stop\" playwright", "13": "Puts down, as tile", "18": "Spray can", "23": "Just fine", "25": "Mortar troughs", "26": "Great Plains tribe", "28": "Floundering", "30": "Stereotypical techie", "31": "Applications", "32": "Naomi or Wynonna of country music", "33": "\"Got it!\"", "34": "Clumsy", "36": "Laundry basin", "40": "Lighted part of a candle", "41": "Part of a plant or tooth", "44": "Becomes charged, as the atmosphere", "47": "Stuck, with no way to get down", "49": "Sue Grafton's \"___ for Evidence\"", "51": "Really bug", "53": "Barely bite, as someone's heels", "55": "Rod who was a seven-time A.L. batting champ", "56": "Prefix with -glyphics", "57": "\"The ___ DeGeneres Show\"", "58": "Many an Iraqi", "59": "Corn Belt tower", "60": "Seize", "64": "Spanish gold", "65": "What TV watchers often zap"}, "across": {"1": "Wood for a chest", "6": "Holy Land", "10": "TV's Dr. ___", "14": "Love, Italian-style", "15": "\"Dies ___\" (Latin hymn)", "16": "Gossipy Barrett", "17": "Unseen purchase", "19": "Like custard and meringue", "20": "Writer Wiesel", "21": "Long, long time", "22": "- - -", "24": "Transparent, informally", "26": "\"___ Mio\"", "27": "Greet with a honk", "29": "Reeves of \"The Matrix\"", "32": "Holy wars", "35": "Drag behind, as a trailer", "37": "Designer Saint Laurent", "38": "Made in ___ (garment label)", "39": "You can't make a silk purse out of it, they say", "42": "Before, poetically", "43": "Actress Moore of \"Ghost\"", "45": "Tell a whopper", "46": "Buzz and bleep", "48": "Daniel who wrote \"Robinson Crusoe\"", "50": "Drive-in server", "52": "How to sign a contract", "54": "Ambassador's helper", "58": "Birthplace of St. Francis", "60": "African antelope", "61": "Part that wags", "62": "Big name in crackers", "63": "Like some wasteful government spending", "66": "Toward shelter, nautically", "67": "Asia's diminished ___ Sea", "68": "John ___ (tractor maker)", "69": "Physiques", "70": "Words before and after \"or not\"", "71": "Attach, as a button"}}}
        self.grid = [['' for j in range(15)] for i in range(15)]
        self.grid_owners = [[None for j in range(15)] for i in range(15)]
        self.grid_owner_counts = {}
        self.grid_changes = {}
        #self.grid_corrects = {}
        self.grid_corrects = []
        self.last_grid_change = None
        self.last_grid_correct = None

        self.id = uuid.uuid4()
        self.complete = False
        self.competitive = True

        self.start_time = current_time()

        self.client_squares = {}

        room_hash[str(self.id)] = self

    def broadcast(self, message):
        for id in self.clients.keys():
            if id not in self.clients_exited:
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

    def errors(self):
        errors = []
        for i in range(self.puzzle['height']):
            for j in range(self.puzzle['width']):
                if self.puzzle['puzzle'][i][j] != '_' and self.puzzle['puzzle'][i][j] != self.grid[i][j]:
                    errors.append([i, j])

        return errors

    def finished(self):
        return self.complete or len(self.errors()) == 0

    def check_puzzle(self):
        if self.complete:
            return True
        if self.finished():
            self.complete = True
            message = {
                'type': 'puzzle finished',
            }
            self.broadcast(json.dumps(message))

            scores = self.rank_grid_owners()
            standings = ''.join(['<li value="%d">%s: %d squares</li>' % (rank, name, score) for (rank, score, name) in scores])
            self.room_chat('Standings: <ol>' + standings + '</ol>')
            return True
        return False

    def grid_owner_colors(self):
        return [[self.clients[j].color if j is not None else None for j in i] for i in self.grid_owners]

    def count_grid_owners(self):
        # The first two stanzas can be replaced since we now have self.grid_owner_counts
        owner_counts = {}
        for client_id in self.clients:
            owner_counts[client_id] = 0
        
        for row in self.grid_owners:
            for owner in row:
                if owner is not None:
                    if owner not in owner_counts:
                        owner_counts[owner] = 0
                    owner_counts[owner] += 1

        scores = []
        for id in owner_counts:
            if id in sockets:
                scores.append((owner_counts[id], sockets[id].name))

        return sorted(scores)[::-1]

    def rank_grid_owners(self):
        scores = self.count_grid_owners()

        ranked = []
        last = None
        for i, (score, name) in enumerate(scores):
            if last != score:
                rank, last = i + 1, score
            ranked.append((rank, score, name))
            
        return ranked

    def grid_change(self, client_id, i, j, new_char):
        if client_id not in self.grid_changes:
            self.grid_changes[client_id] = { 'color': self.clients[client_id].color, 'data': [] }

        old_char = self.grid[i][j]

        old_correct = int(self.puzzle['puzzle'][i][j] == old_char)
        new_correct = int(self.puzzle['puzzle'][i][j] == new_char)
        delta = new_correct - old_correct
        old_owner_id = self.grid_owners[i][j]

        # Update grid_owners if cell was changed
        if self.grid[i][j] != new_char:
            self.grid_owners[i][j] = client_id
        if new_char == '':
            self.grid_owners[i][j] = None

        self.grid[i][j] = new_char

        # No need for superfluous grid change entries
        time_since_start = current_time() - self.start_time
        if 1: ## delta != 0 or len(self.grid_changes[client_id]) < 2 or self.grid_changes[client_id][-2]['correct'] != self.grid_changes[client_id][-1]['correct']:
            # Penalizing the old owner is unfair, must be smart about contributions vs. correctness
            changed_client_id = old_owner_id if delta == -1 else client_id
            if changed_client_id is not None:
                self.grid_owner_counts[changed_client_id] += delta

            # self.last_grid_change = { 'time': time_since_start, 'correct': self.grid_owner_counts[client_id] }
            self.last_grid_change = { 'client_id': client_id, 'server_time': current_time(), 'correct': self.grid_owner_counts[client_id] }
            self.last_grid_correct = { 'client_id': client_id, 'server_time': current_time(), 'correct': sum(self.grid_owner_counts.values()) }
            self.grid_changes[client_id]['data'].append(self.last_grid_change)
            self.grid_corrects.append(self.last_grid_correct)
        ## else:
        ##     self.grid_changes[client_id][-1]['time'] = time_since_start

    def broadcast_memberlist(self, own_socket_id):
        message = {
            'type': 'room members',
            'content': [sockets[id].metadata() for id in self.clients if id not in self.clients_exited]
        }
        self.broadcast(json.dumps(message))


class GameHandler(tornado.web.RequestHandler):
    def get(self, room_name):
        # create room if necessary
        if room_name not in rooms:
            rooms[room_name] = Room()
        print 'Game' + room_name + ' ' + str(rooms[room_name].id)

        self.write(loader.load('game.html').generate(id=room_name,room=rooms[room_name]))


class LobbyHandler(tornado.web.RequestHandler):
    def get(self):
        self.write(loader.load('lobby.html').generate())


class UploadHandler(tornado.web.RequestHandler):
    def post(self, room_id):
        if room_id in room_hash:
            raw_puzzle = self.request.files['puzzle'][0]['body']

            # print raw_puzzle
            room = room_hash[room_id]
            room.puzzle = parse(raw_puzzle)
            print json.dumps(room.puzzle)
            room.start_time = current_time()

            message = {}
            message['content'] = room.puzzle
            message['type'] = 'new puzzle'
            message['start_time'] = room.start_time

            # set up room grid
            room.grid = {}
            room.grid_owners = [[None for j in range(room.puzzle['width'])] for i in range(room.puzzle['height'])]
            for i in range(room.puzzle['height']):
                room.grid[i] = {}
                for j in range(room.puzzle['width']):
                    room.grid[i][j] = ''

            room.complete = False

            room.broadcast(json.dumps(message))
            room.room_chat('Puzzle changed to %s.' % room.puzzle['title'])
            self.write('Success!')
        else:
            self.write('Failure...')


class PlayerWebSocket(tornado.websocket.WebSocketHandler):
    def __init__(self, *args, **kwargs):
        super(PlayerWebSocket, self).__init__(*args, **kwargs)

    def open(self, room):
        print room
        self.room = room
        # Generate alphabetic username (not alphanumeric)
        self.name = ''.join(random.choice(string.ascii_uppercase) for x in range(5))
        print 'Opening', self.name

    def open2(self, username):
        # look up the uuid in the NSA's huge data center
        if uuid in rooms[self.room].clients.keys():
            self.id = uuid
            self.color = color_scheme[rooms[self.room].clients.keys().index(uuid) % len(color_scheme)]
        else:
            self.id = str(uuid.uuid4())
            self.color = next_color_in_scheme(len(rooms[self.room].clients))
            self.send({
                'type': 'new uuid',
                'uuid': self.id
                })

        sockets[self.id] = self

        message = {
            'type': 'room chat message',
            'content': 'Welcome! You can change your username with /u.'
        }
        self.send(message)

        # add to room list
        rooms[self.room].clients[self.id] = self
        # No encapsulation? #YOLO
        if self.id not in rooms[self.room].grid_owner_counts:
            rooms[self.room].grid_owner_counts[self.id] = 0

        message = {
            'type': 'room chat message',
            'content': self.name + ' joined.'
        }
        rooms[self.room].broadcast(json.dumps(message))
        rooms[self.room].broadcast_memberlist(self.id)

        # send puzzle, if any
        if rooms[self.room].puzzle is not None:
            message = {}
            message['type'] = 'existing puzzle'
            message['content'] = {
                'puzzle': rooms[self.room].puzzle,
                'grid': rooms[self.room].grid,
                'player_squares': rooms[self.room].grid_owner_colors(),
                'complete': rooms[self.room].complete,
                'start_time': rooms[self.room].start_time,
                'current_time': current_time(),
                'grid_corrects': rooms[self.room].grid_corrects
            }
            self.send(message)

    def metadata(self):
        return {'name': self.name, 'id': str(self.id),
            'color': self.color}

    def on_close(self):
        print 'Closing:', self.name, self.id
        print rooms[self.room].clients


        # leave the room
        rooms[self.room].clients_exited.add(self.id)

        # notify the room that the player has left
        message = {
            'type': 'room chat message',
            'content': self.name + ' left.'
        }
        rooms[self.room].broadcast(json.dumps(message))
        rooms[self.room].broadcast_memberlist(self.id)

        del sockets[self.id]

    def broadcast_others(self, message):
        for id in rooms[self.room].clients:
            if id not in rooms[self.room].clients_exited:
                if id != self.id:
                    sockets[id].write_message(json.dumps(message))

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

        if message['type'] == 'recall uuid':
            self.open2(message['uuid'])

        if message['type'] == 'client chat message':
            # like the NSA, read the message to check for commands
            if len(message['content']) > 0 and message['content'][0] != '/':
                message['name'] = self.name
                rooms[self.room].broadcast(json.dumps(message))
            else:
                message['type'] = 'room chat message'
                if '/u' in message['content']:
                    new_username = ' '.join(message['content'].split()[1:])
                    if new_username.isalnum():
                        alert = '%s changed their name to %s' % (self.name, new_username)
                        self.name = new_username
                        rooms[self.room].room_chat(alert)
                        rooms[self.room].broadcast_memberlist(self.id)
                    else:
                        message['content'] = 'Invalid username.'
                        self.send(message)
                else:
                    message['content'] = 'Invalid command.'
                    self.send(message)

        if message['type'] == 'change square':
            # update state of puzzle
            data = message['content']

            rooms[self.room].grid_change(self.id, data['i'], data['j'], data['char'])

            message['color'] = rooms[self.room].grid_owner_colors()[data['i']][data['j']]
            message['grid_changes'] = rooms[self.room].grid_changes
            #message['last_grid_change'] = rooms[self.room].last_grid_change
            #message['last_grid_correct'] = rooms[self.room].last_grid_correct
            message['grid_corrects'] = rooms[self.room].grid_corrects
            rooms[self.room].broadcast(json.dumps(message))
            rooms[self.room].print_grid()
            rooms[self.room].check_puzzle()

        if message['type'] == 'set cursor':
            message['user'] = self.metadata()
            self.broadcast_others(message)

        if message['type'] == 'want cursors':
            self.broadcast_others(message)

        if message['type'] == 'toggle option':
            pass

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
    [(r'/', LobbyHandler),
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
