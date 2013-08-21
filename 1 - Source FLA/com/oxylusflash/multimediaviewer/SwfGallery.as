package com.oxylusflash.multimediaviewer 
{
	//{ region IMPORT CLASSES
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextFieldAutoSize;
	
	import caurina.transitions.Tweener;
	import com.oxylusflash.framework.resize.Resize;
	import com.oxylusflash.framework.resize.ResizeType;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class SwfGallery extends MultimediaViewer
	{
		//{ region FIELDS
		private var dataLoader : Loader;
		private var urlREQ : URLRequest;
		
		private var target : String = "";
		private var link : String = "";
		//} endregion
		
		//{ region CONSTRUCTOR
		public function SwfGallery() 
		{
			super();
		}
		//} endregion
		
		//{ region EVENT HANDLERS///////////////////////////////////////////////////////////////////
		
		//{ region INIT
		private final function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			startApp();
		}
		//} endregion
		
		//{ region ROLL OVER HANDLER
		override internal function rollOverHandler(e:MouseEvent = null):void 
		{
			Tweener.addTween(mcHeader, { y: 0, time: .3, transition: "easeOutQuad" } );
			if (e != null) 
			{
				e.updateAfterEvent();
			}
		}
		//} endregion
		
		//{ region ROLL OUT HANDLER
		override internal function rollOutHandler(e:MouseEvent = null):void 
		{
			if (!somebodyIsDraging)
			{
				Tweener.addTween(mcHeader, { y: int( - mcHeader.mcBg.height), time: .3, transition: "easeOutQuad" } );
				if (e != null) 
				{
					e.updateAfterEvent();
				}
			}
		}
		//} endregion
		
		//{ region SIGNAL HANDLER
		override public function signalHandler(e:String = "", mouseEv : MouseEvent = null):void
		{
			switch (e)
			{
				case "MAIN ROLL OUT":
					if (!this.hitTestPoint(mouseEv.stageX, mouseEv.stageY)) 
					{
						somebodyIsDraging = false;
						rollOutHandler();
					}
				break;
				
				case "DRAG TRUE":
					if (!somebodyIsDraging) 
					{
						somebodyIsDraging = true;
					}
				break;
				
				case "DRAG FALSE":
					if (somebodyIsDraging) 
					{
						somebodyIsDraging = false;
					}
				break;
			}
		}
		//} endregion
		
		//{ region DATA LOADER IO ERROR HANDLER
		private final function dataLoader_IoErrorHandler(e:IOErrorEvent):void 
		{
			dataLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, dataLoader_IoErrorHandler);
			dataLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, dataLoader_CompleteHandler);
			
			trace("data loader IOError, class SwfGallery.as", e);
			
			try 
			{
				dataLoader.close();
				dataLoader.unload();
				dataLoader = null;
			}catch (err:Error)
			{
			}
		}
		//} endregion
		
		//{ region DATA LOADER COMPLETE HANDLER
		private final function dataLoader_CompleteHandler(e:Event):void
		{
			dataLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, dataLoader_IoErrorHandler);
			dataLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, dataLoader_CompleteHandler);
			urlREQ = null;
			
			//trace("SWF", "WIDTH: ", dataLoader.contentLoaderInfo.width, "HEIGHT: ", dataLoader.contentLoaderInfo.height);
			
			try 
			{
				dataLoader.content.scrollRect = new Rectangle(0, 0, dataLoader.contentLoaderInfo.width, dataLoader.contentLoaderInfo.height);
				
				mcVh.addChild(dataLoader.content);
				
				if (link != "")
				{
					if (target == "") 
					{
						target = "_blank";
					}
					
					mcVh.addEventListener(MouseEvent.CLICK, mcVh_ClickHandler, false, 0, true);
				}
				mcVh.cacheAsBitmap = true;
				
				mcVh.width = Math.round(cWidth);
				mcVh.height = Math.round(cHeight);
			}catch (err:Error)
			{
			}
			
			try 
			{
				dataLoader.close();
				dataLoader.unload();
				dataLoader = null;
			}catch (err:Error)
			{
			}
			
			if (stage) 
			{
				init();
			}else 
			{
				this.addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			}
		}
		//} endregion
		
		//{ region MC VH CLICK HANDLER
		private final function mcVh_ClickHandler(e:MouseEvent):void 
		{
			navigateToURL(new URLRequest(link), target);
		}
		//} endregion
		
		//{ region CLOSE BTN MOUSE DOWN HANDLER
		override function closeBtn_MouseDownHandler(e:MouseEvent):void 
		{
			btn_mc.drag = true;
			signalHandler("DRAG TRUE", null);
			stage.addEventListener(MouseEvent.MOUSE_UP, closeBtnStage_mouseUpHandler, false, 0, true);
		}
		//} endregion
		
		//{ region CLOSE BTN MOUSE UP HANDLER
		private final function closeBtnStage_mouseUpHandler(e:MouseEvent):void 
		{
			btn_mc.drag = false;
			signalHandler("DRAG FALSE", null);
			
			if (e.target != btn_mc)
			{
				signalHandler("MAIN ROLL OUT", e);
			}
			
			if (e.target != btn_mc) 
			{
				btn_mc.rollOutHandler();
			}
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, closeBtnStage_mouseUpHandler);
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS///////////////////////////////////////////////////////////////////////////
		
		//{ region RESET
		override public function reset():void 
		{
			//this.x = 
			//this.y = 
			mcVh.x = 
			mcVh.y = 
			mcHeader.x = 
			mcMask.x = 
			mcMask.y = 0;
			
			//HEADER
			mcHeader.y = int( -mcHeader.mcBg.height);
			
			//formatting mcHeader.mcNpLbl.txt
			mcHeader.mcNpLbl.txt.autoSize = TextFieldAutoSize.LEFT;
			mcHeader.mcNpLbl.txt.selectable = false;
			mcHeader.mcNpLbl.txt.condenseWhite = true;
			mcHeader.mcNpLbl.txt.multiline = false;
			mcHeader.mcNpLbl.txt.embedFonts = true;
			mcHeader.mcNpLbl.txt.wordWrap = false;
			mcHeader.mcNpLbl.txt.text = "";
			mcHeader.mcNpLbl.txt.mouseWheelEnabled = false;
			//for testing only
			//mcHeader.mcNpLbl.txt.background = true;
			//mcHeader.mcNpLbl.txt.backgroundColor = 0x006633;
			
			//formatting mcHeader.mcNpTxt.txt
			mcHeader.mcNpTxt.txt.autoSize = TextFieldAutoSize.LEFT;
			mcHeader.mcNpTxt.txt.selectable = false;
			mcHeader.mcNpTxt.txt.condenseWhite = true;
			mcHeader.mcNpTxt.txt.multiline = false;
			mcHeader.mcNpTxt.txt.embedFonts = true;
			mcHeader.mcNpTxt.txt.wordWrap = false;
			mcHeader.mcNpTxt.txt.text = "";
			mcHeader.mcNpTxt.txt.mouseWheelEnabled = false;
			//for testing only
			//mcHeader.mcNpTxt.txt.background = true;
			//mcHeader.mcNpTxt.txt.backgroundColor = 0x006633;
			
			mcHeader.mcNpLbl.x = TITLE_LEFT;
			mcHeader.mcNpLbl.y = TITLE_TOP;
			mcHeader.mcNpLbl.txt.text = detailView.settings.label;
			
			mcHeader.mcNpTxt.x = mcHeader.mcNpLbl.x + mcHeader.mcNpLbl.width + TITLE_TXT_LEFT;
			mcHeader.mcNpTxt.y = TITLE_TOP;
			
			//CLOSE BTN
			btn_mc = new CloseBtn();
			
			btn_mc.addEventListener(MouseEvent.MOUSE_DOWN, closeBtn_MouseDownHandler, false, 0, true);
			
			btn_mc.lbl_mc.txt.alpha = 
			btn_mc.nAlpha = detailView.closeBtn.normalAlpha;
			btn_mc.oAlpha = detailView.closeBtn.overAlpha;
			
			btn_mc.lbl_mc.txt.text = detailView.closeBtn.label;
			
			btn_mc.lbl_mc.x = CLOSE_TXT_LEFT;
			btn_mc.lbl_mc.y = CLOSE_TXT_TOP;
			
			btn_mc.sign_mc.x = int(CLOSE_SIGN_LEFT + btn_mc.lbl_mc.width + btn_mc.lbl_mc.x);
			btn_mc.sign_mc.y = CLOSE_SIGN_TOP;
			
			btn_mc.hitArea_mc.width = int(btn_mc.sign_mc.x + btn_mc.sign_mc.width + CLOSE_TXT_LEFT + 2);
			
			btn_mc.y = CLOSE_TOP;
			btn_mc.hitArea_mc.alpha = 0;
			
			mcHeader.addChild(btn_mc);
			mcHeader.mcBg.useHandCursor = false;
			
			mcController.removeChild(mcController.mcBg);
			mcController.mcBg = null;
			
			removeChild(mcController);
			mcController = null;
			
			removeChild(mcVideoPlayerBg);
			mcVideoPlayerBg = null;
			
			//removeChild(mcVideoColorBg);
			//mcVideoColorBg = null;
			
			mcVideoColorBg.visible = true;
			mcVideoColorBg.alpha = 0;
			
			removeChild(mcVideoPlayerBgN);
			mcVideoPlayerBgN = null;
			
			removeChild(mcPlayBtn);
			mcPlayBtn = null;
			
			mcError.mcTxt.removeChild(mcError.mcTxt.txt);
			mcError.mcTxt.txt = null;
			
			mcError.removeChild(mcError.mcTxt);
			mcError.mcTxt = null;
			
			removeChild(mcError);
			mcError = null;
			
			btn_mc.visible = true;
			btn_mc.alpha = 1;
			btn_mc.mouseEnabled = true;
			
			mcVh.visible = false;
			mcVh.alpha = 0;
			
			this.mouseChildren = true;
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, 0, true);
			
			resize(true);
		}
		//} endregion
		
		//{ region RESIZE
		override public function resize(pFirst : Boolean = false):void
		{
			mcVideoColorBg.width = 
			mcHeader.mcBg.width = 
			mcMask.width = cWidth;
			
			mcVideoColorBg.height = 
			mcMask.height = cHeight;
			this.scrollRect = mcMask;
			
			if (!pFirst) 
			{
				if (Tweener.isTweening(mcHeader)) 
				{
					Tweener.removeTweens(mcHeader);
				}
				
				mcVh.width = Math.round(cWidth);
				mcVh.height = Math.round(cHeight);
			}else 
			{
				if (Tweener.isTweening(mcHeader)) 
				{
					Tweener.removeTweens(mcHeader);
				}
				
				mcHeader.y = int( -mcHeader.mcBg.height);
			}
			btn_mc.x = int(mcHeader.mcBg.width - (btn_mc.hitArea_mc.width + CLOSE_LEFT));
			SetTitleMask();
		}
		//} endregion
		
		//{ region LOAD SWF
		public final function LoadMe(pURL : String = "", pLink : String = "", pTarget : String = ""):void 
		{
			link = pLink;
			target = pTarget;
			
			try 
			{
				urlREQ = new URLRequest(pURL);
				dataLoader = new Loader();
				dataLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, dataLoader_IoErrorHandler, false, 0, true);
				dataLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, dataLoader_CompleteHandler, false, 0, true);
				dataLoader.load(urlREQ);
			}catch (err:Error)
			{
				trace("SWF load failure, class SwfGallery.as", err);
			}
		}
		//} endregion
		
		//{ region DESTROY
		override internal function DestroyMe():void 
		{
			if (mcVh.hasEventListener(MouseEvent.CLICK)) 
			{
				mcVh.removeEventListener(MouseEvent.CLICK, mcVh_ClickHandler);
			}
			
			if (mcVh.numChildren - 1 >= 0) 
			{
				while (mcVh.numChildren - 1) 
				{
					mcVh.removeChildAt(mcVh.numChildren - 1);
				}
			}
			
			this.removeChild(mcVh);
			mcVh = null;
			
			btn_mc.removeEventListener(MouseEvent.MOUSE_DOWN, closeBtn_MouseDownHandler);
			if (stage && stage.hasEventListener(MouseEvent.MOUSE_UP)) 
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, closeBtnStage_mouseUpHandler);
			}
			
			btn_mc.Destroy();
			btn_mc = null;
			
			if (dataLoader && dataLoader.contentLoaderInfo && dataLoader.contentLoaderInfo.hasEventListener(IOErrorEvent.IO_ERROR) || 
			dataLoader && dataLoader.contentLoaderInfo && dataLoader.contentLoaderInfo.hasEventListener(Event.COMPLETE)) 
			{
				dataLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, dataLoader_IoErrorHandler);
				dataLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, dataLoader_CompleteHandler);
			}
			
			try 
			{
				dataLoader.close();
				dataLoader.unload();
				dataLoader = null;
			}catch (err:Error)
			{
			}
			
			removeChild(mcVideoColorBg);
			mcVideoColorBg = null;
			
			mcHeader.mcNpLbl.removeChild(mcHeader.mcNpLbl.txt);
			mcHeader.mcNpLbl.txt = null;
			
			mcHeader.removeChild(mcHeader.mcNpLbl);
			mcHeader.mcNpLbl = null;
			
			mcHeader.mcNpTxt.removeChild(mcHeader.mcNpTxt.txt);
			mcHeader.mcNpTxt.txt = null;
			
			mcHeader.removeChild(mcHeader.mcNpTxt);
			mcHeader.mcNpTxt = null;
			
			this.removeChild(mcHeader);
			mcHeader = null;
			
			this.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			this.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			
			this.parent.removeChild(this);
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		//} endregion
	}
}