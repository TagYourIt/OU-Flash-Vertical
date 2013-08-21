package com.oxylusflash.framework.math 
{
	import com.oxylusflash.framework.core.Destructible;
	
	/**
	 * Percent
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Percent extends Destructible
	{
		private var _value:Number = 0;
		private var _limits:Limits;
		
		/**
		 * Creat new percent object
		 * @param	percent	Percent as string (e.g. 78.5%)
		 */
		public function Percent(percent:String = null, limits:Limits = null) 
		{
			if (percent) this.value = fromString(percent);
			if (limits) this.limits = limits;
		}
		
		/* Percent value */
		public function get value():Number { return _value; }		
		public function set value(value:Number):void 
		{
			_value = _limits ? _limits.toLimited(value) : value;
		}
		
		/* Percent limits */
		public function get limits():Limits { return _limits; }		
		public function set limits(value:Limits):void 
		{
			if (_limits)
			{
				_limits.destroy();
				_limits = null;
			}
			if (value)
			{
				_limits = value;
				this.value = _limits.toLimited(this.value);
			}
		}
		
		/* Percent as string */
		public function toString():String { return (Math.round(_value * 100000) / 1000) + "%"; }
		
		/**
		 * Get percent from string
		 * @param	percent Percent string
		 * @return	Percent as number
		 */
		public function fromString(percent:String):Number
		{
			return Number(percent.replace(/[^\d.]+/g, '')) / 100;
		}
		
		/* Destroy percent object */
		override public function destroy():void 
		{
			_value = 0;
			this.limits = null;
			super.destroy();
		}
		
	}

}