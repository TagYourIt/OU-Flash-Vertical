/* @author: Adrian Bota, adrian@oxylus.ro
 * @version: 23/01/10 (mm/dd/yy)
 * 
 * METHODS:
 * --------
 * (!) also check methods of the "EventDispatcher" class
 * reset() - stops playback and resets everything
 * load(mediaURL:String) - load media
 * play() - play loaded media
 * pause() - pause playback
 * stop() - stop playback
 * replay() - play from the begining
 * seek(seekValue:Number, usePercentage:Boolean = true) - seek to time value or percentage
 * getTimeString(ts:Number) - returns a formatted string of the given time in seconds (e.g. 74 sec -> 01:14)
 * 
 * PROPERTIES:
 * -----------
 * (!) also check properties of the "EventDispatcher" class
 * isReady [Boolean][readonly] - check if media is ready for playback
 * isPlaying [Boolean][readonly] - check if media is playing
 * isBuffering [Boolean][readonly] - check if media is buffering
 * autoPlay [Boolean] - if true, media will start playing after a load call
 * repeat [Boolean] - if true, media will repeat after playback complete
 * volume [Number] - set the volume between (0, 1) 
 * totalTime [Number][readonly] - get total playback time
 * currentTime [Number] - get or set current playback position
 * totalBytes [Number][readonly] - get total bytes
 * loadedBytes [Number][readonly] - get loaded bytes
 * bufferTime [Number] - get or set the buffer time in seconds
 * isLoaded [Boolean][readonly] - check if media is completly loaded or not
 * media [String] - get or set media url for playback
 * 
 */

