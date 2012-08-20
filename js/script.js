$(function () {
	var curColor = 0;
	var colors = [];

	$.getJSON(
		"http://www.colourlovers.com/api/palettes/random?format=json&jsonCallback=?",
		null,
		function(res) {
			colors = res[0].colors;
		}
    );

	setInterval(
		function () {

			$('#screen_contents').css('background-color', '#' + colors[curColor]);
			$('#screen_contents span').html('#' + colors[curColor]);

			curColor++;
			if (curColor > colors.length) {
				curColor = 0;
			}
		},
		3000
	);

});