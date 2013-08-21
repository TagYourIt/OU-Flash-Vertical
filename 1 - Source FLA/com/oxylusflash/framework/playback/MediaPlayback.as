package com.oxylusflash.framework.playback
{
	import com.oxylusflash.framework.core.DestructibleEventDispatcher;
	import com.oxylusflash.framework.events.*;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * Media playback implementation
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class MediaPlayback extends DestructibleEventDispatcher implements IMediaPlayback
	{
		protected var _buffering:Boolean = false;
		protected var _loaded:Boolean = false;
		protected var _ready:Boolean = false;
		protected var _playing:Boolean = false;
		protected var _complete:Boolean = false;
		protected var _totalTime:Number = 0;
		protected var _currentTime:Number = 0;
		protected var _totalBytes:Number = 0;
		protected var _loadedBytes:Number = 0;
		protected var _buffer:Number = 1;
		protected var _autoPlay:Boolean = true;
		protected var _repeat:Boolean = false;
		protected var _rewind:Boolean = true;
		protected var _volume:Number = 0.75;
		protected var _media:String;
		
		protected var checkMethods:Array;
		protected var checkTimer:Timer = new Timer(33);
		
		/* Media placybak object */
		public function MediaPlayback()
		{
			checkTimer.addEventListener(TimerEvent.TIMER, checkTimer_timerHandler, false, 0, true);
		}
		
		/* Check timer event handler */
		private function checkTimer_timerHandler(e:TimerEvent):void
		{
			if (checkMethods)
			{
				for each(var method:Function in checkMethods) method.call(this);
			}
		}
		
		/* Stop playback and clear media */
		public function clear():void
		{
			stop();
			
			if (checkTimer && checkTimer.running) checkTimer.reset();
			if (checkMethods) checkMethods = null;
			
			if (_totalTime != 0 || _currentTime != 0)
			{
				_totalTime = _currentTime = 0;
				dispatchEvent(new MediaPlaybackEvent(MediaPlaybackEvent.PLAYBACK_TIME_UPDATE, _totalTime, _currentTime));
			}
			
			if (_totalBytes != 0 || _loadedBytes != 0)
			{
				_totalBytes = 0;
				_loadedBytes = 0;
				dispatchEvent(new MediaLoadEvent(MediaLoadEvent.LOAD_PROGRESS, _totalBytes, _loadedBytes));
			}
			
			if (_buffering)
			{
				_buffering = false;
				dispatchEvent(new MediaBufferingEvent(MediaBufferingEvent.BUFFERING_PROGRESS, _buffer, _buffer));
				dispatchEvent(new MediaBufferingEvent(MediaBufferingEvent.BUFFERING_END, _buffer, _buffer));
			}
			
			_loaded = false;
			_ready = false;
			_complete = false;
			
			if (_media)
			{
				mediaClear();
				_media = null;
			}
		}
		
		/**
		 * Load media
		 * @param	media	Media URL as string
		 */
		public function load(media:String):void
		{
			//if (_media != media)
			//{
				clear();
				
				_media = media;
				dispatchEvent(new MediaPropsChangeEvent(MediaPropsChangeEvent.MEDIA_CHANGE, _volume, _autoPlay, _repeat, _rewind, _media, _buffer));
				
				mediaLoad(_media);
				dispatchEvent(new MediaLoadEvent(MediaLoadEvent.LOAD_START, _totalBytes, _loadedBytes));
				dispatchEvent(new MediaLoadEvent(MediaLoadEvent.LOAD_PROGRESS, _totalBytes, _loadedBytes));
				
				_buffering = true;
				dispatchEvent(new MediaBufferingEvent(MediaBufferingEvent.BUFFERING_START, _buffer, 0));
				dispatchEvent(new MediaBufferingEvent(MediaBufferingEvent.BUFFERING_PROGRESS, _buffer, 0));
			//}
		}
		
		/* Make playback ready */
		protected function makeReady():void
		{
			if (!_ready)
			{
				if (_autoPlay) play();
				else if (_playing) mediaPlay();
				
				if (!checkTimer.running) checkTimer.start();
				
				_ready = true;
				dispatchEvent(new MediaPlaybackEvent(MediaPlaybackEvent.PLAYBACK_READY, _totalTime, _currentTime));
			}
		}
		
		/* Play media */
		public function play():void
		{
			if (!_rewind && _complete) replay();
			else if (!_playing && _media)
			{
				if (_ready) mediaPlay();
				_playing = true;
				dispatchEvent(new MediaPlaybackEvent(MediaPlaybackEvent.PLAYBACK_START, _totalTime, _currentTime));
			}
		}
		
		/* Pause media */
		public function pause():void
		{
			if (_playing && _media)
			{
				if (_ready) mediaPause();
				_playing = false;
				dispatchEvent(new MediaPlaybackEvent(MediaPlaybackEvent.PLAYBACK_STOP, _totalTime, _currentTime));
			}
		}
		
		/* Stop media */
		public function stop():void
		{
			if (_playing && _media)
			{
				if (_ready) mediaStop();
				_playing = false;
				dispatchEvent(new MediaPlaybackEvent(MediaPlaybackEvent.PLAYBACK_STOP, _totalTime, _currentTime));
			}
			else seek(0);
		}
		
		/**
		 * Seek media
		 * @param	to			To time value
		 * @param	percent		Time as percentage
		 */
		public function seek(to:Number, percent:Boolean = true):void
		{
			if (_complete) _complete = false;
			if (_ready && _media)
			{
				var seekTime:Number = Math.max(0, Math.min(totalTime - 1, percent ? _totalTime * Math.max(0, Math.min(1, to)) : to));
				if (seekTime != _currentTime) mediaSeek(seekTime);
			}
		}
		
		/* Play media from the begining */
		public function replay():void
		{
			seek(0);
			play();
		}
		
		/* Media is buffering */
		public function get buffering():Boolean { return _buffering; }
		
		/* Media is loaded */
		public function get loaded():Boolean { return _loaded; }
		
		/* Media is ready for playback */
		public function get ready():Boolean { return _ready; }
		
		/* Media is playing */
		public function get playing():Boolean { return _playing; }
		
		/* Media total playback time in seconds */
		public function get totalTime():Number { return _totalTime; }
		public function set totalTime(value:Number):void { _totalTime = value; }
		
		/* Media total bytes */
		public function get totalBytes():Number { return _totalBytes; }
		
		/* Media loaded bytes */
		public function get loadedBytes():Number { return _loadedBytes; }
		
		/* Media current playback time in seconds */
		public function get currentTime():Number { return _currentTime; }
		public function set currentTime(value:Number):void
		{
			seek(value, false);
		}
		
		/* Media playback buffer time */
		public function get buffer():Number { return _buffer; }
		public function set buffer(value:Number):void
		{
			value = Math.max(0, value);
			if (_buffer != value)
			{
				_buffer = value;
				updateBuffer(_buffer);
				dispatchEvent(new MediaPropsChangeEvent(MediaPropsChangeEvent.BUFFER_CHANGE, _volume, _autoPlay, _repeat, _rewind, _media, _buffer));
			}
		}
		
		/* Media will auto play when ready, after a load action */
		public function get autoPlay():Boolean { return _repeat; }
		public function set autoPlay(value:Boolean):void
		{
			if (_autoPlay != value)
			{
				_autoPlay = value;
				dispatchEvent(new MediaPropsChangeEvent(MediaPropsChangeEvent.AUTO_PLAY_CHANGE, _volume, _autoPlay, _repeat, _rewind, _media, _buffer));
			}
		}
		
		/* Media will start from the begining when playback ends */
		public function get repeat():Boolean { return _repeat; }
		public function set repeat(value:Boolean):void
		{
			if (_repeat != value)
			{
				_repeat = value;
				dispatchEvent(new MediaPropsChangeEvent(MediaPropsChangeEvent.REPEAT_CHANGE, _volume, _autoPlay, _repeat, _rewind, _media, _buffer));
			}
		}
		
		/* Media will reset to the begining when playback ends */
		public function get rewind():Boolean { return _rewind; }
		public function set rewind(value:Boolean):void
		{
			if (_rewind != value)
			{
				_rewind = value;
				dispatchEvent(new MediaPropsChangeEvent(MediaPropsChangeEvent.REPEAT_CHANGE, _volume, _autoPlay, _repeat, _rewind, _media, _buffer));
			}
		}
		
		/* Media playback volume */
		public function get volume():Number { return _volume; }
		public function set volume(value:Number):void
		{
			value = Math.max(0, Math.min(1, value));
			if (_volume != value)
			{
				_volume = value;
				updateVolume(_volume);
				dispatchEvent(new MediaPropsChangeEvent(MediaPropsChangeEvent.VOLUME_CHANGE, _volume, _autoPlay, _repeat, _rewind, _media, _buffer));
			}
		}
		
		/* Media source */
		public function get media():String { return _media; }
		public function set media(value:String):void
		{
			load(value);
		}
		
		/* Specific media clear */
		protected function mediaClear():void { }
		
		/* Specific media load */
		protected function mediaLoad(media:String):void { }
		
		/* Specific media play */
		protected function mediaPlay():void { }
		
		/* Specific media pause */
		protected function mediaPause():void { }
		
		/* Specific media stop */
		protected function mediaStop():void { }
		
		/* Specific media seek */
		protected function mediaSeek(seekTime:Number):void { }
		
		/* Specific media buffer update */
		protected function updateBuffer(value:Number):void { }
		
		/* Specific media volume update */
		protected function updateVolume(value:Number):void { }
		
		/* Periodically check media load */
		protected function checkLoad():void
		{
			dispatchEvent(new MediaLoadEvent(MediaLoadEvent.LOAD_PROGRESS, _totalBytes, _loadedBytes));
			if (_loadedBytes == _totalBytes && _totalBytes > 0)
			{
				_loaded = true;
				checkMethods = [checkTime];
				dispatchEvent(new MediaLoadEvent(MediaLoadEvent.LOAD_COMPLETE, _totalBytes, _loadedBytes));
			}
		}
		
		/* Periodically check media buffer status */
		protected function checkBuffer():void
		{
			_buffering = false;
			dispatchEvent(new MediaBufferingEvent(MediaBufferingEvent.BUFFERING_PROGRESS, _buffer, _buffer));
			dispatchEvent(new MediaBufferingEvent(MediaBufferingEvent.BUFFERING_END, _buffer, _buffer));
		}
		
		/* Periodically check media playback time */
		protected function checkTime():void
		{
			dispatchEvent(new MediaPlaybackEvent(MediaPlaybackEvent.PLAYBACK_TIME_UPDATE, _totalTime, _currentTime));
		}
		
		/* Destroy media playback object (prepares it for garbage collection) */
		override public function destroy():void
		{
			clear();
			
			checkMethods = null;
			if (checkTimer && checkTimer.hasEventListener(TimerEvent.TIMER)) 
			{
				checkTimer.removeEventListener(TimerEvent.TIMER, checkTimer_timerHandler);
				checkTimer = null;
			}
			
			super.destroy();
		}

	}

}
