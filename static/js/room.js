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
	}
	if(data.type == 'room chat message') {
		console.log(data.name + ': ' + data.content);
		$('#chat_box').append('<p>'+
			'<i>'+ data.content+ '</i>' +
			'</p>');
	}
}

var paper = Raphael("crossword_canvas", 542, 542);
paper.rect(0, 0, 540, 540);


Zepto(function($){
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