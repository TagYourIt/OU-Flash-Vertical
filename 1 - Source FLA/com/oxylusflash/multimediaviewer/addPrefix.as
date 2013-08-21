package com.oxylusflash.multimediaviewer 
{
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	//{ region ADD PREFIX
	internal function addPrefix(pTotalSec : Number = 0, pPartSec : Number = 0):String
	{
		var minutes : Number = Math.floor(pTotalSec / 60);
		var hours : Number = Math.floor(minutes / 60);
		hours %= 24;
		
		var pMin : Number = Math.floor(pPartSec / 60);
		var pHours : Number = Math.floor(pMin / 60);
		pHours %= 24;
		
		var timeString:String = "";
		if (hours && !pHours) timeString = "00:";
		return timeString;
	}
	//} endregion
	
}