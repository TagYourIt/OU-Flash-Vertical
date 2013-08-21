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
 * netStreamInstance [NetStream][readonly] - returns the "NetStream" instance
 * originalVideoWidth [Number][readonly] - original video width
 * originalVideoHeight [Number][readonly] - original video height
 * 
 */

package com.oxylusflash.AVPlayback
{
	import com.oxylusflash.AVPlayback.PlaybackController;
	import com.oxylusflash.AVPlayback.events.PlaybackEvent;
	import flash.net.URLRequest;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;	
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.utils.Timer;	
	import flash.net.NetConnection;
	import flash.net.NetStream;	
	
	public class VideoPlaybackController extends PlaybackController
	{
		private var netStrm:NetStream;
		private var netConn:NetConnection;
		private var video:Video;
		private var metadata:Object;
		
		private var _originalVideoWidth:Number = 0;
		private var _originalVideoHeight:Number = 0;
		
		private var sizeListenTimer:Timer;
		
		/**
		 * Create instance.
		 * @param	videoInstance Video instance.
		 */
		public function VideoPlaybackController(videoInstance:Video) 
		{
			video = videoInstance;
			
			netConn = new NetConnection();
			netConn.connect(null);
			
			metadata = new Object();
			metadata.onMetaData = netStrm_metadataHandler;
			
			netStrm = new NetStream(netConn);			
			netStrm.client = metadata;
			netStrm.addEventListener(NetStatusEvent.NET_STATUS, netStrm_netStatusHandler, false, 0, true);
			netStrm.addEventListener(IOErrorEvent.IO_ERROR, netStrm_ioErrorHandler, false, 0, true);
			netStrm.addEventListener(AsyncErrorEvent.ASYNC_ERROR, netStrm_asyncErrorHandler, false, 0, true);
			netStrm.soundTransform = new SoundTransform(_volume);
			
			video.attachNetStream(netStrm);
			
			sizeListenTimer = new Timer(CHECK_INTERVAL, 1);
			sizeListenTimer.addEventListener(TimerEvent.TIMER, sizeListenTimer_timerHandler, false, 0, true);
		}
		
		/// PRIVATE METHODS
		
		override protected function doReset():void 
		{
			try
			{
				if (netStrm.bytesLoaded < netStrm.bytesTotal)
				{
					netStrm.close();
				}
			} catch (error:Error) { }			
			
			_originalVideoWidth = 0;
			_originalVideoHeight = 0;
		}
		
		override protected function doLoad():void
		{
			netStrm.bufferTime = _bufferTime;
			netStrm.play(_media);
			
			if (!_autoPlay)
				doStop();
			
			thingsToCheck = [checkTimeUpdate, checkBufferStatus, checkLoadProgress];
		}
		
		override protected function doPlay(startTime:Number = -1):void 
		{
			netStrm.resume();
		}
		
		override protected function doPause():void
		{
			netStrm.pause();
		}
		
		override protected function doStop():void 
		{
			netStrm.seek(0);
			netStrm.pause();
		}
		
		override protected function doReplay():void
		{
			netStrm.seek(0);
			netStrm.resume();			
		}
		
		override protected function doSeek(position:Number):void
		{
			netStrm.seek(position);
		}
		
		/// OTHER PRIVATE METHODS
		
		private function listenForVideoSize():void
		{
			if (video.videoWidth > 0 && video.videoHeight > 0)
			{
				_originalVideoWidth = video.videoWidth;
				_originalVideoHeight = video.videoHeight;
				
				initVideo();
			} 
			else 
			{
				sizeListenTimer.reset();
				sizeListenTimer.start();
			}
		}
		
		private function initVideo():void
		{
			_isReady = true;			
			dispatchEvent(new PlaybackEvent(PlaybackEvent.PLAYBACK_READY, getDefaultParams()));
			
			checkTimer.start();
		}		
		
		private function checkLoadProgress():void
		{
			var totBytes:Number = netStrm.bytesTotal;
			var lodBytes:Number = netStrm.bytesLoaded;
			
			if (isNaN(totBytes)) totBytes = 0; 
			if (isNaN(lodBytes)) lodBytes = 0; 
			
			if (_totalBytes != totBytes || _loadedBytes != lodBytes) 
			{
				_totalBytes  = totBytes;
				_loadedBytes = lodBytes;
				
				dispatchEvent(new PlaybackEvent(PlaybackEvent.LOAD_PROGRESS, getLoadProgressParams()));
			}
			
			if (_totalBytes > 0 && _loadedBytes == _totalBytes) 
			{
				_isLoaded = true;
				thingsToCheck = [checkTimeUpdate]; 
				
				dispatchEvent(new PlaybackEvent(PlaybackEvent.BUFFER_PROGRESS, getBufferProgressParams()));
				
				if (_isBuffering) 
				{
					_isBuffering = false;
					dispatchEvent(new PlaybackEvent(PlaybackEvent.BUFFER_FULL, getDefaultParams()));
				}				
			}
		}
		
		private function checkTimeUpdate():void
		{
			var crtTime:Number = netStrm.time;
			if (isNaN(crtTime)) crtTime = 0;
			
			if (_currentTime != crtTime) 
			{
				_currentTime = crtTime;
				
				if (_currentTime > _totalTime) 
				{
					_totalTime = _currentTime;
				}
				
				dispatchEvent(new PlaybackEvent(PlaybackEvent.PLAYBACK_TIME_UPDATE, getTimeUpdateParams()));
			}
		}
		
		private function checkBufferStatus():void
		{
			if (netStrm.bufferLength < netStrm.bufferTime) 
			{
				dispatchEvent(new PlaybackEvent(PlaybackEvent.BUFFER_PROGRESS, getBufferProgressParams(netStrm.bufferLength / netStrm.bufferTime)));
				
				if (!_isBuffering) 
				{
					_isBuffering = true;
					dispatchEvent(new PlaybackEvent(PlaybackEvent.BUFFERING, getDefaultParams()));
				}
			} 
			else 
			{
				if (_isBuffering) 
				{
					_isBuffering = false;					
					dispatchEvent(new PlaybackEvent(PlaybackEvent.BUFFER_PROGRESS, getBufferProgressParams()));
					dispatchEvent(new PlaybackEvent(PlaybackEvent.BUFFER_FULL, getDefaultParams()));					
				}
			}
		}
		
		
		// EVENT HANDLERS
		private function netStrm_metadataHandler(info:Object):void
		{
			if (info.width && info.height)
			{
				_originalVideoWidth = Number(info.width);
				_originalVideoHeight = Number(info.height);
				
				initVideo();
			} 
			else 
			{
				listenForVideoSize();
			}
			
			if (info.duration)
			{
				_totalTime = Number(info.duration);
				dispatchEvent(new PlaybackEvent(PlaybackEvent.PLAYBACK_TIME_UPDATE, getTimeUpdateParams()));
			}
		}
		
		private function netStrm_netStatusHandler(event:NetStatusEvent):void 
		{
			switch (event.info.code) {			
				case "NetStream.Play.Stop" :
						
						dispatchEvent(new PlaybackEvent(PlaybackEvent.PLAYBACK_COMPLETE, getDefaultParams()));
						
						if (_repeat)
							replay();
						else
							stop();
						
					break;
					
				case "NetStream.Play.StreamNotFound" :
	
						dispatchEvent(new PlaybackEvent(PlaybackEvent.ERROR, getErrorParams("NetStreamStatus: Stream not found.")));
						reset();

					break;
					
				case "NetStream.Seek.InvalidTime" :
						seek(Number(event.info.details), false);
						
					break;
			}
		}
		
		private function netStrm_asyncErrorHandler(event:AsyncErrorEvent):void 
		{
			dispatchEvent(new PlaybackEvent(PlaybackEvent.ERROR, getErrorParams(event.text)));
			reset();
		}
		
		private function netStrm_ioErrorHandler(event:IOErrorEvent):void 
		{
			dispatchEvent(new PlaybackEvent(PlaybackEvent.ERROR, getErrorParams(event.text)));
			reset();
		}
		
		private function sizeListenTimer_timerHandler(event:TimerEvent):void 
		{
			listenForVideoSize();
		}
		
		/// PROPERTIES
		
		override public function set volume(value:Number):void 
		{
			super.volume = value;
			netStrm.soundTransform = new SoundTransform(_volume);
		}
		
		/* Video original width. */
		public function get originalVideoWidth():Number { return _originalVideoWidth; }
		
		/* Video original height. */
		public function get originalVideoHeight():Number { return _originalVideoHeight; }
		
		/* Get NeStream instance. */
		public function get netStreamInstance():NetStream { return netStrm; }
	}
}