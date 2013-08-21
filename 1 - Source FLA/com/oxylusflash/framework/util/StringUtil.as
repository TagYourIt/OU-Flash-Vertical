package com.oxylusflash.framework.util 
{
	/**
	 * String util
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class StringUtil
	{
		public function StringUtil() 
		{
			throw new Error("StringUtil class has static methods. No need for instatiation.");
		}
		
		/**
		 * Generate random id as string
		 * @param	length	Id string length
		 * @param	radix	Number of allowed chars
		 * @return	Random id as string
		 */
		public static function randomId(length:uint = 8, radix:uint = 61):String
		{
			var id:String = "";
			radix = Math.min(radix, ALLOWED.length);
			while (length--) { id += ALLOWED.charAt(Math.round(Math.random() * radix)); }
			return id;
		}
		private static const ALLOWED:String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
		
		/**
		 * Remove all white space chars from a string
		 * @param	string	Source string
		 * @return	String with no white spaces
		 */
		public static function removeWhite(string:String):String
		{
			return string.replace(/\s/g, '');
		}
		
		/**
		 * Remove extra white spaces from a string
		 * @param	string	Source string
		 * @return	Squeezed string
		 */
		public static function squeeze(string:String):String
		{
			return trim(string).replace(/\s+/g, ' ');
		}
		
		/**
		 * Remove spaces at the beginning and at the end of a string
		 * @param	string Source string
		 * @return	Trimmed string
		 */
		public static function trim(string:String):String
		{
			return string.replace(/^\s+|\s+$/g, "");
		}
		
		/**
		 * Check if string is blank
		 * @param	string	String to check
		 * @return	True if string is blank
		 */
		public static function isBlank(string:String):Boolean
		{
			return removeWhite(string) == "";
		}
		
		/**
		 * Check if a string is an email address
		 * @param	string String to check
		 * @return	True if string is an email, false otherwise
		 */
		public static function isEmail(string:String):Boolean 
		{
			return string.replace(/^[a-z0-9._%+-]+@(?:[a-z0-9-]+\.)+[a-z]{2,4}$/i, '') == '';
		}
		
		/**
		 * Check if string is a number
		 * @param	string	String to check
		 * @return	True if string is a number, false otherwise
		 */
		public static function isNumber(string:String):Boolean
		{
			return string.replace(/\s*[0-9]+(?:\.[0-9])?\s*/, '') == '';
		}
		
		/**
		 * Check if string is boolean
		 * @param	string	String to check
		 * @return	True if string is boolean
		 */
		public static function isBoolean(string:String):Boolean
		{
			return string.replace(/\s*((true)|(false))\s*/i, '') == '';
		}
		
		/**
		 * Convert string to boolean
		 * @param	string	Source string
		 * @return	True or false
		 */
		public static function toBoolean(string:String):Boolean
		{
			return string.replace(/\s*(true)\s*/i, '') == '';
		}
		
		/**
		 * Convert string to top-level data type
		 * @param	string String to parse
		 * @return	A boolean, number or string value
		 */
		public static function parse(string:String):* 
		{
			if (isBoolean(string)) return toBoolean(string);
			if (isNumber(string)) return Number(string);
			return string;
		}
		
		/**
		 * Convert seconds to time string (00:00)
		 * @param	seconds		Seconds to convert
		 * @return	Time string
		 */
		public static function toTimeString(seconds:Number):String
		{
			var minutes : Number = Math.floor(seconds / 60);
			var hours : Number = Math.floor(minutes / 60);
			
			seconds %= 60;
			minutes %= 60;
			hours %= 24;
			
			var timeString:String = '';
			if (hours) timeString += (hours < 10 ? '0' : '') + String(hours) + ':';
			timeString += (minutes < 10 ? '0' : '') + String(minutes) + ':';
			return timeString + (seconds < 10 ? '0' : '') + String(seconds);
		}
	}
}