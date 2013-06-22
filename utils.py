import random

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

def random_color():
    r = lambda: random.randint(0,255)
    return '#%02X%02X%02X' % (r(),r(),r())

# TODO: don't hardcode
color_scheme = [
    'rgb(63, 61, 153)', 'rgb(153, 61, 113)', 'rgb(153, 139, 61)', 'rgb(61, 153, 86)',
    'rgb(61, 90, 153)', 'rgb(153, 61, 144)', 'rgb(153, 109, 61)', 'rgb(67, 153, 61)',
    'rgb(61, 121, 153)', 'rgb(132, 61, 153)', 'rgb(153, 78, 61)', 'rgb(98, 153, 61)',
    'rgb(61, 151, 153)', 'rgb(101, 61, 153)', 'rgb(153, 61, 75)'
]

def next_color_in_scheme(i):
    return color_scheme[i % len(color_scheme)]

