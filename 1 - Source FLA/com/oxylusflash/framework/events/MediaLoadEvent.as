package com.oxylusflash.framework.events 
{
	import flash.events.Event;
	
	/**
	 * Media load event
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class MediaLoadEvent extends Event 
	{
		/* Media load start event */
		public static const LOAD_START:String = "loadStart";
		
		/* Media load progress event */
		public static const LOAD_PROGRESS:String = "loadProgress";
		
		/* Media load complete event */
		public static const LOAD_COMPLETE:String = "loadComplete";
		
		/* Media total bytes */
		public var totalBytes:Number;
		/* Media loaded bytes */
		public var loadedBytes:Number;
		
		/**
		 * Media load event
		 * @param	type		Event type
		 * @param	totalBytes	Media total bytes
		 * @param	loadedBytes	Media loaded bytes
		 */
		public function MediaLoadEvent(type:String, totalBytes:Number, loadedBytes:Number) 
		{ 
			super(type);
			this.totalBytes = totalBytes;
			this.loadedBytes = loadedBytes;			
		} 
		
		/* Clone media load event */
		override public function clone():Event 
		{ 
			return new MediaLoadEvent(type, totalBytes, loadedBytes);
		} 
		
		override public function toString():String 
		{ 
			return formatToString("MediaLoadEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}