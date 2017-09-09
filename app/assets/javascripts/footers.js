$(function() {

  uri = location.href;
  $footerLinkElem = $(".l-footerNav .m-navigation ul li");
  loginUser = $footerLinkElem.eq(4).length;
  
  RECOMMEND = 1;
  CIINIISEARCH = 2;
  THESES = 3;
  TOP = 0;
 
  SIGNUP = 1;
  LOGIN = 2;

  if (loginUser){
    if(uri.match(/recommendations/)) $footerLinkElem.eq(RECOMMEND).addClass("active");

    else if(uri.match(/ciniis/)) $footerLinkElem.eq(CIINIISEARCH).addClass("active");

    else if(uri.match(/theses/)) $footerLinkElem.eq(THESES).addClass("active");

    else $footerLinkElem.eq(TOP).addClass("active");
  }
  else {
    if(uri.match(/mail_addresses/)) $footerLinkElem.eq(SIGNUP).addClass("active");
    
    else if(uri.match(/login/)) $footerLinkElem.eq(LOGIN).addClass("active");
   
    else $footerLinkElem.eq(TOP).addClass("active");
  }

   $footerLinkElem.mouseover(function() {
    $(this).addClass("bottom-border");
  }).mouseout(function() {
    $(this).removeClass("bottom-border");
  });

});
