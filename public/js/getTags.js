$(function() {

  $.ajax({
    type: "GET",
    dataType: "json",
    url: "/tags",
    success: function(data) {
      console.log(data);
    }

  });

});
