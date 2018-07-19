// DO NOT REQUIRE TREE!

// CRITICAL that vendor-bundle must be BEFORE bootstrap-sprockets and turbolinks
// since it is exposing jQuery and jQuery-ujs

//= require vendor-bundle
//= require app-bundle

//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require plugins/bootstrap
//= require plugins/bootstrap.file-input
//= require plugins/bootstrap-select
//= require plugins/equal-height
//= require plugins/fastclick
//= require plugins/icheck.min
//= require plugins/jquery.peity
//= require plugins/jquery.sparkline.min
//= require plugins/modernizr
//= require plugins/morris
//= require plugins/placeholders
//= require plugins/moment
//= require plugins/bootstrap-datetimepicker.min
//= require custom/scripts
//= require action_cable 

// Initialize ActionCable Consumer
this.App || (this.App = {});
App.cable = ActionCable.createConsumer();