package com.oxylusflash.framework.math 
{
	import com.oxylusflash.framework.core.Destructible;
	
	/**
	 * Limits
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Limits extends Destructible
	{
		private var _lowerLimit:Number = 0;
		private var _upperLimit:Number = 0;
		
		/**
		 * Create new limits object
		 * @param	lower	Lower limit
		 * @param	upper	Upper limit
		 */
		public function Limits(lower:Number = 0, upper:Number = 0) 
		{
			addLimit(lower);
			addLimit(upper);
		}
		
		/* Lower limit */
		public function get lowerLimit():Number { return _lowerLimit; }		
		public function set lowerLimit(value:Number):void 
		{
			addLimit(value);
		}
		
		/* Upper limit */
		public function get upperLimit():Number { return _upperLimit; }		
		public function set upperLimit(value:Number):void 
		{
			addLimit(value);
		}
		
		/**
		 * Add limit
		 * @param	value Limit value
		 */
		public function addLimit(value:Number):void
		{
			_lowerLimit = Math.min(_upperLimit, value);
			_upperLimit = Math.max(_upperLimit, value);
		}
		
		/**
		 * Get limited value
		 * @param	value	Value as number
		 * @return	Limited value
		 */
		public function toLimited(value:Number):Number
		{
			return Math.min(upperLimit, Math.max(lowerLimit, value));
		}
		
		/* Destroy limits object */
		override public function destroy():void 
		{
			_lowerLimit = _upperLimit = 0;
			super.destroy();
		}
		
	}

}