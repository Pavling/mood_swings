
function setup_chart() {
  new Morris.Line({
    element: 'myChart',
    ymax: 5,
    ymin: 1,
    smooth: false,
    data: $('#line-chart').data('data'),
    xkey: 'timestamp',
    ykeys: $('#line-chart').data('keys')
  });

};

$(function(){
  setup_chart();
});
