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
        self.puzzle = {"title": "NY Times, Mon, Jun 03, 2013", "puzzle": ["CEDAR_ZION_PHIL", "AMORE_IRAE_RONA", "PIGINAPOKE_EGGY", "ELIE_EON_DASHES", "SEETHRU_OSOLE__", "___TOOTAT_KEANU", "JIHADS_TOW_YVES", "USA_SOWSEAR_ERE", "DEMI_LIE_SOUNDS", "DEFOE_CARHOP___", "__ININK_ATTACHE", "ASSISI_GNU_TAIL", "RITZ_PORKBARREL", "ALEE_ARAL_DEERE", "BODS_TOBE_SEWON"], "author": "John Lampkin / Will Shortz", "height": 15, "width": 15, "clues": {"down": {"1": "Bullfighters wave them", "2": "Writer Zola", "3": "Cowherd's stray", "4": "Short operatic song", "5": "Stimpy's bud", "6": "Like some detachable linings", "7": "What bodybuilders pump", "8": "Wood for a chest", "9": "Essentials", "10": "\"Blue Suede Shoes\" singer", "11": "Ecstatic state, informally", "12": "\"Bus Stop\" playwright", "13": "Puts down, as tile", "18": "Spray can", "23": "Just fine", "25": "Mortar troughs", "26": "Great Plains tribe", "28": "Floundering", "30": "Stereotypical techie", "31": "Applications", "32": "Naomi or Wynonna of country music", "33": "\"Got it!\"", "34": "Clumsy", "36": "Laundry basin", "40": "Lighted part of a candle", "41": "Part of a plant or tooth", "44": "Becomes charged, as the atmosphere", "47": "Stuck, with no way to get down", "49": "Sue Grafton's \"___ for Evidence\"", "51": "Really bug", "53": "Barely bite, as someone's heels", "55": "Rod who was a seven-time A.L. batting champ", "56": "Prefix with -glyphics", "57": "\"The ___ DeGeneres Show\"", "58": "Many an Iraqi", "59": "Corn Belt tower", "60": "Seize", "64": "Spanish gold", "65": "What TV watchers often zap"}, "across": {"1": "Wood for a chest", "6": "Holy Land", "10": "TV's Dr. ___", "14": "Love, Italian-style", "15": "\"Dies ___\" (Latin hymn)", "16": "Gossipy Barrett", "17": "Unseen purchase", "19": "Like custard and meringue", "20": "Writer Wiesel", "21": "Long, long time", "22": "- - -", "24": "Transparent, informally", "26": "\"___ Mio\"", "27": "Greet with a honk", "29": "Reeves of \"The Matrix\"", "32": "Holy wars", "35": "Drag behind, as a trailer", "37": "Designer Saint Laurent", "38": "Made in ___ (garment label)", "39": "You can't make a silk purse out of it, they say", "42": "Before, poetically", "43": "Actress Moore of \"Ghost\"", "45": "Tell a whopper", "46": "Buzz and bleep", "48": "Daniel who wrote \"Robinson Crusoe\"", "50": "Drive-in server", "52": "How to sign a contract", "54": "Ambassador's helper", "58": "Birthplace of St. Francis", "60": "African antelope", "61": "Part that wags", "62": "Big name in crackers", "63": "Like some wasteful government spending", "66": "Toward shelter, nautically", "67": "Asia's diminished ___ Sea", "68": "John ___ (tractor maker)", "69": "Physiques", "70": "Words before and after \"or not\"", "71": "Attach, as a button"}}}
        self.grid = [['' for j in range(15)] for i in range(15)]
        # self.grid = [['', 'A', 'S', 'S', 'E', 'S', '', 'B', 'O', 'A', 'T', '', 'S', 'T', 'E'], ['E', 'M', 'P', 'I', 'R', 'E', '', 'E', 'A', 'V', 'E', '', 'A', 'I', 'D'], ['S', 'T', 'A', 'L', 'E', 'C', 'O', 'F', 'F', 'E', 'E', '', 'L', 'P', 'S'], ['', '', 'M', 'A', 'I', 'T', 'A', 'I', '', '', '', 'T', 'O', 'T', 'E'], ['J', 'A', 'B', 'S', '', '', 'S', 'T', 'E', 'E', 'L', 'W', 'O', 'O', 'L'], ['I', 'D', 'O', '', 'D', 'D', 'T', '', 'B', 'Y', 'L', 'I', 'N', 'E', 'S'], ['G', 'A', 'T', 'E', 'A', 'U', '', 'A', 'R', 'E', 'A', 'S', '', '', ''], ['', '', 'S', 'T', 'Y', 'L', 'E', 'P', 'O', 'I', 'N', 'T', 'S', '', ''], ['', '', '', 'H', 'O', 'U', 'S', 'E', '', 'N', 'O', 'S', 'T', 'R', 'A'], ['P', 'A', 'T', 'E', 'N', 'T', 'S', '', 'F', 'G', 'S', '', 'R', 'U', 'G'], ['S', 'T', 'O', 'L', 'E', 'H', 'O', 'M', 'E', '', '', 'V', 'I', 'B', 'E'], ['A', 'M', 'P', 'S', '', '', '', 'E', 'L', 'O', 'P', 'E', 'D', '', ''], ['L', 'O', 'G', '', 'S', 'T', 'O', 'O', 'L', 'P', 'I', 'G', 'E', 'O', 'N'], ['M', 'S', 'U', '', 'T', 'H', 'A', 'W', '', 'E', 'L', 'A', 'N', 'D', 'S'], ['S', 'T', 'N', '', 'Y', 'U', 'K', 'S', '', 'N', 'E', 'S', 'T', 'E', 'A']]
        self.id = uuid.uuid4()
        self.complete = False
        self.competitive = True

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

    def errors(self):
        errors = []
        for i in range(self.puzzle['height']):
            for j in range(self.puzzle['width']):
                if self.puzzle['puzzle'][i][j] != '_' and self.puzzle['puzzle'][i][j] != self.grid[i][j]:
                    errors.append([i, j])
        print 'errors', errors
        return errors

    def finished(self):
        return self.complete or len(self.errors()) == 0

    def check_puzzle(self):
        if self.complete:
            return True
        if self.finished():
            self.complete = True
            self.room_chat('Puzzle finished!')
            message = {
                'type': 'puzzle finished',
            }
            self.broadcast(json.dumps(message))
            return True
        return False

    def broadcast_memberlist(self):
        message = {
            'type': 'room members',
            'content': [sockets[id].name for id in self.clients]
        }
        self.broadcast(json.dumps(message))

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

            message = {}
            message['content'] = room.puzzle
            message['type'] = 'new puzzle'

            # set up room grid
            room.grid = {}
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

        message = {
            'type': 'room chat message',
            'content': 'Welcome! You can change your username with /u.'
        }
        self.send(message)

        # add to room list
        rooms[room].clients.add(self.id)

        message = {
            'type': 'room chat message',
            'content': self.name + ' joined.'
        }
        rooms[self.room].broadcast(json.dumps(message))
        rooms[self.room].broadcast_memberlist()

        # send puzzle, if any
        if rooms[self.room].puzzle is not None:
            message = {}
            message['type'] = 'existing puzzle'
            message['content'] = {
                'puzzle': rooms[self.room].puzzle,
                'grid': rooms[self.room].grid,
                'complete': rooms[self.room].complete
            }
            self.send(message)
        
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
        rooms[self.room].broadcast_memberlist()

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
                        rooms[self.room].broadcast_memberlist()
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
            rooms[self.room].check_puzzle()


################### Tornado server settings ####################
settings = {
    'debug' : True,
    'static_path'  : os.path.join(os.path.realpath(__file__ + '/../'), 'static'),
    'template_path'  : os.path.join(os.path.realpath(__file__ + '/../'), 'templates'),
    'cookie_secret' : "Ol7xSC1zQ09SXnESNi3L",
    'login_url' : '/login'
}

print settings['static_path']

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
