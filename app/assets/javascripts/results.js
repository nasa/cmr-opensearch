// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

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