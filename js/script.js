$(function () {
	if ($('#demo')) {
		var curColor = 0;
		var colors = [];
		var title = '';

		$.getJSON(
			"http://www.colourlovers.com/api/palettes/random?format=json&jsonCallback=?",
			null,
			function(res) {
				colors = res[0].colors;
				title = res[0].title;
			}
	    );

		setInterval(
			function () {

				$('#screen_contents').css('background-color', '#' + colors[curColor]);
				$('#primary_text').html('#' + colors[curColor]);
				$('#secondary_text').html(title.toLowerCase());

				curColor++;
				if (curColor >= colors.length) {
					curColor = 0;
				}
			},
			3000
		);
	}

	$('#download').click(function() {
		_gaq.push(['_trackEvent', 'Downloads', 'Header Download']);
	});

	$('.download_button').click(function() {
		_gaq.push(['_trackEvent', 'Downloads', 'Button Download']);
	});

	$('.release_notes_download').click(function() {
		_gaq.push(['_trackEvent', 'Downloads', 'Release Notes Download']);
	});
});