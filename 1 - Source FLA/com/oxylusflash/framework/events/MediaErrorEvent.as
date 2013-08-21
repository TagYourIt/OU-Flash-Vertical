package com.oxylusflash.framework.events 
{
	import flash.events.Event;
	
	/**
	 * Media error event
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class MediaErrorEvent extends Event 
	{
		/* Media error event */
		public static const ERROR:String = "error";
		
		/* Media error message */
		public var message:String;
		
		/**
		 * Media error event
		 * @param	type		Event type
		 * @param	message		Error message
		 */
		public function MediaErrorEvent(type:String, message:String) 
		{ 
			super(type, bubbles, cancelable);
			
			this.message = message;
		} 
		
		/* Clone media error event */
		public override function clone():Event 
		{ 
			return new MediaErrorEvent(type, message);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("MediaErrorEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}