package com.oxylusflash.multimediaviewer
{
	//{ region IMPORT CLASSES
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import caurina.transitions.Tweener;
	import org.osflash.signals.Signal;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class FullscreenBtn extends MovieClip
	{
		//{ region FIELDS
		public var mcFs : MovieClip;
		public var mcNs : MovieClip;
		public var mcHitArea : MovieClip;
		
		private var _fullScreenSignal : Signal;
		private var mouseTimer : Timer;
		private var _delay : Number = 0;
		private var _doHide : Boolean = true;
		private var drag : Boolean = false;
		//} endregion
		
		//{ region CONSTRUCTOR
		public function FullscreenBtn() 
		{
			_fullScreenSignal = new Signal(String, MouseEvent);
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
			this.hitArea = mcHitArea;
			
			mcFs.mcO.visible = false;
			mcFs.mcO.alpha = 0;
			
			mcNs.mcO.visible = false;
			mcNs.mcO.alpha = 0;
			
			mcFs.mcN.x = 
			mcFs.mcN.y = 
			mcFs.mcO.x = 
			mcFs.mcO.y = 
			mcNs.mcN.x = 
			mcNs.mcN.y = 
			mcNs.mcO.x = 
			mcNs.mcO.y = 0;
			
			mcNs.x = 
			mcFs.x = int(mcHitArea.width - mcNs.width) * 0.5;
			
			mcNs.y = 
			mcFs.y = int(mcHitArea.height - mcNs.height) * 0.5;
			
			mcHitArea.alpha = 0;
			
			mcFs.visible = false;
			mcFs.alpha = 0;
			
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverhandler, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, 0, true);
			this.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler, false, 0, true);
			mouseTimer = new Timer(_delay, 1);
			mouseTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timerComplete, false, 0, true);
		}
		//} endregion
		
		//{ region ROLL OVER HANDLER
		private final function rollOverhandler(e:MouseEvent):void 
		{
			if (mcNs.visible) 
			{
				mcNs.mcO.visible = true;
				Tweener.addTween(mcNs.mcO, { alpha: 1, time: 0.3, transition: "easeoutquad" });
			}else 
			{
				mcFs.mcO.visible = true;
				Tweener.addTween(mcFs.mcO, { alpha: 1, time: 0.3, transition: "easeoutquad" });
			}
		}
		//} endregion
		
		//{ region ROLL OUT HANDLER
		private final function rollOutHandler(e:MouseEvent = null):void 
		{
			if (!drag) 
			{
				if (mcNs.visible) 
				{
					Tweener.addTween(mcNs.mcO, { alpha: 0, time: 0.3, transition: "easeoutquad", onComplete: function ():void 
					{
						mcNs.mcO.visible = false;
					} });
				}else 
				{
					Tweener.addTween(mcFs.mcO, { alpha: 0, time: 0.3, transition: "easeoutquad", onComplete: function ():void 
					{
						mcFs.mcO.visible = false;
					} });
				}
			}
		}
		//} endregion
		
		//{ region CLICK HANDLER
		internal final function clickHandler(e:MouseEvent = null):void 
		{
			if (stage.displayState == StageDisplayState.NORMAL)
			{
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}else 
			{
				stage.displayState = StageDisplayState.NORMAL;
			}
		}
		//} endregion
		
		//{ region MOUSE DOWN HANDLER
		private final function mouseDownHandler(e:MouseEvent):void 
		{
			drag = true;
			_fullScreenSignal.dispatch("DRAG TRUE", null);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
		}
		//} endregion
		
		//{ region STAGE MOUSE UP HANDLER
		private final function stage_mouseUpHandler(e:MouseEvent):void 
		{
			drag = false;
			_fullScreenSignal.dispatch("DRAG FALSE", null);
			
			if (e.target != this)
			{
				_fullScreenSignal.dispatch("MAIN ROLL OUT", e);
			}
			
			if (e.target != this) 
			{
				rollOutHandler();
			}
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		}
		//} endregion
		
		//{ region FULL SCREEN HANDLER
		private final function fullScreenHandler(e:FullScreenEvent):void 
		{
			if (stage && stage.displayState == StageDisplayState.NORMAL)
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				stage.removeEventListener(MouseEvent.CLICK, stageClickHandler);
				
				Mouse.show();
				mouseTimer.reset();
				mouseTimer.stop();
				_fullScreenSignal.dispatch("NORMAL", null);
			}else 
			{
				if(stage)
				{
					stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
					stage.addEventListener(MouseEvent.CLICK, stageClickHandler, false, 0, true);
					mouseTimer.reset();
					mouseTimer.start();
					_fullScreenSignal.dispatch("FULLSCREEN", null);
				}
			}
		}
		//} endregion
		
		//{ region STAGE CLICK HANDLER
		private final function stageClickHandler(e:MouseEvent):void 
		{
			if (stage && stage.displayState == StageDisplayState.FULL_SCREEN)
			{
				Mouse.show();
				_fullScreenSignal.dispatch("FULLSCREEN SHOW CONTROLLER", null);
				mouseTimer.reset();
				mouseTimer.start();
			}else 
			{
				Mouse.show();
				mouseTimer.reset();
				mouseTimer.stop();
			}
		}
		//} endregion
		
		//{ region MOUSE MOVE HANDLER
		private final function mouseMoveHandler(e:MouseEvent):void 
		{
			Mouse.show();
			_fullScreenSignal.dispatch("FULLSCREEN SHOW CONTROLLER", null);
			mouseTimer.reset();
			mouseTimer.start();
		}
		//} endregion
		
		//{ region SET BTN TYPE
		internal final function setBtnType(pType : Boolean = true):void
		{
			if (pType) 
			{//FULLSCREEN
				mcNs.visible = false;
				mcNs.alpha = 0;
				
				mcNs.mcO.visible = false;
				mcNs.mcO.alpha = 0;
				
				mcFs.visible = true;
				mcFs.alpha = 1;
				
				if (mcFs.mcO.visible)
				{
					mcFs.mcO.visible = false;
					mcFs.mcO.alpha = 0;
				}
			}else//NORMAL 
			{
				mcFs.visible = false;
				mcFs.alpha = 0;
				
				mcFs.mcO.visible = false;
				mcFs.mcO.alpha = 0;
				
				mcNs.visible = true;
				mcNs.alpha = 1;
				
				if (!mcNs.mcO.visible) 
				{
					mcNs.mcO.visible = false;
					mcNs.mcO.alpha = 0;
				}
			}
		}
		//} endregion
		
		//{ region TIMER COMPLETE
		private final function timerComplete(e:TimerEvent):void 
		{
			_fullScreenSignal.dispatch("FULLSCREEN HIDE CONTROLLER", null);
			if (doHide) 
			{
				Mouse.hide();
				mouseTimer.reset();
				mouseTimer.stop();
			}
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS///////////////////////////////////////////////////////////////////////////////////////////////
		
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
			if (mouseTimer && mouseTimer.hasEventListener(TimerEvent.TIMER_COMPLETE)) 
			{
				mouseTimer.stop();
				mouseTimer.reset();
				mouseTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerComplete);
			}
			
			this.removeEventListener(MouseEvent.ROLL_OVER, rollOverhandler);
			this.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			this.removeEventListener(MouseEvent.CLICK, clickHandler);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			if (stage && stage.hasEventListener(MouseEvent.MOUSE_UP)) 
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			}
			
			if (stage && stage.hasEventListener(FullScreenEvent.FULL_SCREEN)) 
			{
				stage.removeEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler);
			}
			
			mcFs.removeChild(mcFs.mcN);
			mcFs.mcN = null;
			
			mcFs.removeChild(mcFs.mcO);
			mcFs.mcO = null;
			
			mcNs.removeChild(mcNs.mcN);
			mcNs.mcN = null;
			
			mcNs.removeChild(mcNs.mcO);
			mcNs.mcO = null;
			
			this.removeChild(mcFs);
			mcFs = null;
			
			this.removeChild(mcNs);
			mcNs = null;
			
			this.removeChild(mcHitArea);
			mcHitArea = null;
			
			this.parent.removeChild(this);
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		internal function get delay():Number { return _delay; }
		internal function set delay(value:Number):void 
		{
			_delay = value;
		}
		
		internal function get doHide():Boolean { return _doHide; }
		internal function set doHide(value:Boolean):void 
		{
			_doHide = value;
		}
		
		public function get fullScreenSignal():Signal { return _fullScreenSignal; }
		public function set fullScreenSignal(value:Signal):void 
		{
			_fullScreenSignal = value;
		}
		//} endregion
	}
}