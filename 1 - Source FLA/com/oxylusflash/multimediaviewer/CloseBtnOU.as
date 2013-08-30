package com.oxylusflash.multimediaviewer 
{
	//{ region IMPORT CLASSES
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	
	import caurina.transitions.Tweener;
	
	import org.osflash.signals.Signal;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class CloseBtnOU extends Sprite
	{
		//{ region FIELDS
		//public var lbl_mc : MovieClip;
		//public var sign_mc : MovieClip;
		public var hitArea_mc : MovieClip;
		
		private var _btnSignal : Signal;
		//private var _nAlpha : Number = 0.3;
		//private var _oAlpha : Number = 0.5;
		private var _drag : Boolean = false;
		//} endregion
		
		//{ region CONSTRUCTOR
		public function CloseBtnOU() 
		{
			_btnSignal = new Signal(String);
			this.visible = false;
			this.alpha = 0;
			
			this.buttonMode = true;
			this.mouseChildren = false;
			this.mouseEnabled = false;
			
			//sign_mc.o_mc.visible = false;
			//sign_mc.o_mc.alpha = 0;
			
			//formatting lbl_mc.txt
			//lbl_mc.txt.autoSize = TextFieldAutoSize.LEFT;
			//lbl_mc.txt.selectable = false;
			//lbl_mc.txt.condenseWhite = true;
			//lbl_mc.txt.multiline = false;
			//lbl_mc.txt.embedFonts = true;
			//lbl_mc.txt.wordWrap = false;
			//lbl_mc.txt.text = "";
			//lbl_mc.txt.mouseWheelEnabled = false;
			//for testing only
			//lbl_mc.txt.background = true;
			//lbl_mc.txt.backgroundColor = 0x006633;
			
			//this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, false, 0, true);
			//this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, 0, true);
			this.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
		}
		//} endregion
		
		//{ region EVENT HANDLERS//////////////////////////////////////////////////////////////////////////////
		
		//{ region ROLL OVER HANDLER
		/*private final function rollOverHandler(e:MouseEvent):void 
		{
			sign_mc.o_mc.visible = true;
			Tweener.addTween(sign_mc.o_mc, { alpha: 1, time: 0.3, transition: "easeoutquad" } );
			Tweener.addTween(lbl_mc.txt, { alpha: _oAlpha, time: 0.3, transition: "easeoutquad" });
		}*/
		//} endregion
		
		//{ region ROLL OUT HANDLER
		/*public final function rollOutHandler(e:MouseEvent = null):void 
		{
			if (!_drag) 
			{
				Tweener.addTween(sign_mc.o_mc, { alpha: 0, time: 0.3, transition: "easeoutquad", onComplete: function ():void 
				{
					sign_mc.o_mc.visible = false;
				} } );
				Tweener.addTween(lbl_mc.txt, { alpha: _nAlpha, time: 0.3, transition: "easeoutquad" });
			}
			
		}*/
		//} endregion
		
		//{ region CLICK HANDLER
		private final function clickHandler(e:MouseEvent):void 
		{
			_btnSignal.dispatch("CLOSE ME");
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS/////////////////////////////////////////////////////////////////////////////////////
		
		//{ region DESTROY
		internal final function Destroy():void 
		{
			//this.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			//this.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			this.removeEventListener(MouseEvent.CLICK, clickHandler);
			
			/*if (Tweener.isTweening(sign_mc.o_mc))
			{
				Tweener.removeTweens(sign_mc.o_mc);
			}
			
			if (Tweener.isTweening(sign_mc.n_mc))
			{
				Tweener.removeTweens(sign_mc.n_mc);
			}
			
			if (Tweener.isTweening(lbl_mc.txt))
			{
				Tweener.removeTweens(lbl_mc.txt);
			}
			
			sign_mc.removeChild(sign_mc.o_mc);
			sign_mc.o_mc = null;
			sign_mc.removeChild(sign_mc.n_mc);
			sign_mc.n_mc = null;
			
			this.removeChild(sign_mc);
			sign_mc = null;
			
			lbl_mc.removeChild(lbl_mc.txt);
			lbl_mc.txt = null;
			
			this.removeChild(lbl_mc);
			lbl_mc = null;*/
			
			this.parent.removeChild(this);
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		public function get btnSignal():Signal { return _btnSignal; }
		public function set btnSignal(value:Signal):void 
		{
			_btnSignal = value;
		}
		
		//internal function get oAlpha():Number { return _oAlpha; }
		//internal function set oAlpha(value:Number):void 
		/*{
			_oAlpha = value;
		}*/
		
		//internal function get nAlpha():Number { return _nAlpha; }
		//internal function set nAlpha(value:Number):void 
		/*{
			_nAlpha = value;
		}*/
		
		public function get drag():Boolean { return _drag; }
		public function set drag(value:Boolean):void 
		{
			_drag = value;
		}
		//} endregion
	}
}


