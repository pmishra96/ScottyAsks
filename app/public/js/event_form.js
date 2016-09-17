$(document).ready(function(){


    // initialize input widgets first
    $('#timeSelect .time').timepicker({
        'showDuration': true,
        'timeFormat': 'g:ia'
    });

    $('#timeSelect .date').datepicker({
        'format': 'm/d/yyyy',
        'autoclose': true
    });

    // initialize datepair
    $('#timeSelect').datepair();


});
