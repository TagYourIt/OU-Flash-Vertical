package com.oxylusflash.framework.misc 
{
	import flash.display.Stage;
	
	/**
	 * Stage reference
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class StageReference
	{
		private static var _stage:Stage;
		
		/* Stage reference */
		public function StageReference() 
		{
			throw new Error("StageReference class has static methods. No need for instatiation.");
		}
		
		/**
		 * Init stage reference
		 * @param	stage	Stage
		 */
		public static function init(stage:Stage):void
		{
			_stage = stage;
		}
		
		/* Stage reference */
		public static function get stage():Stage { return _stage; }		
		public static function set stage(value:Stage):void  { _stage = value; }
		
	}

}