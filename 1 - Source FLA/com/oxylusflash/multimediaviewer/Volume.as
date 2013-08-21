package com.oxylusflash.multimediaviewer
{
	//{ region IMPORT CLASSES
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class Volume extends MovieClip
	{
		//{ region FIELDS
		public var mcBg : MovieClip;
		
		private var mouseWheelStep : Number = 0.05;
		
		internal var mcVolBtn : VolBtn;
		internal var _mcVolSlide : VolSlider;
		private var oldVolPerc : Number = 0;
		
		private const ICON_TOP : int = 0;
		private const ICON_LEFT : int = 1;
		private const VOLBAR_LEFT : int = 5;
		private const VOLBAR_TOP : int = 8;
		//} endregion
		
		//{ region CONSTRUCTOR
		public function Volume()
		{
			this.visible = false;
			this.alpha = 0;
			
			mcBg.alpha = 0;
			
			mcVolBtn = new VolBtn();
			mcVolSlide = new VolSlider();
		}
		//} endregion
		
		//{ region EVENT HANDLERS//////////////////////////////////////////////////////////////////////
		
		//{ region INIT
		private final function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.addChild(mcVolBtn);
			this.addChild(mcVolSlide);
			
			mcVolBtn.startMe();
			mcVolSlide.startMe();
			
			mcVolBtn.visible = true;
			mcVolBtn.alpha = 1;
			
			mcVolSlide.visible = true;
			mcVolSlide.alpha = 1;
			
			this.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, 0, true);
		}
		//} endregion
		
		//{ region MOUSE WHEEL HANDLER
		private final function mouseWheelHandler(e:MouseEvent):void 
		{
			mcVolSlide.perc += mouseWheelStep * e.delta;
			mcVolSlide.sliderSignal.dispatch("VOLUME PERC", null);
			e.updateAfterEvent();
		}
		//} endregion
		
		//{ region ROLL OVER HANDLER
		private final function rollOverHandler(e:MouseEvent):void 
		{
			mcVolBtn.imOver = true;
			mcVolBtn.rollOver();
		}
		//} endregion
		
		//{ region ROLL OUT HANDLER
		private final function rollOutHandler(e:MouseEvent):void 
		{
			mcVolBtn.imOver = false;
			if (!mcVolSlide.drag) 
			{
				mcVolBtn.rollOut();
			}
		}
		//} endregion
		
		//{ region SIGNAL HANDLER
		private final function signalHandler(e:String = "", mouseEv : MouseEvent = null):void
		{
			switch (e) 
			{
				case "ROLL OUT":
					if (!mcVolBtn.imOver) 
					{
						mcVolBtn.rollOut();
					}
				break;
				
				case "VOLUME PERC":
					if (mcVolSlide.perc == 0)
					{
						oldVolPerc = mcVolSlide.perc;
						mcVolBtn.mute();
					}else 
					{
						if (mcVolSlide.perc != 0 && mcVolBtn.mcMstate.visible) 
						{
							oldVolPerc = mcVolSlide.perc;
							mcVolBtn.unMute();
						}
					}
				break;
				
				case "CLICK":
					if (mcVolSlide.perc != 0 || oldVolPerc == 0) 
					{
						mcVolBtn.mute();
						oldVolPerc = mcVolSlide.perc;
						mcVolSlide.perc = 0;
						
					}else 
					{
						mcVolBtn.unMute();
						mcVolSlide.perc = oldVolPerc;
					}
				break;
			}
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS/////////////////////////////////////////////////////////////////////////////
		
		//{ region SET DATA
		internal final function setData(pInitVol : Number):void 
		{
			mcVolSlide.perc = pInitVol;
			mcVolSlide.sliderSignal.add(signalHandler);
			mcVolBtn.btnSignal.add(signalHandler);
			
			if (pInitVol != 0)
			{
				mcVolBtn.initIcon();
			}else 
			{
				mcVolBtn.initIcon(false);
			}
			
			mcVolBtn.x = ICON_LEFT;
			mcVolSlide.x = VOLBAR_LEFT + mcVolBtn.x + mcVolBtn.mcVolBtnHitArea.width;
			
			mcVolBtn.y = ICON_TOP;
			mcVolBtn.x = ICON_LEFT;
			
			mcVolSlide.y = VOLBAR_TOP;
			
			mcBg.x = 
			mcBg.y = 0;
			
			mcBg.width = mcVolSlide.x + mcVolSlide.mcHitArea.width;
			startMe();
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
			this.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			this.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			this.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			
			mcVolSlide.sliderSignal.remove(signalHandler);
			mcVolBtn.btnSignal.remove(signalHandler);
			
			mcVolBtn.Destroy();
			mcVolBtn = null;
			mcVolSlide.Destroy();
			mcVolSlide = null;
			
			this.removeChild(mcBg);
			mcBg = null;
			
			this.parent.removeChild(this);
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		public function get mcVolSlide():VolSlider { return _mcVolSlide; }
		public function set mcVolSlide(value:VolSlider):void 
		{
			_mcVolSlide = value;
		}
		//} endregion
	}
}