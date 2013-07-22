class @KeyManager
  oses: ['Mac', 'Win']

  bindings:
    'default':
      'all':
        'tab':         'moveToNextClue'
        'shift+tab':   'moveToPreviousClue'
        'space':       'flipDir'
        'backspace':   'backspace'
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
      for seq, fn of @bindings.default[bd]
        do (seq, fn) =>
          key seq, (e) ->
            e.preventDefault()
            puzzleManager[fn]()

    # Bindings for arrows and letters are established by imperial fiat
    for k in ['right', 'left', 'up', 'down']
      do (k) ->
        key k, (e) ->
          e.preventDefault()
          puzzleManager.move dir[k.toUpperCase()]

    for char in "abcdefghijklmnopqrstuvwxyz1234567890"
      do (char) ->
        key char, (e) ->
          puzzleManager.setCurrentSquare char.toUpperCase(), true

    return
