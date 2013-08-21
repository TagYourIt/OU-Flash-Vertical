package com.oxylusflash.multimediaviewer 
{
	//{ region IMPORT CLASSES
	import flash.display.MovieClip;
	import flash.events.Event;
	import org.osflash.signals.Signal;
	
	import com.oxylusflash.AVPlayback.AudioPlaybackController;
	import com.oxylusflash.AVPlayback.events.PlaybackEvent;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class AudioPlayer extends MovieClip
	{
		//{ region FIELDS
		private var _audioSignal : Signal;
		private var _autoPlay : Boolean = true;
		private var _repeat : Boolean = true;
		private var _buffer : Number = 1;
		private var _volume : Number = 0.5;
		private var _apc : AudioPlaybackController;
		private var audioURL:String;
		//} endregion
		
		//{ region CONSTRUCTOR
		public function AudioPlayer() 
		{
			this.visible = false;
			this.alpha = 0;
			_audioSignal = new Signal(String);
		}
		//} endregion
		
		//{ region EVENT HANDLERS/////////////////////////////////////////////////////////////////
		
		//{ region INIT
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			apc.load(audioURL);
		}
		//} endregion
		
		//{ region PLAYBACK CONTROLLER BUFFERING HANDLER
		private final function pc_bufferingHandler(e:PlaybackEvent):void 
		{
			_audioSignal.dispatch("BUFFER ON");
		}
		//} endregion
		
		//{ region PLAYBACK CONTROLLER BUFFER PROGRESS HANDLER
		/*private final function pc_bufferProgressHandler(e:PlaybackEvent):void 
		{
			//buffer progress
		}*/
		//} endregion
		
		//{ region PLAYBACK CONTROLLER BUFFER FULL HANDLER
		private final function pc_bufferFullHandler(e:PlaybackEvent):void 
		{
			_audioSignal.dispatch("BUFFER OFF");
		}
		//} endregion
		
		//{ region PLAYBACK CONTROLLER LOAD PROGRESS HANDLER
		private final function pc_loadProgressHandler(e:PlaybackEvent):void 
		{
			_audioSignal.dispatch("LOADING PROGRESS");
		}
		//} endregion
		
		//{ region PLAYBACK CONTROLLER COMPLETE HANDLER
		private final function pc_playbackCompleteHandler(e:PlaybackEvent):void 
		{
			_audioSignal.dispatch("PLB COMPLETE");
		}
		//} endregion
		
		//{ region PLAYBACK CONTROLLER READY HANDLER
		/*private final function pc_playbackReadyHandler(e:PlaybackEvent):void 
		{
			//_audioSignal.dispatch("PLB RDY");
		}*/
		//} endregion
		
		//{ region PLAYBACK CONTROLLER START HANDLER
		private final function pc_playbackStartHandler(e:PlaybackEvent):void 
		{
			_audioSignal.dispatch("PLAY");
		}
		//} endregion
		
		//{ region PLAYBACK CONTROLLER STOP HANDLER
		private final function pc_playbackStopHandler(e:PlaybackEvent):void 
		{
			_audioSignal.dispatch("PAUSE");
		}
		//} endregion
		
		//{ region PLAYBACK CONTROLLER UPDATE HANDLER
		private final function pc_playbackTimeUpdateHandler(e:PlaybackEvent):void 
		{
			_audioSignal.dispatch("TIME UPDATE");
			//trace("[INFO]:", e.info.currentTimeString, e.info.totalTimeString);
		}
		//} endregion
		
		//{ region PLAYBACK CONTROLLER ERROR HANDLER
		private final function pc_errorHandler(e:PlaybackEvent):void 
		{
			trace("[ERROR]: Playback error: " + e.info.message);
			_audioSignal.dispatch("ERROR");
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS////////////////////////////////////////////////////////////////////////
		
		//{ region START ME
		internal final function StartMe(pAudioURL : String = ""):void 
		{
			_apc = new AudioPlaybackController();
			
			//<start>controller settings
			_apc.volume = volume;
			_apc.autoPlay = autoPlay;
			_apc.repeat = repeat;
			_apc.bufferTime = buffer;
			//<end>
			
			//<start>listeners
			_apc.addEventListener(PlaybackEvent.BUFFERING, pc_bufferingHandler, false, 0, true);
			//_apc.addEventListener(PlaybackEvent.BUFFER_PROGRESS, pc_bufferProgressHandler, false, 0, true);
			_apc.addEventListener(PlaybackEvent.BUFFER_FULL, pc_bufferFullHandler, false, 0, true);		
			
			_apc.addEventListener(PlaybackEvent.LOAD_PROGRESS, pc_loadProgressHandler, false, 0, true);		
			
			_apc.addEventListener(PlaybackEvent.PLAYBACK_COMPLETE, pc_playbackCompleteHandler, false, 0, true);
			//_apc.addEventListener(PlaybackEvent.PLAYBACK_READY, pc_playbackReadyHandler, false, 0, true);
			_apc.addEventListener(PlaybackEvent.PLAYBACK_START, pc_playbackStartHandler, false, 0, true);			
			_apc.addEventListener(PlaybackEvent.PLAYBACK_STOP, pc_playbackStopHandler, false, 0, true);
			_apc.addEventListener(PlaybackEvent.PLAYBACK_TIME_UPDATE, pc_playbackTimeUpdateHandler, false, 0, true);
			
			_apc.addEventListener(PlaybackEvent.ERROR, pc_errorHandler, false, 0, true);
			//<end>
			
			audioURL = pAudioURL;
			
			if (stage) 
			{
				//apc.load(pAudioURL);
				init();
			}else 
			{
				this.addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			}
			//apc.load(pAudioURL);
		}
		//} endregion
		
		//{ region DESTROY
		internal function Destroy():void 
		{
			_apc.removeEventListener(PlaybackEvent.BUFFERING, pc_bufferingHandler);
			//_apc.removeEventListener(PlaybackEvent.BUFFER_PROGRESS, pc_bufferProgressHandler);
			_apc.removeEventListener(PlaybackEvent.BUFFER_FULL, pc_bufferFullHandler);		
			
			_apc.removeEventListener(PlaybackEvent.LOAD_PROGRESS, pc_loadProgressHandler);		
			
			_apc.removeEventListener(PlaybackEvent.PLAYBACK_COMPLETE, pc_playbackCompleteHandler);
			//_apc.removeEventListener(PlaybackEvent.PLAYBACK_READY, pc_playbackReadyHandler);
			_apc.removeEventListener(PlaybackEvent.PLAYBACK_START, pc_playbackStartHandler);			
			_apc.removeEventListener(PlaybackEvent.PLAYBACK_STOP, pc_playbackStopHandler);
			_apc.removeEventListener(PlaybackEvent.PLAYBACK_TIME_UPDATE, pc_playbackTimeUpdateHandler);
			
			_apc.removeEventListener(PlaybackEvent.ERROR, pc_errorHandler);
			apc = null;
			
			this.parent.removeChild(this);
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		internal function get apc():AudioPlaybackController { return _apc; }
		internal function set apc(value:AudioPlaybackController):void 
		{
			_apc = value;
		}
		
		internal function get audioSignal():Signal { return _audioSignal; }
		internal function set audioSignal(value:Signal):void 
		{
			_audioSignal = value;
		}
		
		internal function get autoPlay():Boolean { return _autoPlay; }
		internal function set autoPlay(value:Boolean):void 
		{
			_autoPlay = value;
		}
		
		internal function get repeat():Boolean { return _repeat; }
		internal function set repeat(value:Boolean):void 
		{
			_repeat = value;
		}
		
		internal function get buffer():Number { return _buffer; }
		internal function set buffer(value:Number):void 
		{
			_buffer = value;
		}
		
		internal function get volume():Number { return _volume; }
		internal function set volume(value:Number):void 
		{
			_volume = value;
		}
		//} endregion
	}
}