var init_stock_lookup;

var hide_spinner = function() {
  $('#spinner').hide();
  
}

var show_spinner = function() {
  $('#spinner').show();
}


init_stock_lookup = function() {
  
  $('#stock-lookup-form').on('ajax:before', function(event, data, status) {
    show_spinner();
  })
  $('#stock-lookup-form').on('ajax:after', function(event, data, status) {
    hide_spinner();
  })
  $('#stock-lookup-form').on('ajax:success', function(event, data, status) {
    $('#stock-lookup').replaceWith(data);
    init_stock_lookup(); // why need to add again, must reinitlized them cause listeners are gone
  });
  // error handling ajax
  $('#stock-lookup-form').on('ajax:error', function(event, xhr, status, error) {
    hide_spinner();
    $('#stock-lookup-results').replaceWith(' ');
    $('#stock-lookup-errors').replaceWith('Stock was not found.');
    
  });
};


$(document).ready(function() {
  init_stock_lookup();
  
  
});