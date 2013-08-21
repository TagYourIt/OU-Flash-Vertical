package com.oxylusflash.multimediaviewer
{
	//{ region IMPORT CLASSES
	import caurina.transitions.Tweener;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import org.osflash.signals.Signal;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class ProgressBar extends MovieClip
	{
		//{ region FIELDS
		public var mcTime : MovieClip;
		public var mcBuff : MovieClip;
		public var mcTrack : MovieClip;
		public var mcBtn : MovieClip;
		public var mcHitArea : MovieClip;
		public var mcTrackShadow : MovieClip;
		
		private var _progressSignal : Signal;
		private var _perc : Number = 0;
		private var _drag : Boolean = false;
		private var _percLimit : Number = 1;
		//} endregion
		
		//{ region CONSTRUCTOR
		public function ProgressBar() 
		{
			this.visible = false;
			this.alpha = 0;
			
			//formatting mcTime.mcTotalTime.txt
			mcTime.mcTotalTime.txt.autoSize = TextFieldAutoSize.LEFT;
			mcTime.mcTotalTime.txt.selectable = false;
			mcTime.mcTotalTime.txt.condenseWhite = true;
			mcTime.mcTotalTime.txt.multiline = false;
			mcTime.mcTotalTime.txt.embedFonts = true;
			mcTime.mcTotalTime.txt.wordWrap = false;
			mcTime.mcTotalTime.txt.text = "";
			mcTime.mcTotalTime.txt.mouseWheelEnabled = false;
			//for testing only
			//mcTime.mcTotalTime.txt.background = true;
			//mcTime.mcTotalTime.txt.backgroundColor = 0x006633;
			
			//formatting mcPartTime.txt
			mcTime.mcPartTime.txt.autoSize = TextFieldAutoSize.LEFT;
			mcTime.mcPartTime.txt.selectable = false;
			mcTime.mcPartTime.txt.condenseWhite = true;
			mcTime.mcPartTime.txt.multiline = false;
			mcTime.mcPartTime.txt.embedFonts = true;
			mcTime.mcPartTime.txt.wordWrap = false;
			mcTime.mcPartTime.txt.text = "";
			mcTime.mcPartTime.txt.mouseWheelEnabled = false;
			//for testing only
			//mcTime.mcPartTime.txt.background = true;
			//mcTime.mcPartTime.txt.backgroundColor = 0x006633;
			
			mcHitArea.alpha = 0;
			
			_progressSignal = new Signal(String, MouseEvent);
		}
		//} endregion
		
		//{ region EVENT HANDLERS//////////////////////////////////////////////////////////////////////
		
		//{ region INIT
		private final function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.hitArea = mcHitArea;
			this.buttonMode = true;
			this.mouseChildren = false;
			
			mcHitArea.x = 
			mcHitArea.y = 0;
			
			//mcBuff.width = 
			mcBtn.width = 0;
			
			mcBuff.y = int((mcHitArea.height - mcBuff.height) * 0.5);
			mcTrackShadow.y = 
			mcTrack.y = int((mcHitArea.height - mcTrack.height) * 0.5);
			mcBtn.y = int((mcHitArea.height - mcBtn.height) * 0.5);
			
			mcTrackShadow.x = 
			mcTrack.x = 
			mcBuff.x = 
			mcBtn.x = 0;
			
			this.addEventListener(MouseEvent.CLICK, mouseClickHandler, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
		}
		//} endregion
		
		//{ region MOUSE CLICK HANDLER
		private final function mouseClickHandler(e:MouseEvent):void 
		{
			e.updateAfterEvent();
			setPerc();
			_progressSignal.dispatch("PROG CLICK", null);
		}
		//} endregion
		
		//{ region MOUSE DOWN HANDLER
		private final function mouseDownHandler(e:MouseEvent):void 
		{
			e.updateAfterEvent();
			setPerc();
			
			if (!drag) 
			{
				_progressSignal.dispatch("PROG DRAG TRUE", null);
			}
			
			drag = true;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
		}
		//} endregion
		
		//{ region STAGE MOUSE MOVE HANDLER
		private final function stage_mouseMoveHandler(e:MouseEvent):void 
		{
			e.updateAfterEvent();
			updatePercentage();
		}
		//} endregion
		
		//{ region STAGE MOUSE UP HANDLER
		private final function stage_mouseUpHandler(e:MouseEvent):void 
		{
			e.updateAfterEvent();
			
			setPerc();
			
			if (drag) 
			{
				_progressSignal.dispatch("PROG DRAG FALSE", null);
			}
			
			drag = false;
			
			if (e.target != this)
			{
				_progressSignal.dispatch("MAIN ROLL OUT", e);
			}
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS////////////////////////////////////////////////////////////////////////////
		
		//{ region UPDATE PERCENTAGE
		internal final function updatePercentage():void
		{
			setPerc();
			_progressSignal.dispatch("PROGRESS PERC", null);
		}
		//} endregion
		
		//{ region SET PERC
		private final function setPerc():void
		{
			perc = this.mouseX / mcTrack.width;
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
			this.removeEventListener(MouseEvent.CLICK, mouseClickHandler);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			if (stage && stage.hasEventListener(MouseEvent.MOUSE_MOVE)) 
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			}
			
			if (stage && stage.hasEventListener(MouseEvent.MOUSE_UP)) 
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			}
			
			mcTime.mcTotalTime.removeChild(mcTime.mcTotalTime.txt);
			mcTime.mcTotalTime.txt = null;
			
			mcTime.removeChild(mcTime.mcTotalTime);
			mcTime.mcTotalTime = null;
			
			mcTime.mcPartTime.removeChild(mcTime.mcPartTime.txt);
			mcTime.mcPartTime.txt = null;
			
			mcTime.removeChild(mcTime.mcPartTime);
			mcTime.mcPartTime = null;
			
			this.removeChild(mcTime);
			mcTime = null;
			
			this.removeChild(mcBuff);
			mcBuff = null;
			
			this.removeChild(mcTrack);
			mcTrack = null;
			
			this.removeChild(mcBtn);
			mcBtn = null;
			
			this.removeChild(mcHitArea);
			mcHitArea = null;
			
			this.removeChild(mcTrackShadow);
			mcTrackShadow = null;
			
			this.parent.removeChild(this);
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		internal function get progressSignal():Signal { return _progressSignal; }
		internal function set progressSignal(value:Signal):void 
		{
			_progressSignal = value;
		}
		
		internal function get perc():Number { return _perc; }
		internal function set perc(value:Number):void 
		{
			value = Math.max(0, Math.min(_percLimit, value));
			if (_perc != value)
			{
				_perc = value;
				mcBtn.width = (mcTrack.width * _perc <= mcBuff.width)? mcTrack.width * _perc : mcBuff.width;
			}
		}
		
		internal function get drag():Boolean { return _drag; }
		internal function set drag(value:Boolean):void 
		{
			_drag = value;
		}
		
		internal function get percLimit():Number { return _percLimit; }
		internal function set percLimit(value:Number):void 
		{
			_percLimit = value;
		}
		//} endregion
	}
}