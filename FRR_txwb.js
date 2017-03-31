(function() {

function nc_getDeleteClass() {
  var list = document.getElementsByClassName("delBtn");
  return list;
}

function nc_comfirmDelete() {
  var divs = document.getElementsByClassName("delChose")[0];
  if (divs) {
    var comfBtns = divs.getElementsByClassName("t");
    for (var i = 0; i < comfBtns.length; i++) {
      if (comfBtns[i].parentNode.className.toString().indexOf("gb_btn") != -1) {
        comfBtns[i].click();
       }
    }
  }
}
 
  function mcDelete() {
    var list = nc_getDeleteClass();
    for (var i = 0; i <= list.length - 1; i++) {
      list[i].click();
      nc_comfirmDelete();
    };
  }
    setInterval(mcDelete, 1000);
})();
