$(function() {

  $('#notices p').each(function(index,e){
    $e = $(e);
    $e.hide();
    var notyTypeMappings = {
      'notice': 'information',
      'alert': 'error'
      }

    if($e.text() > '') {
      noty({
        layout: 'bottom',
        text: $e.text(),
        timeout: 1750,
        type: notyTypeMappings[$e.prop('class')] || 'information'
      });
    }
  });

});
