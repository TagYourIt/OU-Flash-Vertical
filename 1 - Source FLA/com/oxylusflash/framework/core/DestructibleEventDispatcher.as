package com.oxylusflash.framework.core 
{
	import flash.events.EventDispatcher;
	
	/**
	 * Base class for destructible event dispatcher objects
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class DestructibleEventDispatcher extends EventDispatcher implements IDestructible
	{
		protected var _destroyed:Boolean = false;
		
		/* Create destructible event dispatcher object */
		public function DestructibleEventDispatcher() { } 
		
		/* Destroy object */
		public function destroy():void { _destroyed = true; }
		
		/* Check if object is destroyed */
		public function get destroyed():Boolean { return _destroyed; }
		
	}

}