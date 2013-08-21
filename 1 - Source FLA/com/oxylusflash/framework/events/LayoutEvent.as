package com.oxylusflash.framework.events 
{
	import flash.events.Event;
	
	/**
	 * Layout event
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class LayoutEvent extends Event 
	{
		/* Layout size change event */
		public static const SIZE_CHANGE:String = "sizeChange";
		
		public var width:Number;
		public var height:Number;
		
		/**
		 * Create layout event
		 * @param	type	Event type
		 * @param	width	Layout width
		 * @param	height	Layout height
		 */
		public function LayoutEvent(type:String, width:Number, height:Number) 
		{ 
			super(type);
			
			this.width = width;
			this.height = height;
		} 
		
		/* Clone layout event */
		public override function clone():Event 
		{ 
			return new LayoutEvent(type, width, height);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("LayoutEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}