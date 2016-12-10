$(document).ready(function(){

	parallax();
	$(window).scroll(function(){
		parallax();
	});


});


function parallax(){
	var image = $(".backgroundImage.image_1");
	var scrolledFromTop = $(window).scrollTop();
	image.css({ "top" : (scrolledFromTop / 2) + "px" });
	//image.css({ "background-position-y" : (scrolledFromTop / 2) + "px" });
}