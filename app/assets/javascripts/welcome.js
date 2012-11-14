//  trying to share js code with PetOwneriOS dw_guide.js 


var EPET_DW_GUIDE = ['1.png','2.png','3.png','4.png','5.png','6.png','7.png','8.png','9.png','10.png',
                    '11.png','12.png','13.png','14.png','15.png','16.png','17.png','18.png','19.png','20.png',
                    '21.png','22.png','23.png','24.png','25.png','26.png','27.png'];

$(document).ready(function() {

});


$("#adwsg_next").click(function() {
    var current = parseInt($("#adwsg_counter").text(), 10);
    var next;
    console.log("adwsg_next clicked - current = " + current + " EPET_DW_GUIDE.length = " + EPET_DW_GUIDE.length);
    if (current === EPET_DW_GUIDE.length) { 
        next = 1;
    } else {
        next = (current + 1);
    }
    console.log("adwsg_next clicked - next = " + next);
    $("#adwsg_counter").text(next);
    $("#avoid_dogwalker_scams_guide").attr('src', "https://s3.amazonaws.com/epetfolio/uploads/dogwalker-guide/" + EPET_DW_GUIDE[(next-1)]);
    hopsPost('next', current, next);
});

$("#adwsg_prev").click(function() {
    var current = parseInt($("#adwsg_counter").text(), 10);
    var prev;
    console.log("adwsg_prev clicked - current = " + current + " EPET_DW_GUIDE.length = " + EPET_DW_GUIDE.length);
    if (current === 1) { 
        prev = EPET_DW_GUIDE.length;
    } else {
        prev = (current - 1);
    }
    console.log("adwsg_prev clicked - prev = " + prev);
    $("#adwsg_counter").text(prev);
    $("#avoid_dogwalker_scams_guide").attr('src', "https://s3.amazonaws.com/epetfolio/uploads/dogwalker-guide/" + EPET_DW_GUIDE[(prev-1)]);
    hopsPost('prev', current, prev);
});

$("#adwsg_menu").click(function() {
	console.log("dw_guid - adwsg_menu button clicked");
    var current = parseInt($("#adwsg_counter").text(), 10);
    hopsPost('menu', current, 'home');
    window.location = "/";
});

function hopsPost(button, current, next) {
    console.log("webapp hopsPost start - button = " + button + " - current = " + current + " next page is " + next);
    var timezone = jstz.determine();

//    var HOST = "http://calm-falls-3515.herokuapp.com/";
    var HOST = "http://localhost:3000/";

    var target = HOST + "hop.json";
    var payload = { "hop" : 
                  {  "prev_page"      : current,
                     "page"           : button + " : " + next,
                     "description"    : timezone.name(),
                     "timestamp"      : new Date()  
    }};
    console.log("webapp hopsPost: start POST ajax call");
    var request = $.ajax({
      url: target,
      type: "POST",
      data: payload,
      dataType: "json"
    });
    request.done(function(msg) {
        console.log("hops good");
    });
    request.fail(function(jqXHR, textStatus) {
        console.log("hops error - textStatus = " + textStatus);
    });
}



