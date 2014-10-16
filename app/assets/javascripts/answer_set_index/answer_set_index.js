function setup_chart() {
  var chart = new Morris.Line({
    element: 'myChart',
    ymax: 5,
    ymin: 1,
    smooth: false,
    data: $('#line-chart').data('data'),
    labels: $('#line-chart').data('labels'),
    xkey: 'timestamp',
    ykeys: $('#line-chart').data('keys'),
    xLabels: $('#line-chart').data('x-labels'),
    moveHover: false,
    hoverContainer: $('#hoverContainer'),
    compactLegend: true
  });

  if ($('#myChart').length) {
    $(window).on('resize', function(){
      $('svg').css("width", "100%"); // Improves redraw
      chart.redraw();
    });
  }
};

$(function(){
  setup_chart();
});
