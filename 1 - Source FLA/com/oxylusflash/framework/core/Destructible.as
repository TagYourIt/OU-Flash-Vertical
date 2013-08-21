package com.oxylusflash.framework.core 
{
	/**
	 * Base class for destructible objects
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Destructible implements IDestructible
	{
		protected var _destroyed:Boolean = false;
		
		/* Create destructible object */
		public function Destructible() { }
		
		/* Destroy object */
		public function destroy():void { _destroyed = true; }
		
		/* Check if object is destroyed */
		public function get destroyed():Boolean { return _destroyed; }
		
	}

}