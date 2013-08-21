package com.oxylusflash.multimediaviewer 
{
	//{ region IMPORT CLASSES
	import caurina.transitions.Tweener;
	import com.oxylusflash.framework.util.StringUtil;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class AudioGallery extends MultimediaViewer
	{
		//{ region FIELDS
		internal const VOLUME_R : int = 15;
		
		private var preloader : Preloader;
		private var title_mask : Rectangle = new Rectangle();
		private var dataLoader : Loader;
		private var urlREQ : URLRequest;
		private var color : ColorTransform;
		private var pic_bitMapD : BitmapData;
		private var pic_bitMap : Bitmap;
		private var audioPlayer : AudioPlayer;
		private var resizeTimeLeft : Boolean = true;
		private var buffWidth : Number = 0;
		private var bufferOn : Boolean = false;
		//} endregion
		
		//{ region CONSTRUCTOR
		public function AudioGallery() 
		{
			super();
		}
		//} endregion
		
		//{ region EVENT HANDLERS/////////////////////////////////////////////////////////////
		
		//{ region AUDIO PLAYER HANDLER
		private final function audioPlayerHandler(pType : String = ""):void
		{
			switch (pType) 
			{
				case "BUFFER ON":
					bufferOn = true;
					animatePreloader(true);
				break;
				
				case "BUFFER OFF":
					bufferOn = false;
					animatePreloader(false);
				break;
				
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
				
				case "TIME UPDATE":
					mcProgressBar.mcTime.mcPartTime.txt.htmlText = addPrefix(Math.round(audioPlayer.apc.totalTime), Math.round(audioPlayer.apc.currentTime)) + 
					StringUtil.toTimeString(Math.round(audioPlayer.apc.currentTime));
					mcProgressBar.mcTime.mcTotalTime.txt.htmlText = StringUtil.toTimeString(Math.round(audioPlayer.apc.totalTime));
					
					mcProgressBar.perc = (audioPlayer.apc.totalTime > 0)? Math.round(audioPlayer.apc.currentTime) / Math.round(audioPlayer.apc.totalTime) : 0;
					
					if (Math.round(audioPlayer.apc.currentTime) < 1) 
					{
						posCounter(false);
					}
					
					if (!resizeTimeLeft) 
					{
						posCounter(false, false);
					}else 
					{
						posCounter(false);
					}
				break;
				
				case "LOADING PROGRESS":
					if (!isNaN(audioPlayer.apc.loadedBytes / audioPlayer.apc.totalBytes)) 
					{
						buffWidth = (audioPlayer.apc.loadedBytes / audioPlayer.apc.totalBytes);
						mcProgressBar.mcHitArea.width = 
						mcProgressBar.mcBuff.width = Math.round(mcProgressBar.mcTrack.width * buffWidth);
					}
				break;
				
				case "PLB COMPLETE":
					resizeTimeLeft = true;
					//trace("[INFO]: Playback complete.");
				break;
				
				/*case "PLB RDY":
					//...
				break;*/
				
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
					if (audioPlayer.apc) 
					{
						audioPlayer.apc.seek(Math.round(audioPlayer.apc.totalTime) * mcProgressBar.perc, false);
					}
				break;
				
				case "PROG DRAG TRUE":
					if (audioPlayer.apc) 
					{
						audioPlayer.apc.seek(Math.round(audioPlayer.apc.totalTime) * mcProgressBar.perc, false);
					}
				break;
				
				case "PROGRESS PERC":
					if (audioPlayer.apc) 
					{
						audioPlayer.apc.seek(Math.round(audioPlayer.apc.totalTime) * mcProgressBar.perc, false);
					}
				break;
				
				case "PROG CLICK":
					if (audioPlayer.apc) 
					{
						audioPlayer.apc.seek(Math.round(audioPlayer.apc.totalTime) * mcProgressBar.perc, false);
					}
				break;
				
				case "MAIN VOLUME PERC":
					if (audioPlayer.apc) 
					{
						audioPlayer.apc.volume = mcVolume.mcVolSlide.perc;
					}
				break;
				
				case "PAUSE":
					if (audioPlayer.apc.isPlaying) 
					{
						audioPlayer.apc.pause();
					}
				break;
				
				case "PLAY":
					if (!audioPlayer.apc.isPlaying) 
					{
						audioPlayer.apc.play();
					}
				break;
			}
		}
		//} endregion
		
		//{ region INIT
		private final function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			startApp();
		}
		//} endregion
		
		//{ region DATA LOADER PROGRESS HANDLER
		private final function dataLoader_ProgressHandler(e:ProgressEvent):void 
		{
			try 
			{
				dataLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, dataLoader_ProgressHandler);
			}catch (err:Error)
			{
			}
			
			animatePreloader(true);
		}
		//} endregion
		
		//{ region DATA LOADER IO ERROR HANDLER
		private final function dataLoader_IoErrorHandler(e:IOErrorEvent):void 
		{
			dataLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, dataLoader_ProgressHandler);
			dataLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, dataLoader_IoErrorHandler);
			dataLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, dataLoader_CompleteHandler);
			
			trace("data loader IOError, class AudioGallery.as", e);
			
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
			dataLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, dataLoader_ProgressHandler);
			dataLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, dataLoader_IoErrorHandler);
			dataLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, dataLoader_CompleteHandler);
			urlREQ = null;
			
			pic_bitMapD = new BitmapData(dataLoader.content.width, dataLoader.content.height, true, 0x000000);
			pic_bitMapD.draw(dataLoader.content);
			pic_bitMap = new Bitmap(pic_bitMapD, "auto", true);
			
			if (!bufferOn) 
			{
				animatePreloader(false);
			}
			
			try 
			{
				mcVh.addChild(pic_bitMap);
				mcVh.cacheAsBitmap = true;
				mcVh.width = cWidth;
				mcVh.height = cHeight;
				
				pic_bitMapD = null;
				pic_bitMap = null;
				
				mcVh.visible = true;
				Tweener.addTween(mcVh, { alpha: 1, time: animation.bringToFrontTime, transition: animation.bringToFrontType });
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
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS///////////////////////////////////////////////////////////////////
		
		//{ region RESET
		override public function reset():void 
		{
			super.reset();
			
			mcProgressBar.hitArea = mcProgressBar.mcBuff;
			
			mcVideoColorBg.visible = false;
			mcVideoColorBg.alpha = 0;
			
			mcFullscreen.fullScreenSignal.remove(signalHandler);
			mcFullscreen.Destroy();
			mcFullscreen = null;
			
			mcError.mcTxt.removeChild(mcError.mcTxt.txt);
			mcError.mcTxt.txt = null;
			
			mcError.removeChild(mcError.mcTxt);
			mcError.mcTxt = null;
			
			removeChild(mcError);
			mcError = null;
		}
		//} endregion
		
		//{ region RESIZE
		override public function resize(pFirst : Boolean = false):void 
		{
			posCounterFlag = (buffWidth == 1);
			
			mcController.mcBg.width = 
			mcHeader.mcBg.width = 
			mcVideoColorBg.width = 
			mcVideoPlayerBg.width = 
			mcVideoPlayerBgN.width = 
			mcMask.width = cWidth;
			
			mcVideoColorBg.height = 
			mcVideoPlayerBg.height = 
			mcVideoPlayerBgN.height = 
			mcMask.height = cHeight;
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
				
				mcController.y = int(mcVideoPlayerBg.height);
				mcHeader.y = int( -mcHeader.mcBg.height);
				
				mcVh.width = cWidth;
				mcVh.height = cHeight;
				
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
				
				rollOut = true;
				
				mcController.y = int(mcVideoPlayerBg.height);
				mcHeader.y = int( -mcHeader.mcBg.height);
			}
			
			mcVolume.x = int(mcController.mcBg.width - (mcVolume.mcBg.width + VOLUME_R));
			btn_mc.x = int(mcHeader.mcBg.width - (btn_mc.hitArea_mc.width + CLOSE_LEFT));
			
			mcPlayBtn.x = int((mcVideoPlayerBg.width - mcPlayBtn.width) * 0.5);
			mcPlayBtn.y = int((mcVideoPlayerBg.height - mcPlayBtn.height) * 0.5);
			posCounter(posCounterFlag);
			
			if (audioPlayer && audioPlayer.apc) 
			{
				mcProgressBar.mcBtn.width = mcProgressBar.mcTrack.width * (Math.round(audioPlayer.apc.currentTime) / 
				Math.round(audioPlayer.apc.totalTime));
				audioPlayerHandler("TIME UPDATE");
			}
			
			if (preloader && this.contains(preloader)) 
			{
				preloader.x = int(cWidth * 0.5);
				preloader.y = int(cHeight * 0.5);
			}
			
			btn_mc.x = int(mcHeader.mcBg.width - (btn_mc.hitArea_mc.width + CLOSE_LEFT));
			SetTitleMask();
		}
		//} endregion
		
		//{ region START ME UP
		public function StartMeUp(pMp3URL : String = "", pAlbArtURL : String = ""):void
		{
			if (stage) 
			{
				init();
			}else 
			{
				this.addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			}
			
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
			
			audioPlayer = new AudioPlayer();
			this.addChild(audioPlayer);
			
			audioPlayer.audioSignal.add(audioPlayerHandler);
			audioPlayer.volume = detailView.settings.initVolume;
			audioPlayer.autoPlay = detailView.settings.autoPlay;
			audioPlayer.repeat = detailView.settings.repeat;
			audioPlayer.buffer = detailView.settings.buffer;
			
			audioPlayer.StartMe(pMp3URL);
			
			try 
			{
				urlREQ = new URLRequest(pAlbArtURL);
				dataLoader = new Loader();
				dataLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, dataLoader_ProgressHandler, false, 0, true);
				dataLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, dataLoader_IoErrorHandler, false, 0, true);
				dataLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, dataLoader_CompleteHandler, false, 0, true);
				dataLoader.load(urlREQ);
			}catch (err:Error)
			{
				trace("Picture load failure, class AudioGallery.as", err);
			}
		}
		//} endregion
		
		//{ region SHOW APP
		override internal function showApp():void
		{
			super.visible = true;
			Tweener.addTween(super, { alpha: 1, time: 0.3, transition: "easeoutquad" } );
		}
		//} endregion
		
		//{ region SWAP PRELOADER
		private final function SwapPreloader():void
		{
			this.swapChildren(preloader, mcPlayBtn);
		}
		//} endregion
		
		//{ region ANIMATE PRELOADER
		private final function animatePreloader(arg1:Boolean):void
		{
			if (preloader) 
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
		}
		//} endregion
		
		//{ region DESTROY ME
		override internal function DestroyMe():void
		{
			super.DestroyMe();
			
			audioPlayer.audioSignal.remove(audioPlayerHandler);
			audioPlayer.apc.stop();
			audioPlayer.apc.reset();
			
			audioPlayer.Destroy();
			audioPlayer = null;
			
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
			
			if (dataLoader && dataLoader.contentLoaderInfo && dataLoader.contentLoaderInfo.hasEventListener(ProgressEvent.PROGRESS) ||
			dataLoader && dataLoader.contentLoaderInfo && dataLoader.contentLoaderInfo.hasEventListener(IOErrorEvent.IO_ERROR) ||
			dataLoader && dataLoader.contentLoaderInfo && dataLoader.contentLoaderInfo.hasEventListener(Event.COMPLETE)) 
			{
				dataLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, dataLoader_ProgressHandler);
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
			
			if (stage.hasEventListener(MouseEvent.MOUSE_UP)) 
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