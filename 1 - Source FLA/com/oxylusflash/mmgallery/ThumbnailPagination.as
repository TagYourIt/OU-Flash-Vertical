package com.oxylusflash.mmgallery 
{
	//{ region IMPORT CLASSES
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	import caurina.transitions.Tweener;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class ThumbnailPagination extends Sprite
	{
		//{ region FIELDS
		public var bg_mc : MovieClip;
		public var h_mc : MovieClip;
		public var thumbBtn_mc : ThumbBtn;
		public var toolTip_mc : ToolTip;
		
		private var _pagSignal : Signal;
		private var _totalNrOfThumbs : int = 0;
		private var _uCase : Boolean = true;
		private var _settings : Object;
		private var _toolTipSettings : Object;
		private var _bgWidth : uint = 0;
		private var _bgHeight : uint = 0;
		private var _hideMe : Boolean = false;
		
		private var btnLimit : uint = 0;
		private var thumbInd : int = 0;
		private var old_ChildInd : int = -1;
		private var selectedChild : int = 0;
		
		private var old_XmlEnd : int = -1;
		private var old_xmlStart : int = -1;
		//} endregion
		
		//{ region CONSTRUCTOR
		public function ThumbnailPagination() 
		{
			//...
			_pagSignal = new Signal(int, int);
			this.visible = false;
			this.alpha = 0;
			this.mouseChildren = true;
		}
		//} endregion
		
		//{ region EVENT HANDLERS///////////////////////////////////////////////////////////////////////
		
		//{ region THUMB SIGNAL HANDLER
		private final function thumbSignalHandler(pAction : String = "", childInd : int = -1):void
		{
			switch (pAction) 
			{
				case "THUMB ROLL OVER":
					ToggleToolTip(true, 
					ThumbBtn(h_mc.getChildAt(childInd)).xmlStart, 
					ThumbBtn(h_mc.getChildAt(childInd)).xmlEnd, 
					ThumbBtn(h_mc.getChildAt(childInd)).x, 
					ThumbBtn(h_mc.getChildAt(childInd)).n_mc.width
					);
				break;
				
				case "THUMB ROLL OUT":
					ToggleToolTip(false);
				break;
				
				case "THUMB CLICK":
					if (old_ChildInd != -1 && old_ChildInd != childInd) 
					{
						ThumbBtn(h_mc.getChildAt(old_ChildInd)).isSelected = false;
						ThumbBtn(h_mc.getChildAt(old_ChildInd)).buttonMode = true;
						ThumbBtn(h_mc.getChildAt(old_ChildInd)).mouseEnabled = true;
						ThumbBtn(h_mc.getChildAt(old_ChildInd)).doUnSelAnim();
					}
					
					ToggleToolTip(false);
					
					if (childInd != old_ChildInd || childInd == old_ChildInd) 
					{
						if (old_xmlStart != ThumbBtn(h_mc.getChildAt(childInd)).xmlStart || old_XmlEnd != ThumbBtn(h_mc.getChildAt(childInd)).xmlEnd) 
						{
							old_xmlStart = ThumbBtn(h_mc.getChildAt(childInd)).xmlStart;
							old_XmlEnd = ThumbBtn(h_mc.getChildAt(childInd)).xmlEnd;
							_pagSignal.dispatch(ThumbBtn(h_mc.getChildAt(childInd)).xmlStart, ThumbBtn(h_mc.getChildAt(childInd)).xmlEnd);
						}
						
						selectedChild = childInd;
						ThumbBtn(h_mc.getChildAt(childInd)).isSelected = true;
						if (ThumbBtn(h_mc.getChildAt(childInd)).mouseEnabled) 
						{
							ThumbBtn(h_mc.getChildAt(childInd)).buttonMode = false;
							ThumbBtn(h_mc.getChildAt(childInd)).mouseEnabled = false;
						}
						ThumbBtn(h_mc.getChildAt(childInd)).doSelAnim();
						old_ChildInd = childInd;
					}
				break;
			}
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS//////////////////////////////////////////////////////////////////////////////
		
		//{ region SET THUMB
		internal final function SetThumb(pThumbPerPage : uint = 0):void 
		{
			btnLimit = Math.ceil(_totalNrOfThumbs / pThumbPerPage);
			if (h_mc) 
			{
				if (this.contains(h_mc)) 
				{
					old_ChildInd = -1;
					thumbInd = 0;
					this.removeChild(h_mc);
					
					while (h_mc.numChildren-1) 
					{
						thumbBtn_mc = ThumbBtn(h_mc.getChildAt(h_mc.numChildren - 1));
						thumbBtn_mc.signal.remove(thumbSignalHandler);
						thumbBtn_mc.Destroy();
						h_mc.removeChild(thumbBtn_mc);
						thumbBtn_mc = null;
					}
					h_mc = null;
				}
			}
				
			if (!h_mc) 
			{
				h_mc = new MovieClip();
				this.addChild(h_mc);
			}
			
			h_mc.x = _settings.holderOffsetX;
			h_mc.y = _settings.holderOffsetY;
			
			for (var i:int = 0; i < btnLimit; ++i) 
			{
				thumbBtn_mc = new ThumbBtn();
				
				//set XML start point & end point
				if (i != btnLimit - 1) 
				{
					thumbBtn_mc.xmlStart = Math.round(pThumbPerPage * i);
					thumbBtn_mc.xmlEnd = Math.round(pThumbPerPage * (i + 1));
				}else 
				{//last one
					thumbBtn_mc.xmlStart = Math.round(pThumbPerPage * i);
					thumbBtn_mc.xmlEnd = _totalNrOfThumbs;
					
					if ((thumbBtn_mc.xmlEnd - thumbBtn_mc.xmlStart) < pThumbPerPage) 
					{
						thumbBtn_mc.xmlStart = thumbBtn_mc.xmlStart - (pThumbPerPage - (thumbBtn_mc.xmlEnd - thumbBtn_mc.xmlStart));
					}
				}
				
				thumbBtn_mc.x = (thumbBtn_mc.n_mc.width + _settings.offsetX) * i;
				thumbBtn_mc.y = _settings.offsetY;
				thumbBtn_mc.signal.add(thumbSignalHandler);
				
				if (i == btnLimit-1) 
				{
					_bgWidth = int(2 * _settings.holderOffsetX + thumbBtn_mc.x + thumbBtn_mc.n_mc.width);
					_bgHeight = int(2 * _settings.holderOffsetY + thumbBtn_mc.n_mc.height);
					
					bg_mc.width = _bgWidth;
					bg_mc.height = _bgHeight;
				}
				
				thumbBtn_mc.childInd = thumbInd;
				h_mc.addChildAt(thumbBtn_mc, thumbInd);
				thumbBtn_mc.ShowMe();
				
				if (selectedChild == thumbInd) 
				{
					thumbBtn_mc.clickHandler();
				}else 
				{
					if (selectedChild > btnLimit-1 && i == btnLimit-1) 
					{
						thumbBtn_mc.clickHandler();
					}
				}
				
				thumbInd++;
			}
			
			if (btnLimit > 1 || _hideMe) 
			{
				ShowComp();
			}else 
			{
				ShowComp(false);
			}
		}
		//} endregion
		
		//{ region SHOW COMP
		private final function ShowComp(pShow : Boolean = true):void
		{
			if (pShow) 
			{
				if (Tweener.isTweening(this)) 
				{
					Tweener.removeTweens(this);
				}
				
				this.visible = true;
				Tweener.addTween(this, { alpha: 1, time: 0.3, transition: "easeoutquad" });
			}else 
			{
				Tweener.addTween(this, { alpha: 0, time: 0.3, transition: "easeoutquad", onComplete: function ():void 
				{
					this.visible = false;
				} });
			}
		}
		//} endregion
		
		//{ region TOGGLE TOOL TIP
		private final function ToggleToolTip(pShow : Boolean = false, xmlStart : int = -1, xmlEnd : int = -1, thumbX : int = -1, thumbW : int = -1):void
		{
			if (pShow) 
			{//SHOW
				if (toolTip_mc) 
				{//SHOW
					toolTip_mc.title_mc.txt.htmlText = _toolTipSettings.pagination.replace("%FROM%", xmlStart + 1).replace("%TO%", xmlEnd).replace("%TOTAL%", _totalNrOfThumbs);
					toolTip_mc.ResizeMe(false);
				}else 
				{//CREATE IT
					toolTip_mc = new ToolTip();
					toolTip_mc.settings = _toolTipSettings;
					toolTip_mc.title_mc.txt.text = _toolTipSettings.pagination.replace("%FROM%", xmlStart + 1).replace("%TO%", xmlEnd).replace("%TOTAL%", _totalNrOfThumbs);
					toolTip_mc.SetMe(false);
					this.addChild(toolTip_mc);
				}
				
				toolTip_mc.y = int(bg_mc.y - (toolTip_mc.tr_mc.y + toolTip_mc.settings.offsetY));
				toolTip_mc.x = int((h_mc.x + thumbX + toolTip_mc.settings.offsetX) + (thumbW - toolTip_mc.stroke_mc.width) * 0.5);
				toolTip_mc.ShowMe();
			}else 
			{//HIDE
				if (toolTip_mc) 
				{
					toolTip_mc.ShowMe(false);
				}
			}
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		internal function get totalNrOfThumbs():int { return _totalNrOfThumbs; }
		internal function set totalNrOfThumbs(value:int):void 
		{
			_totalNrOfThumbs = value;
		}
		
		internal function get uCase():Boolean { return _uCase; }
		internal function set uCase(value:Boolean):void 
		{
			_uCase = value;
		}
		
		internal function get settings():Object { return _settings; }
		internal function set settings(value:Object):void 
		{
			_settings = value;
		}
		
		internal function get bgHeight():uint { return _bgHeight; }
		internal function set bgHeight(value:uint):void 
		{
			_bgHeight = value;
		}
		
		internal function get bgWidth():uint { return _bgWidth; }
		internal function set bgWidth(value:uint):void 
		{
			_bgWidth = value;
		}
		
		internal function get hideMe():Boolean { return _hideMe; }
		internal function set hideMe(value:Boolean):void 
		{
			_hideMe = value;
		}
		
		internal function get pagSignal():Signal { return _pagSignal; }
		internal function set pagSignal(value:Signal):void 
		{
			_pagSignal = value;
		}
		
		internal function get toolTipSettings():Object { return _toolTipSettings; }
		internal function set toolTipSettings(value:Object):void 
		{
			_toolTipSettings = value;
		}
		//} endregion
	}
}