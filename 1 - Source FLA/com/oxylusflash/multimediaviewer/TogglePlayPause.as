package com.oxylusflash.multimediaviewer
{
	//{ region IMPORT CLASSES
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import caurina.transitions.Tweener;
	import org.osflash.signals.Signal;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class TogglePlayPause extends MovieClip
	{
		//{ region FIELDS
		public var mcPause : MovieClip;
		public var mcPlay : MovieClip;
		public var mcBg : MovieClip;
		
		private var _playPauseSignal : Signal;
		private var drag : Boolean = false;
		//} endregion
		
		//{ region CONSTRUCTOR
		public function TogglePlayPause()
		{
			_playPauseSignal = new Signal(String, MouseEvent);
			this.visible = false;
			this.alpha = 0;
		}
		//} endregion
		
		//{ region EVENT HANDLERS////////////////////////////////////////////////////////////////////////////
		
		//{ region INIT
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.buttonMode = true;
			this.mouseChildren = false;
			this.hitArea = mcBg;
			
			mcPause.mcO.visible = false;
			mcPause.mcO.alpha = 0;
			mcPause.x = int(mcBg.width - mcPause.width) * 0.5;
			mcPause.y = int(mcBg.height - mcPause.height) * 0.5;
			
			mcPlay.mcO.visible = false;
			mcPlay.mcO.alpha  = 0;
			mcPlay.x = int(mcBg.width - mcPlay.width) * 0.5;
			mcPlay.y = int(mcBg.height - mcPlay.height) * 0.5;
			
			mcBg.x = 
			mcBg.y = 0;
			mcBg.alpha = 0;
			
			mcPause.visible = false;
			mcPause.alpha = 0;
			
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverhandler, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, 0, true);
			this.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
		}
		//} endregion
		
		//{ region ROLL OVER HANDLER
		private final function rollOverhandler(e:MouseEvent = null):void 
		{
			if (mcPlay.visible) 
			{
				mcPlay.mcO.visible = true;
				Tweener.addTween(mcPlay.mcO, { alpha: 1, time: 0.3, transition: "easeoutquad" });
			}else 
			{
				mcPause.mcO.visible = true;
				Tweener.addTween(mcPause.mcO, { alpha: 1, time: 0.3, transition: "easeoutquad" });
			}
		}
		//} endregion
		
		//{ region ROLL OUT HANDLER
		private final function rollOutHandler(e:MouseEvent = null):void 
		{
			if (!drag) 
			{
				if (mcPlay.visible) 
				{
					Tweener.addTween(mcPlay.mcO, { alpha: 0, time: 0.3, transition: "easeoutquad", onComplete: function ():void 
					{
						mcPlay.mcO.visible = false;
					} });
				}else 
				{
					Tweener.addTween(mcPause.mcO, { alpha: 0, time: 0.3, transition: "easeoutquad", onComplete: function ():void 
					{
						mcPause.mcO.visible = false;
					} });
				}
			}
		}
		//} endregion
		
		//{ region CLICK HANDLER
		internal final function clickHandler(e:MouseEvent = null):void 
		{
			if (mcPlay.visible)
			{
				_playPauseSignal.dispatch("PLAY", null);
			}else 
			{
				_playPauseSignal.dispatch("PAUSE", null);
			}
		}
		//} endregion
		
		//{ region MOUSE DOWN HANDLER
		private final function mouseDownHandler(e:MouseEvent):void 
		{
			drag = true;
			_playPauseSignal.dispatch("DRAG TRUE", null);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
		}
		//} endregion
		
		//{ region STAGE MOUSE UP HANDLER
		private final function stage_mouseUpHandler(e:MouseEvent):void 
		{
			drag = false;
			_playPauseSignal.dispatch("DRAG FALSE", null);
			
			if (e.target != this)
			{
				_playPauseSignal.dispatch("MAIN ROLL OUT", e);
			}
			
			if (e.target != this) 
			{
				rollOutHandler();
			}
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS///////////////////////////////////////////////////////////////////////////////////
		
		//{ region GET STATE
		internal final function getState():String
		{
			if (mcPlay.visible) 
			{
				return "PAUSE";
			}else 
			{
				return "PLAY";
			}
			return "";
		}
		//} endregion
		
		//{ region START ME
		internal final function startMe():void 
		{
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
			this.removeEventListener(MouseEvent.ROLL_OVER, rollOverhandler);
			this.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			this.removeEventListener(MouseEvent.CLICK, clickHandler);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			mcPlay.removeChild(mcPlay.mcO);
			mcPlay.mcO = null;
			mcPlay.removeChild(mcPlay.mcN);
			mcPlay.mcN = null;
			
			mcPause.removeChild(mcPause.mcO);
			mcPause.mcO = null;
			mcPause.removeChild(mcPause.mcN);
			mcPause.mcN = null;
			
			this.removeChild(mcPlay);
			mcPlay = null;
			this.removeChild(mcPause);
			mcPause = null;
			
			this.removeChild(mcBg);
			mcBg = null;
			
			this.parent.removeChild(this);
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		internal function get playPauseSignal():Signal { return _playPauseSignal; }
		internal function set playPauseSignal(value:Signal):void 
		{
			_playPauseSignal = value;
		}
		//} endregion
	}
}