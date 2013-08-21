package com.oxylusflash.framework.events
{
	import flash.events.Event;
	
	/**
	 * Media properties event
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class MediaPropsChangeEvent extends Event
	{
		/* Media volume change event */
		public static const VOLUME_CHANGE:String = "volumeChange";
		
		/* Media autoPlay change event */
		public static const AUTO_PLAY_CHANGE:String = "autoPlayChange";
		
		/* Media playback repeat change event */
		public static const REPEAT_CHANGE:String = "repeatChange";
		
		/* Media playback rewind change event */
		public static const REWIND_CHANGE:String = "rewindChange";
		
		/* Media source change event */
		public static const MEDIA_CHANGE:String = "mediaChange";
		
		/* Media buffer time change event */
		public static const BUFFER_CHANGE:String = "bufferChange";
		
		/* Media volume */
		public var volume:Number;
		
		/* Media autoPlay */
		public var autoPlay:Boolean;
		
		/* Media repeat */
		public var repeat:Boolean;
		
		/* Media rewind */
		public var rewind:Boolean;
		
		/* Media */
		public var media:String;
		
		/* Buffer */
		public var buffer:Number;
		
		/**
		 * Media volume event
		 * @param	type	Event type
		 * @param	volume	Media volume
		 */
		public function MediaPropsChangeEvent(type:String, volume:Number, autoPlay:Boolean, repeat:Boolean, rewind:Boolean, media:String, buffer:Number)
		{
			super(type);
			
			this.volume = volume;
			this.autoPlay = autoPlay;
			this.repeat = repeat;
			this.rewind = rewind;
			this.media = media;
			this.buffer = buffer;
		}
		
		/* Clone media volume event */
		override public function clone():Event
		{
			return new MediaPropsChangeEvent(type, volume, autoPlay, repeat, rewind, media, buffer);
		}
		
		override public function toString():String
		{
			return formatToString("MediaPropsChangeEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
}
