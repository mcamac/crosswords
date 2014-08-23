class @KeyManager
  oses: ['Mac', 'Win']

  bindings:
    'default':
      'all':
        'tab':               'moveToNextClue'
        'shift+tab':         'moveToPreviousClue'

        'space':             'flipDir'
        'backspace':         'backspace'
        'delete':            'delete'
      'Mac':
        'home':              'moveToFirstWhiteCell'
        'end':               'moveToLastWhiteCell'

        # moveToStartOfCurrentClue
        # moveToEndOfCurrentClue
        'command+backspace': 'eraseToStartOfCurrentClue'
        'command+delete':    'eraseToEndOfCurrentClue'

        'option+backspace':  'eraseToStartOfCurrentLetterSequence'
        'option+delete':     'eraseToEndOfCurrentLetterSequence'

        'shift+enter':       'enterRebus'
      'Win':
        'ctrl+home':         'moveToFirstWhiteCell'
        'ctrl+end':          'moveToLastWhiteCell'

        'home':              'moveToStartOfCurrentClue'
        'end':               'moveToEndOfCurrentClue'
        # eraseToStartOfCurrentClue
        # eraseToEndOfCurrentClue

        'ctrl+backspace':    'eraseToStartOfCurrentLetterSequence'
        'ctrl+delete':       'eraseToEndOfCurrentLetterSequence'

        'insert':            'enterRebus'

  aliases:
    'alphanum':
      'substitutes': 'abcdefghijklmnopqrstuvwxyz1234567890'.split ''
      'prependArgs': (letter) -> [letter.toUpperCase()]
    'arrow':
      'substitutes': ['right', 'left', 'up', 'down']
      'prependArgs': (direction) -> [dir[direction.toUpperCase()]]

  registerBindings: (puzzleManager) ->
    relevantDefaultBindingDomains = ['all']
    for os in @oses
      if ~window.navigator.appVersion.indexOf os
        relevantDefaultBindingDomains.push os

    for bd in relevantDefaultBindingDomains
      for seq, fNameAndArgs of @bindings.default[bd]
        if typeof fNameAndArgs is 'string'
          @_key puzzleManager, seq, fNameAndArgs
        else
          @_key puzzleManager, seq, fNameAndArgs...

    # TODO per OS
    for k in ['right', 'left', 'up', 'down']
      direction = dir[k.toUpperCase()]
      @_key puzzleManager,              k, 'moveInDirection',                                  direction, false
      @_key puzzleManager, 'command+' + k, 'moveToFarthestValidCellInDirection',               direction, true
      @_key puzzleManager,  'option+' + k, 'moveToBoundaryOfCurrentLetterSequenceInDirection', direction, true

    for char in "abcdefghijklmnopqrstuvwxyz1234567890"
      @_key puzzleManager, char, 'setCurrentSquare', char.toUpperCase(), true

    return

  _key: (puzzleManager, k, puzzleManagerFunctionName, puzzleManagerFunctionArgs...) ->
    key k, (e) ->
      e.preventDefault()
      puzzleManager[puzzleManagerFunctionName] puzzleManagerFunctionArgs...
