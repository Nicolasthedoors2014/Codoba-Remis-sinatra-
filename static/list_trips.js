$(document).ready(function() {
  // Add listener for the submit button.
  $('#submit-button').click(function() {
    var origin = $('#origin').first().attr('value');
    var destination = $('#destination').first().attr('value');
    if (origin != '' && destination != '') {
      $.ajax({
        url: 'available_trips',
        type: 'POST',
        data: {origin: origin, destination: destination},
        success: function(data, textStatus, jqXHR) {
            $('#available_trip_list').html(data);
            // Update all the mdl elements in data to apply the css styles.
            componentHandler.upgradeAllRegistered();
        }, error: function(jqXHR, textStatus, errorThrown) {
          console.log('error');
        }
      });
    }
  });
  $('#submit-button').click();
});
