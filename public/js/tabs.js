// function openMe(inside) {
//   var i, content;
//   content =
//   document.getElementsByClassName("content");
//    for (i = 0; i<content.length; i++) {
//      content[i].style.display = "none"
//    }
//    document.getElementById(inside).style.display = "block";
// }

$("document").ready(function() {
 'use strict';

 $('ul li').on('click', function() {
   var tab_data = $(this).data('tab');
   $(this).addClass('active').siblings().removeClass('active');

   $(tab_data).show().siblings().hide();
 })

});
