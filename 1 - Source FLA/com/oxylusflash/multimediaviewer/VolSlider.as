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
	public class VolSlider extends MovieClip
	{
		//{ region FIELDS
		public var mcTrack : MovieClip;
		public var mcBtn : MovieClip;
		public var mcHitArea : MovieClip;
		
		private var _sliderSignal : Signal;
		private var _perc : Number = 0;
		private var _drag : Boolean = false;
		//} endregion
		
		//{ region CONSTRUCTOR
		public function VolSlider() 
		{
			this.visible = false;
			this.alpha = 0;
			
			mcHitArea.alpha = 0;
			mcBtn.width = 0;
			
			_sliderSignal = new Signal(String, MouseEvent);
		}
		//} endregion
		
		//{ region EVENT HANDLERS//////////////////////////////////////////////////////////////////////////////////////
		
		//{ region INIT
		private final function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.hitArea = mcHitArea;
			this.buttonMode = true;
			this.mouseChildren = false;
			
			mcHitArea.x = 
			mcHitArea.y = 0;
			
			mcTrack.y = int((mcHitArea.height - mcTrack.height) * 0.5);
			mcBtn.y = int((mcHitArea.height - mcBtn.height) * 0.5);
			
			mcTrack.x = int((mcHitArea.width - mcTrack.width) * 0.5);
			mcBtn.x = 0;
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, 0, true);
		}
		//} endregion
		
		//{ region ROLL OUT HANDLER
		private final function rollOutHandler(e:MouseEvent = null):void 
		{
			if (!drag) 
			{
				_sliderSignal.dispatch("ROLL OUT", null);
			}
		}
		//} endregion
		
		//{ region MOUSE DOWN HANDLER
		private final function mouseDownHandler(e:MouseEvent):void 
		{
			drag = true;
			_sliderSignal.dispatch("DRAG TRUE", null);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
			updatePercentage();
		}
		//} endregion
		
		//{ region STAGE MOUSE MOVE HANDLER
		private final function stage_mouseMoveHandler(e:MouseEvent):void 
		{
			updatePercentage();
			e.updateAfterEvent();
		}
		//} endregion
		
		//{ region STAGE MOUSE UP HANDLER
		private final function stage_mouseUpHandler(e:MouseEvent):void 
		{
			drag = false;
			_sliderSignal.dispatch("DRAG FALSE", null);
			
			if (e.target != this)
			{
				_sliderSignal.dispatch("MAIN ROLL OUT", e);
			}
			
			if (e.target != this) 
			{
				rollOutHandler();
			}
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS/////////////////////////////////////////////////////////////////////////////////////////////
		
		//{ region UPDATE PERCENTAGE
		internal final function updatePercentage():void
		{
			perc = this.mouseX / mcTrack.width;
			_sliderSignal.dispatch("VOLUME PERC", null);
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
			this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			this.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			
			if (stage && stage.hasEventListener(MouseEvent.MOUSE_MOVE)) 
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			}
			
			if (stage && stage.hasEventListener(MouseEvent.MOUSE_UP)) 
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			}
			
			this.removeChild(mcTrack);
			mcTrack = null;
			this.removeChild(mcBtn);
			mcBtn = null;
			this.removeChild(mcHitArea);
			mcHitArea = null;
			
			this.parent.removeChild(this);
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		internal function get sliderSignal():Signal { return _sliderSignal; }
		internal function set sliderSignal(value:Signal):void 
		{
			_sliderSignal = value;
		}
		
		public function get perc():Number { return _perc; }
		public function set perc(value:Number):void 
		{
			value = Math.max(0, Math.min(1, value));
			if (_perc != value)
			{
				_perc = value;
				_sliderSignal.dispatch("MAIN VOLUME PERC", null);
				mcBtn.width = mcTrack.width * _perc;
			}
		}
		
		internal function get drag():Boolean { return _drag; }
		internal function set drag(value:Boolean):void 
		{
			_drag = value;
		}
		//} endregion
	}
}