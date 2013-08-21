package com.oxylusflash.mmgallery 
{
	//{ region IMPORT CLASSES
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	
	import caurina.transitions.Tweener;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class ToolTip extends Sprite
	{
		//{ region FIELDS
		public var lbl_mc : MovieClip;
		public var title_mc : MovieClip;
		public var tr_mc : MovieClip;
		public var stroke_mc : MovieClip;
		public var bg_mc : MovieClip;
		
		internal const DESTROY : String = "desTroyMe";
		internal const REMOVE_LISTENER:String = "removeListener";
		
		internal const BG_POS : int = 1;
		private const TITLE_POS : int = 3;
		
		private var _settings : Object;
		private var _compH : int = -1;
		private var _itIsFlipped : Boolean = false;
		//} endregion
		
		//{ region CONSTRUCTOR
		public final function ToolTip() 
		{
			this.visible = false;
			this.alpha = 0;
			
			//formatting lbl_mc.txt
			lbl_mc.txt.autoSize = TextFieldAutoSize.LEFT;
			lbl_mc.txt.selectable = false;
			lbl_mc.txt.condenseWhite = true;
			lbl_mc.txt.multiline = false;
			lbl_mc.txt.embedFonts = true;
			lbl_mc.txt.wordWrap = false;
			lbl_mc.txt.text = "";
			lbl_mc.txt.mouseWheelEnabled = false;
			//for testing only
			//lbl_mc.txt.background = true;
			//lbl_mc.txt.backgroundColor = 0x006633;
			
			//formatting title_mc.txt
			title_mc.txt.autoSize = TextFieldAutoSize.LEFT;
			title_mc.txt.selectable = false;
			title_mc.txt.condenseWhite = true;
			title_mc.txt.multiline = false;
			title_mc.txt.embedFonts = true;
			title_mc.txt.wordWrap = false;
			title_mc.txt.text = "";
			title_mc.txt.mouseWheelEnabled = false;
			//for testing only
			//title_mc.txt.background = true;
			//title_mc.txt.backgroundColor = 0x006633;
		}
		//} endregion
		
		//{ region EVENT HANDLERS//////////////////////////////////////////////////////////////////////////////////////
		
		//} endregion
		
		//{ region METHODS//////////////////////////////////////////////////////////////////////////////////////
		
		//{ region SHOW ME
		internal function ShowMe(pShow : Boolean = true, destroyMe : Boolean = false):void 
		{
			if (pShow) 
			{//SHOW
				
				if (Tweener.isTweening(this)) 
				{
					this.visible = false;
					this.alpha = 0;
					Tweener.removeTweens(this);
				}
				
				this.visible = true;
				Tweener.addTween(this, { alpha: 1, time: 0.3, transition: "easeoutquad" } );
			}else 
			{//HIDE
				Tweener.addTween(this, { alpha: 0, time: 0.3, transition: "easeoutquad", onComplete: function ():void 
				{
					this.visible = false;
					
					if (destroyMe) 
					{
						dispatchEvent(new Event(DESTROY));
					}else 
					{
						dispatchEvent(new Event(REMOVE_LISTENER));
					}
				} });
			}
		}
		//} endregion
		
		//{ region SET ME
		internal final function SetMe(pType : Boolean = true):void 
		{
			if (pType) 
			{//under mouse tool tip
				tr_mc.y = 0;
				stroke_mc.x = 0;
				stroke_mc.y = int((tr_mc.y + tr_mc.height) - BG_POS);
				
				bg_mc.x = BG_POS;
				bg_mc.y = stroke_mc.y + BG_POS;
				
				ResizeMe();
			}else 
			{//over thumb tool tip
				stroke_mc.x = 
				stroke_mc.y = 0;
				
				bg_mc.x = 
				bg_mc.y = BG_POS;
				
				lbl_mc.removeChild(lbl_mc.txt);
				lbl_mc.txt = null;
				this.removeChild(lbl_mc);
				lbl_mc = null;
				
				ResizeMe(false);
				tr_mc.rotation = 180;
				tr_mc.y = int(bg_mc.height + tr_mc.height + BG_POS);
			}
		}
		//} endregion
		
		//{ region RESIZE ME
		internal final function ResizeMe(pType : Boolean = true):void
		{
			if (pType) 
			{
				if (_settings.useUpperCase) 
				{
					title_mc.txt.text = title_mc.txt.text.toUpperCase();
					lbl_mc.txt.text = lbl_mc.txt.text.toUpperCase();
				}
				
				lbl_mc.x = _settings.textOffsetX;
				lbl_mc.y = stroke_mc.y + _settings.textOffsetY;
				
				title_mc.x = int(lbl_mc.x + lbl_mc.txt.textWidth + TITLE_POS);
				title_mc.y = lbl_mc.y;
				
				bg_mc.width = int(title_mc.x + title_mc.txt.textWidth + 1 + _settings.textOffsetX);
				
				stroke_mc.height = bg_mc.height + 2 * BG_POS;
				stroke_mc.width = 2 * bg_mc.x + bg_mc.width;
				
				tr_mc.x = int((stroke_mc.width - tr_mc.width) * 0.5);
				compH = int(stroke_mc.height + stroke_mc.y - BG_POS);
			}else 
			{
				if (_settings.useUpperCase) 
				{
					
					title_mc.txt.text = title_mc.txt.text.toUpperCase();
				}
				
				title_mc.x = _settings.textOffsetX;
				//int((bg_mc.width - title_mc.txt.textWidth) * 0.5);
				title_mc.y = _settings.textOffsetY;
				
				//bg_mc.width = int(title_mc.x + title_mc.txt.textWidth + _settings.textOffsetX);
				bg_mc.width = int(2 * title_mc.x + title_mc.txt.textWidth + 1);
				
				stroke_mc.height = bg_mc.height + 2 * BG_POS;
				stroke_mc.width = 2 * bg_mc.x + bg_mc.width;
				
				tr_mc.x = int((stroke_mc.width + tr_mc.width) * 0.5);
				compH = int(tr_mc.y);
			}
		}
		//} endregion
		
		//{ region DESTROY
		internal final function Destroy():void 
		{
			if (lbl_mc) 
			{
				lbl_mc.removeChild(lbl_mc.txt);
				lbl_mc.txt = null;
				this.removeChild(lbl_mc);
				lbl_mc = null;
			}
			
			if (title_mc) 
			{
				title_mc.removeChild(title_mc.txt);
				title_mc.txt = null;
				this.removeChild(title_mc);
				title_mc = null;
			}
			
			if (tr_mc) 
			{
				this.removeChild(tr_mc);
				tr_mc = null;
			}
			
			if (stroke_mc) 
			{
				this.removeChild(stroke_mc);
				stroke_mc = null;
			}
			
			if (bg_mc) 
			{
				this.removeChild(bg_mc);
				bg_mc = null;
			}
		}
		//} endregion
		
		//{ region FLIP ME
		internal final function FlipMe(pType : Boolean = true):void 
		{
			if (pType) 
			{//rotate 0
				_itIsFlipped = false;
				this.visible = false;
				
				if (tr_mc.rotation == 180) 
				{
					tr_mc.rotation = 0;
				}
				
				tr_mc.y = 0;
				
				stroke_mc.x = 0;
				stroke_mc.y = int((tr_mc.y + tr_mc.height) - BG_POS);
				
				bg_mc.x = BG_POS;
				bg_mc.y = stroke_mc.y + BG_POS;
				
				lbl_mc.x = _settings.textOffsetX;
				lbl_mc.y = stroke_mc.y + _settings.textOffsetY;
				
				title_mc.x = int(lbl_mc.x + lbl_mc.txt.textWidth + TITLE_POS);
				title_mc.y = lbl_mc.y;
				
				bg_mc.width = int(title_mc.x + title_mc.txt.textWidth + 1 + _settings.textOffsetX);
				
				stroke_mc.height = bg_mc.height + 2 * BG_POS;
				stroke_mc.width = 2 * bg_mc.x + bg_mc.width;
				
				tr_mc.x = int((stroke_mc.width - tr_mc.width) * 0.5);
				this.visible = true;
			}else 
			{//rotate 180
				_itIsFlipped = true;
				this.visible = false;
				
				stroke_mc.x = 
				stroke_mc.y = 0;
				
				bg_mc.x = 
				bg_mc.y = BG_POS;
				
				lbl_mc.x = _settings.textOffsetX;
				lbl_mc.y = _settings.textOffsetY;
				
				title_mc.x = int(lbl_mc.x + lbl_mc.txt.textWidth + TITLE_POS);
				
				title_mc.y = lbl_mc.y;
				
				bg_mc.width = int(title_mc.x + title_mc.txt.textWidth + 1 + _settings.textOffsetX);
				
				stroke_mc.height = bg_mc.height + 2 * BG_POS;
				stroke_mc.width = 2 * bg_mc.x + bg_mc.width;
				
				tr_mc.x = int((stroke_mc.width + tr_mc.width) * 0.5);
				
				if (tr_mc.rotation == 0) 
				{
					tr_mc.rotation = 180;
				}
				
				tr_mc.y = int(bg_mc.height + tr_mc.height + BG_POS);
				this.visible = true;
			}
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		internal function get settings():Object { return _settings; }
		internal function set settings(value:Object):void 
		{
			_settings = value;
		}
		
		internal function get compH():int { return _compH; }
		internal function set compH(value:int):void 
		{
			_compH = value;
		}
		
		internal function get itIsFlipped():Boolean { return _itIsFlipped; }
		internal function set itIsFlipped(value:Boolean):void 
		{
			_itIsFlipped = value;
		}
		//} endregion
	}
}