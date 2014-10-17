function setup_chart() {
  var resizeTimer;
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

  $('#hoverContainer').css('border', '1px solid #afd8f8').show();
  $('#myChart').css('height', '400px').show();

  $(window).on('resize', function(){
    clearTimeout(resizeTimer);
    $('svg').css("width", "100%"); // Improves redraw
    resizeTimer = setTimeout(chart.redraw(), 250);
  });
};

$(function(){
  if ($('#myChart').length && $('#line-chart').data('data').length) {
    setup_chart();
  }
});
