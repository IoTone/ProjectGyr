  $('document').ready(function() {

    $.ajax({
      type: 'GET',
      url: '/taglist'
    }).done(function(data) {
      console.log(data);
     
    })
});
