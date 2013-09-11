package com.oxylusflash.multimediaviewer 
{
	//{ region IMPORT CLASSES
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	
	import fl.display.ProLoader;
	import flash.events.Event;
	import flash.text.TextField;	
	import flash.net.URLRequest;
	
	import caurina.transitions.Tweener;
	
	import org.osflash.signals.Signal;
	import com.oxylusflash.multimediaviewer.TogglePlayPause;
	
	
	
	
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class EmailBtnOU extends Sprite
	{
		
		private var _playPauseSignal : Signal;
		public var _iTunesLink : String;
		
		
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
		public function EmailBtnOU() 
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
		
		var fl_ProLoader_2:ProLoader;

		//This variable keeps track of whether you want to load or unload the SWF
		var fl_ToLoad_2:Boolean = true;		
		
		private final function clickHandler(e:MouseEvent):void 
		{
			_btnSignal.dispatch("EMAIL ME"); //goes to MultimediaGallery.as to pause video
			
			fl_ProLoader_2 = new ProLoader();
			fl_ProLoader_2.load(new URLRequest("keyboard.swf"));
			stage.addChild(fl_ProLoader_2);
			
			trace(_iTunesLink);			
			
			fl_ProLoader_2.contentLoaderInfo.addEventListener(Event.COMPLETE, loadHandler);
		}
		
		var pThumbnail;
		
		function loadHandler(event:Event):void
			{
				//_btnSignal.dispatch("EMAIL ME");
				fl_ProLoader_2.content.addEventListener('killMe', killLoadedClip); 
				var child:MovieClip = MovieClip(event.target.content);
				
				var textBuddy:TextField = child.txtBuddy;
				textBuddy.text = _iTunesLink;
			}
		
		//Listener to remove the keyboard
		function killLoadedClip(event:Event):void
		{ 
			_btnSignal.dispatch("KEYBOARD CLOSE"); //resume video
			
			event.target.removeEventListener('killMe', killLoadedClip) 
			stage.removeChild(fl_ProLoader_2); 
			fl_ProLoader_2.unload(); 

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


