package com.oxylusflash.framework.address 
{
	import com.oxylusflash.framework.util.NumberUtil;
	/**
	 * Address
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Address
	{
		/* Address#1 contains address#2 */
		public static const CONTAINS:int = 1;
		
		/* Address#1 is contained in address#2 */
		public static const CONTAINED:int = 2;
		
		/* Address#1 is equal to address#2 */
		public static const EQUAL:int = 3;
		
		/* Address#1 is different from address#2 */
		public static const DIFFERENT:int = 4;
		
		public function Address() 
		{
			throw new Error("Address class has static methods. No need for instatiation.");
		}
		
		/**
		 * Cleanup address
		 * @param	address		Source address
		 * @return	Clean address
		 */
		public static function cleanUp(address:String):String
		{
			return address.replace(/[\s\\]+/g, '/').replace(/^\/+|[^a-z_0-9\-\/]+|\/+$/gi, '').replace(/\/+/g, '/').toLowerCase();
		}
		
		/**
		 * Compare two addresses
		 * @param	address1		Address string
		 * @param	address2		Address string
		 * @param	performCleanUp	Clean addresses before comparing
		 * @return	Address.CONTAINS, Address.CONTAINED, Address.EQUAL, Address.DIFFERENT
		 */
		public static function compare(address1:String, address2:String, performCleanUp:Boolean = false):int
		{
			var levels1:Array = getLevels(address1, performCleanUp);
			var levels2:Array = getLevels(address2, performCleanUp);
			
			var len1:int = levels1.length;
			var len2:int = levels2.length;
			var len:int = Math.min(len1, len2);
			
			for (var i:int = 0; i < len; ++i) { if (levels1[i] != levels2[i]) return DIFFERENT; }
			
			if (len1 == len2) return EQUAL;
			if (len1 < len2) return CONTAINED;
			return CONTAINS;
		}
		
		/**
		 * Get address levels
		 * @param	address			Address string
		 * @param	performCleanUp	Clean addresses first
		 * @return	Address levels
		 */
		public static function getLevels(address:String, performCleanUp:Boolean = false):Array
		{
			if (performCleanUp) address = cleanUp(address);
			return address.split('/');
		}
		
		/**
		 * Truncate address
		 * @param	address			Address string
		 * @param	startLevel		Start level
		 * @param	endLevel		End level
		 * @param	performCleanUp	Clean addresses first
		 * @return	Truncated address
		 */
		public static function truncate(address:String, startLevel:int = 0, endLevel:int = -1, performCleanUp:Boolean = false):String
		{
			var levels:Array = getLevels(address, performCleanUp);
			var len:int = levels.length;
			
			startLevel = NumberUtil.loopIndex(startLevel, len);
			endLevel = NumberUtil.loopIndex(endLevel, len);
			
			return levels.slice(startLevel, endLevel + 1).join('/');
		}
		
	}

}