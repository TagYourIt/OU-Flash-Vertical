package com.oxylusflash.mmgallery 
{
	//{ region IMPORT CLASSES
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.LoaderContext;
	
	import org.osflash.signals.Signal;
	import com.oxylusflash.framework.util.StringUtils;
	import caurina.transitions.Tweener;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public final class Thumbnails extends Thumbnail
	{
		//{ region FIELDS
		private var _thumbType : String = "";
		private var _yt_settings : Object;
		
		private var _tRollOverF : Boolean = false;
		private var _tRollOutF : Boolean = false;
		private var _fastRollOver : Boolean = false;
		private var _fastRollOut : Boolean = false;
		private var _targetName : String = "";
		private var _dY : Number = 0;
		private var _dX : Number = 0;
		
		private var _ytXML : YouTubeXML;
		private var _ytData : Object;
		private var context : LoaderContext;
		private var _title : String = "";
		private var ytThumbF : Boolean = false;
		
		private var _imOver : Boolean = false;
		private var _doOutAnim : Boolean = true;
		private var _mouseDownF : Boolean = false;
		private var _galleryHolder : * ;
		//} endregion
		
		//{ region CONSTRUCTOR
		public final function Thumbnails() 
		{
			super();
			thumbnailSignal =  new Signal(String, Thumbnails);
		}
		//} endregion
		
		//{ region EVENT HANDLERS///////////////////////////////////////////////////////////////
		
		//{ region ROLL OVER HANDLER
		override internal function rollOverHandler(e:MouseEvent = null):void 
		{
			_imOver = true;
			_targetName = "thumbnail";
			
			if (e != null) 
			{
				thumbnailSignal.dispatch("ROLL OVER", this);
			}
			
			if (!_mouseDownF) 
			{
				_fastRollOver = true;
				if (!_tRollOutF) 
				{
					_fastRollOver = false;
					
					Tweener.addTween(this, { rotation: 0, time: .3, transition: "easeoutquad", onUpdate: function ():void 
					{
						if (!_tRollOverF) 
						{
							_tRollOverF = true;
						}
					}, onComplete: function ():void 
					{
						_tRollOverF = false;
						if (_fastRollOut && _targetName != "thumbnail")
						{
							rollOutHandler();
						}
					} } );
					
					if (sign_mc) 
					{
						Tweener.addTween(sign_mc, { rotation: 0, time: 0.3, transition: "easeoutquad" });
					}
				}
				super.rollOverHandler(e);
			}
		}
		//} endregion
		
		//{ region CLICK HANDLER
		override internal function clickHandler(e:MouseEvent):void 
		{
			thumbnailSignal.dispatch("CLICK", this);
		}
		//} endregion
		
		//{ region ROLL OUT HANDLER
		override internal function rollOutHandler(e:MouseEvent = null):void 
		{
			
			_imOver = false;
			if (_doOutAnim) 
			{
				_targetName = "other_thumbnail";
				if (e != null) 
				{
					thumbnailSignal.dispatch("ROLL OUT", this);
				}
				
				if (!_mouseDownF) 
				{
					_fastRollOut = true;
					if (!_tRollOverF) 
					{
						_fastRollOut = false;
						
						Tweener.addTween(this, { rotation: 0/*thumbRotation*/, time: 0.3, transition: "easeoutquad", onUpdate: function ():void 
						{
							if (!_tRollOutF) 
							{
								_tRollOutF = true;
							}
						}, onComplete: function ():void 
						{
							_tRollOutF = false;
							if (_fastRollOver && _targetName == "thumbnail") 
							{
								rollOverHandler();
							}
						} } );
						
						if (sign_mc) 
						{
							Tweener.addTween(sign_mc, { rotation: -thumbRotation, time: 0.3, transition: "easeoutquad" });
						}
					}
					super.rollOutHandler(e);
				}
			}
		}
		//} endregion
		
		//{ region MOUSE DOWN HANDLER
		internal final function mouseDownHandler(e:MouseEvent = null):void 
		{
			_doOutAnim = false;
			thumbnailSignal.dispatch("MOUSE DOWN", this);
		}
		//} endregion
		
		//{ region YOU TUBE SIGNAL HANDLER
		private final function ytSignalHandler(pObject: Object):void
		{
			ytData = pObject;
			ytXML.ytSignal.remove(ytSignalHandler);
			
			/*
			 * returns
			ytData.picUrl, ytData.title, ytData.videoID
			*/
			
			if (StringUtils.isBlank(_title)) 
			{
				_title = ytData.title;
			}
			
			if (ytThumbF) 
			{
				try 
				{
					context = new LoaderContext();
					context.checkPolicyFile = true;
					urlREQ = new URLRequest(ytData.picUrl);
					dataLoader = new Loader();
					
					dataLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, dataLoader_IoErrorHandler, false, 0, true);
					dataLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, dataLoader_CompleteHandler, false, 0, true);
					dataLoader.load(urlREQ, context);
				}catch (err:Error)
				{
					trace("Load XML Error, class Thumbnails.as", err);
				}
			}
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS/////////////////////////////////////////////////////////////////////
		
		//{ region LOAD ME
		override internal function LoadMe(pTitle : XMLList, pThumbURL : XMLList, pType : XMLList, pDetailView : XMLList, pXmlInd : uint):void 
		{
			detailW = int(pDetailView.width) + 2 * settings.border.size;
			detailH = int(pDetailView.height) + 2 * settings.border.size;
			
			xmlInd = pXmlInd;
			_title = String(pTitle);
			_thumbType = String(StringUtils.squeeze(pType).toLowerCase());
			
			sign_mc = new MmSign(String(StringUtils.squeeze(pType).toLowerCase()));
			if (String(StringUtils.squeeze(pType)) != "video" && String(StringUtils.squeeze(pDetailView.source)) != "youtube") 
			{
				yt_settings = [];
				super.LoadMe(pTitle, pThumbURL, pType, pDetailView, pXmlInd);
			}else 
			{
				if (StringUtils.isBlank(pThumbURL)) 
				{
					InstantiateYtXML(pDetailView, true);
				}else 
				{
					if (StringUtils.isBlank(_title)) 
					{
						InstantiateYtXML(pDetailView, false);
					}
					super.LoadMe(pTitle, pThumbURL, pType, pDetailView, pXmlInd);
				}
			}
		}
		//} endregion
		
		//{ region SET DATA
		override internal function SetData():void 
		{
			if (!sign_mc.destroyMe && settings.fileTypeIcon.visible) 
			{
				super.addChild(sign_mc);
				sign_mc.x = 
				sign_mc.y = 0;
			}else 
			{
				sign_mc = null;
			}
			super.SetData();
		}
		//} endregion
		
		//{ region START ME
		override internal function StartMe():void 
		{
			if (sign_mc) 
			{
				sign_mc.rotation = -thumbRotation;
				sign_mc.visible = true;
				sign_mc.alpha = settings.fileTypeIcon.normalAlpha;
			}
			
			super.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
			super.StartMe();
		}
		//} endregion
		
		//{ region INSTANTIATE YOUTUBE XML
		private final function InstantiateYtXML(pDetailView : XMLList, pFlag : Boolean):void
		{
			ytThumbF = pFlag;
			ytXML = new YouTubeXML();
			ytXML.ytSignal.addOnce(ytSignalHandler);
			ytXML.LoadYtXML(pDetailView, _yt_settings);
		}
		//} endregion
		
		//{ region DISABLE MOUSE EVENTS
		override internal function DisableMouseEvents(pDisable : Boolean = true):void 
		{
			super.DisableMouseEvents(pDisable);
			
			if (pDisable)
			{
				super.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			}else 
			{
				super.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
			}
		}
		//} endregion
		
		//{ region DESTROY
		override internal function Destroy():void 
		{
			//_galleryHolder = null;
			if (sign_mc && super.contains(sign_mc)) 
			{
				super.removeChild(sign_mc);
				sign_mc.Destroy();
				sign_mc = null;
			}
			
			super.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			super.Destroy();
		}
		//} endregion
		
		//{ region MOVE THUMB
		internal final function MoveThumb():void 
		{
			initX = 
			this.x = Math.max(0, Math.min(cW, stage.mouseX  - _dX));
			initY = 
			this.y = Math.max(0, Math.min(cH, stage.mouseY  - _dY));
		}
		//} endregion
		
		//{ region TOGGLE SIGN - iCONs
		internal final function ToggleSign(pToggle : Boolean = true):void 
		{
			if (pToggle) 
			{
				Tweener.addTween(sign_mc, { alpha: 0, time: 0.3, transition: "easeoutquad", onComplete: function ():void 
				{
					sign_mc.visible = false;
				} });
			}else 
			{
				sign_mc.visible = true;
				Tweener.addTween(sign_mc, { alpha: settings.fileTypeIcon.normalAlpha, time: 0.3, transition: "easeoutquad" });
			}
		}
		//} endregion
		
		//{ region ANIMATE ME - Animate back in - Leon
		internal final function AnimateMe(pHide : Boolean = true, pW : Number = 0, pH : Number = 0, pTime : Number = 0, pAnimation : String = ""):void 
		{
			if (!pHide) 
			{
				initW = 
				initH = 0;
			}
			
			rotateMe = -360 + thumbRotation;
			Tweener.addTween(super, 
			{
				rotation: rotateMe, 
				x: Math.max(0, Math.min(pW, initX)), 
				y: Math.max(0, Math.min(pH, initY)), 
				width: initW, 
				height: initH, 
				time: pTime, 
				transition: pAnimation,
				onUpdate: function ():void 
				{
					if (_galleryHolder && this.contains(_galleryHolder)) 
					{
						_galleryHolder.cW = 
						_galleryHolder.cWidth = Math.round(bg_mc.width - 2 * settings.border.size);
						
						_galleryHolder.cH = 
						_galleryHolder.cHeight = Math.round(bg_mc.height - 2 * settings.border.size);
						
						_galleryHolder.x = Math.round(bg_mc.width * 0.5 - _galleryHolder.cWidth - settings.border.size);
						_galleryHolder.y = Math.round(bg_mc.height * 0.5 - _galleryHolder.cHeight - settings.border.size);
						_galleryHolder.resize();
					}else 
					{
						if (_galleryHolder != null) 
						{
							_galleryHolder = null;
						}
					}
				}, 
				onComplete: function ():void 
				{
					SetMeOnPos(pW, pH);
					
					if (pHide) 
					{
						if (sign_mc) 
						{
							sign_mc.rotation = -thumbRotation;
							ToggleSign(false);
						}
						
						DisableMouseEvents(false);
					}else 
					{
						Destroy();
						if (this.parent) 
						{
							this.parent.removeChild(this);
						}
					}
				}
			});
		}
		//} endregion

		
		
		//{ region SET ME ON POS
		private final function SetMeOnPos(pW : Number = 0, pH : Number = 0):void
		{
			
			super.x = int(Math.max(0, Math.min(pW, initX)));
			super.y = int(Math.max(0, Math.min(pH, initY)));
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		internal function get thumbType():String { return _thumbType; }
		internal function set thumbType(value:String):void 
		{
			_thumbType = value;
		}
		
		internal function get yt_settings():Object { return _yt_settings; }
		internal function set yt_settings(value:Object):void 
		{
			_yt_settings = value;
		}
		
		internal function get ytData():Object { return _ytData; }
		internal function set ytData(value:Object):void 
		{
			_ytData = value;
		}
		
		internal function get ytXML():YouTubeXML { return _ytXML; }
		internal function set ytXML(value:YouTubeXML):void 
		{
			_ytXML = value;
		}
		
		internal function get title():String { return _title; }
		internal function set title(value:String):void 
		{
			_title = value;
		}
		
		internal function get tRollOutF():Boolean { return _tRollOutF; }
		internal function set tRollOutF(value:Boolean):void 
		{
			_tRollOutF = value;
		}
		
		internal function get dX():Number { return _dX; }
		internal function set dX(value:Number):void 
		{
			_dX = value;
		}
		
		internal function get dY():Number { return _dY; }
		internal function set dY(value:Number):void 
		{
			_dY = value;
		}
		
		internal function get imOver():Boolean { return _imOver; }
		internal function set imOver(value:Boolean):void 
		{
			_imOver = value;
		}
		
		internal function get doOutAnim():Boolean { return _doOutAnim; }
		internal function set doOutAnim(value:Boolean):void 
		{
			_doOutAnim = value;
		}
		
		internal function get mouseDownF():Boolean { return _mouseDownF; }
		internal function set mouseDownF(value:Boolean):void 
		{
			_mouseDownF = value;
		}
		
		internal function get galleryHolder():* { return _galleryHolder; }
		internal function set galleryHolder(value:*):void 
		{
			_galleryHolder = value;
		}
		//} endregion
	}
}