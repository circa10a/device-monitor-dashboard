var value = $('#circle').circleProgress('value');

if (value >= 1.0){
  var color = '#0AB0DE';
  $('#circle').circleProgress({
      fill: { color: [color]}
  });
  $('strong').css({"color":color});

} else {

  var color = '#FF3750'
	$('#circle').circleProgress({
	    fill: { color: [color]}
	 });
  $('strong').css({"color":color});
 }
