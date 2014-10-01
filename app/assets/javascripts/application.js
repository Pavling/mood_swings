// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require_tree ./global

$(function() {
  $(".knob").knob({
    'draw': function(val) {
      this.o['fgColor'] = colourForKnobVal(this.v);
    }
  });

  function colourForKnobVal(val) {
    return {
      1: '#f00',
      2: '#f63',
      3: '#ff0',
      4: '#9f3',
      5: '#0f0'
    }[val] || '#000';
  }

  $( ".datepicker" ).datepicker( {"dateFormat": 'yy-mm-dd'} );

  $('#nav-icon').on('click', function(){
    $('#menu').slideToggle()
  });

});



//= require turbolinks
