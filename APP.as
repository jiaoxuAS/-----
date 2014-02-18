package  
{
	import flash.display.MovieClip;
	import flash.net.XMLSocket;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	
	import com.leapmotion.leap.Controller;
	import com.leapmotion.leap.events.LeapEvent;
	import com.leapmotion.leap.Frame;
	import com.leapmotion.leap.Hand;
	import com.leapmotion.leap.util.LeapUtil;
	
	public class APP extends MovieClip 
	{
		
		private var xmlSocket:XMLSocket;
		private var socketConnect:Boolean;
		
		private var controller:Controller;
		private var leapmotionConnect:Boolean;
		private var timer:Timer;
		
		public function APP() 
		{
			if(stage)
			{
				initialize();
			}else 
			{
				addEventListener(Event.ADDED_TO_STAGE,initialize);
			}
		}
		
		private function initialize(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,initialize);
			
			socketConnectBtn.addEventListener(MouseEvent.CLICK,onBtnClickHandler);
			leapmotionConnectBtn.addEventListener(MouseEvent.CLICK,onBtnClickHandler);
			
			//初始化Socket连接
			xmlSocket=new XMLSocket();
			xmlSocket.addEventListener(Event.CONNECT,onConnectHandler);
			xmlSocket.addEventListener(Event.CLOSE,onCloseHandler);
			xmlSocket.addEventListener(IOErrorEvent.IO_ERROR,onIOErrorHandler);
			
			timer=new Timer(10);
			timer.addEventListener(TimerEvent.TIMER,onTimer);
		}
		
		private function onBtnClickHandler(e:MouseEvent):void
		{
			switch(e.currentTarget)
			{
				case socketConnectBtn:
						xmlSocket.connect('127.0.0.1',8124);
					break;
				case leapmotionConnectBtn:
					if(socketConnect)
					{
						controller=new Controller();
						controller.addEventListener(LeapEvent.LEAPMOTION_CONNECTED,onLeapmotionConnectHandler);
						controller.addEventListener(LeapEvent.LEAPMOTION_FRAME,onLeapmotionFrameHandler);
					}else
					{
						info.text='Please Make Sure Connect!';
					}
						
					break;
				default:
			}
		}
		
		private function onConnectHandler(e:Event):void
		{
			//Socket连接成功
			socketConnect=true;
			info.text='Socket Connect Success!';
		}
		
		private function onCloseHandler(e:Event):void
		{
			info.text='Socket Close';
		}
		
		private function onIOErrorHandler(e:Event):void
		{
			info.text='Socket Connect Error!';
		}
		
		private function onLeapmotionConnectHandler(e:LeapEvent):void
		{
			leapmotionConnect=true;
			info.text='Leapmotion Connect Success!';
		}
		
		private var _roll:int,_pitch:int;
		private var isFirst:Boolean=true;
		
		private function onLeapmotionFrameHandler(e:LeapEvent):void
		{
			var frame:Frame=e.frame;
			
			if(frame.hands.length>0)
			{
				timer.start();
				isFirst=true;
				var hand:Hand=frame.hands[0];
				var roll:int= hand.palmNormal.roll*LeapUtil.RAD_TO_DEG;
				var pitch:int= hand.palmNormal.pitch*LeapUtil.RAD_TO_DEG;
				
				if(roll>-20&&roll<10)
				{
					_roll=-roll+100;
				}
				
				if(pitch>-120&&pitch<-70)
				{
					_pitch=-pitch+10;
				}
			}else
			{
				if(isFirst)
				{
					isFirst=false;
					xmlSocket.send(100+':'+100);
					mc.rotationY=mc.rotationX=0;
				}else
				{
					timer.reset();
				}
			}
		}
		
		private function onTimer(e:TimerEvent):void
		{
			if(_roll!=0&&_pitch!=0&&socketConnect)xmlSocket.send(_roll+':'+_pitch);
			mc.rotationY=-(_roll-105)*2;
			mc.rotationX=-(_pitch-90)*2;
		}
	}
}
