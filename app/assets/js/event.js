$(document).ready( function () {
  $('#event_data').DataTable();

  $("#make_organizer").click(function(){
    $.ajax({
    	type: "POST",
    	url: "/make_organizer", 
      data: $(this).parent().serialize(),
    	success: function(result){
        $(this).parent().replaceWith($("form#revoke").clone());
    }});
	});

  $("#revoke_organizer").click(function(){
    $.ajax({
      type: "POST",
      url: "/revoke_organizer", 
      data: $(this).parent().serialize(),
      success: function(result){
        $(this).parent().replaceWith($("form#make").clone());;
    }});
  });

});