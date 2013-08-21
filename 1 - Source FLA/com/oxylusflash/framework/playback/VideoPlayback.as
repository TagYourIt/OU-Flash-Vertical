package com.oxylusflash.framework.playback
{
	import com.oxylusflash.framework.events.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.Timer;
	
	[Event(name = "playbackReady", 		type = "com.oxylusflash.framework.events.MediaPlaybackEvent")]
	[Event(name = "playbackStart", 		type = "com.oxylusflash.framework.events.MediaPlaybackEvent")]
	[Event(name = "playbackTimeUpdate", 	type = "com.oxylusflash.framework.events.MediaPlaybackEvent")]
	[Event(name = "playbackStop", 		type = "com.oxylusflash.framework.events.MediaPlaybackEvent")]
	[Event(name = "playbackComplete", 	type = "com.oxylusflash.framework.events.MediaPlaybackEvent")]
	[Event(name = "loadStart", 			type = "com.oxylusflash.framework.events.MediaLoadEvent")]
	[Event(name = "loadProgress", 		type = "com.oxylusflash.framework.events.MediaLoadEvent")]
	[Event(name = "loadComplete", 		type = "com.oxylusflash.framework.events.MediaLoadEvent")]
	[Event(name = "bufferingStart", 		type = "com.oxylusflash.framework.events.MediaBufferingEvent")]
	[Event(name = "bufferingProgress", 	type = "com.oxylusflash.framework.events.MediaBufferingEvent")]
	[Event(name = "bufferingEnd", 		type = "com.oxylusflash.framework.events.MediaBufferingEvent")]
	[Event(name = "error", 				type = "com.oxylusflash.framework.events.MediaErrorEvent")]
	[Event(name = "volumeChange", 		type = "com.oxylusflash.framework.events.MediaPropsChangeEvent")]
	[Event(name = "autoPlayChange", 		type = "com.oxylusflash.framework.events.MediaPropsChangeEvent")]
	[Event(name = "repeatChange", 		type = "com.oxylusflash.framework.events.MediaPropsChangeEvent")]
	[Event(name = "mediaChange", 		type = "com.oxylusflash.framework.events.MediaPropsChangeEvent")]
	[Event(name = "bufferChange", 		type = "com.oxylusflash.framework.events.MediaPropsChangeEvent")]
	
	/**
	 * Video playback
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class VideoPlayback extends MediaPlayback
	{
		protected var _video:Video;
		protected var _videoWidth:Number;
		protected var _videoHeight:Number;
		
		protected var netStream:NetStream;
		protected var netConnection:NetConnection = new NetConnection;
		protected var metaDataListener:Object = { };
		
		protected var videoSizeTimer:Timer = new Timer(5);
		
		/**
		 * Video playback object
		 * @param	video	Video instance
		 */
		public function VideoPlayback(video:Video = null)
		{
			netConnection.connect(null);
			
			metaDataListener.onMetaData = netStream_metaDataHandler;
			
			netStream = new NetStream(netConnection);
			netStream.soundTransform = new SoundTransform(_volume);
			netStream.addEventListener(NetStatusEvent.NET_STATUS, netStream_eventsHandler, false, 0, true);
			netStream.addEventListener(IOErrorEvent.IO_ERROR, netStream_eventsHandler, false, 0, true);
			netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, netStream_eventsHandler, false, 0, true);
			netStream.client = metaDataListener;
			updateBuffer(_buffer);
			
			videoSizeTimer.addEventListener(TimerEvent.TIMER, videoSizeTimer_timerHandler, false, 0, true);
			
			if (video) this.video = video;
		}
		
		/* Clear video */
		override protected function mediaClear():void
		{
			if (netStream.bytesTotal > 0 && netStream.bytesLoaded < netStream.bytesTotal) { try { netStream.close(); } catch (e:Error) { } }
			videoSizeTimer.reset();
			_video.clear();
			_videoWidth = _videoHeight = 0;
		}
		
		/* Load video */
		override protected function mediaLoad(media:String):void
		{
			netStream.play(media);
			if (!_autoPlay) mediaStop();
			checkMethods = [checkLoad, checkBuffer, checkTime];
		}
		
		/* Play video */
		override protected function mediaPlay():void
		{
			netStream.resume();
		}
		
		/* Pause video */
		override protected function mediaPause():void
		{
			netStream.pause();
		}
		
		/* Stop video */
		override protected function mediaStop():void
		{
			netStream.seek(0);
			netStream.pause();
		}
		
		/* Video seek */
		override protected function mediaSeek(seekTime:Number):void
		{
			netStream.seek(seekTime);
		}
		
		/* Video instance */
		public function get video():Video { return _video; }
		public function set video(value:Video):void
		{
			if (_video != value)
			{
				if (_video) _video.clear();
				if (value) { value.attachNetStream(netStream); }
				_video = value;
			}
		}
		
		/* Video original width */
		public function get videoWidth():Number { return _videoWidth; }
		
		/* Video original height */
		public function get videoHeight():Number { return _videoHeight; }
		
		/* Net stream metadata handler */
		protected function netStream_metaDataHandler(meta:Object):void
		{
			if (!_ready)
			{
				if (meta.width && meta.height)
				{
					_videoWidth = Number(meta.width);
					_videoHeight = Number(meta.height);
					makeReady();
				}
				else
				{
					videoSizeTimer.start();
					videoSizeTimer_timerHandler(null);
				}
				
				if (meta.duration)
				{
					_totalTime = Number(meta.duration);
					super.checkTime();
				}
			}
		}
		
		/* Net stream events handler */
		protected function netStream_eventsHandler(e:Event):void
		{
			switch(e.type)
			{
				case NetStatusEvent.NET_STATUS:
					var info:Object = NetStatusEvent(e).info;
					switch(info.code)
					{
						case "NetStream.Play.Stop":
							if (_repeat) replay();
							else if (_rewind) stop();
							else
							{
								_complete = true;
								pause();
							}
							dispatchEvent(new MediaPlaybackEvent(MediaPlaybackEvent.PLAYBACK_COMPLETE, _totalTime, _currentTime));
							break;
							
						case "NetStream.Play.StreamNotFound":
							clear();
							dispatchEvent(new MediaErrorEvent(MediaErrorEvent.ERROR, "NetStreamStatus: Stream not found."));
							break;
							
						case "NetStream.Seek.InvalidTime":
							seek(Number(info.details), false);
							break;
					}
					break;
					
				case IOErrorEvent.IO_ERROR:
				case AsyncErrorEvent.ASYNC_ERROR:
					dispatchEvent(new MediaErrorEvent(MediaErrorEvent.ERROR, ErrorEvent(e).text));
					break;
			}
		}
		
		/* Video size check timer handler */
		protected function videoSizeTimer_timerHandler(e:TimerEvent):void
		{
			if (_video.videoWidth > 0 && _video.videoHeight > 0)
			{
				videoSizeTimer.reset();
				_videoWidth = video.videoWidth;
				_videoHeight = video.videoHeight;
				makeReady();
			}
		}
		
		/* Check video loading */
		override protected function checkLoad():void
		{
			if (_totalBytes != netStream.bytesTotal || _loadedBytes != netStream.bytesLoaded)
			{
				_totalBytes = netStream.bytesTotal;
				_loadedBytes = netStream.bytesLoaded;
				super.checkLoad();
			}
		}
		
		/* Check video buffer status */
		override protected function checkBuffer():void
		{
			if (_loaded && _buffering) super.checkBuffer();
			else
			{
				if (netStream.bufferLength < _buffer)
				{
					if (!_buffering)
					{
						_buffering = true;
						dispatchEvent(new MediaBufferingEvent(MediaBufferingEvent.BUFFERING_START, netStream.bufferLength, _buffer));
					}
					dispatchEvent(new MediaBufferingEvent(MediaBufferingEvent.BUFFERING_PROGRESS, netStream.bufferLength, _buffer));
				}
				else
				{
					if (_buffering) super.checkBuffer();
				}
			}
		}
		
		/* Check video playback time */
		override protected function checkTime():void
		{
			if (_currentTime != netStream.time)
			{
				_currentTime = netStream.time;
				_totalTime = Math.max(_currentTime , _totalTime);
				
				super.checkTime();
			}
		}
		
		/* Update video buffer */
		override protected function updateBuffer(value:Number):void
		{
			netStream.bufferTime = value;
		}
		
		/* Update video volume */
		override protected function updateVolume(value:Number):void
		{
			netStream.soundTransform = new SoundTransform(value);
		}
		
		/* Destroy video playback object */
		override public function destroy():void
		{
			super.destroy();
			
			this.video = null;
			
			if (netStream) 
			{
				netStream.soundTransform = null;
				netStream.removeEventListener(NetStatusEvent.NET_STATUS, netStream_eventsHandler);
				netStream.removeEventListener(IOErrorEvent.IO_ERROR, netStream_eventsHandler);
				netStream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, netStream_eventsHandler);
				netStream = null;
			}
			
			netConnection = null;;
			
			if (metaDataListener) 
			{
				delete metaDataListener.onMetaData;
			}
			metaDataListener = null;
			
			if (videoSizeTimer) 
			{
				videoSizeTimer.removeEventListener(TimerEvent.TIMER, videoSizeTimer_timerHandler);
				videoSizeTimer = null;
			}
		}
	}
}