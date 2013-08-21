package com.oxylusflash.mmgallery 
{
	//{ region IMPORT CLASSES
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import caurina.transitions.Tweener;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class MmSign extends Sprite
	{
		//{ region FIELDS
		public var vid_mc : MovieClip;
		public var flash_mc : MovieClip;
		public var music_mc : MovieClip;
		
		private var _destroyMe : Boolean = false;
		//} endregion
		
		//{ region CONSTRUCTOR
		public function MmSign(pType : String = "") 
		{
			this.visible = false;
			this.alpha = 0;
			
			this.buttonMode = true;
			this.mouseChildren = false;
			
			vid_mc.visible = 
			flash_mc.visible = 
			music_mc.visible = false;
			
			vid_mc.alpha = 
			flash_mc.alpha = 
			music_mc.alpha = 0;
			
			switch (pType) 
			{
				case "video":
					removeChild(flash_mc);
					removeChild(music_mc);
					flash_mc = null;
					music_mc = null;
					
					vid_mc.visible = true;
					vid_mc.alpha = 1;
				break;
				
				case "flash":
					removeChild(vid_mc);
					removeChild(music_mc);
					vid_mc = null;
					music_mc = null;
					
					flash_mc.visible = true;
					flash_mc.alpha = 1;
				break;
				
				case "audio":
					removeChild(flash_mc);
					removeChild(vid_mc);
					flash_mc = null;
					vid_mc = null;
					
					music_mc.visible = true;
					music_mc.alpha = 1;
				break;
				
				default:
					Destroy();
				break;
			}
		}
		//} endregion
		
		//{ region EVENT HANDLERS//////////////////////////////////////////////////////////////////////////////////////////////////
		
		//} endregion
		
		//{ region METHODS/////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		//{ region DESTROY
		internal final function Destroy():void 
		{
			_destroyMe = true;
			if (flash_mc) 
			{
				removeChild(flash_mc);
				flash_mc = null;
			}
			
			if (vid_mc) 
			{
				removeChild(vid_mc);
				vid_mc = null;
			}
			
			if (music_mc) 
			{
				removeChild(music_mc);
				music_mc = null;
			}
			//this = null;
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		internal function get destroyMe():Boolean { return _destroyMe; }
		internal function set destroyMe(value:Boolean):void 
		{
			_destroyMe = value;
		}
		//} endregion
	}
}