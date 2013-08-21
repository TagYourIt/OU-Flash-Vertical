package com.oxylusflash.framework.events 
{
	import flash.events.Event;
	
	/**
	 * Media playback event
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class MediaPlaybackEvent extends Event 
	{
		/* Media ready for playback event */
		public static const PLAYBACK_READY:String = "playbackReady";
		
		/* Media playback start event */
		public static const PLAYBACK_START:String = "playbackStart";
		
		/* Media playback time update event */
		public static const PLAYBACK_TIME_UPDATE:String = "playbackTimeUpdate";
		
		/* Media playback stop event */
		public static const PLAYBACK_STOP:String = "playbackStop";
		
		/* Media playback complete event */
		public static const PLAYBACK_COMPLETE:String = "playbackComplete";
		
		/* Total playback time */
		public var totalTime:Number;
		
		/* Current playback time */
		public var currentTime:Number;
		
		/**
		 * Media playback event
		 * @param	type			Event type
		 * @param	totalTime		Total playback time
		 * @param	currentTime		Current playback time
		 */
		public function MediaPlaybackEvent(type:String, totalTime:Number, currentTime:Number) 
		{ 
			super(type);
			
			this.totalTime = totalTime;
			this.currentTime = currentTime;
		} 
		
		/* Clone media playback event */
		override public function clone():Event 
		{ 
			return new MediaPlaybackEvent(type, totalTime, currentTime);
		} 
		
		override public function toString():String 
		{ 
			return formatToString("MediaPlaybackEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}