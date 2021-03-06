/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}


/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "/scripts/";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	__webpack_require__(1);
	__webpack_require__(2);
	__webpack_require__(7);
	__webpack_require__(9);
	__webpack_require__(3);
	__webpack_require__(4);
	__webpack_require__(5);
	module.exports = __webpack_require__(6);


/***/ },
/* 1 */
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global, module) {/*** IMPORTS FROM imports-loader ***/
	(function() {

	this.dir = {
	  RIGHT: [0, 1],
	  LEFT: [0, -1],
	  DOWN: [1, 0],
	  UP: [-1, 0],
	  ACROSS: [0, 1],
	  down: [1, 0],
	  across: [0, 1],
	  reflect: function(_arg) {
	    var c, r;
	    r = _arg[0], c = _arg[1];
	    return [-r, -c];
	  }
	};

	if (typeof global !== "undefined" && global !== null) {
	  global.dir = this.dir;
	}

	this.Puzzle = (function() {
	  function Puzzle(puzzle) {
	    var c, cellNumberCallback, clue, currentNumber, d, dClues, num, r, _ref;
	    this.title = puzzle.title;
	    this.grid = puzzle.puzzle;
	    this.height = puzzle.height;
	    this.width = puzzle.width;
	    this.clues = puzzle.clues;
	    this.json = puzzle;
	    this.notes = puzzle.notes;
	    this.circled = puzzle.circled;
	    this.clueNumbers = {};
	    _ref = this.clues;
	    for (d in _ref) {
	      dClues = _ref[d];
	      this.clueNumbers[d] = (function() {
	        var _results;
	        _results = [];
	        for (num in dClues) {
	          clue = dClues[num];
	          _results.push(parseInt(num));
	        }
	        return _results;
	      })();
	    }
	    this.gridNumbers = (function() {
	      var _i, _ref1, _results;
	      _results = [];
	      for (r = _i = 0, _ref1 = this.height; 0 <= _ref1 ? _i < _ref1 : _i > _ref1; r = 0 <= _ref1 ? ++_i : --_i) {
	        _results.push((function() {
	          var _j, _ref2, _results1;
	          _results1 = [];
	          for (c = _j = 0, _ref2 = this.width; 0 <= _ref2 ? _j < _ref2 : _j > _ref2; c = 0 <= _ref2 ? ++_j : --_j) {
	            _results1.push(null);
	          }
	          return _results1;
	        }).call(this));
	      }
	      return _results;
	    }).call(this);
	    this.gridNumbersRev = {};
	    currentNumber = 1;
	    this._loopGrid(function(_arg) {
	      var c, r;
	      r = _arg[0], c = _arg[1];
	      if (this.isWhite([r, c])) {
	        if (!(this.isValidSquare([r - 1, c]) && this.isValidSquare([r, c - 1]))) {
	          this.gridNumbersRev[currentNumber] = [r, c];
	          this.gridNumbers[r][c] = currentNumber++;
	        }
	      }
	    });
	    this.cellNumbers = (function() {
	      var _i, _ref1, _results;
	      _results = [];
	      for (r = _i = 0, _ref1 = this.height; 0 <= _ref1 ? _i < _ref1 : _i > _ref1; r = 0 <= _ref1 ? ++_i : --_i) {
	        _results.push((function() {
	          var _j, _ref2, _results1;
	          _results1 = [];
	          for (c = _j = 0, _ref2 = this.width; 0 <= _ref2 ? _j < _ref2 : _j > _ref2; c = 0 <= _ref2 ? ++_j : --_j) {
	            _results1.push({
	              across: null,
	              down: null
	            });
	          }
	          return _results1;
	        }).call(this));
	      }
	      return _results;
	    }).call(this);
	    cellNumberCallback = function(dirName, _arg) {
	      var coff, roff;
	      roff = _arg[0], coff = _arg[1];
	      currentNumber = null;
	      return function(_arg1) {
	        var c, r;
	        r = _arg1[0], c = _arg1[1];
	        if (!this.isValidSquare([r - roff, c - coff])) {
	          currentNumber = this.gridNumbers[r][c];
	        }
	        if (this.isWhite([r, c])) {
	          this.cellNumbers[r][c][dirName] = currentNumber;
	        }
	      };
	    };
	    this._loopGrid(cellNumberCallback('across', dir.ACROSS));
	    this._loopGrid(cellNumberCallback('down', dir.DOWN), false, true);
	    this.firstWhiteCell = this._loopGrid(this.isWhite, false);
	    this.lastWhiteCell = this._loopGrid(this.isWhite, true);
	  }

	  Puzzle.prototype.getNextClueNumber = function(clueNumber, direction, offset) {
	    var currentClueIndex, dirClueNumbers, dirKey, nextClueIndex;
	    dirKey = direction === dir.ACROSS ? 'across' : 'down';
	    dirClueNumbers = this.clueNumbers[dirKey];
	    currentClueIndex = dirClueNumbers.indexOf(clueNumber);
	    nextClueIndex = (currentClueIndex + offset + dirClueNumbers.length) % dirClueNumbers.length;
	    return dirClueNumbers[nextClueIndex];
	  };

	  Puzzle.prototype.isValidSquare = function(cell) {
	    return this.isInsideGrid(cell) && this.isWhite(cell);
	  };

	  Puzzle.prototype.isWhite = function(_arg) {
	    var c, r;
	    r = _arg[0], c = _arg[1];
	    return this.grid[r][c] !== '_';
	  };

	  Puzzle.prototype.isInsideGrid = function(_arg) {
	    var c, r;
	    r = _arg[0], c = _arg[1];
	    return (0 <= r && r < this.height) && (0 <= c && c < this.width);
	  };

	  Puzzle.prototype.getNextSquareInDirection = function(_arg, _arg1, remainOnThisClue) {
	    var c, coff, nc, nr, r, roff, _ref;
	    r = _arg[0], c = _arg[1];
	    roff = _arg1[0], coff = _arg1[1];
	    _ref = [r + roff, c + coff], nr = _ref[0], nc = _ref[1];
	    while (!this.isValidSquare([nr, nc])) {
	      if (!this.isInsideGrid([nr, nc]) || remainOnThisClue) {
	        return [r, c];
	      }
	      nr += roff;
	      nc += coff;
	    }
	    return [nr, nc];
	  };

	  Puzzle.prototype.getClueNumberForCell = function(_arg, direction) {
	    var c, dirKey, r;
	    r = _arg[0], c = _arg[1];
	    dirKey = direction === dir.ACROSS ? 'across' : 'down';
	    return this.cellNumbers[r][c][dirKey];
	  };

	  Puzzle.prototype.getFarthestValidCellInDirection = function(_arg, _arg1, skipFirstBlackCells, f) {
	    var allBlackSoFar, c, coff, nextCell, nextCellIsBlack, nextCellIsInvalid, pc, pr, r, roff, _ref;
	    r = _arg[0], c = _arg[1];
	    roff = _arg1[0], coff = _arg1[1];
	    allBlackSoFar = true;
	    while (true) {
	      if (f) {
	        try {
	          f([r, c]);
	        } catch (_error) {
	          return [pr, pc];
	        }
	      }
	      _ref = [r, c], pr = _ref[0], pc = _ref[1];
	      nextCell = [r += roff, c += coff];
	      nextCellIsInvalid = !this.isValidSquare(nextCell);
	      allBlackSoFar &= nextCellIsBlack = nextCellIsInvalid && this.isInsideGrid(nextCell);
	      if (nextCellIsInvalid && !(skipFirstBlackCells && allBlackSoFar)) {
	        break;
	      }
	    }
	    return [pr, pc];
	  };

	  Puzzle.prototype.getCursorRanges = function(_arg) {
	    var c, ec, er, r, sc, sr, _ref;
	    r = _arg[0], c = _arg[1];
	    _ref = [r, r, c, c], sr = _ref[0], er = _ref[1], sc = _ref[2], ec = _ref[3];
	    while (this.isValidSquare([sr - 1, c])) {
	      sr--;
	    }
	    while (this.isValidSquare([er + 1, c])) {
	      er++;
	    }
	    while (this.isValidSquare([r, sc - 1])) {
	      sc--;
	    }
	    while (this.isValidSquare([r, ec + 1])) {
	      ec++;
	    }
	    return [sr, er, sc, ec];
	  };

	  Puzzle.prototype._loopGrid = function(callback, reverse, transpose) {
	    var c, cell, cols, r, rows, _i, _j, _k, _l, _len, _len1, _ref, _ref1, _ref2, _results, _results1;
	    rows = (function() {
	      _results = [];
	      for (var _i = 0, _ref = this.height; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
	      return _results;
	    }).apply(this);
	    cols = (function() {
	      _results1 = [];
	      for (var _j = 0, _ref1 = this.width; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; 0 <= _ref1 ? _j++ : _j--){ _results1.push(_j); }
	      return _results1;
	    }).apply(this);
	    if (reverse) {
	      rows = rows.reverse();
	      cols = cols.reverse();
	    }
	    if (transpose) {
	      _ref2 = [cols, rows], rows = _ref2[0], cols = _ref2[1];
	    }
	    for (_k = 0, _len = rows.length; _k < _len; _k++) {
	      r = rows[_k];
	      for (_l = 0, _len1 = cols.length; _l < _len1; _l++) {
	        c = cols[_l];
	        cell = !transpose ? [r, c] : [c, r];
	        if (callback.bind(this)(cell)) {
	          return cell;
	        }
	      }
	    }
	  };

	  Puzzle.prototype.map = function(fn) {
	    var c, cols, r, ret, row, rows, _i, _j, _k, _l, _len, _len1, _ref, _ref1, _results, _results1;
	    rows = (function() {
	      _results = [];
	      for (var _i = 0, _ref = this.height; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
	      return _results;
	    }).apply(this);
	    cols = (function() {
	      _results1 = [];
	      for (var _j = 0, _ref1 = this.width; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; 0 <= _ref1 ? _j++ : _j--){ _results1.push(_j); }
	      return _results1;
	    }).apply(this);
	    ret = [];
	    for (_k = 0, _len = rows.length; _k < _len; _k++) {
	      r = rows[_k];
	      row = [];
	      for (_l = 0, _len1 = cols.length; _l < _len1; _l++) {
	        c = cols[_l];
	        row.push(fn([r, c]));
	      }
	      ret.push(row);
	    }
	    return ret;
	  };

	  return Puzzle;

	})();

	if (typeof module !== "undefined" && module !== null) {
	  module.exports = this.Puzzle;
	}
	}.call(window));
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }()), __webpack_require__(12)(module)))

