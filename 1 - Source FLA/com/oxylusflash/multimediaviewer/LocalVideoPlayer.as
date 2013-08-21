package com.oxylusflash.multimediaviewer 
{
	//{ region IMPORT CLASSES
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.media.Video;
	
	import org.osflash.signals.Signal;
	import caurina.transitions.Tweener;
	
	import com.oxylusflash.framework.events.MediaBufferingEvent;
	import com.oxylusflash.framework.events.MediaErrorEvent;
	import com.oxylusflash.framework.events.MediaLoadEvent;
	import com.oxylusflash.framework.events.MediaPlaybackEvent;
	import com.oxylusflash.framework.playback.VideoPlayback;
	import com.oxylusflash.framework.resize.Resize;
	import com.oxylusflash.framework.resize.ResizeType;
	import com.oxylusflash.framework.util.StringUtil;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class LocalVideoPlayer extends MovieClip
	{
		//{ region FIELDS
		private var _videoSignal : Signal;
		private var _autoPlay : Boolean = true;
		private var _repeat : Boolean = true;
		private var _buffer : Number = 1;
		private var _volume : Number = 0.5;
		private var _vpc : VideoPlayback;
		private var vidURL : String;
		private var _video : Video;
		private var _isDragging : Boolean = false;
		private var firstPlay : Boolean = true;
		private var _tltTime : Number = -1;
		//} endregion
		
		//{ region CONSTRUCTOR
		public function LocalVideoPlayer() 
		{
			this.visible = false;
			this.alpha = 0;
			_videoSignal = new Signal(String);
		}
		//} endregion
		
		//{ region EVENT HANDLERS/////////////////////////////////////////////////////////////////////////////
		
		//{ region BUFF START HANDLER
		private final function buffStartHandler(e:MediaBufferingEvent):void 
		{
			_videoSignal.dispatch("BUFFER ON");
		}
		//} endregion
		
		//{ region BUFF PROGRESS HANDLER
		/*private final function buffProgressHandler(e:MediaBufferingEvent):void 
		{
			//...
		}*/
		//} endregion
		
		//{ region BUFF END HANDLER
		private final function buffEndHandler(e:MediaBufferingEvent):void 
		{
			_videoSignal.dispatch("BUFFER OFF");
		}
		//} endregion
		
		//{ region LOAD START HANDLER
		/*private final function loadStartHandler(e:MediaLoadEvent):void 
		{
			_videoSignal.dispatch("LOADING START");
		}*/
		//} endregion
		
		//{ region LOAD PROGRESS HANDLER
		private final function loadProgressHandler(e:MediaLoadEvent):void 
		{
			_videoSignal.dispatch("LOADING PROGRESS");
		}
		//} endregion
		
		//{ region LOAD COMPLETE HANDLER
		private final function loadCompleteHandler(e:MediaLoadEvent):void 
		{
			//_videoSignal.dispatch("LOADING COMPLETE");
			_vpc.removeEventListener(MediaLoadEvent.LOAD_PROGRESS, loadProgressHandler);
			_vpc.removeEventListener(MediaLoadEvent.LOAD_COMPLETE, loadCompleteHandler);
		}
		//} endregion
		
		//{ region PLAYBACK COMPLETE HANDLER
		private final function playBackCompleteHandler(e:MediaPlaybackEvent):void 
		{
			if (!isDragging) 
			{
				if (_repeat)
				{
					_vpc.replay();
				}else 
				{
					_vpc.stop();
					/*_vpc.seek(0);
					_vpc.pause();*/
				}
				
				//firstPlay = true;
				//vpc.totalTime = tltTime;
				_videoSignal.dispatch("PLB COMPLETE");
			}
		}
		//} endregion
		
		//{ region PLAYBACK READY HANDLER
		private final function playBackReadyHandler(e:MediaPlaybackEvent):void 
		{
			_videoSignal.dispatch("PLB RDY");
		}
		//} endregion
		
		//{ region PLAYBACK START HANDLER
		private final function playBackStartHandler(e:MediaPlaybackEvent):void 
		{
			if (firstPlay && vpc.totalTime != 0) 
			{
				firstPlay = false;
				tltTime = vpc.totalTime;
			}
			_videoSignal.dispatch("PLAY");
		}
		//} endregion
		
		//{ region PLAYBACK STOP HANDLER
		private final function playBackStopHandler(e:MediaPlaybackEvent):void 
		{
			_videoSignal.dispatch("PAUSE");
		}
		//} endregion
		
		//{ region PLAYBACK TIME UPDATE HANDLER
		private final function playBackTimeUpdateHandler(e:MediaPlaybackEvent):void 
		{
			_videoSignal.dispatch("TIME UPDATE");
			//trace("[INFO]:", e.currentTime, e.totalTime);
		}
		//} endregion
		
		//{ region PLAYBACK ERROR HANDLER
		private final function errorHandler(e:MediaErrorEvent):void 
		{
			trace("[ERROR]: Playback error: " +  e.message);
			_videoSignal.dispatch("ERROR");
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS///////////////////////////////////////////////////////////////////////////////////
		
		//{ region START ME
		internal final function StartMe(pVidURL : String = ""):void 
		{
			vidURL = pVidURL;
			
			_video = new Video();
			_video.x = 
			_video.y = 0;
			
			_video.visible = false;
			_video.alpha = 0;
			
			this.addChild(_video);
			
			_vpc = new VideoPlayback(_video);
			
			//<start>listeners
			_vpc.addEventListener(MediaBufferingEvent.BUFFERING_START, buffStartHandler, false, 0, true);
			//_vpc.addEventListener(MediaBufferingEvent.BUFFERING_PROGRESS, buffProgressHandler, false, 0, true);
			_vpc.addEventListener(MediaBufferingEvent.BUFFERING_END, buffEndHandler, false, 0, true);
			
			//_vpc.addEventListener(MediaLoadEvent.LOAD_START, loadStartHandler, false, 0, true);
			_vpc.addEventListener(MediaLoadEvent.LOAD_PROGRESS, loadProgressHandler, false, 0, true);
			_vpc.addEventListener(MediaLoadEvent.LOAD_COMPLETE, loadCompleteHandler, false, 0, true);
			
			_vpc.addEventListener(MediaPlaybackEvent.PLAYBACK_COMPLETE, playBackCompleteHandler, false, 0, true);
			_vpc.addEventListener(MediaPlaybackEvent.PLAYBACK_READY, playBackReadyHandler, false, 0, true);
			
			_vpc.addEventListener(MediaPlaybackEvent.PLAYBACK_START, playBackStartHandler, false, 0, true);
			_vpc.addEventListener(MediaPlaybackEvent.PLAYBACK_STOP, playBackStopHandler, false, 0, true);
			
			_vpc.addEventListener(MediaPlaybackEvent.PLAYBACK_TIME_UPDATE, playBackTimeUpdateHandler, false, 0, true);
			
			_vpc.addEventListener(MediaErrorEvent.ERROR, errorHandler, false, 0, true);
			//<end>
			
			//<start>controller settings
			_vpc.volume = _volume;
			_vpc.autoPlay = _autoPlay;
			//_vpc.repeat = _repeat;
			_vpc.buffer = _buffer;
			
			//_vpc.rewind = true;
			_vpc.repeat = false;
			_vpc.rewind = false;
			//<end>
			
			_vpc.load(vidURL);
		}
		//} endregion
		
		//{ region DESTROY
		internal function Destroy():void 
		{
			this.removeChild(_video);
			_video = null;
			_vpc.stop();
			
			_vpc.removeEventListener(MediaBufferingEvent.BUFFERING_START, buffStartHandler);
			//_vpc.removeEventListener(MediaBufferingEvent.BUFFERING_PROGRESS, buffProgressHandler);
			_vpc.removeEventListener(MediaBufferingEvent.BUFFERING_END, buffEndHandler);
			
			//_vpc.removeEventListener(MediaLoadEvent.LOAD_START, loadStartHandler);
			_vpc.removeEventListener(MediaLoadEvent.LOAD_PROGRESS, loadProgressHandler);
			_vpc.removeEventListener(MediaLoadEvent.LOAD_COMPLETE, loadCompleteHandler);
			
			_vpc.removeEventListener(MediaPlaybackEvent.PLAYBACK_COMPLETE, playBackCompleteHandler);
			_vpc.removeEventListener(MediaPlaybackEvent.PLAYBACK_READY, playBackReadyHandler);
			
			_vpc.removeEventListener(MediaPlaybackEvent.PLAYBACK_START, playBackStartHandler);
			_vpc.removeEventListener(MediaPlaybackEvent.PLAYBACK_STOP, playBackStopHandler);
			
			_vpc.removeEventListener(MediaPlaybackEvent.PLAYBACK_TIME_UPDATE, playBackTimeUpdateHandler);
			
			_vpc.removeEventListener(MediaErrorEvent.ERROR, errorHandler);
			_vpc.totalTime = 0;
			_vpc.destroy();
			_vpc = null;
			
			this.parent.removeChild(this);
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		internal function get vpc():VideoPlayback { return _vpc; }
		internal function set vpc(value:VideoPlayback):void 
		{
			_vpc = value;
		}
		
		internal function get volume():Number { return _volume; }
		internal function set volume(value:Number):void 
		{
			_volume = value;
		}
		
		internal function get buffer():Number { return _buffer; }
		internal function set buffer(value:Number):void 
		{
			_buffer = value;
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
		
		internal function get videoSignal():Signal { return _videoSignal; }
		internal function set videoSignal(value:Signal):void 
		{
			_videoSignal = value;
		}
		
		internal function get video():Video { return _video; }
		internal function set video(value:Video):void 
		{
			_video = value;
		}
		
		internal function get isDragging():Boolean { return _isDragging; }
		internal function set isDragging(value:Boolean):void 
		{
			_isDragging = value;
		}
		
		internal function get tltTime():Number { return _tltTime; }
		internal function set tltTime(value:Number):void 
		{
			_tltTime = value;
		}
		//} endregion
	}
}