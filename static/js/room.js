var ws = new WebSocket('ws://' + location.hostname + ':' + location.port + location.pathname + '/sub');

ws.onmessage = function(msg) {
	// console.log(msg);
	var data = JSON.parse(msg.data);
	console.log(data);

	if(data.type == 'client chat message') {
		console.log(data.name + ': ' + data.content);
		$('#chat_box').append('<p>'+
			'<b>' + data.name + '</b>' + ': ' + data.content+
			'</p>');

		var $el = $('#chat_box');
		var el = $el[0]; /* Actual DOM element */

		/* Scroll to bottom */
		el.scrollTop = el.scrollHeight - $el.height();
	}
	if(data.type == 'room chat message') {
		console.log(data.name + ': ' + data.content);
		$('#chat_box').append('<p>'+
			'<i>'+ data.content+ '</i>' +
			'</p>');


	}
}


Zepto(function($){

	var grid_lines = [];
	var size = 540;

	var paper = Raphael("crossword_canvas", size + 2, size + 2);
	paper.rect(0, 0, size, size);

	$('#chat_input').on('keyup', function(e) {
		if (e.keyCode == 13) {
			ws.send(JSON.stringify({
				type: 'client chat message',
				content: $(this).val(),
			}));
			$(this).val('');
		}
	});
})