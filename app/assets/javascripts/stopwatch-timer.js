// global vars  -- crockford style says to make them all caps
// timer for running the stopwatch
var STOPWATCHTIMER = 0;

// the input parameter is a millisecond timestamp value
// these functions format the hours/mins/secs to always show two numbers - prefix with 0 if necessary
// the function 'three' is not currently needed - it is for formatting micro/millisecond values with three places
//  called by: time(ms)
function two(x) {return ((x>9)?"":"0")+x}
function three(x) {return ((x>99)?"":"0")+((x>9)?"":"0")+x}

//  called by: runStopwatch()
function time(ms) {
    var sec = Math.floor(ms/1000)
    ms = ms % 1000
    //t = three(ms)

    var min = Math.floor(sec/60)
    sec = sec % 60
    //t = two(sec) + ":" + t
    t = two(sec) 

    var hr = Math.floor(min/60)
    min = min % 60
    t = two(min) + ":" + t

    //var day = Math.floor(hr/60)
    hr = hr % 60
    t = two(hr) + ":" + t
    //t = day + ":" + t

    return t
}

//  when a user is viewing an active dogwalk, this function
//  performs stopwatch feature by running every second
//  and calculating the time since the dogwalk started
//  
//  called by: manageTimer(state) 
function runStopwatch() {
    console.log("runStopwatch start");

    if( $("#dogwalk_start_as_millis").val() ) {
        var now = new Date();
        var ms = now.getTime() - parseInt($("#dogwalk_start_as_millis").val());
        //$("#elapsed-stopwatch").text(time(ms));
        //$("#dogwalk_time_elapsed").val(time(ms));
        $("#stopwatch_elapsed_time").text(time(ms));
    } else {
        return false;
    }
}

//  Timer is used to create a stopwatch on an active dogwalk
//  valid params state = "start", "stop"
//  when the dogwalk is active, run the stopwath every second
//  related to functions:  runStopwatch()
//  
//  called by: manageDogwalkSetup(), bindDogwalkButtons(scope) [several calls]
function manageTimer(state) {
    console.log("begin manageTimer -- state= " + state + " STOPWATCHTIMER= " + STOPWATCHTIMER);

    if(state === "start") {
        STOPWATCHTIMER = setInterval('runStopwatch("run")',1000);
    } else {     //  if (state == "stop") {   any param value other than start should get rid of timer
        clearTimeout(STOPWATCHTIMER);
    }

    console.log("end manageTimer -- state= " + state + " STOPWATCHTIMER= " + STOPWATCHTIMER);
}
