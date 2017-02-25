
var value = $('#circle').circleProgress('value');
if (value >= 1.0){
  //$('#circle').circleProgress({ fill: "green" });
  noty({text: '100% of devices online',
  type: 'success',
  theme: 'metroui',
  closeWith   : ['click'],
  progressBar : true,
  timeout     : 10000,
  animation   : {
   open  : 'animated bounceInRight',
   close : 'animated bounceOutRight',
   easing: 'swing',
  }
  });
  
} else {
  noty({text: value * 100 + ' % of devices online',
   type: 'error',
   theme: 'metroui',
   closeWith   : ['click'],
   progressBar : true,
   timeout     : 15000,
   animation   : {
    open  : 'animated bounceInRight',
    close : 'animated bounceOutRight',
    easing: 'swing',
  }

  });
 }
 noty({
   text: "Report created " + "02/25/2017 14:06:38",
   type: 'information',
   theme: 'metroui',
   closeWith   : ['click'],
   progressBar : true,
   timeout     : 15000,
   animation   : {
     open  : 'animated bounceInRight',
     close : 'animated bounceOutRight',
     easing: 'swing',
   }
 });
