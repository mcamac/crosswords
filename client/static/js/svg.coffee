class @Render
	svgNS = "http://www.w3.org/2000/svg"

	@_setAttributes: (el, attrs) ->
		for k, v of attrs
			el.setAttribute k, v
		return

	_Render =
		setDims: (parent, width, height) ->
			parent.setAttribute "width", width
			parent.setAttribute "height", height
			return

		rect: (parent, x, y, width, height, attrs) ->
			el = document.createElementNS(svgNS, "rect")
			el.setAttribute "x", x
			el.setAttribute "y", y
			el.setAttribute "width", width
			el.setAttribute "height", height
			@_setAttributes el, attrs
			parent.appendChild el

		path: (parent, d) ->
			el = document.createElementNS(svgNS, "path")
			el.setAttribute "d", d
			parent.appendChild el

		text: (parent, x, y, s, attrs) ->
			el = document.createElementNS(svgNS, "text")
			el.setAttribute "x", x
			el.setAttribute "y", y
			el.appendChild document.createTextNode(s)
			@_setAttributes el, attrs
			parent.appendChild el

	for k, f of _Render
		@[k] = do (f) => (id) -> f.bind @, document.getElementById id
