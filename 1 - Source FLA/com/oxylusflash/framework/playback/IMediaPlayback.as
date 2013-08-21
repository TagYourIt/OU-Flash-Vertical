package com.oxylusflash.framework.playback 
{
	/**
	 * Interface for audio/video playback
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public interface IMediaPlayback 
	{
		/* Methods */
		
		function clear():void;
		function load(media:String):void;
		function play():void;
		function pause():void;
		function stop():void;
		function seek(to:Number, percent:Boolean = true):void;
		function replay():void;	

		/* Read-only properties */
		
		function get buffering():Boolean;
		function get loaded():Boolean;
		function get ready():Boolean;
		function get playing():Boolean;
		function get totalTime():Number;
		function get totalBytes():Number;
		function get loadedBytes():Number;
		
		/* Properties */
		
		function get currentTime():Number;
		function set currentTime(value:Number):void;
		function get buffer():Number;
		function set buffer(value:Number):void;
		function get autoPlay():Boolean;
		function set autoPlay(value:Boolean):void;
		function get repeat():Boolean;
		function set repeat(value:Boolean):void;
		function get volume():Number;
		function set volume(value:Number):void;
		function get media():String;
		function set media(value:String):void;
		
	}
	
}