package com.oxylusflash.AVPlayback 
{
	import com.oxylusflash.AVPlayback.events.PlaybackEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;	
	import flash.utils.Timer;
	
	public class PlaybackController extends EventDispatcher
	{
		protected var _isReady:Boolean;
		protected var _isPlaying:Boolean;
		protected var _isBuffering:Boolean;
		protected var _autoPlay:Boolean = false;
		protected var _repeat:Boolean = false;	
		protected var _volume:Number = 0.75;	
		protected var _totalTime:Number;
		protected var _currentTime:Number;	
		protected var _totalBytes:Number;
		protected var _loadedBytes:Number;
		protected var _bufferTime:Number = 1;		
		protected var _isLoaded:Boolean;
		protected var _media:String;
		
		protected var thingsToCheck:Array;
		protected var checkTimer:Timer;		
		protected static const CHECK_INTERVAL:Number = 33;
		
		public function PlaybackController() 
		{
			checkTimer = new Timer(CHECK_INTERVAL);
			checkTimer.addEventListener(TimerEvent.TIMER, checkTimer_timerHandler, false, 0, true);
			
			reset();
		}
		
		/// START METHODS
		
		/**
		 * Reset media playback controller.
		 */
		public function reset():void
		{
			checkTimer.reset();
			thingsToCheck = null;
			
			stop();
			
			_isReady 		= false;
			_isPlaying 		= false;
			_isBuffering 	= false;
			_totalTime 		= 0;
			_currentTime 	= 0;
			_totalBytes 	= 0;
			_loadedBytes 	= 0;
			_isLoaded 		= false;
			_media 			= null;
			
			dispatchEvent(new PlaybackEvent(PlaybackEvent.PLAYBACK_TIME_UPDATE, getTimeUpdateParams()));
			dispatchEvent(new PlaybackEvent(PlaybackEvent.LOAD_PROGRESS, getLoadProgressParams()));
			dispatchEvent(new PlaybackEvent(PlaybackEvent.BUFFER_PROGRESS, getBufferProgressParams()));
			dispatchEvent(new PlaybackEvent(PlaybackEvent.BUFFER_FULL, getDefaultParams()));			
			
			doReset();
		}
		
		/**
		 * Load media for playback.
		 * @param	mediaURL 	Media URL as string.
		 */
		public function load(mediaURL:String):void
		{
			reset();
			
			_isBuffering = true;
			_isPlaying = _autoPlay;
			
			dispatchEvent(new PlaybackEvent(PlaybackEvent.BUFFER_PROGRESS, getBufferProgressParams(0)));
			dispatchEvent(new PlaybackEvent(PlaybackEvent.BUFFERING, getDefaultParams()));
			dispatchEvent(new PlaybackEvent(_autoPlay ? PlaybackEvent.PLAYBACK_START : PlaybackEvent.PLAYBACK_STOP, getDefaultParams()));
			
			_media = mediaURL;
			
			doLoad();
		}
		
		/**
		 * Start media playback.
		 */
		public function play():void
		{
			if (_isReady && !_isPlaying)
			{
				doPlay();
			
				_isPlaying = true;
				dispatchEvent(new PlaybackEvent(PlaybackEvent.PLAYBACK_START, getDefaultParams()));
			}
		}
		
		/**
		 * Pause media playback.
		 */
		public function pause():void
		{
			if (_isReady && _isPlaying)
			{
				doPause();
				
				_isPlaying = false;
				dispatchEvent(new PlaybackEvent(PlaybackEvent.PLAYBACK_STOP, getDefaultParams()));
			}
		}
		
		/**
		 * Stop media playback. 
		 */
		public function stop():void 
		{
			if (_isReady)
			{
				doStop();
				
				_isPlaying = false;
				dispatchEvent(new PlaybackEvent(PlaybackEvent.PLAYBACK_STOP, getDefaultParams()));
			}
		}
		
		/** 
		 * Start media playback from the begining. 
		 */
		public function replay():void
		{
			if (_isReady)
			{
				doReplay();
				
				_isPlaying = true;
				dispatchEvent(new PlaybackEvent(PlaybackEvent.PLAYBACK_START, getDefaultParams()));
			}
		}
		
		/**
		 * Media playback seek to time or percentage.
		 * @param	seekValue		Time in seconds or percentage of total time.
		 * @param	usePercentage	If true, seekValue will be treated as pecentage.
		 */
		public function seek(seekValue:Number, usePercentage:Boolean = true):void
		{
			if (_isReady)
			{
				doSeek(Math.max(0, Math.min(_totalTime - 1, usePercentage ? seekValue * _totalTime : seekValue)));
			}
		}
		
		/**
		 * Convert time from seconds to formatted string.
		 * @param	ts	Time in seconds.
		 * @return	Time string formatted as mm:ss.
		 */
		public function getTimeString(ts:Number):String 
		{
			ts 				= Math.round(ts);
			var hrs:Number 	= Math.floor(ts / 3600);
			var min:Number 	= Math.floor((ts % 3600) / 60);
			var sec:Number 	= Math.round((ts % 3600) % 60);
			
			var hrsStr:String = (hrs < 10 ? "0" : "") + String(hrs); 
			var minStr:String = (min < 10 ? "0" : "") + String(min); 
			var secStr:String = (sec < 10 ? "0" : "") + String(sec);
			
			if (hrs > 0) 	return hrsStr + ":" + minStr + ":" + secStr;
			else 			return minStr + ":" + secStr;
		}
		
		/// END METHODS
		
		/// START PROPERTIES
		
		/* [read-only] Check if media is ready for playback. */
		public function get isReady():Boolean { return _isReady; }
		
		/* [read-only] Check if media is playing. */
		public function get isPlaying():Boolean { return _isPlaying; }
		
		/* [read-only] Check if media is buffering. */
		public function get isBuffering():Boolean { return _isBuffering; }
		
		/* If true, media will play after loading. */
		public function get autoPlay():Boolean { return _autoPlay; }		
		public function set autoPlay(value:Boolean):void 
		{
			_autoPlay = value;
		}
		
		/* If true, media will start from the begining after playback is complete. */
		public function get repeat():Boolean { return _repeat; }		
		public function set repeat(value:Boolean):void 
		{
			_repeat = value;
		}
		
		/* Media volume percentage [0, 1]. */
		public function get volume():Number { return _volume; }		
		public function set volume(value:Number):void 
		{
			_volume = Math.max(0, Math.min(1, value));
		}
		
		/* [read-only] Media total playback time in seconds. */
		public function get totalTime():Number { return _totalTime; }
		
		/* Media current playback time in seconds. */
		public function get currentTime():Number { return _currentTime; }		
		public function set currentTime(value:Number):void 
		{
			seek(value, false);
		}
		
		/* [read-only] Media total bytes. */
		public function get totalBytes():Number { return _totalBytes; }
		
		/* [read-only] Media load bytes. */
		public function get loadedBytes():Number { return _loadedBytes; }
		
		/* Media buffer time in seconds. */
		public function get bufferTime():Number { return _bufferTime; }		
		public function set bufferTime(value:Number):void 
		{
			_bufferTime = value;
		}
		
		/* Media url string. */
		public function get media():String { return _media; }		
		public function set media(value:String):void 
		{
			load(value);
		}
		
		/// PROTECTED
		protected function doReset():void { }		
		protected function doLoad():void { }		
		protected function doPlay(startTime:Number = -1):void { }	
		protected function doPause():void { }	
		protected function doStop():void { }	
		protected function doReplay():void { }		
		protected function doSeek(position:Number):void { }
		
		protected function checkTimer_timerHandler(event:TimerEvent):void 
		{ 
			checkThings();
		}
		
		protected function checkThings():void {
			for each(var func:Function in thingsToCheck)
			{
				func.call(this);
			}
		}
		
        /* Events parameters. */
		protected function getTimeUpdateParams():Object 
		{
            var params:Object = getDefaultParams();
            params.totalTime = _totalTime;
            params.currentTime = _currentTime;
            params.totalTimeString = getTimeString(_totalTime);
            params.currentTimeString = getTimeString(_currentTime);
            
			return params;
		}
		protected function getLoadProgressParams():Object 
		{
            var params:Object = getDefaultParams();
            params.totalBytes = _totalBytes;
            params.loadedBytes = _loadedBytes;
            
			return params;
		}
		protected function getDefaultParams():Object
		{
			return { target: this };
		}
        protected function getBufferProgressParams(progress:Number = 1):Object
        {
            var params:Object = getDefaultParams();
            params.progress = Math.max(0, Math.min(1, progress));
            return params;
        }
		protected function getErrorParams(message:String):Object
		{
			var params:Object = getDefaultParams();
            params.message = message;
            return params;
		}
 	}
}