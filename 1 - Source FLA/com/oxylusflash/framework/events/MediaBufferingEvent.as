package com.oxylusflash.framework.events 
{
	import flash.events.Event;
	
	/**
	 * Media buffering event
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class MediaBufferingEvent extends Event 
	{
		/* Media buffering start event */
		public static const BUFFERING_START:String = "bufferingStart";
		
		/* Media buffering progress event */
		public static const BUFFERING_PROGRESS:String = "bufferingProgress";
		
		/* Media buffering end event */
		public static const BUFFERING_END:String = "bufferingEnd";
		
		/* Total buffer length */
		public var totalBuffer:Number;
		
		/* Current buffer length */
		public var currentBuffer:Number;
		
		/**
		 * Media buffering event
		 * @param	type			Event type
		 * @param	totalBuffer		Total buffer length
		 * @param	currentBuffer	Current buffer length
		 */
		public function MediaBufferingEvent(type:String, totalBuffer:Number, currentBuffer:Number) 
		{ 
			super(type);
			
			this.totalBuffer = totalBuffer;
			this.currentBuffer = currentBuffer;
		} 
		
		/* Clone media buffering event */
		override public function clone():Event 
		{ 
			return new MediaBufferingEvent(type, totalBuffer, currentBuffer);
		} 
		
		override public function toString():String 
		{ 
			return formatToString("MediaBufferingEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}