/***/ },
/* 2 */
/***/ function(module, exports, __webpack_require__) {

	/*** IMPORTS FROM imports-loader ***/
	(function() {

	var Player;

	Player = (function() {
	  function Player(_at_id) {
	    this.id = _at_id;
	    this.name = Math.random().toString(36).substr(2, 5);
	  }

	  return Player;

	})();

	if (typeof exports !== "undefined" && exports !== null) {
	  exports.Player = Player;
	}
	}.call(window));

/***/ },
/* 3 */
/***/ function(module, exports, __webpack_require__) {

	/*** IMPORTS FROM imports-loader ***/
	(function() {

	var __slice = [].slice;

	this.KeyManager = (function() {
	  KeyManager.prototype.oses = ['Mac', 'Win'];

	  KeyManager.prototype.bindings = {
	    'default': {
	      'all': {
	        'alphanum': ['setCurrentSquare', true],
	        'arrow': ['moveInDirection', false],
	        'tab': 'moveToNextClue',
	        'shift+tab': 'moveToPreviousClue',
	        'space': 'flipDir',
	        'backspace': 'backspace',
	        'delete': 'delete',
	        'shift+/': 'help'
	      },
	      'Mac': {
	        'home': 'moveToFirstWhiteCell',
	        'end': 'moveToLastWhiteCell',
	        'command+arrow': ['moveToFarthestValidCellInDirection', true],
	        'command+backspace': 'eraseToStartOfCurrentClue',
	        'command+delete': 'eraseToEndOfCurrentClue',
	        'option+arrow': ['moveToBoundaryOfCurrentLetterSequenceInDirection', true],
	        'option+backspace': 'eraseToStartOfCurrentLetterSequence',
	        'option+delete': 'eraseToEndOfCurrentLetterSequence',
	        'shift+enter': 'enterRebus'
	      },
	      'Win': {
	        'ctrl+home': 'moveToFirstWhiteCell',
	        'ctrl+end': 'moveToLastWhiteCell',
	        'home': 'moveToStartOfCurrentClue',
	        'end': 'moveToEndOfCurrentClue',
	        'ctrl+arrow': ['moveToBoundaryOfCurrentLetterSequenceInDirection', true],
	        'ctrl+backspace': 'eraseToStartOfCurrentLetterSequence',
	        'ctrl+delete': 'eraseToEndOfCurrentLetterSequence',
	        'insert': 'enterRebus'
	      }
	    }
	  };

	  KeyManager.prototype.aliases = {
	    'alphanum': {
	      'substitutes': 'abcdefghijklmnopqrstuvwxyz1234567890'.split(''),
	      'prependArgs': function(letter) {
	        return [letter.toUpperCase()];
	      }
	    },
	    'arrow': {
	      'substitutes': ['right', 'left', 'up', 'down'],
	      'prependArgs': function(direction) {
	        return [dir[direction.toUpperCase()]];
	      }
	    }
	  };

	  function KeyManager(puzzleManager) {
	    this.setRelevantBindings();
	    puzzleManager.renderKeyBindings(this.relevantBindings);
	    this.expandAliases();
	    this.registerBindings(puzzleManager);
	  }

	  KeyManager.prototype.setRelevantBindings = function() {
	    var bd, fNameAndArgs, os, seq, _i, _j, _len, _len1, _ref, _ref1, _results;
	    this.relevantDefaultBindingDomains = ['all'];
	    _ref = this.oses;
	    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
	      os = _ref[_i];
	      if (~window.navigator.appVersion.indexOf(os)) {
	        this.relevantDefaultBindingDomains.push(os);
	      }
	    }
	    this.relevantBindings = {};
	    _ref1 = this.relevantDefaultBindingDomains;
	    _results = [];
	    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
	      bd = _ref1[_j];
	      _results.push((function() {
	        var _ref2, _results1;
	        _ref2 = this.bindings["default"][bd];
	        _results1 = [];
	        for (seq in _ref2) {
	          fNameAndArgs = _ref2[seq];
	          if (typeof fNameAndArgs === 'string') {
	            fNameAndArgs = [fNameAndArgs];
	          }
	          _results1.push(this.relevantBindings[seq] = fNameAndArgs);
	        }
	        return _results1;
	      }).call(this));
	    }
	    return _results;
	  };

	  KeyManager.prototype.expandAliases = function() {
	    var alias, aliasPattern, fArgs, fName, fNameAndArgs, matches, prependArgs, seq, substitute, substitutedSeq, substitutes, _i, _len, _ref, _ref1, _results;
	    aliasPattern = new RegExp('\\b(?:' + Object.keys(this.aliases).join('|') + ')\\b');
	    _ref = this.relevantBindings;
	    _results = [];
	    for (seq in _ref) {
	      fNameAndArgs = _ref[seq];
	      matches = aliasPattern.exec(seq);
	      if (matches != null) {
	        fName = fNameAndArgs[0], fArgs = 2 <= fNameAndArgs.length ? __slice.call(fNameAndArgs, 1) : [];
	        _ref1 = this.aliases[alias = matches[0]], substitutes = _ref1.substitutes, prependArgs = _ref1.prependArgs;
	        for (_i = 0, _len = substitutes.length; _i < _len; _i++) {
	          substitute = substitutes[_i];
	          substitutedSeq = seq.replace(aliasPattern, substitute);
	          this.relevantBindings[substitutedSeq] = [fName].concat(__slice.call(prependArgs(substitute)), __slice.call(fArgs));
	        }
	        _results.push(delete this.relevantBindings[seq]);
	      } else {
	        _results.push(void 0);
	      }
	    }
	    return _results;
	  };

	  KeyManager.prototype.registerBindings = function(puzzleManager) {
	    var fNameAndArgs, seq, _ref;
	    _ref = this.relevantBindings;
	    for (seq in _ref) {
	      fNameAndArgs = _ref[seq];
	      this._key.apply(this, [puzzleManager, seq].concat(__slice.call(fNameAndArgs)));
	    }
	  };

	  KeyManager.prototype._key = function() {
	    var k, puzzleManager, puzzleManagerFunctionArgs, puzzleManagerFunctionName;
	    puzzleManager = arguments[0], k = arguments[1], puzzleManagerFunctionName = arguments[2], puzzleManagerFunctionArgs = 4 <= arguments.length ? __slice.call(arguments, 3) : [];
	    return key(k, function(e) {
	      e.preventDefault();
	      return puzzleManager[puzzleManagerFunctionName].apply(puzzleManager, puzzleManagerFunctionArgs);
	    });
	  };

	  return KeyManager;

	})();

	module.exports = KeyManager;
	}.call(window));

