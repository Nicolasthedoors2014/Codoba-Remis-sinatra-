$(document).ready(function() {

  $('#submit-button').click(function() {
    var email = $('#email').first().val();
    var user_type = $('input[type=radio][name=options]:checked').val();
    $.ajax({
      url: 'login',
      type: 'POST',
      data: {email: email, user_type: user_type},
      success: function(data, textStatus, jqXHR) {
          top.location.href = data;  // redirection
        }, error: function(jqXHR, textStatus, errorThrown) {
          $('.error-div').html('El correo electrónico no está registrado');
        }
    });
  });

});
