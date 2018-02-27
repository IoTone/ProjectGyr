$('document').ready(function() {

// https://stackoverflow.com/questions/14964035/how-to-export-javascript-array-info-to-csv-on-client-side

        $.ajax({
          type: 'GET',
          url: '/taglist_2',
        success: function(data) {
         // Looping through RFID objects
          for( var i=0; i<data.length; i++ ) {
            csv_data = data[i].count + data[i].discovery + data[i].epc +
            data[i].last_tag_read + data[i].time_difference + data[i].read +
            data[i].rssi
         $('#csv').click(function() {
           let csvContent = "data:text/csv;charset=utf-8," + csv_data

           var encodedUri = encodeURI(csvContent);
           var link = document.createElement("a");
           link.setAttribute("href", encodedUri);
           link.setAttribute("download", "data.csv");
           document.body.appendChild(link); // Required for FF

           link.click();
         });


      }

    }

  })
})
