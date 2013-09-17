package com.oxylusflash.mmgallery 
{
	//{ region IMPORT CLASSES
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import org.osflash.signals.Signal;
	import com.oxylusflash.framework.util.StringUtils;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class YouTubeXML
	{
		//{ region FIELDS
		private var _ytSignal : Signal;
		private var urlREQ : URLRequest;
		private var urlLoader : URLLoader;
		private var vidURLvariables : URLVariables;
		private var ytXML : XML;
		//} endregion
		
		//{ region CONSTRUCTOR
		public function YouTubeXML() 
		{
			//...
			_ytSignal = new Signal(Object);
		}
		//} endregion
		
		//{ region EVENT HANDLERS//////////////////////////////////////////////////////////////
		
		//{ region URL LOADER SECURITY ERROR HANDLER
		private final function urlLoader_SecurityErrorHandler(e:SecurityErrorEvent):void 
		{
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoader_SecurityErrorHandler);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, urlLoader_IoErrorHandler);
			urlLoader.removeEventListener(Event.COMPLETE, urlLoader_CompleteHandler);
			trace("youtube XML loader Security Error, class YouTubeXML.as", e);
			
			try 
			{
				urlLoader.close();
				urlLoader = null;
			}catch (err:Error)
			{
			}
		}
		//} endregion
		
		//{ region URL LOADER IO ERROR HANDLER
		private final function urlLoader_IoErrorHandler(e:IOErrorEvent):void 
		{
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoader_SecurityErrorHandler);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, urlLoader_IoErrorHandler);
			urlLoader.removeEventListener(Event.COMPLETE, urlLoader_CompleteHandler);
			trace("youtube XML loader IOError, class YouTubeXML.as", e);
			
			try 
			{
				urlLoader.close();
				urlLoader = null;
			}catch (err:Error)
			{
			}
		}
		//} endregion
		
		//{ region URL LOADER COMPLETE HANDLER
		private final function urlLoader_CompleteHandler(e:Event):void 
		{
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoader_SecurityErrorHandler);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, urlLoader_IoErrorHandler);
			urlLoader.removeEventListener(Event.COMPLETE, urlLoader_CompleteHandler);
			
			ytXML = new XML(urlLoader.data);
			namespace atom = "http://www.w3.org/2005/Atom"
			namespace media = "http://search.yahoo.com/mrss/";
			namespace gd = "http://schemas.google.com/g/2005";
			namespace yt = "http://gdata.youtube.com/schemas/2007";
			namespace etag = "W/&quot;D0ACQ347eCp7ImA9Wx5RF0w.&quot;";
			_ytSignal.dispatch(
			{
				picUrl : String(XMLList(ytXML.media::group.media::thumbnail)[0].@url), 
				
				title : String(XMLList(ytXML.media::group.media::title)), 
				videoID : String(XMLList(ytXML.media::group.yt::videoid))
			});
			//trace(picUrl);
			try 
			{
				urlLoader.close();
				urlLoader = null;
			}catch (err:Error)
			{
			}
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS/////////////////////////////////////////////////////////////////////
		
		//{ region LOAD YOU TUBE XML
		public function LoadYtXML(pDetailView : XMLList, _yt_settings : Object):void 
		{
			urlREQ = new URLRequest(_yt_settings.API.location + StringUtils.squeeze(pDetailView.file));
			
			urlLoader = new URLLoader();
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoader_SecurityErrorHandler, false, 0, true);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoader_IoErrorHandler, false, 0, true);
			urlLoader.addEventListener(Event.COMPLETE, urlLoader_CompleteHandler, false, 0, true);
			
			vidURLvariables = new URLVariables();
			vidURLvariables.v = _yt_settings.API.version;
			vidURLvariables.format = _yt_settings.API.format;
			urlREQ.data = vidURLvariables;
			
			try 
			{
				urlLoader.load(urlREQ);
			} 
			catch (error:SecurityError) 
			{
				trace("A SecurityError occurred while loading, class YouTubeXML.as", urlREQ.url);
			}
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		public function get ytSignal():Signal { return _ytSignal; }
		public function set ytSignal(value:Signal):void 
		{
			_ytSignal = value;
		}
		//} endregion
	}
}