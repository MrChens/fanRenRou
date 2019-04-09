
function notifyMe() {
    var notification = new Notification('抢券了拉', {
      icon: 'http://cdn.sstatic.net/stackexchange/img/logos/so/so-icon.png',
      body: "阿龙，准备抢券了拉",
    });

    notification.onclick = function () {
      // window.open("https://stackoverflow.com/a/13328397/1269037");
    };
}

function check_people_num (){
	tag = document.getElementById('attend');
	console.log(tag.textContent);
	var str = tag.textContent;
	console.log(str.substring("参与人数".length ,str.length));
	var num = str.substring("参与人数".length ,str.length);
	  if(parseInt(num) > 69900){
	    console.log("hahah:" + num);
	    notifyMe();
	    alert('阿龙，准备抢券了拉' + name);
	  } else {

	  location.reload(true);
	  }
}

if (Notification.permission !== "granted")
  Notification.requestPermission();

window.setInterval(check_people_num, 2000);
