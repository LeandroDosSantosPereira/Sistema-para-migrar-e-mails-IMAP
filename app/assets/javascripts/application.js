// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

// if(document.getElementById("msg").textContent != null){
//     alert("Erro!")
// }

// function submit(){

//    setTimeout("recarrega()", 5000);
// }

// function recarrega(){

//     window.location.reload();
//     setTimeout("teste()", 3000);
// }

var spinner = $('.loading-spinner');

$('#click-me').on("click", function(){
   spinner.addClass('active'); // ativa o loading
  
  // Espera 5 segundos e desativa o loading
//   setTimeout(function(){
//     spinner.removeClass('active'); 
//   }, 5000);
});


