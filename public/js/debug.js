$('document').ready(function() {
  // (function worker() {
        $.ajax({
          type: 'GET',
          url: '/taglist_2',
        success: function(data) {
         // Looping through RFID objects
          for( var i=0; i<data.length; i++ ) {
              array = data[i]

              count = data[i].count
              discovery = data[i].discovery
              epc = data[i].epc
              last_tag_read = data[i].last_tag_read
              time_difference = data[i].time_difference
              read = data[i].read
              rssi = data[i].rssi

          var tagdata = '<tr><th class="row_width" scope="row">' + epc + '</th>' +
          '<td class="row_width2">' + last_tag_read + '</td>' +
          '<td class="row_width3">' + rssi + '</td>' +
          '<td class="row_width4">' + count + '</td>' +
            '</tr>'

          $('#table_body').prepend(tagdata)
      }
//     },
//     complete: function() {
//       setTimeout(worker, 5000);
//     }
//   });
// })();
  }
 })
})
