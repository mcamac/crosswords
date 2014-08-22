class @KeyManager
  oses: ['Mac', 'Win']

  bindings:
    'default':
      'all':
        'tab':               'moveToNextClue'
        'shift+tab':         'moveToPreviousClue'

        # On Mac, home = fn+left and end = fn+right. I expect that Mac users
        # will probably ignore these bindings and instead use shift+arrow.
        'home':              'moveToStartOfCurrentClue'
        'end':               'moveToEndOfCurrentClue'

        'space':             'flipDir'
        'backspace':         'backspace'
        'delete':            'delete'
      'Mac':
        'command+up':        'moveToFirstWhiteCell'
        'command+down':      'moveToLastWhiteCell'

        'command+backspace': 'eraseToStartOfCurrentClue'
        'command+delete':    'eraseToEndOfCurrentClue'

        'option+backspace':  'eraseToStartOfCurrentLetterSequence'
        'option+delete':     'eraseToEndOfCurrentLetterSequence'

        'shift+enter':       'enterRebus'
      'Win':
        'ctrl+home':         'moveToFirstWhiteCell'
        'ctrl+end':          'moveToLastWhiteCell'

        'ctrl+backspace':    'eraseToStartOfCurrentClue'
        'ctrl+delete':       'eraseToEndOfCurrentClue'

        'insert':            'enterRebus'

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

    for k in ['right', 'left', 'up', 'down']
      direction = dir[k.toUpperCase()]
      @_key puzzleManager,              k, 'moveInDirection',                                  direction, false
      @_key puzzleManager,   'shift+' + k, 'moveToFarthestValidCellInDirection',               direction, true
      @_key puzzleManager,  'option+' + k, 'moveToBoundaryOfCurrentLetterSequenceInDirection', direction, true

    for char in "abcdefghijklmnopqrstuvwxyz1234567890"
      @_key puzzleManager, char, 'setCurrentSquare', char.toUpperCase(), true

    return

  _key: (puzzleManager, k, puzzleManagerFunctionName, puzzleManagerFunctionArgs...) ->
    key k, (e) ->
      e.preventDefault()
      puzzleManager[puzzleManagerFunctionName] puzzleManagerFunctionArgs...
