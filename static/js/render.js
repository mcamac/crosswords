var Render = (function () {
	var svgNS = 'http://www.w3.org/2000/svg';
	var _Render = {
		setDims: function(width, height) {
			this.setAttribute('width', width);
			this.setAttribute('height', height);
		},
		rect: function(x, y, width, height, attrs) {
			var el = document.createElementNS(svgNS, 'rect');
			el.setAttribute('x', x);
			el.setAttribute('y', y);
			el.setAttribute('width', width);
			el.setAttribute('height', height);
			for (var k in attrs)
				el.setAttribute(k, attrs[k]);
			this.appendChild(el);
			return el;
		},
		path: function(d) {
			var el = document.createElementNS(svgNS, 'path');
			el.setAttribute('d', d);
			el.setAttribute('fill', 'blue');
			this.appendChild(el);
		},
		text: function(x, y, s, attrs) {
			var el = document.createElementNS(svgNS, 'text');
			el.setAttribute('x', x);
			el.setAttribute('y', y);
			el.appendChild(document.createTextNode(s));
			for (var k in attrs)
				el.setAttribute(k, attrs[k]);
			this.appendChild(el);
			return el;
		},

	};

	var Render = {};
	for (var f in _Render) {
		(function(f) {
			Render[f] = function(id) {
				var el = document.getElementById(id);
				return _Render[f].bind(el);
			};
		})(f);
	}

	return Render;
})();
