$('document').ready(function() {
  (function worker() {


        $.ajax({
          type: 'GET',
          dataType: 'json',
          url: '/trakr_list',
        success: function(data) {
          var html;
          for(var i = 0; data.length > i; i++) {
            console.log(data[i]);
          html += "<tr id='tag'><th class='row_width' scope='row'>" + data[i]['epc'] + "</th></tr>";

          }

          console.log(html);
          $('#table_body').html(html);
         // Looping through RFID objects
         // console.log(data)

      //     for( var i=0; i<data.length; i++ ) {
      //         // console.log(data[i].epc)
      //
      //
      // }

    },
    complete: function() {
      setTimeout(worker, 5000);
    }
  });
})();
})
