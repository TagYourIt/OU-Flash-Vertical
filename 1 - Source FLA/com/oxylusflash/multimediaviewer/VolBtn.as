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
	public class VolBtn extends MovieClip
	{
		//{ region FIELDS
		public var mcNstate : MovieClip;
		public var mcMstate : MovieClip;
		public var mcVolBtnHitArea : MovieClip;
		
		private var _btnSignal : Signal;
		private var _imOver : Boolean = false;
		private var drag : Boolean = false;
		//} endregion
		
		//{ region CONSTRUCTOR
		public function VolBtn() 
		{
			_btnSignal = new Signal(String, MouseEvent);
			this.visible = false;
			this.alpha = 0;
		}
		//} endregion
		
		//{ region EVENT HANDLERS///////////////////////////////////////////////////////////////////////////////////////
		
		//{ region INIT
		private final function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.buttonMode = true;
			this.mouseChildren = false;
			this.hitArea = mcVolBtnHitArea;
			
			mcNstate.mcO.visible = false;
			mcNstate.mcO.alpha = 0;
			
			mcMstate.mcO.visible = false;
			mcMstate.mcO.alpha = 0;
			
			mcNstate.mcN.x = 
			mcNstate.mcN.y = 
			mcNstate.mcO.x = 
			mcNstate.mcO.y = 
			mcMstate.mcN.x = 
			mcMstate.mcN.y = 
			mcMstate.mcO.x = 
			mcMstate.mcO.y = 0;
			
			mcNstate.x = 
			mcMstate.x = (mcVolBtnHitArea.width - mcMstate.width) * 0.5;
			
			mcNstate.y = 
			mcMstate.y = (mcVolBtnHitArea.height - mcMstate.height) * 0.5;
			
			mcVolBtnHitArea.alpha = 0;
			this.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
		}
		//} endregion
		
		//{ region CLICK HANDLER
		internal final function clickHandler(e:MouseEvent):void 
		{
			_btnSignal.dispatch("CLICK", null);
		}
		//} endregion
		
		//{ region MOUSE DOWN HANDLER
		private final function mouseDownHandler(e:MouseEvent):void 
		{
			drag = true;
			_btnSignal.dispatch("DRAG TRUE", null);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
		}
		//} endregion
		
		//{ region STAGE MOUSE UP HANDLER
		private final function stage_mouseUpHandler(e:MouseEvent):void 
		{
			drag = false;
			_btnSignal.dispatch("DRAG FALSE", null);
			
			if (e.target != this)
			{
				_btnSignal.dispatch("MAIN ROLL OUT", e);
			}
			
			if (e.target != this) 
			{
				rollOut();
			}
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS/////////////////////////////////////////////////////////////////////////////////////////////
		
		//{ region MUTE
		internal final function mute():void 
		{
			mcNstate.visible = false;
			mcNstate.alpha = 0;
			
			mcMstate.visible = true;
			mcMstate.alpha = 1;
			
			if (!mcMstate.mcO.visible) 
			{
				mcMstate.mcO.visible = true;
				mcMstate.mcO.alpha  = 1;
			}
		}
		//} endregion
		
		//{ region UNMUTE
		internal final function unMute():void 
		{
			mcMstate.visible = false;
			mcMstate.alpha = 0;
			
			mcNstate.visible = true;
			mcNstate.alpha = 1;
			
			if (!mcNstate.mcO.visible) 
			{
				mcNstate.mcO.visible = true;
				mcNstate.mcO.alpha = 1;
			}
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
		
		//{ region INIT ICON
		internal final function initIcon(pType : Boolean = true):void 
		{
			if (pType) 
			{
				mcMstate.visible = false;
				mcMstate.alpha = 0;
				
				if (!mcNstate.visible) 
				{
					mcNstate.visible = true;
					mcNstate.alpha = 1;
				}
			}else 
			{
				mcNstate.visible = false;
				mcNstate.alpha = 0;
				
				if (!mcMstate.visible) 
				{
					mcMstate.visible = true;
					mcMstate.alpha = 1;
				}
			}
		}
		//} endregion
		
		//{ region ROLL OVER
		internal final function rollOver():void
		{
			if (mcNstate.visible) 
			{
				mcNstate.mcO.visible = true;
				Tweener.addTween(mcNstate.mcO, { alpha: 1, time: 0.3, transition: "easeoutquad" });
			}else 
			{
				mcMstate.mcO.visible = true;
				Tweener.addTween(mcMstate.mcO, { alpha: 1, time: 0.3, transition: "easeoutquad" });
			}
		}
		//} endregion
		
		//{ region ROLL OUT
		internal final function rollOut():void
		{
			if (!drag) 
			{
				if (mcNstate.visible) 
				{
					Tweener.addTween(mcNstate.mcO, { alpha: 0, time: 0.3, transition: "easeoutquad", onComplete: function ():void 
					{
						mcNstate.mcO.visible = false;
					} });
				}else 
				{
					Tweener.addTween(mcMstate.mcO, { alpha: 0, time: 0.3, transition: "easeoutquad", onComplete: function ():void 
					{
						mcMstate.mcO.visible = false;
					} });
				}
			}
		}
		//} endregion
		
		//{ region DESTROY
		internal final function Destroy():void 
		{
			this.removeEventListener(MouseEvent.CLICK, clickHandler);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			if (stage && stage.hasEventListener(MouseEvent.MOUSE_UP)) 
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			}
			
			mcNstate.removeChild(mcNstate.mcO);
			mcNstate.mcO = null;
			
			mcNstate.removeChild(mcNstate.mcN);
			mcNstate.mcN = null;
			
			this.removeChild(mcNstate);
			mcNstate = null;
			
			mcMstate.removeChild(mcMstate.mcO);
			mcMstate.mcO = null;
			
			mcMstate.removeChild(mcMstate.mcN);
			mcMstate.mcN = null;
			
			this.removeChild(mcMstate);
			mcMstate = null;
			
			this.removeChild(mcVolBtnHitArea);
			mcVolBtnHitArea = null;
			
			this.parent.removeChild(this);
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		internal function get btnSignal():Signal { return _btnSignal; }
		internal function set btnSignal(value:Signal):void 
		{
			_btnSignal = value;
		}
		
		internal function get imOver():Boolean { return _imOver; }
		internal function set imOver(value:Boolean):void 
		{
			_imOver = value;
		}
		//} endregion
	}
}