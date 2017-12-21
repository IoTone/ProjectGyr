  $('document').ready(function() {

  $('.butt').on('click', function(e) {
    $.ajax({
      type: 'GET',
      url: '/tags',
      dataType: 'json'
    }).done(function(data) {
      console.log(data);
    })

    e.preventDefault()
    console.log('1234567890-');
  });
})
