//= require jquery.tmpl.min
//= require underscore.min
//= require backbone.min
//= require main_template
//= require recipe
//= require recipe.follow
//= require_self

jQuery(function($) {
  $(".cate-recipe-card").recipe()



  // slider
  $('#left-btn').bind('click', function () {
    var button = $(this);
    if (button.attr("allow") == "true" ){
      if(parseInt($(".slider").css("margin-left") ) < 0 ){
        $(this).attr("allow" , "false");
        $('.slider').animate({
          'marginLeft' : "+=562"
          }, {
          duration: 500,
          specialEasing: {
          },
          complete: function() {
            button.attr("allow" , "true");
          }
        });
      }
    }  
    return false;
  });

  $('#right-btn').bind('click', function () {
    var button = $(this)
    if (button.attr("allow") == "true" ){
      var li_length = $(".slider li.cate-recipe-card").length - 2
      if(parseInt($(".slider").css("margin-left") ) > li_length * -270 ){
        button.attr("allow" , "false");
        $('.slider').animate({
          'marginLeft' : "-=562" 
          }, {
          duration: 500,
          specialEasing: {
          },
          complete: function() {
            button.attr("allow" , "true");
          }
        });
      }  
    }
    return false;
  });
// end slider
});


