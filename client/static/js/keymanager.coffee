class @KeyManager
  oses: ['Mac', 'Win']

  bindings:
    'default':
      'all':
        'tab':         'moveToNextClue'
        'shift+tab':   'moveToPreviousClue'

        # On Mac, home = fn+left and end = fn+right. I expect that Mac users
        # will probably ignore these bindings and instead use shift+arrow.
        'home':        'moveToStartOfCurrentClue'
        'end':         'moveToEndOfCurrentClue'

        'space':       'flipDir'
        'backspace':   ['erase', true, true]
        'delete':      ['erase', true, false]
      'Mac':
        'command+up':  'moveToFirstWhiteCell'
        'command+down':'moveToLastWhiteCell'

        'option+backspace': 'eraseToStartOfCurrentClue'
        'option+delete': 'eraseToEndOfCurrentClue'

        'shift+enter': 'enterRebus'
      'Win':
        'ctrl+home':   'moveToFirstWhiteCell'
        'ctrl+end':    'moveToLastWhiteCell'

        'ctrl+backspace': 'eraseToStartOfCurrentClue'
        'ctrl+delete': 'eraseToEndOfCurrentClue'

        'insert':      'enterRebus'

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
      @_key puzzleManager, k, 'moveInDirection', dir[k.toUpperCase()], false
      @_key puzzleManager, 'shift+' + k, 'moveToFarthestValidCellInDirection', dir[k.toUpperCase()], true

    for char in "abcdefghijklmnopqrstuvwxyz1234567890"
      @_key puzzleManager, char, 'setCurrentSquare', char.toUpperCase(), true

    return

  _key: (puzzleManager, k, puzzleManagerFunctionName, puzzleManagerFunctionArgs...) ->
    key k, (e) ->
      e.preventDefault()
      puzzleManager[puzzleManagerFunctionName] puzzleManagerFunctionArgs...
