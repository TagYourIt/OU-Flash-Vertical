package com.oxylusflash.framework.playback
{
	import com.oxylusflash.framework.events.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.URLRequest;
	
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
	 * Audio playback
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class AudioPlayback extends MediaPlayback
	{
		protected var sound:Sound;
		protected var channel:SoundChannel;
		protected var loaderContext:SoundLoaderContext = new SoundLoaderContext;
		
		protected var channelPosition:Number = 0;
		
		/* Audio playback */
		public function AudioPlayback()
		{
			updateBuffer(_buffer);
		}
		
		/* Clear audio */
		override protected function mediaClear():void
		{
			channelPosition = 0;
			destroySound();
			destroyChannel();
		}
		
		/* Destroy used sound object */
		protected function destroySound():void
		{
			if (sound)
			{
				try { sound.close(); } catch (e:Error) { }
				sound.removeEventListener(IOErrorEvent.IO_ERROR, sound_eventsHandler);
				sound.removeEventListener(Event.OPEN, sound_eventsHandler);
				sound.removeEventListener(ProgressEvent.PROGRESS, sound_eventsHandler);
				sound.removeEventListener(Event.COMPLETE, sound_eventsHandler);
				sound = null;
			}
		}
		
		/* Destroy used audio channel */
		protected function destroyChannel():void
		{
			if (channel)
			{
				channel.stop();
				channel.soundTransform.volume = 0;
				channel.removeEventListener(Event.SOUND_COMPLETE, channel_eventsHandler);
				channel = null;
			}
		}
		
		/* Load audio */
		override protected function mediaLoad(media:String):void
		{
			sound = new Sound;
			sound.addEventListener(IOErrorEvent.IO_ERROR, sound_eventsHandler, false, 0, true);
			sound.addEventListener(Event.OPEN, sound_eventsHandler, false, 0, true);
			sound.addEventListener(ProgressEvent.PROGRESS, sound_eventsHandler, false, 0, true);
			sound.addEventListener(Event.COMPLETE, sound_eventsHandler, false, 0, true);
			sound.load(new URLRequest(media), loaderContext);
			checkMethods = [checkBuffer, checkTime];
		}
		
		/* Play audio */
		override protected function mediaPlay():void
		{
			destroyChannel();
			channel = sound.play(channelPosition, 0, new SoundTransform(_volume));
			channel.addEventListener(Event.SOUND_COMPLETE, channel_eventsHandler, false, 0, true);
		}
		
		/* Pause audio */
		override protected function mediaPause():void
		{
			channel.stop();
			channelPosition = channel.position;
			destroyChannel();
		}
		
		/* Stop audio */
		override protected function mediaStop():void
		{
			channelPosition = 0;
			mediaPlay();
			destroyChannel();
		}
		
		/* Audio seek */
		override protected function mediaSeek(seekTime:Number):void
		{
			seekTime = Math.max(0, Math.min(seekTime, _totalTime - _buffer));
			channelPosition = seekTime * 1000;
			mediaPlay();
			if (!playing) destroyChannel();
		}
		
		/* Sound object events handler */
		private function sound_eventsHandler(e:Event):void
		{
			switch(e.type)
			{
				case IOErrorEvent.IO_ERROR:
					clear();
					dispatchEvent(new MediaErrorEvent(MediaErrorEvent.ERROR, IOErrorEvent(e).text));
					break;
					
				case Event.OPEN:
					checkTimer.start();
					break;
					
				case ProgressEvent.PROGRESS:
					var info:ProgressEvent = ProgressEvent(e);
					if (_totalBytes != info.bytesTotal || _loadedBytes != info.bytesLoaded)
					{
						_totalBytes = info.bytesTotal;
						_loadedBytes = info.bytesLoaded;
						dispatchEvent(new MediaLoadEvent(MediaLoadEvent.LOAD_PROGRESS, _totalBytes, _loadedBytes));
					}
					break;
					
				case Event.COMPLETE:
					_loaded = true;
					checkMethods = [checkTime];
					dispatchEvent(new MediaLoadEvent(MediaLoadEvent.LOAD_COMPLETE, _totalBytes, _loadedBytes));
					checkBuffer();
					break;
			}
		}
		
		/* Sound channel events handler */
		private function channel_eventsHandler(e:Event):void
		{
			switch(e.type)
			{
				case Event.SOUND_COMPLETE:
					channelPosition = 0;
					if (_repeat) replay();
					else if (_rewind) stop();
					else
					{
						_complete = true;
						pause();
					}
					dispatchEvent(new MediaPlaybackEvent(MediaPlaybackEvent.PLAYBACK_COMPLETE, _totalTime, _currentTime));
					break;
			}
		}
		
		/* Check buffer status */
		override protected function checkBuffer():void
		{
			var tempChannelPosition:Number = 0;
			if (channel) tempChannelPosition = channel.position;
			
			var playDist:Number = (sound.length - tempChannelPosition) / 1000;
			
			if (playDist <= _buffer)
			{
				if (!_buffering)
				{
					_buffering = true;
					dispatchEvent(new MediaBufferingEvent(MediaBufferingEvent.BUFFERING_START, _buffer, 0));
				}
				dispatchEvent(new MediaBufferingEvent(MediaBufferingEvent.BUFFERING_PROGRESS, _buffer, playDist));
			}
			else
			{
				if (_buffering) super.checkBuffer();
			}
		}
		
		/* Check playback time update */
		override protected function checkTime():void
		{
			if (!_ready)
			{
				if (_totalTime > 0 && sound.length >= _buffer * 1000) makeReady();
			}
			
			if (channel) channelPosition = channel.position;
			
			var newCurrentTime:Number = channelPosition / 1000;
			var newTotalTime:Number = (_loaded ? sound.length : (_loadedBytes > 0 ? sound.length * _totalBytes / _loadedBytes : 0)) / 1000;
			
			if (_currentTime != newCurrentTime || _totalTime != newTotalTime)
			{
				_currentTime = newCurrentTime;
				_totalTime = Math.max(_currentTime, newTotalTime);
				
				if (_ready) super.checkTime();
			}
		}
		
		/* Update sound volume */
		override protected function updateVolume(value:Number):void
		{
			if (channel) channel.soundTransform = new SoundTransform(value);
		}
		
		/* Update sound buffer */
		override protected function updateBuffer(value:Number):void
		{
			loaderContext.bufferTime = value * 1000;
		}
		
		/* Destroy audio playback object */
		override public function destroy():void
		{
			super.destroy();
			loaderContext = null;
		}
		
	}

}
