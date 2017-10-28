var value = $('#circle').circleProgress('value');
if (value >= 1.0){
  //$('#circle').circleProgress({ fill: "green" });
  new Noty({text: '100% of devices online',
  type: 'success',
  theme: 'mint',
  closeWith   : ['click'],
  progressBar : true,
  timeout     : 10000,
  animation   : {
   open  : 'animated bounceInRight',
   close : 'animated bounceOutRight',
   easing: 'swing',
  }
  }).show();

} else {
  new Noty({text: value * 100 + ' % of devices online',
   type: 'error',
   theme: 'mint',
   closeWith   : ['click'],
   progressBar : true,
   timeout     : 10000,
   animation   : {
    open  : 'animated bounceInRight',
    close : 'animated bounceOutRight',
    easing: 'swing',
  }
  }).show();
 }
