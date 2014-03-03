$(function(){

  function setup_chart() {
    new Morris.Line({
      element: 'myChart',
      ymax: 5,
      ymin: 1,
      smooth: false,
      data: $('#line-chart').data('data'),
      labels: $('#line-chart').data('labels'),
      xkey: 'timestamp',
      ykeys: $('#line-chart').data('keys'),
      xLabels: $('#line-chart').data('x-labels')
    });

  };

  $(function(){
    setup_chart();
  });

});
