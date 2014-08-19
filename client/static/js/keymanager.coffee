class @KeyManager
  oses: ['Mac', 'Win']

  bindings:
    'default':
      'all':
        'tab':         'moveToNextClue'
        'shift+tab':   'moveToPreviousClue'
        'space':       'flipDir'
        'backspace':   ['backspace', true]
      'Mac':
        'shift+enter': 'enterRebus'
      'Win':
        'insert':      'enterRebus'

  registerBindings: (puzzleManager) ->
    # Haunted by syntactic theory
    relevantDefaultBindingDomains = ['all']
    for os in @oses
      # Javascript's new snake operator
      if ~window.navigator.appVersion.indexOf os
        relevantDefaultBindingDomains.push os

    for bd in relevantDefaultBindingDomains
      for seq, fNameAndArgs of @bindings.default[bd]
        if typeof fNameAndArgs is 'string'
          @_key puzzleManager, seq, fNameAndArgs
        else
          @_key puzzleManager, seq, fNameAndArgs...

    # Bindings for arrows and letters are established by imperial fiat
    for k in ['right', 'left', 'up', 'down']
      @_key puzzleManager, k, 'move', dir[k.toUpperCase()], false

    for char in "abcdefghijklmnopqrstuvwxyz1234567890"
      @_key puzzleManager, char, 'setCurrentSquare', char.toUpperCase(), true

    return

  _key: (puzzleManager, k, puzzleManagerFunctionName, puzzleManagerFunctionArgs...) ->
    key k, (e) ->
      e.preventDefault()
      puzzleManager[puzzleManagerFunctionName] puzzleManagerFunctionArgs...
