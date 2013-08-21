/* @author: Adrian Bota, adrian@oxylus.ro
 * @last update: 11/26/09 (mm/dd/yy)
 */

package com.oxylusflash.AVPlayback.events 
{
	import flash.events.Event;
	
	public class PlaybackEvent extends Event 
	{
		/* Fired when media is loading. */
		public static const LOAD_PROGRESS:String = "loadProgress";
		
		/* Fired when media is buffering. */
		public static const BUFFERING:String = "buffering";
		
		/* Fired when media is buffering, everytime the buffer is updating. */
		public static const BUFFER_PROGRESS:String = "bufferProgress";
		
		/* Fired when media buffering is done. */
		public static const BUFFER_FULL:String = "bufferFull";
		
		/* Fired when media is ready for playback. */
		public static const PLAYBACK_READY:String = "playbackReady";
		
		/* Fired when current/total playback time is updated. */
		public static const PLAYBACK_TIME_UPDATE:String = "playbackTimeUpdate";
		
		/* Fired when playback starts. */
		public static const PLAYBACK_START:String = "playbackStart";
		
		/* Fired when playback stops/pauses. */
		public static const PLAYBACK_STOP:String = "playbackStop";
		
		/* Fired when playback completes. */
		public static const PLAYBACK_COMPLETE:String = "playbackComplete";
		
		/* Fired when an error occurs. */
		public static const ERROR:String = "error";
		
		/* Fired for mp3 files when ID3 is available. */
		public static const MP3_ID3:String = "mp3ID3";
		
		/* Event information object.
		 * Properties, readonly :
		 * - target : [PlaybackController] controller instance reference (available for all events)
		 * - currentTime : [Number] Current playback time in seconds (available for PLAYBACK_TIME_UPDATE event)
		 * - totalTime : [Number] Total playback time in seconds (available for PLAYBACK_TIME_UPDATE event)
		 * - currentTimeString : [String] Current playback time string (e.g.: 08:45) (available for PLAYBACK_TIME_UPDATE event)
		 * - totalTimeString : [String] Total playback time string (available for PLAYBACK_TIME_UPDATE event)
		 * - totalBytes : [Number] Total bytes (available for LOAD_PROGRESS event)
		 * - loadedBytes : [Number] Loaded bytes (available for LOAD_PROGRESS event)
		 * - progress : [Number] Buffering porgress, between (0, 1) (available for BUFFER_PROGRESS event)
		 * - message : [String] Error message (available for ERROR event)
		 * - id3 : [ID3Info] ID3 info object for mp3 files (available for MP3_ID3 event)
		 */
		public var info:Object;
		
		public function PlaybackEvent(type:String, infoObj:Object) 
		{
			super(type);
			this.info = infoObj;
		}
	}
}












