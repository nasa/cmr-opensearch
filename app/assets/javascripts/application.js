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
//= require jquery_ujs
//= require jquery-1.7.2.min
//= require jquery-ui-1.8.20.custom.min
//= require jquery-ui-sliderAccess
//= require jquery-ui-timepicker-addon

$(document).ready(function () {
    // Attach calendar widgets
    var temporalOptions = {
        timezoneIso8601:true,
        separator:'T',
        timeSuffix:'Z',
        showSecond:true,
        dateFormat:'yy-mm-dd',
        timeFormat:'hh:mm:ss'
    };

    $('#startTime').datetimepicker(temporalOptions);
    $('#endTime').datetimepicker(temporalOptions);

    // Show relevant spatial extent
    $('.bbox, .geometry, .placename').hide();
    var spatial_type = $('#spatial_type').val();
    $('.' + spatial_type).show();

    $('#spatial_type').change(function () {
        $('.bbox, .geometry, .placename').hide();
        var spatial_type = $('#spatial_type').val();
        $('.' + spatial_type).show();
    });
});
