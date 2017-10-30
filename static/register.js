$(document).ready(function() {

  $('#register-user-button').click(function() {
    $.ajax({
      url: 'register_passenger',
      type: 'POST',
      data: {
        email: $('#user-email').first().val(),
        name: $('#user-name').first().val(),
        phone: $('#user-phone').first().val()
      },
      success: function(data, textStatus, jqXHR) {
          top.location.href = data;  // redirection
        }, error: function(jqXHR, textStatus, errorThrown) {
          $('.error-div-passenger').html(
            'El correo electrónico ya está registrado');
        }
    });
  });

  $('#register-driver-button').click(function() {
    $.ajax({
      url: 'register_driver',
      type: 'POST',
      data: {
        email: $('#driver-email').first().val(),
        name: $('#driver-name').first().val(),
        phone: $('#driver-phone').first().val(),
        licence: $('#driver-license').first().val(),
        fare: $('#driver-fare').first().val()
      },
      success: function(data, textStatus, jqXHR) {
          top.location.href = data;  // redirection
        }, error: function(jqXHR, textStatus, errorThrown) {
          $('.error-div-driver').html(
            'El correo electrónico ya está registrado');
        }
    });
  });

});
