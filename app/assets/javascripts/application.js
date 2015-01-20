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
// 
//= VENDOR
//= require jquery-ui-1.10.4.custom
//= require jquery.knob
//= require jquery.noty.packaged
//= require morris
//= require noty-config
//= require raphael-min
// 
//= require_tree ./answer_set_index
//= require_self

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
    $('#menu').slideToggle();
  });

  $('.not-applicable-answer :checkbox').click(function() {
    makeNotApplicable = $(this).is(':checked');
    $parent = $(this).parent().parent();
    inputs = $parent.find(':input:not(:checkbox)');
    inputs.prop('disabled', makeNotApplicable);

    if (makeNotApplicable) {
      $('<div>', {
                  class: 'overlay',
                  css: {
                      position: 'absolute',
                      width: $parent.outerWidth(),
                      height: $parent.outerHeight() - 25,
                      top: $parent.position().top,
                      left: $parent.position().left,
                      backgroundColor: '#f7f7f7',
                      zIndex: 10
                  }
      }).appendTo( $parent );
    } else {
      $parent.find('.overlay').remove();
    }
  });


  $("#student_search").autocomplete({ 
    source: function (request, response) {
      $.get("/cohorts/"+ $("#student_search").data('cohortId') + "/autocomplete_users", {
        q: request.term
      }, function (data) {
        response(data);
      });
    },
    select: function( event, ui ) {
      event.preventDefault();

      var checkbox = '<li><input checked="checked" id="student_ids" name="cohort[student_ids][]" type="checkbox" value="' + ui.item.id + '" /><label>' + ui.item.value + '</label></li>';

      $('#cohort_students').prepend(checkbox);
      $("#student_search").val('');
    }
  });

  $("#administrator_search").autocomplete({ 
    source: function (request, response) {
      $.get("/cohorts/"+ $("#administrator_search").data('cohortId') + "/autocomplete_administrators", {
        q: request.term
      }, function (data) {
        response(data);
      });
    },
    select: function( event, ui ) {
      event.preventDefault();

      var checkbox = '<li><input checked="checked" id="administrator_ids" name="cohort[administrator_ids][]" type="checkbox" value="' + ui.item.id + '" /><label>' + ui.item.value + '</label></li>';

      $('#cohort_administrators').prepend(checkbox);
      $("#administrator_search").val('');
    }
  });

});



//= require turbolinks