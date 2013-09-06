package com.oxylusflash.mmgallery 
{
	//{ region IMPORT CLASSES
	import caurina.transitions.Tweener;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.osflash.signals.Signal;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public final class ThumbBtn extends Sprite
	{
		//{ region FIELDS
		public var n_mc : MovieClip;
		public var o_mc : MovieClip;
		public var s_mc : MovieClip;
		
		private var _childInd : int = -1;
		private var _signal : Signal;
		private var _isSelected : Boolean = false;
		
		private var _xmlStart : int = 0;
		private var _xmlEnd : int = 0;
		//} endregion
		
		//{ region CONSTRUCTOR
		public final function ThumbBtn() 
		{
			this.visible = false;
			this.alpha = 0;
			
			_signal = new Signal(String, int);
			
			o_mc.visible = false;
			o_mc.alpha - 0;
			
			s_mc.visible = false;
			s_mc.alpha = 0;
			
			this.buttonMode = true;
			this.mouseChildren = false;
			this.mouseEnabled = false;
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, 0, true);
			this.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			
			
		}
		//} endregion
		
		//{ region EVENT HANDLERS///////////////////////////////////////////////////////////////////////////////////////////////
		
		//{ region INIT
		private final function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.visible = false;
			Tweener.addTween(this, { alpha: 1, time: 0.3, transition: "easeoutquad" });
			
		}
		//} endregion
		
		//{ region ROLL OVER HANDLER
		private final function rollOverHandler(e:MouseEvent):void 
		{
			_signal.dispatch("THUMB ROLL OVER", childInd);
			doRollOverAnim();
		}
		//} endregion
		
		//{ region ROLL OUT HANDLER
		private final function rollOutHandler(e:MouseEvent):void 
		{
			if (!isSelected) 
			{
				_signal.dispatch("THUMB ROLL OUT", childInd);
				doROllOutAnim();
			}
		}
		//} endregion
		
		//{ region CLICK HANDLER
		internal final function clickHandler(e:MouseEvent = null):void 
		{
			_signal.dispatch("THUMB CLICK", childInd);
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		//{ region DO ROLL OVER ANIM
		internal final function doRollOverAnim():void
		{
			o_mc.visible = true;
			Tweener.addTween(o_mc, { alpha: 1, time: 0.3, transition: "easeoutquad" });
		}
		//} endregion
		
		//{ region DO ROLL OUT ANIM
		internal final function doROllOutAnim():void
		{
			Tweener.addTween(o_mc, { alpha: 0, time: 0.3, transition: "easeoutquad", onComplete: function ():void 
			{
				o_mc.visible = false;
			} });
		}
		//} endregion
		
		//{ region DO SEL ANIM
		internal final function doSelAnim():void
		{
			s_mc.visible = true;
			Tweener.addTween(s_mc, { alpha: 1, time: 0.3, transition: "easeoutquad" });
		}
		//} endregion
		
		//{ region DO UNSEL ANIM
		internal final function doUnSelAnim():void
		{
			o_mc.visible = false;
			o_mc.alpha = 0;
			
			Tweener.addTween(s_mc, { alpha: 0, time: 0.3, transition: "easeoutquad", onComplete: function ():void 
			{
				s_mc.visible = false;
			} });
		}
		//} endregion
		
		//{ region SHOW ME
		internal final function ShowMe():void 
		{
			this.mouseEnabled = true;
			
			if (stage) 
			{
				init();
			}else 
			{
				this.addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			}
		}
		//} endregion
		
		//{ region DESTROY
		internal final function Destroy():void 
		{
			if (Tweener.isTweening(n_mc)) 
			{
				Tweener.removeTweens(n_mc);
			}
			
			if (Tweener.isTweening(o_mc)) 
			{
				Tweener.removeTweens(o_mc);
			}
			
			if (Tweener.isTweening(s_mc)) 
			{
				Tweener.removeTweens(s_mc);
			}
			
			this.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			this.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			this.removeEventListener(MouseEvent.CLICK, clickHandler);
			
			this.removeChild(n_mc);
			n_mc = null;
			this.removeChild(o_mc);
			o_mc = null;
			this.removeChild(s_mc);
			s_mc = null;
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		internal function get signal():Signal { return _signal; }
		internal function set signal(value:Signal):void 
		{
			_signal = value;
		}
		
		internal function get childInd():int { return _childInd; }
		internal function set childInd(value:int):void 
		{
			_childInd = value;
		}
		
		internal function get isSelected():Boolean { return _isSelected; }
		internal function set isSelected(value:Boolean):void 
		{
			_isSelected = value;
		}
		
		internal function get xmlEnd():int { return _xmlEnd; }
		internal function set xmlEnd(value:int):void 
		{
			_xmlEnd = value;
		}
		
		internal function get xmlStart():int { return _xmlStart; }
		internal function set xmlStart(value:int):void 
		{
			_xmlStart = value;
		}
		//} endregion
	}
}