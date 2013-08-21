package com.oxylusflash.multimediaviewer 
{
	//{ region IMPORT CLASSES
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextFieldAutoSize;
	
	import caurina.transitions.Tweener;
	import org.osflash.signals.Signal;
	import com.oxylusflash.framework.util.XMLUtils;
	import com.oxylusflash.framework.util.StringUtil;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class MultimediaViewer extends Sprite
	{
		//{ region FIELDS
		public var mcHeader : MovieClip;
		public var mcController : MovieClip;
		public var mcPlayBtn : MovieClip;
		public var mcVideoPlayerBg : MovieClip;
		public var mcVideoPlayerBgN : MovieClip;
		public var mcVh : MovieClip;
		public var mcVideoColorBg : MovieClip;
		public var mcError : MovieClip;
		public var btn_mc : CloseBtn;
		
		//{ region GUI CONSTANT
		internal const FULLSCREEN_DELAY : int = 3000;
		
		internal const TITLE_TOP : int = 7;
		internal const TITLE_LEFT : int = 8;
		internal const TITLE_TXT_LEFT : int = -2;
		
		internal const PLAYPAUSE_TOP : int = 1;
		internal const PLAYPAUSE_LEFT : int = 0;
		
		internal const FULLSCREEN_TOP : int = 1;
		internal const FULLSCREEN_LEFT : int = 0;
		
		internal const VOLUME_TOP : int = 1;
		internal const VOLUME_LEFT : int = 10;
		internal const VOLUME_RIGHT : int = 0;
		
		internal const PROGRESSBAR_PARTTOP : int = -1;
		internal const PROGRESSBAR_PARTLEFT : int = 2;
		internal const PROGRESSBAR_SEP_TOP : int = 0;
		internal const PROGRESSBAR_SEP_LEFT : int = 0;
		internal const PROGRESSBAR_TOTAL_TOP : int = -1;
		internal const PROGRESSBAR_TOTAL_LEFT : int = 1;
		internal const PROGRESSBAR_TIME_TOP : int = 1;
		internal const PROGRESSBAR_TIME_LEFT : int = 7;
		internal const PROGRESSBAR_LEFT : int = 0;
		internal const PROGRESSBAR_TOP : int = 8;
		
		internal const CLOSE_TOP : int = 0;
		internal const CLOSE_LEFT : int = 4;
		internal const CLOSE_TXT_LEFT : int = 4;
		internal const CLOSE_TXT_TOP : int = 7;
		internal const CLOSE_SIGN_LEFT : int = 1;
		internal const CLOSE_SIGN_TOP : int = 10;
		//} endregion
		
		private var _somebodyIsDraging : Boolean = false;
		private var toggleState : String = "";
		private var _rollOut : Boolean = false;
		
		private var mcPlayBtnDrag : Boolean = false;
		
		//mask
		private var _mcMask : Rectangle = new Rectangle();
		private var title_mask : Rectangle = new Rectangle();
		
		private var _mcTogglePp : TogglePlayPause;
		private var _mcFullscreen : FullscreenBtn;
		private var _mcVolume : Volume;
		private var _mcProgressBar : ProgressBar;
		
		private var _detailView : Object = {};
		
		private var dragFlag : Boolean = false;
		private var _autoPlayLoadFlag : Boolean = true;
		private var _hoverMcName : String = "mcVideoPlayerBg";
		private var _hoverMcNameN : String = "mcVideoPlayerBgN";
		private var _posCounterFlag : Boolean = true;
		
		//private var _initVol : Number = 0;
		
		private var _cHeight : Number = 0;
		private var _cWidth : Number = 0;
		
		private var _cW : Number = 0;
		private var _cH : Number = 0;
		private var _animation : Object;
		private var _autoPlay : Boolean = false;
		//} endregion
		
		//{ region CONSTRUCTOR
		public function MultimediaViewer() 
		{
			this.visible = false;
			this.alpha = 0;
		}
		//} endregion
		
		//{ region EVENT HANDLERS///////////////////////////////////////////////////////////////////////////////
		
		//{ region SIGNAL HANDLER
		public function signalHandler(e:String = "", mouseEv : MouseEvent = null):void
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
				
				case "PROG DRAG TRUE":
					dragFlag = true;
					mcTogglePp.mouseEnabled = false;
					toggleState = mcTogglePp.getState();
					signalHandler("PAUSE");
					
					if (!somebodyIsDraging) 
					{
						somebodyIsDraging = true;
					}
				break;
				
				case "PROG DRAG FALSE":
					dragFlag = false;
					
					if (Tweener.isTweening(mcTogglePp.mcPlay.mcO)) 
					{
						Tweener.removeTweens(mcTogglePp.mcPlay.mcO);
					}
					
					mcTogglePp.mcPlay.mcO.visible = false;
					mcTogglePp.mcPlay.mcO.alpha = 0;
					
					mcTogglePp.mouseEnabled = true;
					signalHandler(toggleState);
					checkToggleOstate(toggleState);
					
					if (somebodyIsDraging) 
					{
						somebodyIsDraging = false;
					}
				break;
				
				case "CUED VIDEO":
					autoPlayLoadFlag = false;
					playBtn();
				break;
				
				case "PLAY":
					PlayPause();
				break;
				
				case "PAUSE":
					PlayPause(false);
				break;
				
				case "FULLSCREEN":
					_cHeight = stage.stageHeight;
					_cWidth = stage.stageWidth;
					mcFullscreen.setBtnType();
					//resize();
				break;
				
				case "NORMAL":
					/*
					_cHeight = _cW;
					_cWidth = _cH;
					mcFullscreen.setBtnType(false);
					if (!rollOut)
					{
						resize();
					}else 
					{
						resize(true);
						this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0 , true);
					}
					*/
					
					mcFullscreen.setBtnType(false);
					resize();
					this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0 , true);
				break;
				
				case "FULLSCREEN SHOW CONTROLLER":
					if (rollOut) 
					{
						rollOverHandler();
					}
				break;
				
				case "FULLSCREEN HIDE CONTROLLER":
					if (!somebodyIsDraging) 
					{
						mcFullscreen.doHide = true;
					}else 
					{
						mcFullscreen.doHide = false;
					}
					rollOutHandler();
				break;
			}
		}
		//} endregion
		
		//{ region ROLL OVER HANDLER
		internal function rollOverHandler(e:MouseEvent = null):void 
		{
			if (this.hasEventListener(MouseEvent.MOUSE_MOVE)) 
			{
				this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			}
			
			if (e != null) 
			{
				e.updateAfterEvent();
			}
			
			rollOut = false;
			Tweener.addTween(mcController, { y: int(_cHeight - mcController.mcBg.height), time: .3, transition: "easeOutQuad" } );
			Tweener.addTween(mcHeader, { y: 0, time: .3, transition: "easeOutQuad" } );
		}
		//} endregion
		
		//{ region ROLL OUT HANDLER
		internal function rollOutHandler(e:MouseEvent = null):void 
		{
			if (!somebodyIsDraging)
			{
				if (e != null) 
				{
					e.updateAfterEvent();
				}
				
				rollOut = true;
				Tweener.addTween(mcController, { y: int(_cHeight), time: .3, transition: "easeOutQuad" } );
				Tweener.addTween(mcHeader, { y: int(- mcHeader.mcBg.height), time: .3, transition: "easeOutQuad" } );
			}
		}
		//} endregion
		
		//{ region CLICK HANDLER
		internal function clickHandler(e:MouseEvent):void 
		{
			if (e.target.name == _hoverMcName || e.target.name == _hoverMcNameN)
			{
				if (autoPlayLoadFlag) 
				{
					playBtn(false);
					signalHandler("PAUSE");
					checkToggleOstate("PAUSE");
				}else 
				{
					autoPlayLoadFlag = true;
					signalHandler("PLAY");
					checkToggleOstate("PLAY");
				}
			}
		}
		//} endregion
		
		//{ region PLAY BTN ROLL OVER HANDLER
		internal final function playBtn_rollOverHandler(e:MouseEvent):void 
		{
			Tweener.addTween(mcPlayBtn, { alpha: _detailView.playBtn.overAlpha, time: 0.3, transition: "easeoutquad" });
		}
		//} endregion
		
		//{ region PLAY BTN ROLL OUT HANDLER
		internal final function playBtn_rollOutHandler(e:MouseEvent = null):void 
		{
			if (!mcPlayBtnDrag) 
			{
				Tweener.addTween(mcPlayBtn, { alpha: _detailView.playBtn.normalAlpha, time: 0.3, transition: "easeoutquad" });
			}
		}
		//} endregion
		
		//{ region PLAY BTN CLICK HANDLER
		internal final function playBtn_clickHandler(e:MouseEvent = null):void 
		{
			playBtn();
			signalHandler("PLAY");
			checkToggleOstate();
		}
		//} endregion
		
		//{ region PLAY BTN MOUSE DOWN HANDLER
		internal final function playBtn_mouseDownHandler(e:MouseEvent):void 
		{
			mcPlayBtnDrag = true;
			signalHandler("DRAG TRUE", null);
			stage.addEventListener(MouseEvent.MOUSE_UP, mcPlayBtnStage_mouseUpHandler, false, 0, true);
		}
		//} endregion
		
		//{ region MC PLAY BTN STAGE MOUSE UP HANDLER
		internal final function mcPlayBtnStage_mouseUpHandler(e:MouseEvent):void 
		{
			mcPlayBtnDrag = false;
			signalHandler("DRAG FALSE", null);
			
			if (e.target != mcPlayBtn)
			{
				signalHandler("MAIN ROLL OUT", e);
			}
			
			if (e.target != mcPlayBtn) 
			{
				playBtn_rollOutHandler();
			}
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, mcPlayBtnStage_mouseUpHandler);
		}
		//} endregion
		
		//{ region CLOSE BTN MOUSE DOWN HANDLER
		internal function closeBtn_MouseDownHandler(e:MouseEvent):void 
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
		
		//{ region MOUSE MOVE HANDLER
		internal function mouseMoveHandler(e:MouseEvent = null):void 
		{
			if (rollOut) 
			{
				this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				rollOverHandler();
			}
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS//////////////////////////////////////////////////////////////////////////////////////
		
		//{ region RESET
		public function reset():void
		{
			mcHeader.x = 
			mcController.x = 
			mcVideoPlayerBg.x = 
			mcVideoPlayerBgN.x = 
			mcVideoColorBg.x = 
			mcVideoColorBg.y = 
			mcVideoPlayerBgN.y = 
			mcVideoPlayerBg.y = 
			mcMask.x = 
			mcMask.y = 0;
			
			mcController.y = _cHeight;
			
			//TOGGLE PLAY PAUSE
			mcTogglePp = new TogglePlayPause();
			mcTogglePp.x = PLAYPAUSE_LEFT; 
			mcTogglePp.y = PLAYPAUSE_TOP;
			mcTogglePp.startMe();
			mcTogglePp.playPauseSignal.add(signalHandler);
			mcController.addChild(mcTogglePp);
			
			//FULLSCREEN BTN
			mcFullscreen = new FullscreenBtn();
			mcFullscreen.y = FULLSCREEN_TOP;
			mcFullscreen.delay = FULLSCREEN_DELAY;
			
			mcFullscreen.startMe();
			mcFullscreen.fullScreenSignal.add(signalHandler);
			mcController.addChild(mcFullscreen);
			
			//VOLUME
			mcVolume = new Volume();
			mcVolume.setData(_detailView.settings.initVolume);
			mcVolume.y = VOLUME_TOP;
			
			mcVolume.mcVolSlide.sliderSignal.add(signalHandler);
			mcVolume.mcVolBtn.btnSignal.add(signalHandler);
			mcController.addChild(mcVolume);
			
			//PROGRESS BAR
			mcProgressBar = new ProgressBar();
			mcProgressBar.mcBuff.width = 0;
			mcProgressBar.mcTime.mcPartTime.txt.text = 
			mcProgressBar.mcTime.mcTotalTime.txt.text = "00:00";
			
			mcProgressBar.mcTime.mcPartTime.x = PROGRESSBAR_PARTLEFT;
			mcProgressBar.mcTime.mcPartTime.y = PROGRESSBAR_PARTTOP;
			
			mcProgressBar.mcTime.mcSep.x = int(PROGRESSBAR_SEP_LEFT + mcProgressBar.mcTime.mcPartTime.x + mcProgressBar.mcTime.mcPartTime.width);
			mcProgressBar.mcTime.mcSep.y = PROGRESSBAR_SEP_TOP;
			
			mcProgressBar.mcTime.mcTotalTime.x = int(PROGRESSBAR_TOTAL_LEFT + mcProgressBar.mcTime.mcSep.x + mcProgressBar.mcTime.mcSep.width);
			mcProgressBar.mcTime.mcTotalTime.y = PROGRESSBAR_TOTAL_TOP;
			mcProgressBar.mcTime.mcBg.height = mcProgressBar.mcTime.mcSep.height;
			mcProgressBar.mcTime.mcBg.alpha = 0;
			
			mcProgressBar.mcTime.y = PROGRESSBAR_TIME_TOP;
			
			mcProgressBar.x = int(PROGRESSBAR_LEFT + mcTogglePp.x + mcTogglePp.mcBg.width);
			mcProgressBar.y = PROGRESSBAR_TOP;
			
			mcProgressBar.progressSignal.add(signalHandler);
			
			mcProgressBar.startMe();
			mcController.addChild(mcProgressBar);
			
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
			mcHeader.mcNpLbl.txt.text = _detailView.settings.label;
			
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
			
			btn_mc.visible = true;
			btn_mc.alpha = 1;
			btn_mc.mouseEnabled = true;
			
			//ERROR
			mcError.visible = false;
			mcError.alpha = 0;
			mcError.mcTxt.txt.x = 
			mcError.mcTxt.txt.y = 
			mcError.mcTxt.x = 
			mcError.mcTxt.y = 
			mcError.mcBg.x = 
			mcError.mcBg.y = 
			mcError.mcBg.width = 
			mcError.mcBg.height = 0;
			
			//formatting mcError.mcTxt.txt
			mcError.mcTxt.txt.autoSize = TextFieldAutoSize.LEFT;
			mcError.mcTxt.txt.selectable = false;
			mcError.mcTxt.txt.condenseWhite = true;
			mcError.mcTxt.txt.multiline = false;
			mcError.mcTxt.txt.embedFonts = true;
			mcError.mcTxt.txt.wordWrap = false;
			mcError.mcTxt.txt.text = "";
			mcError.mcTxt.txt.mouseWheelEnabled = false;
			//for testing only
			//mcError.mcTxt.txt.background = true;
			//mcError.mcTxt.txt.backgroundColor = 0x006633;
			
			//PLAY BTN
			mcPlayBtn.buttonMode = true;
			mcPlayBtn.mouseChildren = false;
			mcPlayBtn.addEventListener(MouseEvent.ROLL_OVER, playBtn_rollOverHandler, false, 0, true);
			mcPlayBtn.addEventListener(MouseEvent.ROLL_OUT, playBtn_rollOutHandler, false, 0, true);
			mcPlayBtn.addEventListener(MouseEvent.CLICK, playBtn_clickHandler, false, 0, true);
			mcPlayBtn.addEventListener(MouseEvent.MOUSE_DOWN, playBtn_mouseDownHandler, false, 0, true);
			
			//SHOW COMPONENTS AND HIDE THEM
			mcTogglePp.visible = true;
			mcTogglePp.alpha = 1;
			
			mcProgressBar.visible = true;
			mcProgressBar.alpha = 1;
			
			mcFullscreen.visible = true;
			mcFullscreen.alpha = 1;
			
			mcVolume.visible = true;
			mcVolume.alpha = 1;
			
			mcVideoPlayerBg.alpha = 0;
			mcVideoPlayerBg.visible = false;
			
			mcPlayBtn.visible = true;
			mcPlayBtn.alpha = _detailView.playBtn.normalAlpha;
			
			mcController.mcBg.useHandCursor = false;
			mcHeader.mcBg.useHandCursor = false;
			
			mcVideoPlayerBgN.alpha = 0;
			mcVideoPlayerBgN.visible = true;
			
			mcVh.visible = false;
			mcVh.alpha = 0;
			
			this.mouseChildren = true;
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, 0, true);
			
			resize(true);
		}
		//} endregion
		
		//{ region RESIZE
		public function resize(pFirst : Boolean = false):void
		{
			mcController.mcBg.width = 
			mcHeader.mcBg.width = 
			mcVideoColorBg.width = 
			mcVideoPlayerBg.width = 
			mcVideoPlayerBgN.width = 
			mcMask.width = _cWidth;
			
			mcVideoColorBg.height = 
			mcVideoPlayerBg.height = 
			mcVideoPlayerBgN.height = 
			mcMask.height = _cHeight;
			this.scrollRect = mcMask;
			
			if (!pFirst) 
			{
				if (Tweener.isTweening(mcController)) 
				{
					Tweener.removeTweens(mcController);
				}
				
				if (Tweener.isTweening(mcHeader)) 
				{
					Tweener.removeTweens(mcHeader);
				}
			}else 
			{
				if (Tweener.isTweening(mcHeader)) 
				{
					Tweener.removeTweens(mcHeader);
				}
				
				if (Tweener.isTweening(mcController)) 
				{
					Tweener.removeTweens(mcController);
				}
			}
			
			rollOut = true;
			mcController.y = int(mcVideoPlayerBg.height);
			mcHeader.y = int( -mcHeader.mcBg.height);
			
			mcFullscreen.x = int(mcController.mcBg.width - (mcFullscreen.mcHitArea.width + FULLSCREEN_LEFT));
			mcVolume.x = int(mcFullscreen.x - (mcVolume.mcBg.width + VOLUME_RIGHT));
			/*
			mcError.x = int((_cWidth - mcError.mcBg.width) * 0.5);
			mcError.y = int((_cHeight - mcError.mcBg.height) * 0.5);
			*/
			btn_mc.x = int(mcHeader.mcBg.width - (btn_mc.hitArea_mc.width + CLOSE_LEFT));
			
			mcPlayBtn.x = int((mcVideoPlayerBg.width - mcPlayBtn.width) * 0.5);
			mcPlayBtn.y = int((mcVideoPlayerBg.height - mcPlayBtn.height) * 0.5);
			posCounter(_posCounterFlag);
			
			btn_mc.x = int(mcHeader.mcBg.width - (btn_mc.hitArea_mc.width + CLOSE_LEFT));
			
			SetTitleMask();
		}
		//} endregion
		
		//{ region POS COUNTER
		internal final function posCounter(pType : Boolean = true, pResizeMe : Boolean = true):void
		{
			if (pResizeMe) 
			{
				mcProgressBar.mcTime.mcSep.x = int(PROGRESSBAR_SEP_LEFT + mcProgressBar.mcTime.mcPartTime.x + mcProgressBar.mcTime.mcPartTime.width);
				mcProgressBar.mcTime.mcTotalTime.x = int(PROGRESSBAR_TOTAL_LEFT + mcProgressBar.mcTime.mcSep.x + mcProgressBar.mcTime.mcSep.width);
				mcProgressBar.mcTime.mcBg.width = int(mcProgressBar.mcTime.mcTotalTime.x + mcProgressBar.mcTime.mcTotalTime.width);
				
				mcProgressBar.mcTrackShadow.width = 
				mcProgressBar.mcTrack.width = int(mcVolume.x - (mcProgressBar.x + mcProgressBar.mcTime.mcBg.width + VOLUME_LEFT));
			}
			
			if (pType) 
			{
				mcProgressBar.mcHitArea.width = 
				mcProgressBar.mcBuff.width = int(mcProgressBar.mcTrack.width);
			}
			
			if (!pResizeMe) 
			{
				mcProgressBar.mcTime.mcPartTime.x = int(mcProgressBar.mcTime.mcSep.x - PROGRESSBAR_SEP_LEFT) - int(mcProgressBar.mcTime.mcPartTime.width);
			}else 
			{
				mcProgressBar.mcTime.mcPartTime.x = PROGRESSBAR_PARTLEFT;
			}
			
			mcProgressBar.mcTime.x = int(PROGRESSBAR_TIME_LEFT + mcProgressBar.mcTrack.x + mcProgressBar.mcTrack.width);
		}
		//} endregion
		
		//{ region PLAY BTN
		internal function playBtn(pType : Boolean = true):void
		{
			if (pType) 
			{
				mcPlayBtn.visible = false;
				mcPlayBtn.alpha = 0;
				mcPlayBtn.mouseEnabled = false;
				this.mouseEnabled = true;
				this.buttonMode = true;
				this.addEventListener(MouseEvent.CLICK, clickHandler, false, 00, true);
			}else 
			{
				mcPlayBtn.visible = true;
				Tweener.addTween(mcPlayBtn, { alpha: _detailView.playBtn.normalAlpha, time: 0.3, transition: "easeoutquad" });
				mcPlayBtn.mouseEnabled = true;
				this.mouseEnabled = false;
				this.buttonMode = false;
				this.removeEventListener(MouseEvent.CLICK, clickHandler);
			}
		}
		//} endregion
		
		//{ region PLAY PAUSE
		internal final function PlayPause(play : Boolean  = true):void
		{
			if (play) 
			{//play
				if (!autoPlay) 
				{
					autoPlay = true;
				}
				
				if (!autoPlayLoadFlag) 
				{
					autoPlayLoadFlag = true;
				}
				
				if (mcPlayBtn.visible && !dragFlag) 
				{
					playBtn();
				}
				
				mcTogglePp.mcPlay.visible = false;
				mcTogglePp.mcPlay.alpha = 0;
				
				mcTogglePp.mcPause.visible = true;
				mcTogglePp.mcPause.alpha = 1;
			}else 
			{//pause
				if (!mcPlayBtn.visible && !dragFlag) 
				{
					playBtn(false);
				}
				
				mcTogglePp.mcPause.visible = false;
				mcTogglePp.mcPause.alpha = 0;
				
				mcTogglePp.mcPlay.visible = true;
				mcTogglePp.mcPlay.alpha = 1;
			}
		}
		//} endregion
		
		//{ region CHECK TOGGLE OVER STATE
		internal final function checkToggleOstate(pType : String = "PLAY"):void
		{
			if (pType == "PLAY") 
			{
				if (Tweener.isTweening(mcTogglePp.mcPause.mcO)) 
				{
					Tweener.removeTweens(mcTogglePp.mcPause.mcO);
				}
				mcTogglePp.mcPause.mcO.visible = false;
				mcTogglePp.mcPause.mcO.alpha = 0;
			}else 
			{
				if (Tweener.isTweening(mcTogglePp.mcPlay.mcO)) 
				{
					Tweener.removeTweens(mcTogglePp.mcPlay.mcO);
				}
				mcTogglePp.mcPlay.mcO.visible = false;
				mcTogglePp.mcPlay.mcO.alpha = 0;
			}
		}
		//} endregion
		
		//{ region START APP
		internal function startApp():void
		{
			showApp();
		}
		//} endregion
		
		//{ region SHOW INTERFACE
		public function ShowInterface():void 
		{
			this.visible = true;
			Tweener.addTween(this, { alpha: 1, time: 0.3, transition: "easeoutquad" });
		}
		//} endregion
		
		//{ region SHOW APP
		internal function showApp():void
		{
			/*this.visible = true;
			Tweener.addTween(this, { alpha: 1, time: 0.3, transition: "easeoutquad", onComplete: function ():void 
			{
				mcVh.visible = true;
				Tweener.addTween(mcVh, { alpha: 1, time: _animation.bringToFrontTime, transition: _animation.bringToFrontType });
			} } );*/
			
			mcVh.visible = true;
			Tweener.addTween(mcVh, { alpha: 1, time: _animation.bringToFrontTime, transition: _animation.bringToFrontType });
		}
		//} endregion
		
		//{ region DESTROY
		public function Destroy():void 
		{
			if (Tweener.isTweening(mcVh)) 
			{
				Tweener.removeTweens(mcVh);
			}
			
			if (Tweener.isTweening(this)) 
			{
				Tweener.removeTweens(this);
			}
			
			if (this.hasEventListener(MouseEvent.MOUSE_MOVE)) 
			{
				this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0 , true);
			}
			
			this.visible = false;
			this.alpha = 0;
			DestroyMe();
		}
		//} endregion
		
		//{ region SET TITLE MASK
		public function SetTitleMask():void
		{
			title_mask.height = int(mcHeader.mcNpTxt.txt.textHeight);
			title_mask.width = int(btn_mc.x - mcHeader.mcNpTxt.x);
			mcHeader.mcNpTxt.scrollRect = title_mask;
		}
		//} endregion
		
		//{ region DESTROY ME
		internal function DestroyMe():void
		{
			if (btn_mc.hasEventListener(MouseEvent.MOUSE_DOWN)) 
			{
				btn_mc.removeEventListener(MouseEvent.MOUSE_DOWN, closeBtn_MouseDownHandler);
			}
			
			if (stage && stage.hasEventListener(MouseEvent.MOUSE_UP)) 
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, closeBtnStage_mouseUpHandler);
			}
			//...
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		internal function get rollOut():Boolean { return _rollOut; }
		internal function set rollOut(value:Boolean):void 
		{
			_rollOut = value;
		}
		
		internal function get somebodyIsDraging():Boolean { return _somebodyIsDraging; }
		internal function set somebodyIsDraging(value:Boolean):void 
		{
			_somebodyIsDraging = value;
		}
		
		internal function get mcMask():Rectangle { return _mcMask; }
		internal function set mcMask(value:Rectangle):void 
		{
			_mcMask = value;
		}
		
		internal function get posCounterFlag():Boolean { return _posCounterFlag; }
		internal function set posCounterFlag(value:Boolean):void 
		{
			_posCounterFlag = value;
		}
		
		internal function get mcTogglePp():TogglePlayPause { return _mcTogglePp; }
		internal function set mcTogglePp(value:TogglePlayPause):void 
		{
			_mcTogglePp = value;
		}
		
		public function get mcFullscreen():FullscreenBtn { return _mcFullscreen; }
		public function set mcFullscreen(value:FullscreenBtn):void 
		{
			_mcFullscreen = value;
		}
		
		public function get cW():Number { return _cW; }
		public function set cW(value:Number):void 
		{
			_cW = value;
		}
		
		public function get cH():Number { return _cH; }
		public function set cH(value:Number):void 
		{
			_cH = value;
		}
		
		public function get mcVolume():Volume { return _mcVolume; }
		public function set mcVolume(value:Volume):void 
		{
			_mcVolume = value;
		}
		
		public function get mcProgressBar():ProgressBar { return _mcProgressBar; }
		public function set mcProgressBar(value:ProgressBar):void 
		{
			_mcProgressBar = value;
		}
		
		public function get autoPlayLoadFlag():Boolean { return _autoPlayLoadFlag; }
		public function set autoPlayLoadFlag(value:Boolean):void 
		{
			_autoPlayLoadFlag = value;
		}
		
		public function get cWidth():Number { return _cWidth; }
		public function set cWidth(value:Number):void 
		{
			_cWidth = value;
		}
		
		public function get cHeight():Number { return _cHeight; }
		public function set cHeight(value:Number):void 
		{
			_cHeight = value;
		}
		
		public function get detailView():Object { return _detailView; }
		public function set detailView(value:Object):void 
		{
			_detailView = value;
		}
		
		public function get animation():Object { return _animation; }
		public function set animation(value:Object):void 
		{
			_animation = value;
		}
		
		public function get autoPlay():Boolean { return _autoPlay; }
		public function set autoPlay(value:Boolean):void 
		{
			_autoPlay = value;
		}
		//} endregion
	}
}
