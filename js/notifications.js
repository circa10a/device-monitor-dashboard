var value = $('#circle').circleProgress('value');
if (value >= 1.0){
  //$('#circle').circleProgress({ fill: "green" });
  noty({text: '100% servers online', type: 'success'});
}
else {
  noty({text: value * 100 + ' % of servers online', type: 'error'});
}
