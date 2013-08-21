/* @author: Adrian Bota, adrian@oxylus.ro
 * @version: 23/01/10 (mm/dd/yy)
 * 
 * METHODS:
 * --------
 * (!) check methods of the "PlaybackController" class
 * 
 * PROPERTIES:
 * -----------
 * (!) also check propeties of the "PlaybackController" class
 * soundInstance [Sound][readonly] - returns the "Sound" instance
 * channelInstance [SoundChannel][readonly] - returns the "SoundChannel" instance
 * artist [String][readonly] - get artist name string
 * album [String][readonly] - get album name string
 * songName [String][readonly] - get song name string
 * 
 */

package com.oxylusflash.AVPlayback 
{
	import com.oxylusflash.AVPlayback.PlaybackController;
	import com.oxylusflash.AVPlayback.events.PlaybackEvent;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;	
	import flash.net.URLRequest;
	
	public class AudioPlaybackController extends PlaybackController 
	{
		private var soundObj:Sound;
		private var soundChn:SoundChannel;
		private var soundLdC:SoundLoaderContext;
		
		private var storedCurrentTime:Number = 0;
		
		private var _artist:String = "";
		private var _album:String = "";
		private var _songName:String = "";
		
		public function AudioPlaybackController() { }
		
		/// PRIVATE METHODS
		
		override protected function doReset():void 
		{
			storedCurrentTime = 0;
			
			_artist = "";
			_album = "";
			_songName = "";
			
			try
			{
				soundObj.close();
				soundObj.removeEventListener(ProgressEvent.PROGRESS, soundObj_progressHandler);
				soundObj.removeEventListener(Event.COMPLETE, soundObj_completeHandler);
				soundObj.removeEventListener(IOErrorEvent.IO_ERROR, soundObj_ioErrorHandler);
				soundObj.removeEventListener(Event.OPEN, sounObj_openHandler);
				soundObj.removeEventListener(Event.ID3, soundObj_id3Handler);
			}
			catch (error:Error) { }
			
			soundChn = null;
			soundObj = null;
		}
		
		override protected function doLoad():void
		{
			soundObj = new Sound();
			
			soundObj.addEventListener(IOErrorEvent.IO_ERROR, soundObj_ioErrorHandler, false, 0, true);
			soundObj.addEventListener(Event.OPEN, sounObj_openHandler, false, 0, true);
			soundObj.addEventListener(Event.ID3, soundObj_id3Handler, false, 0, true);
			soundObj.addEventListener(ProgressEvent.PROGRESS, soundObj_progressHandler, false, 0, true);
			soundObj.addEventListener(Event.COMPLETE, soundObj_completeHandler, false, 0, true);
			
			thingsToCheck = [checkTimeUpdate, checkBufferStatus];			
			soundObj.load(new URLRequest(_media), new SoundLoaderContext(_bufferTime * 1000));
		}
		
		override protected function doPlay(startTime:Number = -1):void 
		{
			try
			{
				soundChn.stop();
				soundChn.removeEventListener(Event.SOUND_COMPLETE, soundChn_completeHandler);
			}
			catch (error:Error) { }
			
			soundChn = null;
			soundChn = soundObj.play((startTime < 0 ? storedCurrentTime : startTime) * 1000, 0, new SoundTransform(_volume));
			soundChn.addEventListener(Event.SOUND_COMPLETE, soundChn_completeHandler, false, 0, true);
		}
		
		override protected function doPause():void
		{
			if (soundChn)
				soundChn.stop();
		}
		
		override protected function doStop():void 
		{
			doReplay();
			doPause();
		}
		
		override protected function doReplay():void
		{
			doPlay(0);
		}
		
		override protected function doSeek(position:Number):void
		{
			if (!_isLoaded && position * 1000 > soundObj.length)
				position = soundObj.length / 1000;
			
			storedCurrentTime = position;
			
			if (_isPlaying)
				doPlay();
		}
		
		/// EVENT HANDLERS
		private function soundObj_ioErrorHandler(event:IOErrorEvent):void 
		{
			dispatchEvent(new PlaybackEvent(PlaybackEvent.ERROR, getErrorParams(event.text)));
			reset();
		}
		
		private function sounObj_openHandler(event:Event):void 
		{
			checkTimer.start();
		}
		
		private function soundObj_progressHandler(event:ProgressEvent):void 
		{
			var totBytes:Number = event.bytesTotal;		
			var lodBytes:Number = event.bytesLoaded;		
			
			if (_totalBytes != totBytes || _loadedBytes != lodBytes) 
			{
				_totalBytes  = totBytes;
				_loadedBytes = lodBytes;
				
				dispatchEvent(new PlaybackEvent(PlaybackEvent.LOAD_PROGRESS, getLoadProgressParams()));
			}
		}
		
		private function soundObj_completeHandler(event:Event):void 
		{
			_isLoaded = true;
			thingsToCheck = [checkTimeUpdate];
			
			if (_isBuffering)
			{
				_isBuffering = false;
				dispatchEvent(new PlaybackEvent(PlaybackEvent.BUFFER_FULL, getDefaultParams()));
			}
			
			dispatchEvent(new PlaybackEvent(PlaybackEvent.BUFFER_PROGRESS, getBufferProgressParams()));			
		}
		
		private function soundObj_id3Handler(event:Event):void 
		{
			_artist = soundObj.id3.artist;
			_album = soundObj.id3.album;
			_songName = soundObj.id3.songName;
			
			var params:Object = getDefaultParams();
			params.id3 = soundObj.id3;
			
			dispatchEvent(new PlaybackEvent(PlaybackEvent.MP3_ID3, params));
		}
		
		private function soundChn_completeHandler(event:Event):void 
		{
			storedCurrentTime = 0;
			
			dispatchEvent(new PlaybackEvent(PlaybackEvent.PLAYBACK_COMPLETE, getDefaultParams()));
			
			if (_repeat)
				replay();
			else 
				stop();
		}
		
		/// OTHER METHODS
		private function checkTimeUpdate():void 
		{	
			if (!_isReady && _totalTime > 0 && soundObj.length >= (_bufferTime * 1000)) 
			{
				_isReady = true;				
				dispatchEvent(new PlaybackEvent(PlaybackEvent.PLAYBACK_READY, getDefaultParams()));
				
				if (_autoPlay) 	
					doPlay(0);
			}			
			
			var crtTime:Number = storedCurrentTime;
			if (soundChn && _isPlaying) {
				crtTime = soundChn.position / 1000;
			}
			
			var totTime:Number = soundObj.length / 1000;
			if (!_isLoaded) 
				totTime *= _totalBytes / _loadedBytes;

			if (isNaN(totTime) || (!_isLoaded && Math.abs(totTime - _totalTime) <= _bufferTime)) 
				totTime = _totalTime;		
			
			if (_currentTime != crtTime || _totalTime != totTime) 
			{
				_currentTime = crtTime;
				_totalTime 	 = totTime;
				
				storedCurrentTime = _currentTime;
				
				if (_totalTime < _currentTime) _totalTime = _currentTime;
				
				dispatchEvent(new PlaybackEvent(PlaybackEvent.PLAYBACK_TIME_UPDATE, getTimeUpdateParams()));
			}
		}
		
		private function checkBufferStatus():void
		{
			var soundChn_pos:Number = 0;
			if (soundChn) soundChn_pos = soundChn.position;
			
			var playLen:Number = (soundObj.length - soundChn_pos) / 1000;
			
			if (playLen <= _bufferTime)
			{
				if (!_isBuffering) 
				{
					_isBuffering = true;
					dispatchEvent(new PlaybackEvent(PlaybackEvent.BUFFERING, getDefaultParams()));
				}
				
				dispatchEvent(new PlaybackEvent(PlaybackEvent.BUFFER_PROGRESS, getBufferProgressParams(playLen / _bufferTime))); 
			}
			else 
			{
				if (_isBuffering) 
				{
					_isBuffering = false;
					
					dispatchEvent(new PlaybackEvent(PlaybackEvent.BUFFER_FULL, getDefaultParams()));
					dispatchEvent(new PlaybackEvent(PlaybackEvent.BUFFER_PROGRESS, getBufferProgressParams())); 
				}
			}
		}
		
		/// PROPERTIES
		override public function set volume(value:Number):void 
		{
			super.volume = value;
			try
			{
				soundChn.soundTransform = new SoundTransform(_volume);
			}
			catch(error:Error) { }
		}
		
		/* Get Sound instance. */
		public function get soundInstance():Sound { return soundObj; }
		
		/* Get current SoundChannel instance. */
		public function get channelInstance():SoundChannel { return soundChn; }
		
		/* Get artist name. */
		public function get artist():String { return _artist; }
		
		/* Get album name. */
		public function get album():String { return _album; }
		
		/* Get song name. */
		public function get songName():String { return _songName; }
	}
}