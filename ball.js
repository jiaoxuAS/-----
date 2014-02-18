//创建socket连接
var net = require('net'); 
var index = 0; 
var mySocket;

var server = net.createServer(function (socket) {
	mySocket=socket;
	index++;
	new Client(index,socket); 
}); 
server.listen(8124, '127.0.0.1');
 
console.log('server started...');

//初始化johnny-five
var five = require("johnny-five"),
  board, servo;

board = new five.Board();

board.on("ready", function() {

  //定义两只舵机
  leftServo = new five.Servo({
    pin: 9,
    range:[90,120]
  });
  rightServo = new five.Servo({
  	range:[80,110],
  	pin:10
  });

  board.repl.inject({
    lservo: leftServo,rservo:rightServo
  });
  lservo.move(100);
  rservo.move(100);
});

//接收到数据后的操作
function Client(index,socket) {
	var myIndex = index;
	socket.setEncoding("utf8");
    socket.on('data',function(data){
		var _data=data.slice(0,data.length-1);
		var index=_data.indexOf(':');
		var r=_data.slice(0,index);
		var p=200-_data.slice(index+1,_data.length);
		console.log('r:'+r+'---'+'p:'+p);
		leftServo.move(r);
		rightServo.move(p);
    });  
} 