/***/ },
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	/*** IMPORTS FROM imports-loader ***/
	(function() {

	var KeyManager, Puzzle, Render, isd,
	  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

	isd = function(a, b) {
	  return (a[0] === b[0]) && (a[1] === b[1]);
	};

	KeyManager = __webpack_require__(3);

	Render = __webpack_require__(6);

	Puzzle = __webpack_require__(1);

	this.PuzzleManager = (function() {
	  var Action, it;

	  function PuzzleManager(options, _at_ui) {
	    var defaultSquareSize, defaultWidth;
	    this.ui = _at_ui;
	    this.existingPuzzle = __bind(this.existingPuzzle, this);
	    this.el = options.elements.gridEl;
	    this.$el = $(this.el);
	    this.socket = options.socket;
	    if (options.title) {
	      this.title = options.title;
	    }
	    this.p = {};
	    if (options.puzzle) {
	      this.p = options.puzzle;
	    }
	    this.keyManager = new KeyManager(this);
	    this.g = {};
	    this.c = {};
	    this.user = {
	      color: 'rgb(232, 157, 52)'
	    };
	    defaultSquareSize = 36;
	    defaultWidth = defaultSquareSize * 15;
	    this.g.grid = {
	      lines: [],
	      squareSize: defaultSquareSize,
	      height: defaultWidth,
	      width: defaultWidth,
	      margin: 2
	    };
	    this.g.highlights = {
	      across: null,
	      down: null,
	      user: {}
	    };
	    Render.setDims('crossword')(this.g.grid.width + this.g.grid.margin, this.g.grid.height + this.g.grid.margin);
	    this.g.overlay = null;
	    this.setUpEvents();
	  }

	  PuzzleManager.prototype.setUpEvents = function() {
	    this.socket.on('square set', (function(_this) {
	      return function(_arg) {
	        var i, id, j, val, _ref;
	        id = _arg[0], (_ref = _arg[1], i = _ref[0], j = _ref[1]), val = _arg[2];
	        return _this._setUserSquare((_this.ui.users.filter(function(user) {
	          return user.id === id;
	        }))[0], [i, j], val, true);
	      };
	    })(this));
	    return this.socket.on('users', (function(_this) {
	      return function(users) {
	        var self;
	        _this.ui.users = users;
	        self = (users.filter(function(user) {
	          return user.id === _this.ui.id;
	        }))[0];
	        return _this.user.color = self.color;
	      };
	    })(this));
	  };

	  PuzzleManager.prototype.existingPuzzle = function(room) {
	    this.loadPuzzle(new Puzzle(room.puzzle));
	    this.eachSquare((function(_this) {
	      return function(_arg) {
	        var c, r;
	        r = _arg[0], c = _arg[1];
	        if (room.grid[r][c]) {
	          return _this._setUserSquare((_this.ui.users.filter(function(user) {
	            return user.id === room.gridOwners[r][c];
	          }))[0], [r, c], room.grid[r][c], true);
	        }
	      };
	    })(this));
	    if (room.isDone) {
	      return this.markDone();
	    }
	  };

	  PuzzleManager.prototype.eachSquare = function(fn) {
	    var c, r, _i, _ref, _results;
	    _results = [];
	    for (r = _i = 0, _ref = this.p.height; 0 <= _ref ? _i < _ref : _i > _ref; r = 0 <= _ref ? ++_i : --_i) {
	      _results.push((function() {
	        var _j, _ref1, _results1;
	        _results1 = [];
	        for (c = _j = 0, _ref1 = this.p.width; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; c = 0 <= _ref1 ? ++_j : --_j) {
	          _results1.push(fn([r, c]));
	        }
	        return _results1;
	      }).call(this));
	    }
	    return _results;
	  };

	  PuzzleManager.prototype.markDone = function() {
	    return $('#background').fadeTo(500, 0.3);
	  };

	  PuzzleManager.prototype.render = function() {
	    var acrossClues, addBlackSquare, addCircle, addCursor, addFilledSquare, addGridline, addLetter, addNumber, c, clue, downClues, num, offset, pxoff, r, rad, _i, _j, _k, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
	    if (this.p.width >= 20 || this.p.height >= 20) {
	      this.g.grid.squareSize = 27;
	    } else {
	      this.g.grid.squareSize = 36;
	    }
	    this.g.grid.width = this.p.width * this.g.grid.squareSize;
	    this.g.grid.height = this.p.height * this.g.grid.squareSize;
	    Render.setDims('crossword')(this.g.grid.width + this.g.grid.margin, this.g.grid.height + this.g.grid.margin);
	    this.g.numbers = {};
	    this.g.blackSquares = {};
	    this.g.filledSquares = {};
	    this.g.letters = {};
	    this.g.circles = [];
	    addNumber = Render.text('numbers');
	    addBlackSquare = Render.rect('black-squares');
	    addFilledSquare = Render.rect('filled-squares');
	    addLetter = Render.text('letters');
	    addCircle = Render.circle('circles');
	    for (r = _i = 0, _ref = this.p.height; 0 <= _ref ? _i < _ref : _i > _ref; r = 0 <= _ref ? ++_i : --_i) {
	      this.g.numbers[r] = {};
	      this.g.blackSquares[r] = {};
	      this.g.filledSquares[r] = {};
	      this.g.letters[r] = {};
	      for (c = _j = 0, _ref1 = this.p.width; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; c = 0 <= _ref1 ? ++_j : --_j) {
	        if (this.p.gridNumbers[r][c]) {
	          this.g.numbers[r][c] = addNumber(this.g.grid.squareSize * c + 3, this.g.grid.squareSize * r + 8.5, this.p.gridNumbers[r][c]);
	        }
	        if (this.p.grid[r][c] === '_') {
	          this.g.blackSquares[r][c] = addBlackSquare(this.g.grid.squareSize * c + 1, this.g.grid.squareSize * r + 1, this.g.grid.squareSize - 1, this.g.grid.squareSize - 1);
	        }
	        this.g.filledSquares[r][c] = addFilledSquare(this.g.grid.squareSize * c + 1, this.g.grid.squareSize * r + 1, this.g.grid.squareSize - 1, this.g.grid.squareSize - 1);
	        this.g.letters[r][c] = addLetter((c + 0.5) * this.g.grid.squareSize, (r + 0.55) * this.g.grid.squareSize, '');
	        if ((_ref2 = this.p.circled) != null ? (_ref3 = _ref2[r]) != null ? _ref3[c] : void 0 : void 0) {
	          console.log(r, c, ((_ref4 = this.p.circled) != null ? (_ref5 = _ref4[r]) != null ? _ref5[c] : void 0 : void 0) != null);
	          rad = this.g.grid.squareSize / 2;
	          this.g.circles.push(addCircle(2 * rad * c + rad + 0.5, 2 * rad * r + rad + 0.5, rad - 1));
	        }
	      }
	    }
	    addGridline = Render.path('gridlines');
	    for (offset = _k = 0, _ref6 = this.p.height; 0 <= _ref6 ? _k <= _ref6 : _k >= _ref6; offset = 0 <= _ref6 ? ++_k : --_k) {
	      pxoff = this.g.grid.squareSize * offset + 0.5;
	      this.g.grid.lines.push(addGridline("M" + pxoff + ",0.5v" + this.g.grid.height), addGridline("M0.5," + pxoff + "h" + this.g.grid.width));
	    }
	    this.g.overlay = Render.rect('background')(0, 0, this.g.grid.width, this.g.grid.height);
	    this.g.overlay.addEventListener('click', (function(_this) {
	      return function(e) {
	        var ei, ej;
	        ei = ~~(e.layerY / _this.g.grid.squareSize);
	        ej = ~~(e.layerX / _this.g.grid.squareSize);
	        if (ei === _this.g.ci && ej === _this.g.cj) {
	          _this.flipDir();
	        }
	        return _this._setHighlight('user', [ei, ej]);
	      };
	    })(this));
	    this.g.ci = 0;
	    this.g.cj = 0;
	    this.g.dir = dir.ACROSS;
	    $('.puzzle-title').html(this.p.title);
	    acrossClues = (function() {
	      var _ref7, _results;
	      _ref7 = this.p.clues.across;
	      _results = [];
	      for (num in _ref7) {
	        clue = _ref7[num];
	        _results.push({
	          num: parseInt(num),
	          text: clue,
	          dir: 'across'
	        });
	      }
	      return _results;
	    }).call(this);
	    downClues = (function() {
	      var _ref7, _results;
	      _ref7 = this.p.clues.down;
	      _results = [];
	      for (num in _ref7) {
	        clue = _ref7[num];
	        _results.push({
	          num: parseInt(num),
	          text: clue,
	          dir: 'down'
	        });
	      }
	      return _results;
	    }).call(this);
	    this.ui.clues.across = acrossClues;
	    this.ui.clues.down = downClues;
	    this.ui.cluesObj = this.p.clues;
	    addCursor = Render.rect('cursor');
	    this.g.highlights.user['user'] = addCursor(3, 3, this.g.grid.squareSize - 5, this.g.grid.squareSize - 5, {
	      'id': 'highlight-square',
	      'stroke-width': 4
	    });
	    this.g.highlights.down = addCursor(0, 0, 0, 0, {
	      'id': 'highlight-down',
	      'stroke-width': 4
	    });
	    this.g.highlights.across = addCursor(0, 0, 0, 0, {
	      'id': 'highlight-across',
	      'stroke-width': 4
	    });
	    console.log('rendered');
	    return this.moveToFirstWhiteCell();
	  };

	  PuzzleManager.prototype.renderKeyBindings = function(bindings) {
	    var categories, category, categoryOrder, el, f, fName, html, kbd, seq, seqAndF, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
	    html = '';
	    categories = {};
	    categoryOrder = ['basic', 'cell', 'misc', 'clue', 'word', 'puzzle'];
	    for (_i = 0, _len = categoryOrder.length; _i < _len; _i++) {
	      category = categoryOrder[_i];
	      categories[category] = [];
	    }
	    for (seq in bindings) {
	      _ref = bindings[seq], fName = _ref[0];
	      f = this[fName];
	      seqAndF = [seq, f];
	      categories[f.category].push(seqAndF);
	      if (f.basic) {
	        categories['basic'].push(seqAndF);
	      }
	    }
	    for (_j = 0, _len1 = categoryOrder.length; _j < _len1; _j++) {
	      category = categoryOrder[_j];
	      html += '<h5>' + category + '</h5><table>';
	      html += '<tr><th class="c1">Shortcut</th><th class="c3">Description</th></tr>';
	      _ref1 = categories[category];
	      for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
	        _ref2 = _ref1[_k], seq = _ref2[0], f = _ref2[1];
	        kbd = '<kbd>' + seq + '</kbd>';
	        html += '<tr><td class="c1">' + kbd + '</td><td class="c3">' + f.desc + '</td></tr>';
	      }
	      html += '</table>';
	    }
	    el = document.getElementById('key-bindings');
	    return el.innerHTML = html;
	  };

	  PuzzleManager.prototype.resetGrid = function() {
	    var c, circle, line, r, _i, _j, _k, _l, _len, _len1, _ref, _ref1, _ref10, _ref11, _ref12, _ref13, _ref14, _ref15, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
	    $('#background').fadeTo(100, 0);
	    for (r = _i = 0, _ref = this.p.height; 0 <= _ref ? _i < _ref : _i > _ref; r = 0 <= _ref ? ++_i : --_i) {
	      for (c = _j = 0, _ref1 = this.p.width; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; c = 0 <= _ref1 ? ++_j : --_j) {
	        if ((_ref2 = this.g.numbers) != null) {
	          if ((_ref3 = _ref2[r]) != null) {
	            if ((_ref4 = _ref3[c]) != null) {
	              _ref4.remove();
	            }
	          }
	        }
	        if ((_ref5 = this.g.letters) != null) {
	          if ((_ref6 = _ref5[r]) != null) {
	            if ((_ref7 = _ref6[c]) != null) {
	              _ref7.remove();
	            }
	          }
	        }
	        if ((_ref8 = this.g.blackSquares) != null) {
	          if ((_ref9 = _ref8[r]) != null) {
	            if ((_ref10 = _ref9[c]) != null) {
	              _ref10.remove();
	            }
	          }
	        }
	        if (this.g.filledSquares) {
	          this._setSquareColor(null, [r, c]);
	        }
	      }
	    }
	    if ((_ref11 = this.g.highlights.user['user']) != null) {
	      _ref11.remove();
	    }
	    if ((_ref12 = this.g.highlights.across) != null) {
	      _ref12.remove();
	    }
	    if ((_ref13 = this.g.highlights.down) != null) {
	      _ref13.remove();
	    }
	    if (this.g.circles) {
	      _ref14 = this.g.circles;
	      for (_k = 0, _len = _ref14.length; _k < _len; _k++) {
	        circle = _ref14[_k];
	        circle.remove();
	      }
	    }
	    _ref15 = this.g.grid.lines;
	    for (_l = 0, _len1 = _ref15.length; _l < _len1; _l++) {
	      line = _ref15[_l];
	      line.remove();
	    }
	    return this.g.grid.lines = [];
	  };

	  PuzzleManager.prototype.loadPuzzle = function(p) {
	    this.resetGrid();
	    this.p = p;
	    return this.render();
	  };

	  PuzzleManager.prototype.getSquare = function(_arg) {
	    var c, r;
	    r = _arg[0], c = _arg[1];
	    return this.g.letters[r][c].firstChild.textContent;
	  };

	  PuzzleManager.prototype.setSquare = function(cell, value, moveForwards) {
	    this._setUserSquare(this.user, cell, value);
	    this.socket.emit('set square', [cell, value]);
	    if (moveForwards) {
	      return this.moveForwards(true);
	    }
	  };

	  PuzzleManager.prototype._setUserSquare = function(user, _arg, value, server) {
	    var c, color, oldValue, r;
	    r = _arg[0], c = _arg[1];
	    oldValue = this.getSquare([r, c]);
	    this.g.letters[r][c].firstChild.textContent = value;
	    color = value && ((user != null ? user.color : void 0) != null) ? user.color : 'none';
	    if (oldValue !== value || server) {
	      return this._setSquareColor(color, [r, c]);
	    }
	  };

	  PuzzleManager.prototype._setSquareColor = function(color, _arg) {
	    var c, r, _ref, _ref1;
	    r = _arg[0], c = _arg[1];
	    return (_ref = this.g.filledSquares[r]) != null ? (_ref1 = _ref[c]) != null ? _ref1.setAttribute('fill', color) : void 0 : void 0;
	  };

	  PuzzleManager.prototype.currentCell = function() {
	    return [this.g.ci, this.g.cj];
	  };

	  PuzzleManager.prototype.currentClue = function(direction) {
	    if (direction == null) {
	      direction = this.g.dir;
	    }
	    return this.p.getClueNumberForCell(this.currentCell(), direction);
	  };

	  PuzzleManager.prototype.currentClueObj = function() {
	    return {
	      direction: isd(this.g.dir, dir.DOWN) ? 'down' : 'across',
	      clueNumber: {
	        down: this.currentClue(dir.DOWN),
	        across: this.currentClue(dir.ACROSS)
	      }
	    };
	  };

	  it = function() {
	    return (function(func, args, ctor) {
	      ctor.prototype = func.prototype;
	      var child = new ctor, result = func.apply(child, args);
	      return Object(result) === result ? result : child;
	    })(Action, arguments, function(){});
	  };

	  Action = (function() {
	    function Action(desc, category, basic, f) {
	      f.desc = desc;
	      f.category = category;
	      f.basic = basic;
	      return f;
	    }

	    return Action;

	  })();

	  PuzzleManager.prototype.help = it('shows this list of keyboard shortcuts', 'misc', false, function() {
	    return $('#key-bindings-dialog').foundation('reveal', 'open');
	  });

	  PuzzleManager.prototype.setCurrentSquare = it('writes the given letter in the current cell', 'cell', true, function(value, moveForwards) {
	    return this.setSquare(this.currentCell(), value, moveForwards);
	  });

	  PuzzleManager.prototype.flipDir = it('switches direction', 'misc', true, function() {
	    this.g.dir = isd(this.g.dir, dir.ACROSS) ? dir.DOWN : dir.ACROSS;
	    return this._reHighlight();
	  });

	  PuzzleManager.prototype.moveToCell = function(cell, d) {
	    return this._setHighlight('user', cell);
	  };

	  PuzzleManager.prototype.moveInDirection = it('moves in the given direction', 'cell', true, function(direction, remainOnThisClue) {
	    return this.moveToCell(this.p.getNextSquareInDirection(this.currentCell(), direction, remainOnThisClue));
	  });

	  PuzzleManager.prototype.moveToFarthestValidCellInDirection = it('moves to the boundary of the current clue in the given direction', 'clue', false, function(direction, skipFirstBlackCells) {
	    return this.moveToCell(this.p.getFarthestValidCellInDirection(this.currentCell(), direction, skipFirstBlackCells));
	  });

	  PuzzleManager.prototype.moveToClue = function(clueNumber, d) {
	    this.g.dir = d ? d : this.g.dir;
	    return this.moveToCell(this.p.gridNumbersRev[clueNumber]);
	  };

	  PuzzleManager.prototype.moveForwards = function(remainOnThisClue) {
	    return this.moveInDirection(this.g.dir, remainOnThisClue);
	  };

	  PuzzleManager.prototype.moveBackwards = function(remainOnThisClue) {
	    return this.moveInDirection(dir.reflect(this.g.dir), remainOnThisClue);
	  };

	  PuzzleManager.prototype.moveToNextClue = it('moves to the start of the next clue', 'clue', true, function() {
	    return this.moveToClue(this.p.getNextClueNumber(this.currentClue(), this.g.dir, 1));
	  });

	  PuzzleManager.prototype.moveToPreviousClue = it('moves to the start of the previous clue', 'clue', false, function() {
	    return this.moveToClue(this.p.getNextClueNumber(this.currentClue(), this.g.dir, -1));
	  });

	  PuzzleManager.prototype.moveToStartOfCurrentClue = it('moves to the start of the current clue', 'clue', false, function() {
	    return this.moveToFarthestValidCellInDirection(dir.reflect(this.g.dir), false);
	  });

	  PuzzleManager.prototype.moveToEndOfCurrentClue = it('moves to the end of the current clue', 'clue', false, function() {
	    return this.moveToFarthestValidCellInDirection(this.g.dir, false);
	  });

	  PuzzleManager.prototype.moveToFirstWhiteCell = it('moves to the first white cell', 'puzzle', false, function() {
	    return this.moveToCell(this.p.firstWhiteCell);
	  });

	  PuzzleManager.prototype.moveToLastWhiteCell = it('moves to the last white cell', 'puzzle', false, function() {
	    return this.moveToCell(this.p.lastWhiteCell);
	  });

	  PuzzleManager.prototype.enterRebus = it('allows writing multiple letters in a single cell', 'misc', false, function() {
	    return console.error(arguments.callee.name + " not implemented");
	  });

	  PuzzleManager.prototype.erase = function(remainOnThisClue, moveBackwards) {
	    this.setCurrentSquare('', false);
	    if (moveBackwards) {
	      return this.moveBackwards(remainOnThisClue);
	    }
	  };

	  PuzzleManager.prototype.backspace = it('erases the current cell, then moves backwards', 'cell', true, function() {
	    return this.erase(true, true);
	  });

	  PuzzleManager.prototype["delete"] = it('erases the current cell, without moving backwards', 'cell', false, function() {
	    return this.erase(true, false);
	  });

	  PuzzleManager.prototype.eraseToStartOfCurrentClue = it('erases to the start of the current clue; or, if the current cell is blank and at the start of a clue, erases to the start of the previous clue', 'clue', false, function() {
	    var skipFirstBlackCells;
	    skipFirstBlackCells = '' === this.getSquare(this.currentCell());
	    return this.moveToCell(this.p.getFarthestValidCellInDirection(this.currentCell(), dir.reflect(this.g.dir), skipFirstBlackCells, (function(_this) {
	      return function(cell) {
	        return _this.setSquare(cell, '', false);
	      };
	    })(this)));
	  });

	  PuzzleManager.prototype.eraseToEndOfCurrentClue = it('erases to the end of the current clue, without moving', 'clue', false, function() {
	    return this.p.getFarthestValidCellInDirection(this.currentCell(), this.g.dir, false, (function(_this) {
	      return function(cell) {
	        return _this.setSquare(cell, '', false);
	      };
	    })(this));
	  });

	  PuzzleManager.prototype._skipAllEmptySoFar = function(erase) {
	    var allEmptySoFar, first;
	    allEmptySoFar = first = true;
	    return (function(_this) {
	      return function(cell) {
	        var currentIsEmpty;
	        if (!first || erase) {
	          allEmptySoFar &= currentIsEmpty = '' === _this.getSquare(cell);
	        } else {
	          first = false;
	        }
	        if (currentIsEmpty && !allEmptySoFar) {
	          throw true;
	        }
	        if (erase) {
	          return _this.setSquare(cell, '', false);
	        }
	      };
	    })(this);
	  };

	  PuzzleManager.prototype.moveToBoundaryOfCurrentLetterSequenceInDirection = it('moves to the end of the sequence of letters in the given direction', 'word', false, function(direction, skipFirstBlackCells) {
	    return this.moveToCell(this.p.getFarthestValidCellInDirection(this.currentCell(), direction, skipFirstBlackCells, this._skipAllEmptySoFar(false)));
	  });

	  PuzzleManager.prototype.eraseToStartOfCurrentLetterSequence = it('erases to the start of the current sequence of letters; or, if the current cell is blank, erases to the start of the previous sequence of letters', 'word', false, function() {
	    var skipFirstBlackCells;
	    skipFirstBlackCells = '' === this.getSquare(this.currentCell());
	    return this.moveToCell(this.p.getFarthestValidCellInDirection(this.currentCell(), dir.reflect(this.g.dir), skipFirstBlackCells, this._skipAllEmptySoFar(true)));
	  });

	  PuzzleManager.prototype.eraseToEndOfCurrentLetterSequence = it('erases to the end of the current sequence of letters, without moving', 'word', false, function() {
	    return this.p.getFarthestValidCellInDirection(this.currentCell(), this.g.dir, false, this._skipAllEmptySoFar(true));
	  });

	  PuzzleManager.prototype._setHighlight = function(id, _arg) {
	    var c, r, _ref;
	    r = _arg[0], c = _arg[1];
	    if (!this.p.isValidSquare([r, c])) {
	      return;
	    }
	    Render._setAttributes(this.g.highlights.user[id], {
	      x: this.g.grid.squareSize * c + 3,
	      y: this.g.grid.squareSize * r + 3
	    });
	    if (id === 'user') {
	      _ref = [r, c], this.g.ci = _ref[0], this.g.cj = _ref[1];
	    }
	    return this._reHighlight();
	  };

	  PuzzleManager.prototype._highlightClass = function(direction) {
	    if (isd(this.g.dir, direction)) {
	      return 'highlight-parallel';
	    } else {
	      return 'highlight-perpendicular';
	    }
	  };

	  PuzzleManager.prototype._reHighlight = function() {
	    var ec, er, sc, sr, _ref;
	    this.ui.currentClue = this.currentClueObj();
	    _ref = this.p.getCursorRanges(this.currentCell()), sr = _ref[0], er = _ref[1], sc = _ref[2], ec = _ref[3];
	    Render._setAttributes(this.g.highlights.down, {
	      x: this.g.grid.squareSize * this.g.cj + 3,
	      y: this.g.grid.squareSize * sr + 3,
	      width: this.g.grid.squareSize - 5,
	      height: this.g.grid.squareSize * (er - sr + 1) - 5
	    });
	    this.g.highlights.down.className.baseVal = this._highlightClass(dir.DOWN);
	    Render._setAttributes(this.g.highlights.across, {
	      x: this.g.grid.squareSize * sc + 3,
	      y: this.g.grid.squareSize * this.g.ci + 3,
	      width: this.g.grid.squareSize * (ec - sc + 1) - 5,
	      height: this.g.grid.squareSize - 5
	    });
	    return this.g.highlights.across.className.baseVal = this._highlightClass(dir.ACROSS);
	  };

	  return PuzzleManager;

	})();

	module.exports = PuzzleManager;
	}.call(window));

