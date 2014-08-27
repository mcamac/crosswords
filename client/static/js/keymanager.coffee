class @KeyManager
  oses: ['Mac', 'Win']

  bindings:
    'default':
      'all':
        'alphanum':          ['setCurrentSquare', true]

        'arrow':             ['moveInDirection', false]

        'tab':               'moveToNextClue'
        'shift+tab':         'moveToPreviousClue'

        'space':             'flipDir'
        'backspace':         'backspace'
        'delete':            'delete'

        'shift+/':           'help'
      'Mac':
        'home':              'moveToFirstWhiteCell'
        'end':               'moveToLastWhiteCell'

        'command+arrow':     ['moveToFarthestValidCellInDirection', true]
        # moveToStartOfCurrentClue
        # moveToEndOfCurrentClue
        'command+backspace': 'eraseToStartOfCurrentClue'
        'command+delete':    'eraseToEndOfCurrentClue'

        'option+arrow':      ['moveToBoundaryOfCurrentLetterSequenceInDirection', true]
        'option+backspace':  'eraseToStartOfCurrentLetterSequence'
        'option+delete':     'eraseToEndOfCurrentLetterSequence'

        'shift+enter':       'enterRebus'
      'Win':
        'ctrl+home':         'moveToFirstWhiteCell'
        'ctrl+end':          'moveToLastWhiteCell'

        # moveToFarthestValidCellInDirection
        'home':              'moveToStartOfCurrentClue'
        'end':               'moveToEndOfCurrentClue'
        # eraseToStartOfCurrentClue
        # eraseToEndOfCurrentClue

        'ctrl+arrow':        ['moveToBoundaryOfCurrentLetterSequenceInDirection', true]
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

  constructor: (puzzleManager) ->
    @setRelevantBindings()
    puzzleManager.renderKeyBindings @relevantBindings
    @expandAliases()
    @registerBindings puzzleManager

  setRelevantBindings: ->
    @relevantDefaultBindingDomains = ['all']
    for os in @oses
      if ~window.navigator.appVersion.indexOf os
        @relevantDefaultBindingDomains.push os

    @relevantBindings = {}
    for bd in @relevantDefaultBindingDomains
      for seq, fNameAndArgs of @bindings.default[bd]
        if typeof fNameAndArgs is 'string'
          fNameAndArgs = [fNameAndArgs]
        @relevantBindings[seq] = fNameAndArgs

  expandAliases: ->
    aliasPattern = new RegExp '\\b(?:' + Object.keys(@aliases).join('|') + ')\\b'

    for seq, fNameAndArgs of @relevantBindings
      matches = aliasPattern.exec seq

      if matches?
        [fName, fArgs...] = fNameAndArgs

        {substitutes, prependArgs} = @aliases[alias = matches[0]]

        for substitute in substitutes
          substitutedSeq = seq.replace aliasPattern, substitute
          @relevantBindings[substitutedSeq] = [fName, (prependArgs substitute)..., fArgs...]

        delete @relevantBindings[seq]

  registerBindings: (puzzleManager) ->
    for seq, fNameAndArgs of @relevantBindings
      @_key puzzleManager, seq, fNameAndArgs...

    return

  _key: (puzzleManager, k, puzzleManagerFunctionName, puzzleManagerFunctionArgs...) ->
    key k, (e) ->
      e.preventDefault()
      puzzleManager[puzzleManagerFunctionName] puzzleManagerFunctionArgs...
