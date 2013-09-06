package com.oxylusflash.multimediaviewer 
{
	//{ region IMPORT CLASSES
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import caurina.transitions.Tweener;
	
	import com.oxylusflash.framework.util.StringUtil;
	import com.oxylusflash.mmgallery.Thumbnails;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class YtGallery extends MultimediaViewer
	{
		//{ region FIELDS
		private var videoPlayer : YouTubePlayer;
		private var resizeTimeLeft : Boolean = true;
		private var objResize : Rectangle = new Rectangle();
		private var isDragging : Boolean = false;
		private var old_parent : Thumbnails;
		//} endregion
		
		//{ region CONSTRUCTOR
		public function YtGallery() 
		{
			//..
			super();
		}
		//} endregion
		
		//{ region EVENT HANDLERS/////////////////////////////////////////////////////////////////////////////////////////////
		
		//{ region ROLL OVER HANDLER
		override internal function rollOverHandler(e:MouseEvent = null):void 
		{
			if (videoPlayer && videoPlayer.vpc && videoPlayer.timer) 
			{
				if (!videoPlayer.timer.running) 
				{
					videoPlayer.timer.reset();
					videoPlayer.timer.start();
				}
			}
			
			super.rollOverHandler(e);
		}
		//} endregion
		
		//{ region ROLL OUT HANDLER
		override internal function rollOutHandler(e:MouseEvent = null):void 
		{
			if (videoPlayer && videoPlayer.vpc && videoPlayer.timer && !isDragging) 
			{
				if (videoPlayer.timer.running) 
				{
					videoPlayer.timer.reset();
					videoPlayer.timer.stop();
				}
			}
			
			super.rollOutHandler(e);
		}
		//} endregion
		
		//{ region VIDEO PLAYER HANDLER
		private final function VideoPlayerHandler(pType : String = ""):void
		{
			switch (pType) 
			{
				case "PLAY":
					if (resizeTimeLeft) 
					{
						resizeTimeLeft = false;
					}
					
					if (mcTogglePp.getState() == "PAUSE") 
					{
						PlayPause();
					}
				break;
				
				case "PAUSE":
					if (mcTogglePp.getState() == "PLAY") 
					{
						PlayPause(false);
					}
				break;
				
				case "AUTOPLAY FALSE":
					signalHandler("PAUSE");
				break;
				
				case "CUED":
					signalHandler("CUED VIDEO");
				break;
				
				case "TIME UPDATE":
					if (!isDragging) 
					{
						mcProgressBar.mcTime.mcPartTime.txt.htmlText = addPrefix(Math.ceil(videoPlayer.vpc.getDuration()), Math.ceil(videoPlayer.vpc.getCurrentTime())) + 
						StringUtil.toTimeString(Math.ceil(videoPlayer.vpc.getCurrentTime()));
						mcProgressBar.mcTime.mcTotalTime.txt.htmlText = StringUtil.toTimeString(Math.ceil(videoPlayer.vpc.getDuration()));
						
						mcProgressBar.perc = Math.ceil(videoPlayer.vpc.getCurrentTime()) / Math.ceil(videoPlayer.vpc.getDuration());
						
						if (Math.ceil(videoPlayer.vpc.getCurrentTime()) < 2) 
						{
							posCounter();
						}
						
						if (!resizeTimeLeft) 
						{
							posCounter(false, false);
						}else 
						{
							posCounter();
						}
					}
				break;
				
				case "PLB COMPLETE":
					if (!isDragging) 
					{
						resizeTimeLeft = true;
						//trace("[INFO]: Playback complete.");
					}
				break;
				
				case "PLB RDY":
					//trace("[INFO]: Playback ready.");
					videoPlayer.vpc.setSize(cWidth, cHeight);
					
					videoPlayer.visible = true;
					videoPlayer.alpha = 1;
					startApp();
				break;
				
				case "ERROR":
					mcProgressBar.mcTime.mcPartTime.txt.htmlText = 
					mcProgressBar.mcTime.mcTotalTime.txt.htmlText = "00:00";
					mcProgressBar.perc = 0;
					mcPlayBtn.visible = false;
					mcPlayBtn.alpha = 0;
					
					posCounter();
					resizeTimeLeft = false;
					
					mcError.mcTxt.txt.htmlText = videoPlayer.errorMsg;
					mcHeader.mcNpTxt.txt.htmlText = videoPlayer.errorMsg;
					mcError.mcBg.width = int(mcError.mcTxt.width + 2 * videoPlayer.settings.error.padX);
					mcError.mcBg.height = int(mcError.mcTxt.height + 2 * videoPlayer.settings.error.padY);
					mcError.mcTxt.x = int((mcError.mcBg.width - mcError.mcTxt.width) * 0.5);
					mcError.mcTxt.y = int((mcError.mcBg.height - mcError.mcTxt.txt.textHeight) * 0.5);
					
					mcError.x = int((cWidth - mcError.mcBg.width) * 0.5 + videoPlayer.settings.error.offsetX);
					mcError.y = int((cHeight - mcError.mcBg.height) * 0.5 + videoPlayer.settings.error.offsetY);
					
					
					mcError.visible = true;
					/*Tu*/
					mcError.alpha = 0;//Black dot
				break;
			}
		}
		//} endregion
		
		//} endregion
		
		//{ region SIGNAL HANDLER
		override public function signalHandler(e : String = "", mouseEv : MouseEvent = null):void 
		{
			super.signalHandler(e, mouseEv);
			
			switch (e) 
			{
				case "PROG DRAG FALSE":
					isDragging = false;
					if (videoPlayer.vpc) 
					{
						videoPlayer.vpc.seekTo(Math.ceil(videoPlayer.vpc.getDuration()) * mcProgressBar.perc, true);
						
						mcProgressBar.mcTime.mcPartTime.txt.htmlText = addPrefix(Math.ceil(videoPlayer.vpc.getDuration()), Math.ceil(videoPlayer.vpc.getCurrentTime())) + 
						StringUtil.toTimeString(Math.ceil(videoPlayer.vpc.getCurrentTime()));
						mcProgressBar.mcTime.mcTotalTime.txt.htmlText = StringUtil.toTimeString(Math.ceil(videoPlayer.vpc.getDuration()));
						
						mcProgressBar.perc = Math.ceil(videoPlayer.vpc.getCurrentTime()) / Math.ceil(videoPlayer.vpc.getDuration());
					}
				break;
				
				case "PROG DRAG TRUE":
					isDragging = true;
					if (videoPlayer.vpc) 
					{
						videoPlayer.vpc.seekTo(Math.ceil(videoPlayer.vpc.getDuration()) * mcProgressBar.perc, false);
						
						mcProgressBar.mcTime.mcPartTime.txt.htmlText = addPrefix(Math.ceil(videoPlayer.vpc.getDuration()), Math.ceil(videoPlayer.vpc.getCurrentTime())) + 
						StringUtil.toTimeString(Math.ceil(videoPlayer.vpc.getCurrentTime()));
						mcProgressBar.mcTime.mcTotalTime.txt.htmlText = StringUtil.toTimeString(Math.ceil(videoPlayer.vpc.getDuration()));
					}
				break;
				
				case "PROGRESS PERC":
					if (videoPlayer.vpc) 
					{
						videoPlayer.vpc.seekTo(Math.ceil(videoPlayer.vpc.getDuration()) * mcProgressBar.perc, false);
						
						mcProgressBar.mcTime.mcPartTime.txt.htmlText = addPrefix(Math.ceil(videoPlayer.vpc.getDuration()), Math.ceil(videoPlayer.vpc.getCurrentTime())) + 
						StringUtil.toTimeString(Math.ceil(videoPlayer.vpc.getCurrentTime()));
						mcProgressBar.mcTime.mcTotalTime.txt.htmlText = StringUtil.toTimeString(Math.ceil(videoPlayer.vpc.getDuration()));
					}
				break;
				
				case "PROG CLICK":
					if (videoPlayer.vpc) 
					{
						videoPlayer.vpc.seekTo(Math.ceil(videoPlayer.vpc.getDuration()) * mcProgressBar.perc, true);
						
						mcProgressBar.mcTime.mcPartTime.txt.htmlText = addPrefix(Math.ceil(videoPlayer.vpc.getDuration()), Math.ceil(videoPlayer.vpc.getCurrentTime())) + 
						StringUtil.toTimeString(Math.ceil(videoPlayer.vpc.getCurrentTime()));
						mcProgressBar.mcTime.mcTotalTime.txt.htmlText = StringUtil.toTimeString(Math.ceil(videoPlayer.vpc.getDuration()));
						
						mcProgressBar.perc = Math.ceil(videoPlayer.vpc.getCurrentTime()) / Math.ceil(videoPlayer.vpc.getDuration());
					}
				break;
				
				case "MAIN VOLUME PERC":
					if (videoPlayer.vpc) 
					{
						videoPlayer.vpc.setVolume(mcVolume.mcVolSlide.perc * 100);
					}
				break;
				
				case "PAUSE":
					if (videoPlayer.vpc && videoPlayer.vpc.getPlayerState() != 2) 
					{
						videoPlayer.vpc.pauseVideo();
					}
				break;
				
				case "PLAY":
					if (videoPlayer.vpc && videoPlayer.vpc.getPlayerState() != 1) 
					{
						videoPlayer.vpc.playVideo();
					}
				break;
				
				case "FULLSCREEN":
					old_parent = Thumbnails(this.parent);
					this.x = -int(cWidth * 0.5);
					this.y = -int(cHeight * 0.5);
					resize();
					
					mcController.y = int(mcVideoPlayerBg.height - mcController.mcBg.height);
					mcHeader.y = 0;
				break;
				
				case "NORMAL":
					old_parent = Thumbnails(this.parent);
					
					cWidth = 
					cW = Math.round(old_parent.bg_mc.width - 2 * old_parent.settings.border.size);
					
					cHeight = 
					cH =  Math.round(old_parent.bg_mc.height - 2 * old_parent.settings.border.size);
					
					this.x = Math.round(old_parent.bg_mc.width * 0.5 - this.cWidth - old_parent.settings.border.size);
					this.y = Math.round(old_parent.bg_mc.height * 0.5 - this.cHeight - old_parent.settings.border.size);
					
					old_parent = null;
				break;
			}
		}
		//} endregion
		
		//{ region METHODS/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		//{ region RESET
		override public function reset():void 
		{
			super.reset();
			/*Tu*/
			mcVideoPlayerBg.alpha = 0;//0
			mcVideoPlayerBg.visible = true;//this allows for mouse over and display the controlls including the close button
			
			mcVideoPlayerBgN.alpha = 0;//0
			mcVideoPlayerBgN.visible = true;
			
			mcProgressBar.mcHitArea.width = mcProgressBar.mcTrack.width;
			mcProgressBar.hitArea = mcProgressBar.mcHitArea;
			mcProgressBar.y = 0;
		}
		//} endregion
		
		//{ region RESIZE
		override public function resize(pFirst : Boolean = false):void 
		{
			posCounterFlag = true;
			super.resize(pFirst);
			
			mcError.x = int((cWidth - mcError.mcBg.width) * 0.5);
			mcError.y = int((cHeight - mcError.mcBg.height) * 0.5);
			
			if (videoPlayer && videoPlayer.vpc && !isDragging) 
			{
				mcProgressBar.mcBtn.width = mcProgressBar.mcTrack.width * (Math.ceil(videoPlayer.vpc.getCurrentTime()) / Math.ceil(videoPlayer.vpc.getDuration()));
				VideoPlayerHandler("TIME UPDATE");
				videoPlayer.vpc.setSize(cWidth, cHeight);
			}
		}
		//} endregion
		
		//{ region START ME UP
		public final function StartMeUp(ytSettings : Object, pPolicy : XMLList, pData : XMLList, pURL : String = ""):void 
		{
			videoPlayer = new YouTubePlayer();
			mcVh.addChild(videoPlayer);
			/*Tu*/
			//videoPlayer.x = -200;
			
			//videoPlayer.x = -20;
			videoPlayer.videoSignal.add(VideoPlayerHandler);
			videoPlayer.volume = detailView.settings.initVolume;
			videoPlayer.autoPlay = detailView.settings.autoPlay;
			videoPlayer.repeat = detailView.settings.repeat;
			videoPlayer.quality = String(pData.quality);
			
			videoPlayer.url = String(pURL);
			videoPlayer.urlXML = pData;
			
			videoPlayer.StartMe(ytSettings, pPolicy);
		}
		//} endregion
		
		//{ region DESTROY ME
		override internal function DestroyMe():void
		{
			mcFullscreen.Destroy();
			mcFullscreen.fullScreenSignal.remove(signalHandler);
			mcFullscreen = null;
			
			super.DestroyMe();
			
			videoPlayer.videoSignal.remove(VideoPlayerHandler);
			videoPlayer.Destroy();
			videoPlayer = null;
			
			if (mcVh.numChildren-1 >= 0) 
			{
				while (mcVh.numChildren-1) 
				{
					mcVh.removeChildAt(mcVh.numChildren - 1);
				}
			}
			
			this.removeChild(mcVh);
			mcVh = null;
			
			btn_mc.Destroy();
			btn_mc = null;
			
			mcTogglePp.playPauseSignal.remove(signalHandler);
			mcTogglePp.Destroy();
			mcTogglePp = null;
			
			mcVolume.mcVolSlide.sliderSignal.remove(signalHandler);
			mcVolume.mcVolBtn.btnSignal.remove(signalHandler)
			mcVolume.Destroy();
			mcVolume = null;
			
			mcProgressBar.progressSignal.remove(signalHandler);
			mcProgressBar.Destroy();
			mcProgressBar = null;
			
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
			
			mcPlayBtn.removeEventListener(MouseEvent.ROLL_OVER, playBtn_rollOverHandler);
			mcPlayBtn.removeEventListener(MouseEvent.ROLL_OUT, playBtn_rollOutHandler);
			mcPlayBtn.removeEventListener(MouseEvent.CLICK, playBtn_clickHandler);
			mcPlayBtn.removeEventListener(MouseEvent.MOUSE_DOWN, playBtn_mouseDownHandler);
			
			if (stage && stage.hasEventListener(MouseEvent.MOUSE_UP)) 
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, mcPlayBtnStage_mouseUpHandler);
			}
			
			removeChild(mcPlayBtn);
			mcPlayBtn = null;
			
			this.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			this.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			
			mcError.mcTxt.removeChild(mcError.mcTxt.txt);
			mcError.mcTxt.txt = null;
			
			mcError.removeChild(mcError.mcTxt);
			mcError.mcTxt = null;
			
			removeChild(mcError);
			mcError = null;
			
			mcController.removeChild(mcController.mcBg);
			mcController.mcBg = null;
			
			removeChild(mcController);
			mcController = null;
			
			removeChild(mcVideoPlayerBg);
			mcVideoPlayerBg = null;
			
			removeChild(mcVideoColorBg);
			mcVideoColorBg = null;
			
			removeChild(mcVideoPlayerBgN);
			mcVideoPlayerBgN = null;
			mcMask = null;
			
			this.parent.removeChild(this);
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		//} endregion
	}
}