/***/ },
/* 5 */
/***/ function(module, exports, __webpack_require__) {

	/*** IMPORTS FROM imports-loader ***/
	(function() {

	var PuzzleManager;

	PuzzleManager = __webpack_require__(4);

	$(function() {
	  var CROSSWORD_CANVAS_EL, ChatBox, ClueList, MembersBox, SOCKET_URL, clueSymbols, puzzleManager, roomName, setTimer, socket, startDate, timer, uiState;
	  SOCKET_URL = location.origin.replace(/^http/, 'ws');
	  CROSSWORD_CANVAS_EL = '#crossword-container';
	  socket = io.connect(SOCKET_URL);
	  startDate = new Date();
	  setTimer = function() {
	    var minutes, seconds;
	    seconds = Math.floor((new Date() - startDate) / 1000);
	    minutes = Math.floor(seconds / 60);
	    seconds = seconds % 60;
	    if (seconds < 10) {
	      seconds = '0' + seconds;
	    }
	    return $('#timer').html(minutes + ":" + seconds);
	  };
	  timer = void 0;
	  MembersBox = Vue.extend({
	    template: '#members-box',
	    data: {
	      users: []
	    }
	  });
	  Vue.component('members-box', MembersBox);
	  ChatBox = new Vue({
	    el: '#chat_box',
	    data: {
	      messages: [],
	      text: ""
	    },
	    methods: {
	      onEnter: function() {
	        socket.emit('chat message', this.text);
	        return this.text = '';
	      }
	    }
	  });
	  ClueList = Vue.extend({
	    template: '#clue-li',
	    data: {
	      dir: 'across',
	      clues: {
	        across: [],
	        down: []
	      }
	    },
	    ready: function() {
	      return this.$watch('current', function(current) {
	        var activeCluePosition, clueNumber, listOffset;
	        clueNumber = current.clueNumber[this.str];
	        listOffset = $(this.$el).scrollTop();
	        activeCluePosition = $(this.$el).find("li[value=" + clueNumber + "]").position().top;
	        return $(this.$el).stop().animate({
	          scrollTop: activeCluePosition + listOffset
	        }, 50);
	      });
	    },
	    methods: {
	      onClick: function(str, num) {
	        return puzzleManager.moveToClue(num, dir[str]);
	      }
	    }
	  });
	  clueSymbols = {
	    down: '▼',
	    across: '▶'
	  };
	  Vue.filter('dir-symbol', function(dir) {
	    return clueSymbols[dir];
	  });
	  Vue.component('clue-list', ClueList);
	  uiState = new Vue({
	    el: '#content',
	    data: {
	      clues: {
	        across: [],
	        down: []
	      },
	      cluesObj: {},
	      currentClue: {},
	      users: [],
	      id: ''
	    },
	    computed: {
	      currentClueDirection: function() {
	        return this.currentClue.direction;
	      },
	      currentClueNumber: function() {
	        var _ref;
	        return (_ref = this.currentClue.clueNumber) != null ? _ref[this.currentClueDirection] : void 0;
	      },
	      currentClueText: function() {
	        var _ref, _ref1;
	        return (_ref = this.cluesObj) != null ? (_ref1 = _ref[this.currentClueDirection]) != null ? _ref1[this.currentClueNumber] : void 0 : void 0;
	      }
	    }
	  });
	  console.log('UI components initialized');
	  roomName = window.location.pathname.substr(1 + window.location.pathname.lastIndexOf('/'));
	  console.log('roomName', roomName);
	  socket.on('user id', function(id) {
	    uiState.id = id;
	    return socket.emit('join room', {
	      roomName: roomName,
	      userId: 'foo'
	    });
	  });
	  socket.on('chat message', function(message) {
	    message.isServer = message.user === '__server';
	    ChatBox.messages.push(message);
	    return setTimeout((function() {
	      return $('#chat').scrollTop($('#chat')[0].scrollHeight);
	    }), 20);
	  });
	  puzzleManager = new PuzzleManager({
	    elements: {
	      gridEl: CROSSWORD_CANVAS_EL
	    },
	    puzzle: {},
	    socket: socket
	  }, uiState);
	  socket.on('existing puzzle', (function(_this) {
	    return function(room) {
	      console.log('existing', room);
	      startDate = new Date(room.startTime);
	      setTimer;
	      if (room.isDone) {
	        clearInterval(timer);
	      } else {
	        timer = setInterval(setTimer, 500);
	      }
	      return puzzleManager.existingPuzzle(room);
	    };
	  })(this));
	  socket.on('done', (function(_this) {
	    return function(room) {
	      console.log('done', room);
	      puzzleManager.markDone();
	      return clearInterval(timer);
	    };
	  })(this));
	  key('shift+o', function(e) {
	    return $('#browse_puzzles_a').trigger('click');
	  });
	  $.getJSON('/api/puzzles', function(data) {
	    var puzzle, _i, _len, _results;
	    _results = [];
	    for (_i = 0, _len = data.length; _i < _len; _i++) {
	      puzzle = data[_i];
	      _results.push($('#browse_puzzles_modal ul').append("<li>\n  " + puzzle.title + " -\n  <a class='load-puzzle-a'\n     data-puzzle-id='" + puzzle._id + "' href='#'>\n    Load\n  </a>\n</li>"));
	    }
	    return _results;
	  });
	  $('#random_a').on('click', function(e) {
	    return $.getJSON("/api/puzzles/random", (function(_this) {
	      return function(puzzle) {
	        return socket.emit('new puzzle', {
	          id: puzzle._id
	        });
	      };
	    })(this));
	  });
	  $('.random-day').on('click', function(e) {
	    var day;
	    day = $(this).html().trim();
	    return $.getJSON("/api/puzzles/random/" + day, (function(_this) {
	      return function(puzzle) {
	        return socket.emit('new puzzle', {
	          id: puzzle._id
	        });
	      };
	    })(this));
	  });
	  $('#browse_puzzles_modal').on('click', '.load-puzzle-a', function(e) {
	    return $.getJSON("/api/puzzles/" + ($(this).data('puzzle-id')), (function(_this) {
	      return function(puzzle) {
	        return socket.emit('new puzzle', {
	          id: $(_this).data('puzzle-id')
	        });
	      };
	    })(this));
	  });
	  return $(document).foundation();
	});
	}.call(window));

/***/ },
/* 6 */
/***/ function(module, exports, __webpack_require__) {

	/*** IMPORTS FROM imports-loader ***/
	(function() {

	this.Render = (function() {
	  var f, k, svgNS, _Render;

	  function Render() {}

	  svgNS = "http://www.w3.org/2000/svg";

	  Render._setAttributes = function(el, attrs) {
	    var k, v;
	    for (k in attrs) {
	      v = attrs[k];
	      el.setAttribute(k, v);
	    }
	  };

	  _Render = {
	    setDims: function(parent, width, height) {
	      parent.setAttribute("width", width);
	      parent.setAttribute("height", height);
	    },
	    rect: function(parent, x, y, width, height, attrs) {
	      var el;
	      el = document.createElementNS(svgNS, "rect");
	      el.setAttribute("x", x);
	      el.setAttribute("y", y);
	      el.setAttribute("width", width);
	      el.setAttribute("height", height);
	      this._setAttributes(el, attrs);
	      return parent.appendChild(el);
	    },
	    path: function(parent, d) {
	      var el;
	      el = document.createElementNS(svgNS, "path");
	      el.setAttribute("d", d);
	      return parent.appendChild(el);
	    },
	    circle: function(parent, cx, cy, r) {
	      var el;
	      el = document.createElementNS(svgNS, "circle");
	      el.setAttribute('cx', cx);
	      el.setAttribute('cy', cy);
	      el.setAttribute('r', r);
	      return parent.appendChild(el);
	    },
	    text: function(parent, x, y, s, attrs) {
	      var el;
	      el = document.createElementNS(svgNS, "text");
	      el.setAttribute("x", x);
	      el.setAttribute("y", y);
	      el.appendChild(document.createTextNode(s));
	      this._setAttributes(el, attrs);
	      return parent.appendChild(el);
	    }
	  };

	  for (k in _Render) {
	    f = _Render[k];
	    Render[k] = (function(f) {
	      return function(id) {
	        return f.bind(this, document.getElementById(id));
	      };
	    })(f);
	  }

	  return Render;

	})();

	module.exports = Render;
	}.call(window));

/***/ },
/* 7 */
/***/ function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag

	// load the styles
	var content = __webpack_require__(8);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(11)(content, {});
	if(content.placeholders) module.exports = content.placeholders;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.placeholders) {
			module.hot.accept("!!./../../../node_modules/css-loader/index.js!./../../../node_modules/sass-loader/index.js?indentedSyntax!./room.sass", function() {
				var newContent = require("!!./../../../node_modules/css-loader/index.js!./../../../node_modules/sass-loader/index.js?indentedSyntax!./room.sass");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ },
/* 8 */
/***/ function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(13)();
	exports.push([module.id, "@font-face{src:url('/static/fonts/SourceSansPro-ExtraLight.ttf');font-family:'Source Sans';font-weight:200;}@font-face{src:url('/static/fonts/SourceSansPro-ExtraLightItalic.ttf');font-family:'Source Sans';font-weight:200;font-style:italic;}@font-face{src:url('/static/fonts/SourceSansPro-Light.ttf');font-family:'Source Sans';font-weight:300;}@font-face{src:url('/static/fonts/SourceSansPro-LightItalic.ttf');font-family:'Source Sans';font-weight:300;font-style:italic;}@font-face{src:url('/static/fonts/SourceSansPro-Regular.ttf');font-family:'Source Sans';font-weight:400;}@font-face{src:url('/static/fonts/SourceSansPro-Italic.ttf');font-family:'Source Sans';font-weight:400;font-style:italic;}@font-face{src:url('/static/fonts/SourceSansPro-Semibold.ttf');font-family:'Source Sans';font-weight:600;}@font-face{src:url('/static/fonts/SourceSansPro-SemiboldItalic.ttf');font-family:'Source Sans';font-weight:600;font-style:italic;}@font-face{src:url('/static/fonts/SourceSansPro-Bold.ttf');font-family:'Source Sans';font-weight:700;}@font-face{src:url('/static/fonts/SourceSansPro-BoldItalic.ttf');font-family:'Source Sans';font-weight:700;font-style:italic;}@font-face{src:url('/static/fonts/SourceSansPro-Black.ttf');font-family:'Source Sans';font-weight:900;}@font-face{src:url('/static/fonts/SourceSansPro-BlackItalic.ttf');font-family:'Source Sans';font-weight:900;font-style:italic;}body,h1,h2,h3,h4,h5,h6{font-family:\"Source Sans\", sans-serif}.game-area{margin-top:-20px;max-width:1240px}.clue-list{font-size:13px;height:250px;overflow-y:scroll;margin-left:0;padding-left:0.5em;position:relative;list-style:none}.clue-list li{padding:0 5px}.clue-list li:hover{background-color:#F0F0F0}.clue-list .active{background-color:rgba(61,104,184,0.55)}.clue-list .inactive{background-color:rgba(61,104,184,0.15)}.clue-list .clue-num{display:inline-block;margin-right:5px;font-style:bold;text-align:right;width:15px}#current-clue .dir-number{font-weight:700;display:inline-block;width:3.5em;padding-right:0em}#current-clue .text{font-size:0.9em}#players{height:65px}#players ul{list-style:none;margin:0;padding:0}#players ul li{display:inline-block}#players ul li:not(:last-of-type){margin-right:0.5em}#players ul li .member{border-bottom:3px solid transparent}#chat{background-color:#FAFAFA;height:360px;overflow-y:scroll;padding:10px}#chat p{font-size:0.9em;margin:0;word-wrap:break-word}#chat p .username{margin-right:3px}#crossword-container{margin:0px 10px 0}.timer{text-align:right}.timer .deciseconds{color:#aaa}svg{shape-rendering:geometricPrecision}ul.puzzle-list{height:400px;overflow:scroll}#key-bindings table{table-layout:fixed;border-radius:4px}#key-bindings table th{text-align:left}#key-bindings table .c1{width:11em}#key-bindings table .c3{width:37em}", ""]);

/***/ },
/* 9 */
/***/ function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag

	// load the styles
	var content = __webpack_require__(10);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(11)(content, {});
	if(content.placeholders) module.exports = content.placeholders;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.placeholders) {
			module.hot.accept("!!./../../../node_modules/css-loader/index.js!./../../../node_modules/sass-loader/index.js?indentedSyntax!./svg.sass", function() {
				var newContent = require("!!./../../../node_modules/css-loader/index.js!./../../../node_modules/sass-loader/index.js?indentedSyntax!./svg.sass");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ },
/* 10 */
/***/ function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(13)();
	exports.push([module.id, "#background{stroke:none;fill:#62cb62;opacity:0}#background.green{opacity:0.2}#black-squares{fill:#333}#gridlines{stroke:#ddd;stroke-width:1px;stroke-linecap:square}#circles{stroke:#ccc;fill:none}#numbers text,#letters text{dominant-baseline:central;font-family:'Source Sans'}#numbers{font-size:11px;font-weight:300;color:#666;text-anchor:start}#letters{font-size:24px;font-weight:600;text-anchor:middle}#highlight-square,#highlight-across,#highlight-down{fill:none}#highlight-square{stroke:#3d68b8}.highlight-parallel{stroke:rgba(61,104,184,0.55)}.highlight-perpendicular{stroke:rgba(61,104,184,0.15)}#their-cursors{fill:none;opacity:0.7}#filled-squares{stroke:none;fill:none;opacity:0.4}", ""]);

/***/ },
/* 11 */
/***/ function(module, exports, __webpack_require__) {

	/*
		MIT License http://www.opensource.org/licenses/mit-license.php
		Author Tobias Koppers @sokra
	*/
	var stylesInDom = {},
		memoize = function(fn) {
			var memo;
			return function () {
				if (typeof memo === "undefined") memo = fn.apply(this, arguments);
				return memo;
			};
		},
		isOldIE = memoize(function() {
			return /msie [6-9]\b/.test(window.navigator.userAgent.toLowerCase());
		}),
		getHeadElement = memoize(function () {
			return document.head || document.getElementsByTagName("head")[0];
		}),
		singletonElement = null,
		singletonCounter = 0;

	module.exports = function(list, options) {
		if(false) {
			if(typeof document !== "object") throw new Error("The style-loader cannot be used in a non-browser environment");
		}

		options = options || {};
		// Force single-tag solution on IE6-9, which has a hard limit on the # of <style>
		// tags it will allow on a page
		if (typeof options.singleton === "undefined") options.singleton = isOldIE();

		var styles = listToStyles(list);
		addStylesToDom(styles, options);

		return function update(newList) {
			var mayRemove = [];
			for(var i = 0; i < styles.length; i++) {
				var item = styles[i];
				var domStyle = stylesInDom[item.id];
				domStyle.refs--;
				mayRemove.push(domStyle);
			}
			if(newList) {
				var newStyles = listToStyles(newList);
				addStylesToDom(newStyles, options);
			}
			for(var i = 0; i < mayRemove.length; i++) {
				var domStyle = mayRemove[i];
				if(domStyle.refs === 0) {
					for(var j = 0; j < domStyle.parts.length; j++)
						domStyle.parts[j]();
					delete stylesInDom[domStyle.id];
				}
			}
		};
	}

	function addStylesToDom(styles, options) {
		for(var i = 0; i < styles.length; i++) {
			var item = styles[i];
			var domStyle = stylesInDom[item.id];
			if(domStyle) {
				domStyle.refs++;
				for(var j = 0; j < domStyle.parts.length; j++) {
					domStyle.parts[j](item.parts[j]);
				}
				for(; j < item.parts.length; j++) {
					domStyle.parts.push(addStyle(item.parts[j], options));
				}
			} else {
				var parts = [];
				for(var j = 0; j < item.parts.length; j++) {
					parts.push(addStyle(item.parts[j], options));
				}
				stylesInDom[item.id] = {id: item.id, refs: 1, parts: parts};
			}
		}
	}

	function listToStyles(list) {
		var styles = [];
		var newStyles = {};
		for(var i = 0; i < list.length; i++) {
			var item = list[i];
			var id = item[0];
			var css = item[1];
			var media = item[2];
			var sourceMap = item[3];
			var part = {css: css, media: media, sourceMap: sourceMap};
			if(!newStyles[id])
				styles.push(newStyles[id] = {id: id, parts: [part]});
			else
				newStyles[id].parts.push(part);
		}
		return styles;
	}

	function createStyleElement() {
		var styleElement = document.createElement("style");
		var head = getHeadElement();
		styleElement.type = "text/css";
		head.appendChild(styleElement);
		return styleElement;
	}

	function createLinkElement() {
		var linkElement = document.createElement("link");
		var head = getHeadElement();
		linkElement.rel = "stylesheet";
		head.appendChild(linkElement);
		return linkElement;
	}

	function addStyle(obj, options) {
		var styleElement, update, remove;

		if (options.singleton) {
			var styleIndex = singletonCounter++;
			styleElement = singletonElement || (singletonElement = createStyleElement());
			update = applyToSingletonTag.bind(null, styleElement, styleIndex, false);
			remove = applyToSingletonTag.bind(null, styleElement, styleIndex, true);
		} else if(obj.sourceMap &&
			typeof URL === "function" &&
			typeof URL.createObjectURL === "function" &&
			typeof URL.revokeObjectURL === "function" &&
			typeof Blob === "function" &&
			typeof btoa === "function") {
			styleElement = createLinkElement();
			update = updateLink.bind(null, styleElement);
			remove = function() {
				styleElement.parentNode.removeChild(styleElement);
				if(styleElement.href)
					URL.revokeObjectURL(styleElement.href);
			};
		} else {
			styleElement = createStyleElement();
			update = applyToTag.bind(null, styleElement);
			remove = function() {
				styleElement.parentNode.removeChild(styleElement);
			};
		}

		update(obj);

		return function updateStyle(newObj) {
			if(newObj) {
				if(newObj.css === obj.css && newObj.media === obj.media && newObj.sourceMap === obj.sourceMap)
					return;
				update(obj = newObj);
			} else {
				remove();
			}
		};
	}

	var replaceText = (function () {
		var textStore = [];

		return function (index, replacement) {
			textStore[index] = replacement;
			return textStore.filter(Boolean).join('\n');
		};
	})();

	function applyToSingletonTag(styleElement, index, remove, obj) {
		var css = remove ? "" : obj.css;

		if (styleElement.styleSheet) {
			styleElement.styleSheet.cssText = replaceText(index, css);
		} else {
			var cssNode = document.createTextNode(css);
			var childNodes = styleElement.childNodes;
			if (childNodes[index]) styleElement.removeChild(childNodes[index]);
			if (childNodes.length) {
				styleElement.insertBefore(cssNode, childNodes[index]);
			} else {
				styleElement.appendChild(cssNode);
			}
		}
	}

	function applyToTag(styleElement, obj) {
		var css = obj.css;
		var media = obj.media;
		var sourceMap = obj.sourceMap;

		if(media) {
			styleElement.setAttribute("media", media)
		}

		if(styleElement.styleSheet) {
			styleElement.styleSheet.cssText = css;
		} else {
			while(styleElement.firstChild) {
				styleElement.removeChild(styleElement.firstChild);
			}
			styleElement.appendChild(document.createTextNode(css));
		}
	}

	function updateLink(linkElement, obj) {
		var css = obj.css;
		var media = obj.media;
		var sourceMap = obj.sourceMap;

		if(sourceMap) {
			css += "\n/*# sourceMappingURL=data:application/json;base64," + btoa(JSON.stringify(sourceMap)) + " */";
		}

		var blob = new Blob([css], { type: "text/css" });

		var oldSrc = linkElement.href;

		linkElement.href = URL.createObjectURL(blob);

		if(oldSrc)
			URL.revokeObjectURL(oldSrc);
	}


/***/ },
/* 12 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = function(module) {
		if(!module.webpackPolyfill) {
			module.deprecate = function() {};
			module.paths = [];
			// module.parent = undefined by default
			module.children = [];
			module.webpackPolyfill = 1;
		}
		return module;
	}


/***/ },
/* 13 */
/***/ function(module, exports, __webpack_require__) {

	/*
		MIT License http://www.opensource.org/licenses/mit-license.php
		Author Tobias Koppers @sokra
	*/
	// css base code, injected by the css-loader
	module.exports = function() {
		var list = [];

		// return the list of modules as css string
		list.toString = function toString() {
			var result = [];
			for(var i = 0; i < this.length; i++) {
				var item = this[i];
				if(item[2]) {
					result.push("@media " + item[2] + "{" + item[1] + "}");
				} else {
					result.push(item[1]);
				}
			}
			return result.join("");
		};

		// import a list of modules into the list
		list.i = function(modules, mediaQuery) {
			if(typeof modules === "string")
				modules = [[null, modules, ""]];
			var alreadyImportedModules = {};
			for(var i = 0; i < this.length; i++) {
				var id = this[i][0];
				if(typeof id === "number")
					alreadyImportedModules[id] = true;
			}
			for(i = 0; i < modules.length; i++) {
				var item = modules[i];
				// skip already imported module
				// this implementation is not 100% perfect for weird media query combinations
				//  when a module is imported multiple times with different media queries.
				//  I hope this will never occur (Hey this way we have smaller bundles)
				if(typeof item[0] !== "number" || !alreadyImportedModules[item[0]]) {
					if(mediaQuery && !item[2]) {
						item[2] = mediaQuery;
					} else if(mediaQuery) {
						item[2] = "(" + item[2] + ") and (" + mediaQuery + ")";
					}
					list.push(item);
				}
			}
		};
		return list;
	};


/***/ }
/******/ ]);