package com.oxylusflash.multimediaviewer
{
	//{ region IMPORT CLASSES
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.utils.Timer;
	import org.osflash.signals.Signal;
	
	import caurina.transitions.Tweener;
	
	import com.oxylusflash.framework.util.StringUtil;
	import com.oxylusflash.mmgallery.YouTubeXML;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class YouTubePlayer extends MovieClip
	{
		//{ region FIELDS
		private const TIMER_VAL : int = 33;//66
		
		private var _videoSignal : Signal;
		private var _vpc : Object;
		private var _settings : Object;
		private var _url : String = "";
		private var _urlXML : XMLList;
		
		private var _errorMsg : String = "";
		private var _quality : String = "";
		private var _volume : Number = 0;
		private var _autoPlay : Boolean;
		private var _repeat : Boolean;
		private var _timer : Timer;
		
		private var loader : Loader;
		private var getXML : YouTubeXML;
		private var urlREQ : URLRequest;
		private var firstVidQuality : Boolean = true;
		private var qualFound : Boolean = false;
		//} endregion
		
		//{ region CONSTRUCTOR
		public function YouTubePlayer() 
		{
			this.visible = false;
			this.alpha = 0;
			
			_videoSignal = new Signal(String);
		}
		//} endregion
		
		//{ region EVENT HANDLERS////////////////////////////////////////////////////////////////////////////////////////////
		
		//{ region SIGNAL HANDLER
		private final function SignalHandler(xml : Object):void
		{
			getXML.ytSignal.remove(SignalHandler);
			_vpc.loadVideoById(xml.videoID);
		}
		//} endregion
		
		//{ region PL LOADER INIT HANDLER
		private final function Loader_initHandler(e:Event):void 
		{
			this.addChild(loader);
			loader.content.addEventListener("onReady", PlayerReadyHandler, false, 0, true);
			loader.content.addEventListener("onError", PlayerErrorHandler, false, 0, true);
			loader.content.addEventListener("onStateChange", PlayerStateChange, false, 0, true);
			loader.content.addEventListener("onPlaybackQualityChange", PlayerPlaybackQualityChangeHandler, false, 0, true);
		}
		//} endregion
		
		//{ region PL LOADER COMPLETE HANDLER
		private final function Loader_completeHandler(e:Event):void 
		{
			loader.contentLoaderInfo.removeEventListener(Event.INIT, Loader_initHandler);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, Loader_completeHandler);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, Loader_iOErrorHandler);
		}
		//} endregion
		
		//{ region PL LOADER IO ERROR HANDLER
		private final function Loader_iOErrorHandler(e:IOErrorEvent):void 
		{
			loader.contentLoaderInfo.removeEventListener(Event.INIT, Loader_initHandler);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, Loader_completeHandler);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, Loader_iOErrorHandler);
			
			trace("youtube player loader IOError, class YouTubePlayer.as", e);
		}
		//} endregion
		
		//{ region TIMER HANDLER
		private final function timerHandler(e:TimerEvent):void
		{
			timer.reset();
			timer.start();
			_videoSignal.dispatch("TIME UPDATE");
		}
		//} endregion
		
		//{ region PLAYER READY HANDLER
		private final function PlayerReadyHandler(e:Event):void 
		{
			// cueVideoById, loadVideoById
			//This event is fired whenever the player's state changes. 
			//Possible values are unstarted (-1), ended (0), playing (1),
			//paused (2), buffering (3), video cued (5). 
			//When the SWF is first loaded it will broadcast an unstarted (-1) event. 
			//When the video is cued and ready to play it will broadcast a video cued event (5).
			
			_vpc = { };
			_vpc = loader.content;
			_videoSignal.dispatch("PLB RDY");
			
			_vpc.mute();
			_vpc.setVolume(_volume * 100);
			
			if (url != "") 
			{
				_vpc.playVideo();
				_vpc.pauseVideo();
				_vpc.unMute();
				_vpc.loadVideoById(url);
			}else 
			{
				_vpc.playVideo();
				_vpc.pauseVideo();
				_vpc.unMute();
				
				getXML = new YouTubeXML();
				getXML.LoadYtXML(urlXML, _settings);
				getXML.ytSignal.add(SignalHandler);
			}
			
			try 
			{
				loader.close();
				loader.unload();
				loader = null;
			}catch (err:Error)
			{
			}
		}
		//} endregion
		
		//{ region PLAYER ERROR HANDLER
		private final function PlayerErrorHandler(e:Event):void 
		{
			_videoSignal.dispatch("PLB RDY");
			/*This event is fired when an error in the player occurs. 
			The possible error codes are 100, 101, and 150. 
			The 100  error code is broadcast when the video requested is not found. 
			This occurs when a video has been removed (for any reason), or it has been marked as private. 
			The 101 error code is broadcast when the video requested does not allow playback in the embedded players. 
			The error code 150 is the same as 101, it's just 101 in disguise!*/
			errorMsg = "";
			switch (int(Object(e).data)) 
			{
				case 100:
					errorMsg = settings.error.notFound;
				break;
				
				case 101:
					errorMsg = settings.error.notAllowed;
				break;
				
				case 150:
					errorMsg = settings.error.notAllowed;
				break;
			}
			_videoSignal.dispatch("ERROR");
		}
		//} endregion
		
		//{ region PLAYER STATE CHANGE
		private final function PlayerStateChange(e:Event = null):void 
		{
			/*This event is fired whenever the player's state changes. 
			Possible values are unstarted ( -1), ended (0), playing (1), paused (2), buffering (3), video cued (5).
			When the SWF is first loaded it will broadcast an unstarted ( -1) event. 
			When the video is cued and ready to play it will broadcast a video cued event (5).*/
			
			switch (int(Object(e).data)) 
			{
				case -1:
				break;
				
				case 0:
					_videoSignal.dispatch("PLB COMPLETE");
					if (_repeat) 
					{
						_vpc.seekTo(0, true);
					}
				break;
				
				case 1:
					timer.reset();
					timer.start();
					
					if (_autoPlay) 
					{
						_videoSignal.dispatch("PLAY");
					}else 
					{
						_autoPlay = true;
						_videoSignal.dispatch("AUTOPLAY FALSE");
					}
				break;
				
				case 2:
					if (_autoPlay) 
					{
						timer.reset();
						timer.stop();
					}
					_videoSignal.dispatch("PAUSE");
				break;
				
				case 3:
				break;
				
				case 5:
					if (_autoPlay) 
					{
						timer.reset();
						timer.start();
						_videoSignal.dispatch("PLAY");
					}else 
					{
						_videoSignal.dispatch("CUED");
						_autoPlay = true;
					}
				break;
			}
		}
		//} endregion
		
		//{ region PLAYER PLAYBACK QUALITY CHANGE HANDLER
		private final function PlayerPlaybackQualityChangeHandler(e:Event):void 
		{
			/*This event is fired whenever the video playback quality changes.
			For example, if you call the setPlaybackQuality(suggestedQuality)  function, this event will fire if the playback quality actually changes.
			Your code should respond to the event and should not assume that the quality will automatically change when the setPlaybackQuality(suggestedQuality)  function is called.
			Similarly, your code should not assume that playback quality will only change as a result of an explicit call 
			to setPlaybackQuality or any other function that allows you to set a suggested playback quality.
			
			The value that the event broadcasts is the new playback quality. 
			Possible values are "small", "medium", "large" and "hd720".*/
			
			if (firstVidQuality) 
			{
				firstVidQuality = false;
				if (_vpc.getPlaybackQuality() != _quality) 
				{
					var qualityLevels : Array = [];
					qualityLevels = _vpc.getAvailableQualityLevels();
					setQuality(qualityLevels, _quality);
				}
			}
		}
		//} endregion
		
		//{ region SET QUALITY
		private final function setQuality(pArray : Array, pType : String = "default"):void
		{
			var qLength : int = pArray.length;
			for (var i:int = 0; i < qLength; i++) 
			{
				if (i < qLength-1)
				{
					if (pArray[i] == _quality) 
					{
						qualFound = true;
						_vpc.setPlaybackQuality(_quality);
					}
				}else 
				{
					if (pArray[i] == _quality) 
					{
						qualFound = true;
						_vpc.setPlaybackQuality(_quality);
					}
					
					if (!qualFound) 
					{
						_vpc.setPlaybackQuality(_quality);
					}
				}
			}
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS//////////////////////////////////////////////////////////////////////////////////////////////////
		
		//{ region START ME
		internal final function StartMe(pSettings : Object, pPolicy : XMLList):void 
		{
			settings = pSettings;
			Security.allowDomain(String(pSettings.securityDomain));
			
			var policyL : int = pPolicy.policy.length();
			
			for (var i:int = 0; i < policyL; i++) 
			{
				Security.loadPolicyFile(String(pPolicy.policy[i]));
			}
			
			urlREQ = new URLRequest(pSettings.player);
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, Loader_initHandler, false, 0, true);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, Loader_completeHandler, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, Loader_iOErrorHandler, false, 0, true);
			
			loader.load(urlREQ);
			
			timer = new Timer(TIMER_VAL, 1);
			timer.addEventListener(TimerEvent.TIMER, timerHandler, false, 0, true);
		}
		//} endregion
		
		//{ region DESTROY
		internal final function Destroy():void 
		{
			if (timer) 
			{
				timer.reset();
				timer.stop();
				
				if (timer.hasEventListener(TimerEvent.TIMER)) 
				{
					timer.removeEventListener(TimerEvent.TIMER, timerHandler);
				}
			}
			
			urlREQ = null;
			
			if (_vpc) 
			{
				_vpc.stopVideo();
				_vpc.destroy();
			}
			
			if (loader && loader.content && loader.content.hasEventListener("onReady"))
			{
				loader.content.addEventListener("onReady", PlayerReadyHandler, false, 0, true);
			}
			
			if (loader && loader.content && loader.content.hasEventListener("onError")) 
			{
				loader.content.addEventListener("onError", PlayerErrorHandler, false, 0, true);
			}
			
			if (loader && loader.content && loader.content.hasEventListener("onStateChange")) 
			{
				loader.content.addEventListener("onStateChange", PlayerStateChange, false, 0, true);
			}
			
			if (loader && loader.content && loader.content.hasEventListener("onPlaybackQualityChange")) 
			{
				loader.content.addEventListener("onPlaybackQualityChange", PlayerPlaybackQualityChangeHandler, false, 0, true);
			}
			
			if (loader && loader.content && loader.content.hasEventListener(Event.INIT) ||
			loader && loader.content && loader.content.hasEventListener(Event.COMPLETE) ||
			loader && loader.content && loader.content.hasEventListener(IOErrorEvent.IO_ERROR)) 
			{
				loader.contentLoaderInfo.removeEventListener(Event.INIT, Loader_initHandler);
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, Loader_completeHandler);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, Loader_iOErrorHandler);
			}
			
			try 
			{
				loader.close();
				loader.unload();
				loader = null;
			}catch (err:Error)
			{
			}
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		internal function get quality():String { return _quality; }
		internal function set quality(value:String):void 
		{
			_quality = value;
		}
		
		internal function get videoSignal():Signal { return _videoSignal; }
		internal function set videoSignal(value:Signal):void 
		{
			_videoSignal = value;
		}
		
		internal function get vpc():Object { return _vpc; }
		internal function set vpc(value:Object):void 
		{
			_vpc = value;
		}
		
		internal function get repeat():Boolean { return _repeat; }
		internal function set repeat(value:Boolean):void 
		{
			_repeat = value;
		}
		
		internal function get autoPlay():Boolean { return _autoPlay; }
		internal function set autoPlay(value:Boolean):void 
		{
			_autoPlay = value;
		}
		
		internal function get volume():Number { return _volume; }
		internal function set volume(value:Number):void 
		{
			_volume = value;
		}
		
		internal function get errorMsg():String { return _errorMsg; }
		internal function set errorMsg(value:String):void 
		{
			_errorMsg = value;
		}
		
		internal function get settings():Object { return _settings; }
		internal function set settings(value:Object):void 
		{
			_settings = value;
		}
		
		internal function get url():String { return _url; }
		internal function set url(value:String):void 
		{
			_url = value;
		}
		
		internal function get urlXML():XMLList { return _urlXML; }
		internal function set urlXML(value:XMLList):void 
		{
			_urlXML = value;
		}
		
		internal function get timer():Timer { return _timer; }
		internal function set timer(value:Timer):void 
		{
			_timer = value;
		}
		//} endregion
	}
}