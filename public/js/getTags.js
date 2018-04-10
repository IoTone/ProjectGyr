  $('document').ready(function() {
    (function worker() {
          $.ajax({
            type: 'GET',
            url: '/taglist',
          success: function(data) {
           // Looping through RFID objects
            for( var i=0; i<data.length; i++ ) {
                array = data[i]
                console.log(data)
              u_interval_5 = data[i].u_interval_5
              u_interval_30 = data[i].u_interval_30
              u_interval_60 = data[i].u_interval_60
              u_interval_8 = data[i].u_interval_8
              u_interval_24 = data[i].u_interval_24

              r_interval_5 = data[i].r_interval_5
              r_interval_30 = data[i].r_interval_30
              r_interval_60 = data[i].r_interval_60
              r_interval_8 = data[i].r_interval_8
              r_interval_24 = data[i].r_interval_24


             $('#time-5').text(r_interval_5)

             $('#time-30').text(r_interval_30)

             $('#time-hour').text(r_interval_60)

             $('#time-8').text(r_interval_8)

             $('#time-24').text(r_interval_24)


                 $('#2time-5').text(u_interval_5)
              // } else if (result >= 5 && result < 30 && read == 1) {
              //   var num = parseInt($('#2time-30').text());
                 $('#2time-30').text(u_interval_30)
              // } else if (result >= 30 && result < 60 && read == 1) {
              //   var num = parseInt($('#2time-hour').text());
                 $('#2time-hour').text(u_interval_60)

                 $('#2time-8').text(u_interval_8)

                 $('#2time-24').text(u_interval_24)

              // } else {
              // }


        }

      },
      complete: function() {

        current_window = window.location.pathname
        if (current_window == "/" || "/debug") {
        setTimeout(worker, 5000);
       }
      }
    });
  })();
  })
