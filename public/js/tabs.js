$("document").ready(function() {
 'use strict';

 $('ul li').on('click', function() {

    console.log(this);
    $(this).addClass('active').siblings().removeClass('active');

 })

});
