package com.oxylusflash.multimediaviewer 
{
	//{ region IMPORT CLASSES
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.sampler.NewObjectSample;
	
	import caurina.transitions.Tweener;
	import com.oxylusflash.framework.resize.Resize;
	import com.oxylusflash.framework.resize.ResizeType;
	import com.oxylusflash.framework.util.StringUtil;
	import com.oxylusflash.mmgallery.Thumbnails;
	import com.oxylusflash.multimediaviewer.LocalVideoPlayer;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class LclVidGallery extends MultimediaViewer
	{
		//{ region FIELDS
		private var preloader : Preloader;		
		private var videoPlayer : LocalVideoPlayer;
		private var buffWidth : Number = 0;
		private var resizeTimeLeft : Boolean = true;
		private var color : ColorTransform;
		private var objResize : Rectangle = new Rectangle();
		private var isDragging : Boolean = false;
		private var percValue : Number = -1;
		private var old_parent : Thumbnails;
		//} endregion
		
		//{ region CONSTRUCTOR
		public function LclVidGallery() 
		{
			super();
			//...
		}
		//} endregion
		
		//{ region EVENT HANDLERS//////////////////////////////////////////////////////////////////////////////////////
		
		//{ region VIDEO PLAYER HANDLER
		private final function VideoPlayerHandler(pType : String = ""):void
		{
			switch (pType) 
			{
				case "BUFFER ON":
					animatePreloader(true);
				break;
				
				case "BUFFER OFF":
					animatePreloader(false);
				break;
				
				case "PLAY":
					animatePreloader(false);
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
				
				case "TIME UPDATE":
					//var crtTime : Number = (videoPlayer.vpc.currentTime < videoPlayer.tltTime && videoPlayer.tltTime != 0)? 
					//Math.round(videoPlayer.vpc.currentTime) : Math.round(videoPlayer.tltTime);
					
					var tltTime : Number = (videoPlayer.vpc.totalTime < videoPlayer.tltTime && videoPlayer.tltTime != 0)? 
					Math.round(videoPlayer.tltTime) : 
					Math.round(videoPlayer.vpc.totalTime);
					
					mcProgressBar.mcTime.mcPartTime.txt.htmlText = addPrefix(tltTime, Math.floor(videoPlayer.vpc.currentTime)) + 
					StringUtil.toTimeString(Math.floor(videoPlayer.vpc.currentTime));
					
					mcProgressBar.mcTime.mcTotalTime.txt.htmlText = StringUtil.toTimeString(tltTime);
					
					/*if (Math.round(videoPlayer.vpc.currentTime) < 1) 
					{
						posCounter(buffWidth == 1);
					}
					
					if (!resizeTimeLeft) 
					{
						posCounter(buffWidth == 1, false);
					}else 
					{
						posCounter(buffWidth == 1);
					}*/
					
					if (!isDragging) 
					{
						//mcProgressBar.perc = (videoPlayer.vpc.totalTime > 0)? Math.floor(videoPlayer.vpc.currentTime) / 
						//Math.round(videoPlayer.vpc.totalTime) : 0;
						
						mcProgressBar.perc = (videoPlayer.vpc.totalTime > 0)? Math.floor(videoPlayer.vpc.currentTime) / 
						tltTime : 0;
					}else 
					{
						//mcProgressBar.percLimit = (Math.floor(videoPlayer.vpc.totalTime - 1) / 
						//Math.round(videoPlayer.vpc.totalTime));
						
						mcProgressBar.percLimit = (tltTime - 1) / 
						tltTime;
					}
					
					if (Math.round(videoPlayer.vpc.currentTime) < 1) 
					{
						posCounter(buffWidth == 1);
					}
					
					if (!resizeTimeLeft) 
					{
						posCounter(buffWidth == 1, false);
					}else 
					{
						posCounter(buffWidth == 1);
					}
				break;
				
				case "LOADING PROGRESS":
					if (!isNaN(videoPlayer.vpc.loadedBytes / videoPlayer.vpc.totalBytes)) 
					{
						buffWidth = (videoPlayer.vpc.loadedBytes / videoPlayer.vpc.totalBytes);
						mcProgressBar.mcHitArea.width = 
						mcProgressBar.mcBuff.width = Math.round(mcProgressBar.mcTrack.width * buffWidth);
						
						if (buffWidth == 1) 
						{
							posCounter(true);
						}
					}
				break;
				
				case "PLB COMPLETE":
					if (!isDragging && mcProgressBar.perc == 1) 
					{
						mcProgressBar.percLimit = 1;
						mcProgressBar.perc = 0;
						resizeTimeLeft = true;
						
						mcProgressBar.mcTime.mcPartTime.txt.htmlText = "00:00";
						mcProgressBar.mcTime.mcTotalTime.txt.htmlText = "00:00";
						posCounter();
						
						//trace("[INFO]: Playback complete.");
					}
					//resizeTimeLeft = true;
				break;
				
				case "PLB RDY":
					//trace("[INFO]: Playback ready.");
					if (!videoPlayer.video.smoothing) 
					{
						videoPlayer.video.smoothing = true;
					}
					
					videoPlayer.visible = true;
					videoPlayer.alpha = 1;
					
					videoPlayer.video.visible = true;
					videoPlayer.video.alpha = 1;
					
					fitMe();
					startApp();
				break;
				
				case "ERROR":
					resizeTimeLeft = false;
				break;
			}
		}
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
						videoPlayer.isDragging = false;
						videoPlayer.vpc.seek(
						((videoPlayer.vpc.totalTime < videoPlayer.tltTime && videoPlayer.tltTime != 0)? 
						Math.round(videoPlayer.tltTime) : Math.round(videoPlayer.vpc.totalTime)) * mcProgressBar.perc, false);
					}
					mcProgressBar.percLimit = 1;
				break;
				
				case "PROG DRAG TRUE":
					isDragging = true;
					if (videoPlayer.vpc) 
					{
						videoPlayer.isDragging = true;
						videoPlayer.vpc.seek(
						((videoPlayer.vpc.totalTime < videoPlayer.tltTime && videoPlayer.tltTime != 0)? 
						Math.round(videoPlayer.tltTime) : Math.round(videoPlayer.vpc.totalTime)) * mcProgressBar.perc, false);
					}
				break;
				
				case "PROGRESS PERC":
					if (videoPlayer.vpc) 
					{
						videoPlayer.vpc.seek(
						((videoPlayer.vpc.totalTime < videoPlayer.tltTime && videoPlayer.tltTime != 0)? 
						Math.round(videoPlayer.tltTime) : Math.round(videoPlayer.vpc.totalTime)) * mcProgressBar.perc, false);
					}
				break;
				
				case "PROG CLICK":
					if (videoPlayer.vpc) 
					{
						videoPlayer.vpc.seek(
						((videoPlayer.vpc.totalTime < videoPlayer.tltTime && videoPlayer.tltTime != 0)? 
						Math.round(videoPlayer.tltTime) : Math.round(videoPlayer.vpc.totalTime)) * mcProgressBar.perc, false);
					}
				break;
				
				case "MAIN VOLUME PERC":
					if (videoPlayer.vpc) 
					{
						videoPlayer.vpc.volume = mcVolume.mcVolSlide.perc;
					}
				break;
				
				case "PAUSE":
					if (videoPlayer.vpc.playing) 
					{
						videoPlayer.vpc.pause();
					}
				break;
				
				case "PLAY":
					if (!videoPlayer.vpc.playing) 
					{
						videoPlayer.vpc.play();
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
		
		//} endregion
		
		//{ region METHODS/////////////////////////////////////////////////////////////////////////////////////////////
		
		//{ region RESET
		override public function reset():void 
		{
			super.reset();
			
			mcError.mcTxt.removeChild(mcError.mcTxt.txt);
			mcError.mcTxt.txt = null;
			
			mcError.removeChild(mcError.mcTxt);
			mcError.mcTxt = null;
			
			removeChild(mcError);
			mcError = null;
			mcProgressBar.hitArea = mcProgressBar.mcBuff;
		}
		//} endregion
		
		//{ region RESIZE
		override public function resize(pFirst : Boolean = false):void 
		{
			posCounterFlag = (buffWidth == 1);
			super.resize(pFirst);
			
			if (preloader) 
			{
				preloader.x = int(cWidth * 0.5);
				preloader.y = int(cHeight * 0.5);
			}
			
			if (videoPlayer && videoPlayer.vpc && !isDragging) 
			{
				mcProgressBar.mcBtn.width = mcProgressBar.mcTrack.width * (Math.floor(videoPlayer.vpc.currentTime) / 
				((videoPlayer.vpc.totalTime < videoPlayer.tltTime && videoPlayer.tltTime != 0)? 
				Math.round(videoPlayer.tltTime) : Math.round(videoPlayer.vpc.totalTime)));
				
				VideoPlayerHandler("TIME UPDATE");
				fitMe();
			}
		}
		//} endregion
		
		//{ region START ME UP
		public final function StartMeUp(pData : XMLList):void 
		{
			preloader = new Preloader();
			preloader.visible = false;
			preloader.alpha = 0;
			
			//color
			color = new ColorTransform();
			color.color = detailView.settings.preloaderColor;
			preloader.transform.colorTransform = color
			
			preloader.x = int(cWidth * 0.5);
			preloader.y = int(cHeight * 0.5);
			
			this.addChild(preloader);
			SwapPreloader();
			
			videoPlayer = new LocalVideoPlayer();
			mcVh.addChild(videoPlayer);
			
			videoPlayer.videoSignal.add(VideoPlayerHandler);
			videoPlayer.volume = detailView.settings.initVolume;
			videoPlayer.autoPlay = detailView.settings.autoPlay;
			videoPlayer.repeat = detailView.settings.repeat;
			videoPlayer.buffer = detailView.settings.buffer;
			
			videoPlayer.StartMe(String(pData.file));
		}
		//} endregion
		
		//{ region ANIMATE PRELOADER
		private final function animatePreloader(arg1:Boolean):void
		{
			if (Tweener.isTweening(preloader)) 
			{
				Tweener.removeTweens(preloader);
			}
			
			if (arg1) 
			{//show Preloader
				preloader.visible = true;
				Tweener.addTween(preloader, { alpha: 1, time: 0.3, transition: "easeoutquad", onComplete: function ():void 
				{
					SwapPreloader();
					
				} } );
			}else 
			{//hidePreloader
				Tweener.addTween(preloader, { alpha: 0, time: 0.3, transition: "easeoutquad", onComplete: function ():void 
				{
					if (preloader) 
					{
						preloader.visible = false;
						SwapPreloader();
					}
				} } );
			}
		}
		//} endregion
		
		//{ region SWAP PRELOADER
		private final function SwapPreloader():void
		{
			this.swapChildren(preloader, mcPlayBtn);
		}
		//} endregion
		
		//{ region FIT ME
		private final function fitMe():void
		{
			switch (String(StringUtil.squeeze(detailView.settings.fit)).toLowerCase())
			{
				case "fittofill":
					objResize = 
					Resize.compute(new Rectangle(0, 0, videoPlayer.vpc.videoWidth, videoPlayer.vpc.videoHeight), 
					new Rectangle(0, 0, cWidth, cHeight), ResizeType.FILL);
				break;
				
				case "fittosize":
					objResize = 
					Resize.compute(new Rectangle(0, 0, videoPlayer.vpc.videoWidth, videoPlayer.vpc.videoHeight), 
					new Rectangle(0, 0, cWidth, cHeight), ResizeType.FIT);
				break;
				
				case "fittosizeforced":
					objResize = 
					Resize.compute(new Rectangle(0, 0, videoPlayer.vpc.videoWidth, videoPlayer.vpc.videoHeight), 
					new Rectangle(0, 0, cWidth, cHeight), ResizeType.FIT_FORCED);
				break;
				
				case "stretch":
					objResize = 
					Resize.compute(new Rectangle(0, 0, videoPlayer.vpc.videoWidth, videoPlayer.vpc.videoHeight), 
					new Rectangle(0, 0, cWidth, cHeight), ResizeType.STRETCH);
				break;
				
				case "normal":
					objResize = 
					Resize.compute(new Rectangle(0, 0, videoPlayer.vpc.videoWidth, videoPlayer.vpc.videoHeight), 
					new Rectangle(0, 0, cWidth, cHeight), ResizeType.NO_RESIZE);
				break;
			}
			
			videoPlayer.video.x = int((cWidth - objResize.width) * 0.5);
			videoPlayer.video.y = int((cHeight - objResize.height) * 0.5);
			
			videoPlayer.video.width = objResize.width;
			videoPlayer.video.height = objResize.height;
			
			objResize = new Rectangle();
		}
		//} endregion
		
		//{ region DESTROY ME
		override internal function DestroyMe():void
		{
			mcFullscreen.Destroy();
			mcFullscreen.fullScreenSignal.remove(signalHandler);
			mcFullscreen = null;
			
			super.DestroyMe();
			
			videoPlayer.vpc.destroy();
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
			
			if (Tweener.isTweening(preloader)) 
			{
				Tweener.removeTweens(preloader);
			}
			
			this.removeChild(preloader);
			preloader = null;
			
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