package com.oxylusflash.framework.cookie 
{
	import flash.net.SharedObject;
	/**
	 * Flash cookie
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Cookie
	{
		/* Flash cookie */
		public function Cookie() 
		{
			throw new Error("Cookie class has static methods. No need for instatiation.");
		}
		
		/**
		 * Store local cookie
		 * @param	cookieName		Cookie name
		 * @param	cookieValue		Cookie value as string
		 * @param	expiresAfter	Number of milliseconds until the cookie expires (use 0 for no expiration period)
		 */
		public static function setCookie(cookieName:String, cookieValue:String, expiresAfter:Number = 0):void
		{
			var so:SharedObject;
			try { so = SharedObject.getLocal(cookieName);	} catch (error:Error) { trace("[COOKIE]: " + error.message); }
			if (so)
			{
				so.data.cookieValue	= cookieValue;
				so.data.expiresAfter = String(expiresAfter ? (new Date).getTime() + expiresAfter : 0);
				so.flush();
			}
		}
		
		/**
		 * Get local cookie value
		 * @param	cookieName	Cookie name
		 * @return	Cookie value
		 */
		public static function getCookie(cookieName:String):String
		{		
			var so:SharedObject;
			try { so = SharedObject.getLocal(cookieName);	} catch (error:Error) { trace("[COOKIE]: " + error.message); }
			if (so)
			{
				var expiresAfter:Number = Number(so.data.expiresAfter);
				if ((expiresAfter == 0 || expiresAfter >= (new Date).getTime()) && so.data.cookieValue != null) return so.data.cookieValue;
				deleteCookie(cookieName);
			}			
			return null;
		}
		
		/**
		 * Delete local cookie
		 * @param	cookieName	Cookie name
		 */
		public static function deleteCookie(cookieName:String):void
		{
			var so:SharedObject;
			try { so = SharedObject.getLocal(cookieName);	} catch (error:Error) { trace("[COOKIE]: " + error.message); }
			if (so) so.clear();
		}
		
	}

}