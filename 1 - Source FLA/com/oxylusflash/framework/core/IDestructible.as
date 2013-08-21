package com.oxylusflash.framework.core 
{
	
	/**
	 * Interface for destructible objects
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public interface IDestructible 
	{
		/* Destroy object */
		function destroy():void;
		
		/* Check if object is destroyed */
		function get destroyed():Boolean;
	}
	
}