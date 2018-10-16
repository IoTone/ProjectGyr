// function ConvertToCSV(objArray) {
//   var array = typeof objArray != 'object' ? JSON.parse(objArray) : objArray;
//   var str = '';
//
//   for (var i=0; i < array.length; i++) {
//     var line = '';
//     for (var index in array[i]) {
//
//       if (line != '') line += ', '
//
//         line += [index] + ": ";
//         line += array[i][index];
//     }
//
//     str += line + '\r\n';
//
//   }
//   return str;
// }

$('document').ready(function() {

// https://stackoverflow.com/questions/14964035/how-to-export-javascript-array-info-to-csv-on-client-side

        $.ajax({
          type: 'GET',
          url: '/taglist_2',
        success: function(data) {
         // Looping through RFID objects
          for( var i=0; i<data.length; i++ ) {

            var array = typeof data != 'object' ? JSON.parse(data) : data;
            var str = '';
            for (var i=0; i < array.length; i++) {
              var line = '';
              var new_id = array[i]["_id"]["$oid"];
                           array[i]["_id"] = new_id;

              for (var index in array[i]) {
                if (line != '') line += ', '

                  line += [index] + ": ";
                  line += array[i][index];
              }
              str += line + '\r\n';
            }


            $('#csv').click(function() {

             let csvContent = "data:text/csv;charset=utf-8," + str

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
