
//  Rails assumption is if the dogwalk_id has some value then we are editing, else it's a new dogwalk
function determineDogwalkState() {
    if ( $("#dogwalk_id").val() ) {
        return "edit";
    } else {
        return "new";
    }
}

function configurePeeButton(scope) {
    var peeValuesArray = ["No", "Yes", "Marking", "Bloody", "Concentrated", "Clear" ];

    //$("#pee-button", scope).click(function() 
    $("#pee-button").click(function() 
        {
            var currPeeValue = $("#dogwalk_pee").val();
            var n = peeValuesArray.indexOf(currPeeValue);
            if (n == ( peeValuesArray.length - 1 )) { n = -1; }
            var pe = peeValuesArray[++n];
            $("#dogwalk_pee").val(pe);
            return false;
        }
    );
}
function configurePooButton(scope) {
    var pooValuesArray = ["No", "Yes", "Loose", "Diarrhea", "Mucous", "Odd Color", "Dry", "Bloody", "Squiggly", "Object?" ];
    
    //$("#poo-button", scope).click(function() 
    $("#poo-button").click(function() 
        {
            var currPooValue = $("#dogwalk_poo").val();
            var o = pooValuesArray.indexOf(currPooValue);
            if (o == ( pooValuesArray.length - 1 )) { o = -1; }
            var po = pooValuesArray[++o];
            $("#dogwalk_poo").val(po);
            return false;
        }
    );
}

function configureWaterButton(scope) {
    var waterValuesArray = ["No", "Drank", "Drank - refilled water bowl", "Drank from water bottle", "Drank at water fountain" ];
    //$("#water-button", scope).click(function() 
    $("#water-button").click(function() 
        {
            var currWaterValue = $("#dogwalk_water").val();
            var o = waterValuesArray.indexOf(currWaterValue);
            if (o == ( waterValuesArray.length - 1 )) { o = -1; }
            var wa = waterValuesArray[++o];
            $("#dogwalk_water").val(wa);
            return false;
        }
    );    
}

function configureTreatButton(scope) {
    var treatValuesArray = ["No", "Yes", "Couple", "Couple for good behavior", "Many" ];
    //$("#treat-button", scope).click(function() 
    $("#treat-button").click(function() 
        {
            var currTreatValue = $("#dogwalk_treat").val();
            var o = treatValuesArray.indexOf(currTreatValue);
            if (o == ( treatValuesArray.length - 1 )) { o = -1; }
            var tr = treatValuesArray[++o];
            $("#dogwalk_treat").val(tr);
            return false;
        }
    );
}

function isStopwatchInUse() {
    console.log("isStopwatchInUse start");
    var use = $("#use_stopwatch").is(':checked');
    
    console.log("use = " + use);

    return false;
}

//  dogwalk_start, dogwalk_time_elapsed, dogwalk_stop 
function resetStopwatchInputFields() {
    $("#dogwalk_start_as_millis").val("");
    $("#dogwalk_stop_as_millis").val("");
    $("#dogwalk_start").val("");
    $("#dogwalk_time_elapsed").val("");
    $("#dogwalk_stop").val("");
    $("#stopwatch_elapsed_time").text("00:00:00");
}


// ************   jquery document ready   ***************************************************************
$(document).ready(function(){

    console.log("start dogwalks.js ready function");
    console.log("form start_as_millis = " + $("#dogwalk_start_as_millis").val());
    console.log("form stop_as_millis = " + $("#dogwalk_stop_as_millis").val());

    // set the timezone for the dogwalk dogwalk
    if ( ! $("#dogwalk_timezone").val() ) {
        var timezone = jstz.determine();
        $("#dogwalk_timezone").val(timezone.name());
        console.log("timezone = " + timezone.name());
    }

    // Check for the various File API support.
    // if (window.File && window.FileReader && window.FileList && window.Blob) {
    //   // Great success! All the File APIs are supported.
    //     console.log("browser supports new File APIs")
    // } else {
    //   alert('The File APIs are not fully supported in this browser.');
    // }
    var dogwalkState = determineDogwalkState();
    var scope = "";
    if (dogwalkState == "new") {
        scope = "#new_dogwalk";
    } else {
        scope = "#edit_dogwalk";
        if ( $("#dogwalk_stop_as_millis").val() ) {
            // stopwatch has been stopped - set the stopwatch button to reset
            $("#stopwatch_multi_button").text("Reset");
            $("#stopwatch_multi_button").removeClass("btn-success");
            $("#stopwatch_multi_button").removeClass("btn-danger");
            $("#stopwatch_elapsed_time").text( $("#dogwalk_time_elapsed").val() );
        } else if ( $("#dogwalk_start_as_millis").val() ) {
            // stopwatch is running - set the stopwatch button to stop
            $("#stopwatch_multi_button").text("Stop");
            $("#stopwatch_multi_button").removeClass("btn-success");
            $("#stopwatch_multi_button").addClass("btn-danger");
            manageTimer("start");
        }
    }
    console.log("dogwalkState = " + dogwalkState);

    configurePeeButton(scope);
    configurePooButton(scope);
    configureWaterButton(scope);
    configureTreatButton(scope);
    
    $("#dogwalk_stopwatch_container").on('click', '#stopwatch_multi_button', function() {
      console.log("stopwatch_multi_button start on click - text is " + $("#stopwatch_multi_button").text());
      if ( $("#stopwatch_multi_button").text() == "Start" ) {
          $("#stopwatch_multi_button").text("Stop");
          $("#stopwatch_multi_button").removeClass("btn-success");
          $("#stopwatch_multi_button").addClass("btn-danger");
          var dt = new Date();
          var millis = dt.getTime();
          $("#dogwalk_start_as_millis").val(millis);
          $("#dogwalk_start").val(dt.format("yyyy-mm-dd'T'HH:MM:ss"));  
          manageTimer("start");

      } else if ( $("#stopwatch_multi_button").text() == "Stop" ) {
          $("#stopwatch_multi_button").text("Reset");
          $("#stopwatch_multi_button").removeClass("btn-success");
          $("#stopwatch_multi_button").removeClass("btn-danger");
          var dt = new Date();
          var millis = dt.getTime();
          $("#dogwalk_stop_as_millis").val(millis);
          $("#dogwalk_stop").val(dt.format("yyyy-mm-dd'T'HH:MM:ss"));
          $("#dogwalk_time_elapsed").val($("#stopwatch_elapsed_time").text());
          manageTimer("stop");

      } else if ( $("#stopwatch_multi_button").text() == "Reset" ) {
          $("#stopwatch_multi_button").text("Start");
          $("#stopwatch_multi_button").addClass("btn-success");
          resetStopwatchInputFields();
      }

    });
    
    $("#dogwalk_stopwatch_container").on('click', '#finished', function() {
        alert("finished clicked");
        // if ( $("#dogwalk_start_as_millis").val() != "")  {
        //     alert("need to stop the stopwatch");
        // }
        return false;
    });
    
});     // end jquery document ready
