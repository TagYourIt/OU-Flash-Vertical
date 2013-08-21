package com.oxylusflash.framework.util
{
	/**
	 * Number util
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class NumberUtils
	{
		/* Number util */
		public function NumberUtils()
		{
			throw new Error("NumberUtils class has static methods. No need for instatiation.");
		}
		
		/**
		 * Get random number between two values
		 * @param	lower	Lower number
		 * @param	upper	Upper number
		 * @return	Random number
		 */
		public static function random(lower:Number = 0, upper:Number = 1):Number
		{
			return lower + Math.round(Math.random() * (upper - lower));
		}
		
		/**
		 * Get number sign
		 * @param	number Number
		 * @return	Number sign (-1 for negative, 1 for positive)
		 */
		public static function sign(number:Number):int
		{
			return number < 0 ? -1 : 1;
		}
		
		/**
		 * Get looped index
		 * @param	index	Index value
		 * @param	length	Maximum length
		 * @return	Looped index
		 */
		public static function loopIndex(index:int, length:int):int
		{
			return (length + index % length) % length;
		}
		
		/**
		 * Convert number to ordinal
		 * @param	number	Number
		 * @return	Ordinal string
		 */
		public static function toOrdinal(number:uint):String
		{
			if (number == 0) return "0";
			if (number >= 10 && number <= 20) return number + "th";
			switch(number % 10)
			{
				case 1: return number + "st";
				case 2: return number + "nd";
				case 3: return number + "rd";
			}
			return number + "th";
		}
		
	}

}
