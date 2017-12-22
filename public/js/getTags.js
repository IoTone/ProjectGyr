  $('document').ready(function() {

    $.ajax({
      type: 'GET',
      url: '/taglist'
    }).done(function(data) {
     // Looping through RFID objects
      for( var i=0; i<data.length; i++ ) {

        epc = data[i].epc // EPC: Unique Identifier of RFID Tag
        count = data[i].count // Count: Number of times reader picked up Tag during read
        rssi = data[i].rssi // RSSI: Relative recieved signal strength of Tag
        data[i].discovery // Discovery: Initial discovery of Tag
        time_difference = data[i].time_difference //
        read = data[i].read
        last_tag_read = data[i].last_tag_read

        var time_now = moment();
        var last = moment.utc(last_tag_read).format('YYYY-MM-DDTHH:mm:ss')
        var result = time_now.diff(last, 'minutes');
        console.log(result);

        if (result < 5) {
          var num = parseInt($('#time-5').text());
          console.log(num);
          $('#time-5').text(num+1)
        } else if (result > 5 && result < 30) {
          var num = parseInt($('#time-30').text());
          console.log(num);
          $('#time-30').text(num+1)
          console.log('peepee')
        } else if (result > 60) {
          var num = parseInt($('#time-hour').text());
          console.log(num);
          $('#time-hour').text(num+1)
        } else {
          console.log("up to date")
        }

        // var time_5 = moment.duration(time);
        // var date = moment(last);
        //
        //
        // console.log(date.subtract(time))

      } //loop for objects
  }) // data
}); // ajax request
