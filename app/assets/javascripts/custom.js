$(document).ready(function() {
  $('.dropdown-toggle').click(function(e) {
    e.preventDefault();
    $(this).next('.dropdown-menu').slideToggle('fast');
  });
});