package com.oxylusflash.mmgallery 
{
	//{ region IMPORT CLASSES
	import com.oxylusflash.framework.events.LayoutEvent;
	import com.oxylusflash.framework.layout.Layout;
	import com.oxylusflash.framework.resize.Resize;
	import com.oxylusflash.framework.resize.ResizeType;
	import com.oxylusflash.framework.util.StringUtils;
	import com.oxylusflash.framework.util.XMLUtils;
	import com.oxylusflash.mmgallery.Thumbnails;
	import com.oxylusflash.multimediaviewer.AudioGallery;
	import com.oxylusflash.multimediaviewer.CloseBtnOU;
	import com.oxylusflash.multimediaviewer.ImgGallery;
	import com.oxylusflash.multimediaviewer.LclVidGallery;
	import com.oxylusflash.multimediaviewer.SwfGallery;
	import com.oxylusflash.multimediaviewer.YtGallery;
	import com.oxylusflash.multimediaviewer.CloseBtnOU;
	import com.oxylusflash.multimediaviewer.EmailBtnOU;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import caurina.transitions.Tweener;
	//import com.oxylusflash.multimediaviewer.EmailBtnOU;

	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public final class MultimediaGallery extends Sprite
	{
		//{ region FIELDS
		[Inspectable(name="XML file", variable = "xmlFile", type = "String")]
		public var xmlFile : String = "";
		public var bg_mc : MovieClip;
		
		private const TOOL_MOUSE_POS_X : int = 7;
		private const TOOL_MOUSE_POS_Y : int = 21;
		private const TOOL_MOUSE_POS_TOP_Y : int = 7;
		
		private var thumbPag : ThumbnailPagination;
		
		private var toolTip_mc : ToolTip;
		
		private var h_mc : MovieClip;
		private var detailsHolder_mc : MovieClip;
		
		private var thumbPagRect : Rectangle = new Rectangle();
		private var thumbnail:Thumbnails;
		private var old_thumbnail : Thumbnails = null;
		
		private var urlREQ : URLRequest;
		private var dataUrlLoader : URLLoader;
		private var _dataXML : XML;
		private var xmlLength : uint = 0;
		private var mask_rec : Rectangle = new Rectangle();
		
		/*Tu*/
		private var thumbSlideSpeed :int = 1.5;
		private var countInterval : uint = 0;
		public var closeBtnOU : CloseBtnOU;
		public var emailBtnOU : EmailBtnOU;
		
		//XML SETTINGS
		private var _layout_settings : Object;
		private var _tooltips_settings : Object;
		private var _thumbCell_settings : Object;
		private var _pagination_settings : Object;
		private var _detailView_settings : Object;
		private var _youTube_settings : Object;
		private var _compLayout : Layout;
		
		private var nrOFthumbsPerP : int = 0;
		private var old_nrOFthumbsPerP : int = -1;
		
		private var mouseDownF : Boolean = false;
		private var mouseMoveF : Boolean = false;
		private var toolTipX : Number = -1;
		private var toolTipY : Number = -1;
		
		private var thumbnailResize : Rectangle = new Rectangle();
		private var tumbnailDetailView_XMLchild : int = -1;
		
		private var endXML : int = -1;
		private var startXML : int = -1;
		
		private var imgGallery : ImgGallery;
		private var swfGallery : SwfGallery;
		private var audioGallery : AudioGallery;
		private var lvGallery : LclVidGallery;
		private var ytGallery : YtGallery;
		private var fullScreenPressed : Boolean = false;
		private var thumbPagElse : Boolean = false;
		//} endregion
		
		//{ region CONSTRUCTOR
		public final function MultimediaGallery() 
		{
			this.visible = false;
			this.alpha = 0;
			
			this.mouseChildren = true;
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
			/*Tu*/
			//trace("stageWidth " + _compLayout.width);
			
			
		}
		//} endregion
		
		//{ region EVENT HANDLERS//////////////////////////////////////////////////////////////////////////////////////////////
		
		//{ region ENTER FRAME
		private final function enterFrameHandler(e:Event):void 
		{
			if (xmlFile)
			{
				this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				
				if (stage) 
				{
					init();
				}else 
				{
					this.addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);				
				}
			}
		}
		//} endregion
		
		//{ region INIT
		private final function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			loadXML(stage.loaderInfo.parameters.xmlFile || xmlFile);
		}
		//} endregion
		
		//{ region DATA URL LOADER INPUT OUTPUT ERROR HANDLER
		private final function dataUrlLoader_IoErrorHandler(e:IOErrorEvent):void 
		{
			dataUrlLoader.removeEventListener(IOErrorEvent.IO_ERROR, dataUrlLoader_IoErrorHandler);
			dataUrlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, dataUrlLoader_SecurityErrorHandler);
			dataUrlLoader.removeEventListener(Event.COMPLETE, dataUrlLoader_CompleteHandler);
			
			trace("XML loader input output error, class MultimediaGallery.as", e.toString());
			
			try 
			{
				dataUrlLoader.close();
				dataUrlLoader = null;
			}catch (err:Error)
			{
			}
		}
		//} endregion
		
		//{ region DATA URL LOADER SECURITY ERROR HANDLER
		private final function dataUrlLoader_SecurityErrorHandler(e:SecurityErrorEvent):void 
		{
			dataUrlLoader.removeEventListener(IOErrorEvent.IO_ERROR, dataUrlLoader_IoErrorHandler);
			dataUrlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, dataUrlLoader_SecurityErrorHandler);
			dataUrlLoader.removeEventListener(Event.COMPLETE, dataUrlLoader_CompleteHandler);
			
			trace("XML loader security error, class MultimediaGallery.as", e.toString());
			
			try 
			{
				dataUrlLoader.close();
				dataUrlLoader = null;
			}catch (err:Error)
			{
			}
		}
		//} endregion
		
		//{ region DATA URL LOADER COMPLETE HANDLER
		private final function dataUrlLoader_CompleteHandler(e:Event):void 
		{
			dataUrlLoader.removeEventListener(IOErrorEvent.IO_ERROR, dataUrlLoader_IoErrorHandler);
			dataUrlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, dataUrlLoader_SecurityErrorHandler);
			dataUrlLoader.removeEventListener(Event.COMPLETE, dataUrlLoader_CompleteHandler);
			
			urlREQ = null;
			_dataXML = new XML(dataUrlLoader.data);
			
			_layout_settings = XMLUtils.toObject(_dataXML.settings.layout[0]);
			_tooltips_settings = XMLUtils.toObject(_dataXML.settings.tooltips[0]);
			_thumbCell_settings = XMLUtils.toObject(_dataXML.settings.thumbCell[0]);
			_pagination_settings = XMLUtils.toObject(_dataXML.settings.pagination[0]);
			_detailView_settings = XMLUtils.toObject(_dataXML.settings.detailView[0]);
			_youTube_settings = XMLUtils.toObject(_dataXML.settings.youtube[0]);
			
			xmlLength = _dataXML.content.item.length();
			/*Tu get total items*/
			trace("length is "  + xmlLength );
			
			try 
			{
				dataUrlLoader.close();
				dataUrlLoader = null;
			}catch (err:Error)
			{
				trace("Data url loader complete handler, class MultimediaGallery.as", err);
			}
			
			reset();
		}
		//} endregion
		
		//{ region COMP LAYOUT SIZE CHANGE HANDLER
		private final function compLayoutSizeChangeHandler(e:LayoutEvent):void
		{
			
			
			if (!this.visible) 
			{
				this.visible = true;
				Tweener.addTween(this, { alpha : 1, time: 0.3, transition: "easeoutquad" } );
			}
				
			if (bg_mc.width != e.width || bg_mc.height != e.height)
			{
				mask_rec.width = 
				bg_mc.width = int(e.width);
				
				mask_rec.height = 
				bg_mc.height = int(e.height); 
				
				
				
				this.scrollRect = mask_rec;
				
				if (old_thumbnail) 
				{
					DoThumbnailResize(old_thumbnail);
				}
				
				if (thumbPag && !thumbPag.visible && thumbPagElse) 
				{
					thumbPagElse = false;
					thumbPag.visible = true;
				}
				
				if (!fullScreenPressed && stage.displayState != StageDisplayState.FULL_SCREEN) 
				{
					Pagination();
				}else 
				{
					if (thumbPag) 
					{
						thumbPagElse = true;
						thumbPag.visible = false;
					}
				}
			}
			/*TU*/
			//trace("resize width " + bg_mc.width);
			trace("resize height " + bg_mc.height);
			
		}
		//} endregion
		
		//{ region FULLSCREEN SIGNAL HANDLER
		private final function FullScreenSignalHandler(e : String = "", mouseEv : MouseEvent = null):void
		{
			switch (e) 
			{
				//{ region FULLSCREEN
				case "FULLSCREEN":
					fullScreenPressed = true;
				break;
				//} endregion
				
				//{ region NORMAL
				case "NORMAL":
					if (thumbPag && !thumbPag.visible) 
					{
						thumbPag.visible = true;
					}
					fullScreenPressed = false;
				break;
				//} endregion
			}
		}
		//} endregion
		
		//{ region THUMB SIGNAL HANDLER
		private final function SignalHandler(pEventType : String = "", pThumbnail: Thumbnails = null):void
		{
			switch (pEventType) 
			{
				//{ region ROLL OVER
				case "ROLL OVER":
					pThumbnail.mouseDownF = mouseDownF;
					if (!mouseDownF) 
					{
						pThumbnail.thumbChildInd = h_mc.getChildIndex(pThumbnail);
						h_mc.setChildIndex(pThumbnail, h_mc.numChildren - 1);
						stage.addEventListener(MouseEvent.MOUSE_MOVE, toolTipMouseMoveHandler, false, 0, true);
						
						//{ region TOOL TIP
						if (toolTip_mc && this.contains(toolTip_mc)) 
						{//show
							
							this.setChildIndex(toolTip_mc, this.numChildren - 1);
							SetToolTipText(toolTip_mc, pThumbnail.thumbType);
							toolTip_mc.title_mc.txt.text = pThumbnail.title;
							toolTip_mc.SetMe();
							
							toolTip_mc.x = int(mouseX - (toolTip_mc.stroke_mc.width + _tooltips_settings.offsetX) * 0.5 + TOOL_MOUSE_POS_X);
							toolTip_mc.y = mouseY + _tooltips_settings.offsetY + TOOL_MOUSE_POS_Y;
							
							toolTip_mc.ShowMe();
						}else 
						{//create
							toolTip_mc = new ToolTip();
							toolTip_mc.settings = _tooltips_settings;
							
							SetToolTipText(toolTip_mc, pThumbnail.thumbType);
							toolTip_mc.title_mc.txt.text = pThumbnail.title;
							
							toolTip_mc.SetMe();
							
							toolTip_mc.x = int(mouseX - (toolTip_mc.stroke_mc.width + _tooltips_settings.offsetX) * 0.5 + TOOL_MOUSE_POS_X);
							toolTip_mc.y = mouseY + _tooltips_settings.offsetY + TOOL_MOUSE_POS_Y;
							
							this.addChild(toolTip_mc);
							toolTip_mc.ShowMe();
						}
						toolTipMouseMoveHandler(null);
						//} endregion
					}
				break;
				//} endregion
				
				//{ region CLICK
				case "CLICK":
					if (!mouseMoveF) 
					{
						if (!detailsHolder_mc.visible)
						{
							detailsHolder_mc.visible = true;
							detailsHolder_mc.alpha = 1;
						}
						
						tumbnailDetailView_XMLchild = pThumbnail.xmlInd;
						pThumbnail.rollOutHandler();
						
						if (pThumbnail.sign_mc) 
						{
							pThumbnail.ToggleSign();
						}
						
						pThumbnail.DisableMouseEvents();
						
						if (toolTip_mc && this.contains(toolTip_mc)) 
						{
							toolTip_mc.addEventListener(toolTip_mc.DESTROY, toolTipDestroyHandler, false, 0, true);
							toolTip_mc.ShowMe(false, true);
						}
						
						DoRotateAnimation(pThumbnail);
						
						/*Tu*/
						//Stop thumb from sliding up
						StopSlideThumbUp(pThumbnail);
						//itunes U
						trace("itunes link is " + pThumbnail.ituneLink);
						
					}
				break;
				//} endregion
				
				//{ region ROLL OUT
				case "ROLL OUT":
					pThumbnail.mouseDownF = mouseDownF;
					if (!mouseDownF) 
					{
						HideToolTip();
						if (pThumbnail.thumbChildInd < h_mc.numChildren - 1) 
						{
							h_mc.setChildIndex(pThumbnail, pThumbnail.thumbChildInd);
						}
						else 
						{
							h_mc.setChildIndex(pThumbnail, h_mc.numChildren - 1);
						}
					}
				break;
				//} endregion
				
				//{ region MOUSE DOWN
				case "MOUSE DOWN":
					HideToolTip();
					
					mouseMoveF = false;
					mouseDownF = true;
					pThumbnail.thumbChildInd = h_mc.numChildren - 1;
					
					thumbnail = pThumbnail;
					pThumbnail.cW = bg_mc.width;
					pThumbnail.cH = bg_mc.height;
					
					pThumbnail.dY = mouseY - pThumbnail.y;
					pThumbnail.dX = mouseX - pThumbnail.x;
					
					stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler, false, 0, true);
					stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
					
					pThumbnail.MoveThumb();
				break;
				//} endregion
				
				//{ region CLOSE BTN
				case "CLOSE ME":
					RollBackAnim(old_thumbnail);
					fullScreenPressed = false;
					/*Tu*/
					ResumeSlideUp();
				break;
				//} endregion
				
				/*
				//{ region FULLSCREEN
				case "FULLSCREEN":
					fullScreenPressed = true;
				break;
				//} endregion
				
				//{ region NORMAL
				case "NORMAL":
					if (thumbPag && !thumbPag.visible) 
					{
						thumbPag.visible = true;
					}
					fullScreenPressed = false;
				break;
				//} endregion
				*/
			}
		}
		//} endregion
		
		//{ region TOOL TIP DESTROY HANDLER
		private final function toolTipDestroyHandler(e:Event):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, toolTipMouseMoveHandler);
			toolTip_mc.removeEventListener(toolTip_mc.DESTROY, toolTipDestroyHandler);
			this.removeChild(toolTip_mc);
			toolTip_mc.Destroy();
			toolTip_mc = null;
		}
		//} endregion
		
		//{ region TOOL TIP MOUSE MOVE HANDLER
		private final function toolTipMouseMoveHandler(e:MouseEvent):void 
		{
			if (toolTip_mc && this.contains(toolTip_mc)) 
			{
				toolTipY = mouseY + _tooltips_settings.offsetY + TOOL_MOUSE_POS_Y;
				toolTipX = (mouseX - (toolTip_mc.stroke_mc.width + _tooltips_settings.offsetX) * 0.5) + TOOL_MOUSE_POS_X;
				
				if (toolTipY < int(bg_mc.height - toolTip_mc.compH)) 
				{
					if (toolTip_mc.tr_mc.rotation != 0 || toolTip_mc.tr_mc.y != 0) 
					{
						toolTip_mc.FlipMe();
					}
					
					if (toolTip_mc.y != mouseY + _tooltips_settings.offsetY + TOOL_MOUSE_POS_Y) 
					{
						toolTip_mc.y = mouseY + _tooltips_settings.offsetY + TOOL_MOUSE_POS_Y;
					}
				}else 
				{
					if (toolTip_mc.tr_mc.rotation != 180 || toolTip_mc.tr_mc.y == 0) 
					{
						toolTip_mc.FlipMe(false);
					}
					
					if (toolTip_mc.y != int(mouseY - ((toolTip_mc.stroke_mc.height + toolTip_mc.stroke_mc.y - toolTip_mc.BG_POS) + _tooltips_settings.offsetY + TOOL_MOUSE_POS_TOP_Y))) 
					{
						toolTip_mc.y = int(mouseY - ((toolTip_mc.stroke_mc.height + toolTip_mc.stroke_mc.y - toolTip_mc.BG_POS) + _tooltips_settings.offsetY + TOOL_MOUSE_POS_TOP_Y));
					}
				}
				
				if (toolTipX > 0 && toolTipX < int(bg_mc.width - toolTip_mc.stroke_mc.width))
				{
					toolTip_mc.x = int(mouseX - (toolTip_mc.stroke_mc.width + _tooltips_settings.offsetX) * 0.5 + TOOL_MOUSE_POS_X);
					
					if (!toolTip_mc.itIsFlipped) 
					{
						toolTip_mc.tr_mc.x = int((toolTip_mc.stroke_mc.width - toolTip_mc.tr_mc.width) * 0.5);
					}else 
					{
						toolTip_mc.tr_mc.x = int((toolTip_mc.stroke_mc.width + toolTip_mc.tr_mc.width) * 0.5);
					}
				}else 
				{
					if (int(toolTip_mc.x + toolTip_mc.stroke_mc.width) >= int(bg_mc.width - toolTip_mc.stroke_mc.width) && toolTip_mc.x > 0) 
					{
						toolTip_mc.x = int(bg_mc.width - toolTip_mc.stroke_mc.width);
					}else 
					{
						toolTip_mc.x = 0;
					}
					
					if (!toolTip_mc.itIsFlipped) 
					{
						toolTip_mc.tr_mc.x = Math.max(0, Math.min(toolTip_mc.stroke_mc.width - toolTip_mc.tr_mc.width, int(toolTip_mc.mouseX - (toolTip_mc.tr_mc.width) * 0.5 + TOOL_MOUSE_POS_X)));
					}else 
					{
						toolTip_mc.tr_mc.x = Math.max(toolTip_mc.tr_mc.width, Math.min(toolTip_mc.stroke_mc.width, int(toolTip_mc.mouseX + (toolTip_mc.tr_mc.width) * 0.5 + TOOL_MOUSE_POS_X)));
					}
				}
			}
			
			if (e != null) 
			{
				e.updateAfterEvent();
			}
		}
		//} endregion
		
		//{ region STAGE MOUSE MOVE HANDLER
		private final function stage_mouseMoveHandler(e:MouseEvent):void 
		{
			mouseMoveF = true;
			
			thumbnail.doOutAnim = false;
			thumbnail.MoveThumb();
		}
		//} endregion
		
		//{ region STAGE MOUSE UP HANDLER
		private final function stage_mouseUpHandler(e:MouseEvent):void 
		{
			mouseDownF = false;
			
			if (!thumbnail.hitTestPoint(mouseX, mouseY)) 
			{
				HideToolTip();
			}
			
			//thumbnail.thumbRotation = (2 * Math.random() - 1) * _thumbCell_settings.thumbnail.maxRotation;
			thumbnail.thumbRotation = 0;
			
			thumbnail.doOutAnim = true;
			
			if (!thumbnail.imOver) 
			{
				thumbnail.mouseDownF = mouseDownF;
				thumbnail.rollOutHandler();
			}else 
			{
				thumbnail.mouseDownF = mouseDownF;
			}
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		}
		//} endregion
		
		//{ region PAGINATION SIGNAL HANDLER
		private final function PaginationSignalHandler(xmlStart : int = -1, xmlEnd : int = -1):void 
		{
			startXML = xmlStart;
			endXML = xmlEnd;
			GenerateThumb(xmlStart, xmlEnd);
		}
		//} endregion
		
		//{ region TOOL TIP MC REMOVE LISTENER
		private final function toolTip_mcRemListenerH(e:Event):void 
		{
			toolTip_mc.removeEventListener(toolTip_mc.REMOVE_LISTENER, toolTip_mcRemListenerH);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, toolTipMouseMoveHandler);
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS////////////////////////////////////////////////////////////////////////////////////////////////////
		
		//{ region RESET
		private final function reset():void
		{
			detailsHolder_mc = new MovieClip();
			detailsHolder_mc.x = 
			detailsHolder_mc.y = 0;
			detailsHolder_mc.visible = false;
			detailsHolder_mc.alpha = 0;
			
			this.addChild(detailsHolder_mc);
			
			mask_rec.x = 
			mask_rec.y = 
			bg_mc.width = 
			bg_mc.height = 
			bg_mc.x = 
			bg_mc.y = 0;
			
			this.scrollRect = mask_rec;
			
			_compLayout = new Layout(stage, 
			_layout_settings.width, 
			_layout_settings.height, 
			_layout_settings.minWidth, 
			_layout_settings.minHeight, 
			_layout_settings.offsetX, 
			_layout_settings.offsetY);
			
			_compLayout.addEventListener(LayoutEvent.SIZE_CHANGE, compLayoutSizeChangeHandler, false, 0, true);
			_compLayout.compute();
			
			this.x = int(_compLayout.x);
			trace("compLayout " + _compLayout.width);
			this.y = int(_compLayout.y);
			
			//TU CLOSE BUTTON
			closeBtnOU = new CloseBtnOU();
			emailBtnOU = new EmailBtnOU();
			
			
			
			closeBtnOU.mouseEnabled = true;
			closeBtnOU.btnSignal.add(SignalHandler);
			emailBtnOU.mouseEnabled = true;
			emailBtnOU.btnSignal.add(SignalHandler);
			
			this.addChild(closeBtnOU);
			this.addChild(emailBtnOU);
			
			
		}
		//} endregion
		
		//{ region PAGINATION
		private final function Pagination():void
		{
			/*Tu modified for no pagination*/
			nrOFthumbsPerP = xmlLength;//int(bg_mc.width / _thumbCell_settings.width) * int(bg_mc.height / _thumbCell_settings.height);
			
			if (nrOFthumbsPerP > xmlLength) 
			{
				nrOFthumbsPerP = xmlLength;
			}
			
			if (thumbPag) 
			{
				SetThumbPagCoord();
				
				if (old_nrOFthumbsPerP != nrOFthumbsPerP) 
				{
					old_nrOFthumbsPerP = nrOFthumbsPerP;
					thumbPag.SetThumb(nrOFthumbsPerP);
				}
			}else 
			{
				thumbPag = new ThumbnailPagination();
				thumbPag.pagSignal.add(PaginationSignalHandler);
				thumbPag.uCase = _tooltips_settings.useUpperCase;
				thumbPag.totalNrOfThumbs = xmlLength;
				thumbPag.toolTipSettings = _tooltips_settings;
				thumbPag.settings = _pagination_settings.thumbOffset;
				thumbPag.hideMe = _pagination_settings.alwaysDisplay;
				
				old_nrOFthumbsPerP = nrOFthumbsPerP;
				thumbPag.SetThumb(nrOFthumbsPerP);
				
				SetThumbPagCoord();
				this.addChild(thumbPag);
				this.setChildIndex(detailsHolder_mc, this.getChildIndex(thumbPag) - 1);
			}
		}
		//} endregion
		
		//{ region GENERATE THUMB
		private function GenerateThumb(xmlStart : int = -1, xmlEnd : int = -1):void
		{
			if (h_mc) 
			{
				if (this.contains(h_mc)) 
				{
					this.removeChild(h_mc);
					while (h_mc.numChildren-1)
					{
						thumbnail = Thumbnails(h_mc.getChildAt(h_mc.numChildren - 1));
						thumbnail.thumbnailSignal.remove(SignalHandler);
						thumbnail.Destroy();
						h_mc.removeChild(thumbnail);
						thumbnail = null;
					}
					h_mc = null;
				}
			}
			
			if (!h_mc) 
			{
				h_mc = new MovieClip();
				h_mc.x = 
				h_mc.y = 0;
				this.addChild(h_mc);
				
				if (this.contains(thumbPag) && thumbPag) 
				{
					this.swapChildren(h_mc, thumbPag);
					this.setChildIndex(detailsHolder_mc, this.getChildIndex(thumbPag) - 1);
				}else 
				{
					this.swapChildren(h_mc, detailsHolder_mc);
				}
			}
			
			var i : int = xmlStart;
			var lastX : int = 
			int(_thumbCell_settings.width * (1 - (Math.ceil(bg_mc.width / _thumbCell_settings.width) - (bg_mc.width / _thumbCell_settings.width))) * 0.5);
			
			var lastY : int = 
			int(_thumbCell_settings.height * (1 - (Math.ceil(bg_mc.height / _thumbCell_settings.height) - (bg_mc.height / _thumbCell_settings.height))) * 0.5);
			
			var lastW : int = 0;
			var lastH : int = 0;
			
			var xCounter : int = 0;
			//var posRect : Rectangle = new Rectangle(0, 0, _thumbCell_settings.width, _thumbCell_settings.height);
			/*Tu*/
			var posRect : Rectangle = new Rectangle(0, 0, _thumbCell_settings.width, _thumbCell_settings.height);
			var delayTime : int = 0;
			
			while (i < xmlEnd)
			{
				posRect.x = int(lastW + lastX);
				posRect.y = int(lastH + lastY);
				
				if (xCounter != int(bg_mc.width / _thumbCell_settings.width) - 1) 
				{
					xCounter++;
					lastX = int(posRect.x);
					lastW = int(posRect.width);
				}else 
				{
					xCounter = 0;
					
					lastX = 
					int(_thumbCell_settings.width * (1 - (Math.ceil(bg_mc.width / _thumbCell_settings.width) - (bg_mc.width / _thumbCell_settings.width))) * 0.5);
					
					lastW = 0;
					
					lastY = int(posRect.y);
					lastH = int(posRect.height);
				}
				
				if (tumbnailDetailView_XMLchild != i) 
				{
					thumbnail = new Thumbnails();
					thumbnail.delayTime = delayTime;
					delayTime++;
					
					thumbnail.name = "thumbnail";
					thumbnail.thumbnailSignal.add(SignalHandler);//Signal event addlistener
					thumbnail.settings = _thumbCell_settings.thumbnail;
					
					thumbnail.yt_settings = _youTube_settings;
					thumbnail.LoadMe(
					_dataXML.content.item[i].title, 
					_dataXML.content.item[i].thumbnail, 
					_dataXML.content.item[i].type, 
					_dataXML.content.item[i].detailView, 
					i); 
					
					/*Tu*/
					//Set itune link to each thumbnail
					thumbnail.ituneLink = _dataXML.content.item[i].detailView.itunesu;
					
					/*thumbnail.thumbRotation = 
					thumbnail.rotation = (2 * Math.random() - 1) * _thumbCell_settings.thumbnail.maxRotation;*/
					/*Tu*/
					thumbnail.thumbRotation = 0;
					
					thumbnail.cW = bg_mc.width;
					/*Tu*/
					//trace("thumbnail setting width " + ls);//is the width from the XML
					thumbnail.cH = bg_mc.height;
					
					thumbnail.x = 
					thumbnail.initX = int(posRect.x + Math.random() * posRect.width);
					
					thumbnail.y = 
					thumbnail.initY = int(posRect.y + Math.random() * posRect.height);
					//trace("thumbnail width " + thumbnail.width);
					//thumbnail.width = 132;
					//thumbnail.height = 86;
					//thumbnail.scaleX = 2;
					//thumbnail.scaleY = 1.5;
					//trace("tu " + thumbnail.scaleX);
					
					
					/*Tu*/
					thumbnail.randomYSpeed = thumbSlideSpeed;
					h_mc.addChild(thumbnail);
					/*Tu*/
					//thumbnail.addEventListener(Event.ENTER_FRAME,SlideThumbUp);
					
				}
				i++;
				/*Tu*/
				//counter for thumb generate
				trace(i);
				trace("endXML " + endXML);
				trace("h_mc children " + h_mc.numChildren);
				if(i == endXML){
					trace("done");
					//Execute function for SlideUp Governor
					SlideUpGovernor();
				}
			}
			
		}
		//} endregion
		/*Tu*/
		private function generateRandomThumbSize():Rectangle
		{
			//var posRect : Rectangle = new Rectangle(0, 0, _thumbCell_settings.width, _thumbCell_settings.height);
			var newRect : Rectangle = new Rectangle(0, 0, 100, 100);
			return newRect;
		}
		
		
		
		//{ region LOAD XML
		private final function loadXML(pXMLpath : String = ""):void
		{
			try 
			{
				urlREQ = new URLRequest(pXMLpath);
				dataUrlLoader = new URLLoader();
				dataUrlLoader.addEventListener(IOErrorEvent.IO_ERROR, dataUrlLoader_IoErrorHandler, false, 0, true);
				dataUrlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, dataUrlLoader_SecurityErrorHandler, false, 0, true);
				dataUrlLoader.addEventListener(Event.COMPLETE, dataUrlLoader_CompleteHandler, false, 0, true);
				dataUrlLoader.load(urlREQ);
			}catch (err:Error)
			{
				trace("Load XML Error, class MultimediaGallery.as", err);
			}
		}
		//} endregion
		
		//{ region SET THUMB PAG COORD
		private final function SetThumbPagCoord():void
		{
			thumbPagRect = Resize.compute(new Rectangle(0, 0, thumbPag.bgWidth, thumbPag.bgHeight),
			new Rectangle(_pagination_settings.offsetX, _pagination_settings.offsetY, bg_mc.width, bg_mc.height),
			ResizeType.NO_RESIZE, _pagination_settings.align);  
			thumbPag.x = thumbPagRect.x;
			thumbPag.y = thumbPagRect.y;
		}
		//} endregion
		
		//{ region SET TOOL TIP TEXT
		private final function SetToolTipText(pToolTip_mc : ToolTip, thumbType : String = ""):void
		{
			switch (thumbType) 
			{
				case "image":
					pToolTip_mc.lbl_mc.txt.text = _tooltips_settings.imagePrefix;
				break;
				
				case "audio":
					pToolTip_mc.lbl_mc.txt.text = _tooltips_settings.audioPrefix;
				break;
				
				case "video":
					pToolTip_mc.lbl_mc.txt.text = _tooltips_settings.videoPrefix;
				break;
				
				case "flash":
					pToolTip_mc.lbl_mc.txt.text = _tooltips_settings.flashPrefix;
				break;
			}
		}
		//} endregion
		
		//{ region HIDE TOOL TIP
		private final function HideToolTip():void
		{
			if (toolTip_mc && this.contains(toolTip_mc)) 
			{
				toolTip_mc.addEventListener(toolTip_mc.REMOVE_LISTENER, toolTip_mcRemListenerH, false, 0, true);
				toolTip_mc.ShowMe(false);
			}
		}
		//} endregion
		
		/*Tu*/
		private function StopSlideThumbUp(pThumbnail:Thumbnails):void
		{
			//thumbnail.removeEventListener(SlideThumbUp);
			
			//removeEventListener(Event.ENTER_FRAME,SlideThumbUp);
			var totalChildren = h_mc.numChildren;
			//.removeEventListener(Event.ENTER_FRAME,SlideThumbUp);
			trace("total children" + totalChildren);
			
			for(var i = 0; i < totalChildren; i++){
				h_mc.getChildAt(i).removeEventListener(Event.ENTER_FRAME,SlideThumbUp);
			}
			pThumbnail.removeEventListener(Event.ENTER_FRAME,SlideThumbUp);
			
			
		}
		/*Tu*/
		//Move thumbnails up
		private function SlideThumbUp(e:Event):void
		{
			var high =  _compLayout.width;
			var	low = 1;
			//trace ("high " + high);
			//trace ("low " + low);
			var myRandomNumber:int = Math.floor(Math.random()*(1+high-low))+low;
			
			trace("myRandomNumber: " + myRandomNumber);
			/*Tu*/
			//trace(e.target.y);
			var tu = e.target as Thumbnails;
			//trace(tu.randomYSpeed);
			var thisHeight = e.target.height;
			e.target.y = e.target.y - tu.randomYSpeed;
			if(e.target.y < (0 - thisHeight)){
				e.target.y = 1300; //height
				e.target.x = myRandomNumber;
			}
		}
		//end
		
		/*Tu*/
		private function ResumeSlideUp():void{
			var totalChildren = h_mc.numChildren;
			for(var i = 0; i < totalChildren; i++){
				h_mc.getChildAt(i).addEventListener(Event.ENTER_FRAME,SlideThumbUp);
			}
		}
		
		/*Tu*/
		
		private function SlideAnother():void{
			h_mc.getChildAt(countInterval).addEventListener(Event.ENTER_FRAME, SlideThumbUp);
			countInterval++;
		}
		
		private function SlideUpGovernor():void{
			//function to slide the thumbs up version 2
			
			
			//clearInterval();
			//var myInterval:uint = setInterval (SlideAnother, 1000);
			//clearInterval(myInterval);
			
			for(var i = 0;i < endXML; i++){
				h_mc.getChildAt(i).addEventListener(Event.ENTER_FRAME, SlideThumbUp);
				
			}
		}
		
		//{ region DO ROTATE ANIMATION
		private final function DoRotateAnimation(pThumbnail : Thumbnails):void
		{
			trace("helloz");
			
			if (old_thumbnail && old_thumbnail != pThumbnail) 
			{
				RollBackAnim(old_thumbnail);
			}
			
			if (pThumbnail != old_thumbnail || pThumbnail == old_thumbnail) 
			{
				detailsHolder_mc.addChild(pThumbnail);
				
				pThumbnail.rotateMe = 360;
				var cmpW : Number = bg_mc.width;
				var cmpH : Number = bg_mc.height;
				trace("bg_mc " + bg_mc.width);
				thumbnailResize = Resize.compute(
				new Rectangle(0, 0, pThumbnail.detailW, pThumbnail.detailH), 
				new Rectangle(0, 0, int(cmpW - 2 * _detailView_settings.margin), int(cmpH - 2 * _detailView_settings.margin)),
				ResizeType.FIT);
				
				trace(thumbnailResize.width);//808
				
				
				Tweener.addTween(pThumbnail, 
				{
					rotation: pThumbnail.rotateMe, 
					x: int(cmpW * 0.5), 
					y: int(cmpH * 0.5), 
					width: thumbnailResize.width, 
					height: thumbnailResize.height, 
					time: _detailView_settings.animation.bringToFrontTime, 
					transition: _detailView_settings.animation.bringToFrontType,
					onUpdate: function ():void 
					{
						if (bg_mc.width != cmpW || bg_mc.height != cmpH) 
						{
							DoThumbnailResize(pThumbnail);
						}
					}, 
					onComplete: function ():void 
					{
						pThumbnail.x = int(cmpW * 0.5);
						
						pThumbnail.y = int(cmpH * 0.5);
						pThumbnail.rotation = 0;
						
						if (bg_mc.width != cmpW || bg_mc.height != cmpH) 
						{
							
							DoThumbnailResize(pThumbnail);
						}
						
						pThumbnail.mouseChildren = true;
						
						switch (pThumbnail.thumbType) 
						{
							//{ region VIDEO
							case "video":
								pThumbnail.buttonMode = false;
								switch (String(StringUtils.squeeze(_dataXML.content.item[pThumbnail.xmlInd].detailView.source)).toLowerCase()) 
								{
									//{ region YOUTUBE
									case "youtube":
										ytGallery = null;
										ytGallery = new YtGallery();
										ytGallery.name = "ytGallery";
										
										ytGallery.animation = _detailView_settings.video.animation;
										ytGallery.detailView.closeBtn = _detailView_settings.closeBtn;
										ytGallery.detailView.playBtn = _detailView_settings.playBtn;
										
										ytGallery.detailView.settings = 
										{ 
											label : _detailView_settings.video.titlePrefix, 
											autoPlay : _detailView_settings.video.autoPlay,
											repeat : _detailView_settings.video.repeat,
											initVolume : _detailView_settings.video.initVolume
										};
										/*Tu*/
										//Set the width and height of youtube player
										ytGallery.cW =
										ytGallery.cWidth = Math.round(pThumbnail.bg_mc.width - 2 * pThumbnail.settings.border.size);
										
										ytGallery.cH =
										ytGallery.cHeight = Math.round(pThumbnail.bg_mc.height - 2 * pThumbnail.settings.border.size);
										
										ytGallery.x = Math.round(pThumbnail.bg_mc.width * 0.5 - ytGallery.cWidth - pThumbnail.settings.border.size);
										ytGallery.y = Math.round(pThumbnail.bg_mc.height * 0.5 - ytGallery.cHeight - pThumbnail.settings.border.size);
										
										ytGallery.reset();
										
										ytGallery.btn_mc.btnSignal.add(SignalHandler);
										/*Tu - adding signal to the close button for OU video*/
										//ytGallery.closeBtnOU.btnSignal.add(SignalHandler);
										ytGallery.mcFullscreen.fullScreenSignal.add(FullScreenSignalHandler);
										
										if (_detailView_settings.useUpperCase) 
										{
											ytGallery.mcHeader.mcNpTxt.txt.text = pThumbnail.title.toUpperCase();
										}else 
										{
											ytGallery.mcHeader.mcNpTxt.txt.text = pThumbnail.title;
										}
										
										ytGallery.SetTitleMask();
										
										if (pThumbnail.ytData && pThumbnail.ytData.videoID) 
										{
											ytGallery.StartMeUp(_youTube_settings, _dataXML.settings.youtube.policyFiles, _dataXML.content.item[pThumbnail.xmlInd].detailView, pThumbnail.ytData.videoID); 
										}else 
										{
											ytGallery.StartMeUp(_youTube_settings, _dataXML.settings.youtube.policyFiles, _dataXML.content.item[pThumbnail.xmlInd].detailView, ""); 
										}
										
										pThumbnail.addChild(ytGallery);//Need
										ytGallery.ShowInterface();//Need
										//Tu
										//CLOSE BUTTON POSITION
										closeBtnOU.visible = true;
										closeBtnOU.alpha = 1;
										
										//EMAIL BUTTON POSITION
										emailBtnOU.visible = true;
										emailBtnOU.alpha = 1;
										
										//trace("position of yt " + ytGallery.x + " " + ytGallery.y);
										//trace(pThumbnail.x + " " + pThumbnail.y);
										var realX = pThumbnail.x + ytGallery.x;
										var realY = pThumbnail.y + ytGallery.y;
										//trace("actually pos " + realX + " " + realY);
										closeBtnOU.x = realX + thumbnailResize.width - (closeBtnOU.width + 4);//4 is the border width
										closeBtnOU.y = realY - (30);//4 is the border width
										
									break;
									//} endregion
									
									//{ region LOCAL
									case "local":
										lvGallery = null;
										lvGallery = new LclVidGallery();
										lvGallery.name = "lvGallery";
										
										lvGallery.animation = _detailView_settings.video.animation;
										lvGallery.detailView.closeBtn = _detailView_settings.closeBtn;
										lvGallery.detailView.playBtn = _detailView_settings.playBtn;
										
										lvGallery.detailView.settings = 
										{ 
											label : _detailView_settings.video.titlePrefix, 
											autoPlay : _detailView_settings.video.autoPlay,
											repeat : _detailView_settings.video.repeat,
											buffer : _detailView_settings.video.buffer,
											initVolume : _detailView_settings.video.initVolume,
											preloaderColor : _detailView_settings.video.preloaderColor, 
											fit : _detailView_settings.video.fit
										};
										
										lvGallery.cW = 
										lvGallery.cWidth = Math.round(pThumbnail.bg_mc.width - 2 * pThumbnail.settings.border.size);
										
										lvGallery.cH = 
										lvGallery.cHeight = Math.round(pThumbnail.bg_mc.height - 2 * pThumbnail.settings.border.size);
										
										lvGallery.x = Math.round(pThumbnail.bg_mc.width * 0.5 - lvGallery.cWidth - pThumbnail.settings.border.size);
										lvGallery.y = Math.round(pThumbnail.bg_mc.height * 0.5 - lvGallery.cHeight - pThumbnail.settings.border.size);
										
										lvGallery.reset();
										lvGallery.btn_mc.btnSignal.add(SignalHandler);
										lvGallery.mcFullscreen.fullScreenSignal.add(FullScreenSignalHandler);
										
										if (_detailView_settings.useUpperCase) 
										{
											lvGallery.mcHeader.mcNpTxt.txt.text = pThumbnail.title.toUpperCase();
										}else 
										{
											lvGallery.mcHeader.mcNpTxt.txt.text = pThumbnail.title;
										}
										
										lvGallery.SetTitleMask();
										
										lvGallery.StartMeUp(_dataXML.content.item[pThumbnail.xmlInd].detailView); 
										
										pThumbnail.addChild(lvGallery);
										lvGallery.ShowInterface();
									break;
									//} endregion
								}
							break;
							//} endregion
							
							//{ region IMAGE
							case "image":
								imgGallery = null;
								imgGallery = new ImgGallery();
								imgGallery.name = "imgGallery";
								
								imgGallery.animation = _detailView_settings.image.animation;
								
								imgGallery.detailView.closeBtn = _detailView_settings.closeBtn;
								imgGallery.detailView.settings = { label : _detailView_settings.image.titlePrefix };
								
								imgGallery.cW = 
								imgGallery.cWidth = Math.round(pThumbnail.bg_mc.width - 2 * pThumbnail.settings.border.size);
								
								imgGallery.cH = 
								imgGallery.cHeight = Math.round(pThumbnail.bg_mc.height - 2 * pThumbnail.settings.border.size);
								
								imgGallery.x = Math.round(pThumbnail.bg_mc.width * 0.5 - imgGallery.cWidth - pThumbnail.settings.border.size);
								imgGallery.y = Math.round(pThumbnail.bg_mc.height * 0.5 - imgGallery.cHeight - pThumbnail.settings.border.size);
								
								imgGallery.reset();
								imgGallery.btn_mc.btnSignal.add(SignalHandler);
								
								if (_detailView_settings.useUpperCase) 
								{
									imgGallery.mcHeader.mcNpTxt.txt.text = pThumbnail.title.toUpperCase();
								}else 
								{
									imgGallery.mcHeader.mcNpTxt.txt.text = pThumbnail.title;
								}
								
								imgGallery.SetTitleMask();
								
								imgGallery.LoadMe(_dataXML.content.item[pThumbnail.xmlInd].detailView.source,
								(_dataXML.content.item[pThumbnail.xmlInd].link != undefined)? _dataXML.content.item[pThumbnail.xmlInd].link : "",
								(_dataXML.content.item[pThumbnail.xmlInd].linkTarget != undefined)?_dataXML.content.item[pThumbnail.xmlInd].linkTarget : "");
								
								pThumbnail.addChild(imgGallery);
								imgGallery.ShowInterface();
							break;
							//} endregion
							
							//{ region FLASH
							case "flash":
								swfGallery = null;
								swfGallery = new SwfGallery();
								swfGallery.name = "swfGallery";
								
								swfGallery.animation = _detailView_settings.flash.animation;
								
								swfGallery.detailView.closeBtn = _detailView_settings.closeBtn;
								swfGallery.detailView.settings = { label : _detailView_settings.flash.titlePrefix };
								
								swfGallery.cW = 
								swfGallery.cWidth = Math.round(pThumbnail.bg_mc.width - 2 * pThumbnail.settings.border.size);
								
								swfGallery.cH = 
								swfGallery.cHeight = Math.round(pThumbnail.bg_mc.height - 2 * pThumbnail.settings.border.size);
								
								swfGallery.x = Math.round(pThumbnail.bg_mc.width * 0.5 - swfGallery.cWidth - pThumbnail.settings.border.size);
								swfGallery.y = Math.round(pThumbnail.bg_mc.height * 0.5 - swfGallery.cHeight - pThumbnail.settings.border.size);
								
								swfGallery.reset();
								swfGallery.btn_mc.btnSignal.add(SignalHandler);
								
								if (_detailView_settings.useUpperCase) 
								{
									swfGallery.mcHeader.mcNpTxt.txt.text = pThumbnail.title.toUpperCase();
								}else 
								{
									swfGallery.mcHeader.mcNpTxt.txt.text = pThumbnail.title;
								}
								
								swfGallery.SetTitleMask();
								
								swfGallery.LoadMe(_dataXML.content.item[pThumbnail.xmlInd].detailView.source,
								(_dataXML.content.item[pThumbnail.xmlInd].link != undefined)? _dataXML.content.item[pThumbnail.xmlInd].link : "",
								(_dataXML.content.item[pThumbnail.xmlInd].linkTarget != undefined)? _dataXML.content.item[pThumbnail.xmlInd].linkTarget : "");
								
								pThumbnail.addChild(swfGallery);
								swfGallery.ShowInterface();
							break;
							//} endregion
							
							//{ region AUDIO
							case "audio":
								pThumbnail.buttonMode = false;
								audioGallery = null;
								audioGallery = new AudioGallery();
								audioGallery.name = "audioGallery";
								
								audioGallery.animation = _detailView_settings.audio.animation;
								
								audioGallery.detailView.closeBtn = _detailView_settings.closeBtn;
								audioGallery.detailView.playBtn = _detailView_settings.playBtn;
								
								audioGallery.detailView.settings = { label : _detailView_settings.audio.titlePrefix, 
								autoPlay : _detailView_settings.audio.autoPlay,
								repeat : _detailView_settings.audio.repeat,
								buffer : _detailView_settings.audio.buffer,
								initVolume : _detailView_settings.audio.initVolume, 
								preloaderColor : _detailView_settings.audio.preloaderColor };
								
								audioGallery.cW = 
								audioGallery.cWidth = Math.round(pThumbnail.bg_mc.width - 2 * pThumbnail.settings.border.size);
								
								audioGallery.cH = 
								audioGallery.cHeight = Math.round(pThumbnail.bg_mc.height - 2 * pThumbnail.settings.border.size);
								
								audioGallery.x = Math.round(pThumbnail.bg_mc.width * 0.5 - audioGallery.cWidth - pThumbnail.settings.border.size);
								audioGallery.y = Math.round(pThumbnail.bg_mc.height * 0.5 - audioGallery.cHeight - pThumbnail.settings.border.size);
								
								audioGallery.reset();
								audioGallery.btn_mc.btnSignal.add(SignalHandler);
								
								if (_detailView_settings.useUpperCase) 
								{
									audioGallery.mcHeader.mcNpTxt.txt.text = pThumbnail.title.toUpperCase();
								}else 
								{
									audioGallery.mcHeader.mcNpTxt.txt.text = pThumbnail.title;
								}
								
								audioGallery.SetTitleMask();
								
								audioGallery.StartMeUp(_dataXML.content.item[pThumbnail.xmlInd].detailView.file, 
								_dataXML.content.item[pThumbnail.xmlInd].detailView.albumArt); 
								
								pThumbnail.addChild(audioGallery);
								audioGallery.ShowInterface();
							break;
							//} endregion
						}
					}
				});
				old_thumbnail = pThumbnail;
			}
		}
		//} endregion
		
		//{ region ROLL BACK ANIM
		private final function RollBackAnim(pOld_thumbnail : Thumbnails):void
		{
			old_thumbnail = null;
			pOld_thumbnail.mouseChildren = false;
			
			if (detailsHolder_mc.contains(pOld_thumbnail)) 
			{
				h_mc.addChild(pOld_thumbnail);
			}
			
			switch (pOld_thumbnail.thumbType) 
			{
				//{ region VIDEO
				case "video":
					pOld_thumbnail.buttonMode = true;
					switch (String(StringUtils.squeeze(_dataXML.content.item[pOld_thumbnail.xmlInd].detailView.source))) 
					{
						//{ region YOUTUBE
						case "youtube":
							if (YtGallery(pOld_thumbnail.getChildByName("ytGallery"))) 
							{
								var ytOld_Gallery : YtGallery = YtGallery(pOld_thumbnail.getChildByName("ytGallery"));
								_detailView_settings.video.initVolume = ytOld_Gallery.mcVolume.mcVolSlide.perc;
								
								if (ytOld_Gallery.autoPlay && !_detailView_settings.video.autoPlay) 
								{
									_detailView_settings.video.autoPlay = true;
								}
								
								pOld_thumbnail.galleryHolder = ytOld_Gallery;
								
								
								if (stage.displayState == StageDisplayState.FULL_SCREEN) 
								{
									//stage.displayState = StageDisplayState.NORMAL;
									//ytOld_Gallery.signalHandler("NORMAL");
								}
								
								ytOld_Gallery.btn_mc.btnSignal.remove(SignalHandler);
								ytOld_Gallery.mcFullscreen.fullScreenSignal.remove(FullScreenSignalHandler);
								ytOld_Gallery.Destroy();
								ytOld_Gallery = null;
								
								//CLOSE BUTTON
								closeBtnOU.visible = false;
								
								closeBtnOU.alpha = 0;
							}
						break;
						//} endregion
						
						//{ region LOCAL
						case "local":
							if (LclVidGallery(pOld_thumbnail.getChildByName("lvGallery"))) 
							{
								var lvOld_Gallery : LclVidGallery = LclVidGallery(pOld_thumbnail.getChildByName("lvGallery"));
								_detailView_settings.video.initVolume = lvOld_Gallery.mcVolume.mcVolSlide.perc;
								
								if (lvOld_Gallery.autoPlay && !_detailView_settings.video.autoPlay) 
								{
									_detailView_settings.video.autoPlay = true;
								}
								
								pOld_thumbnail.galleryHolder = lvOld_Gallery;
								
								if (stage.displayState == StageDisplayState.FULL_SCREEN) 
								{
									//stage.displayState = StageDisplayState.NORMAL;
									//lvOld_Gallery.signalHandler("NORMAL");
								}
								
								lvOld_Gallery.btn_mc.btnSignal.remove(SignalHandler);
								lvOld_Gallery.mcFullscreen.fullScreenSignal.remove(FullScreenSignalHandler);
								lvOld_Gallery.Destroy();
								lvOld_Gallery = null;
							}
						break;
						//} endregion
					}
				break;
				//} endregion
				
				//{ region IMAGE
				case "image":
					if (ImgGallery(pOld_thumbnail.getChildByName("imgGallery"))) 
					{
						var imgOld_Gallery : ImgGallery = ImgGallery(pOld_thumbnail.getChildByName("imgGallery"));
						pOld_thumbnail.galleryHolder = imgOld_Gallery;
						imgOld_Gallery.btn_mc.btnSignal.remove(SignalHandler);
						imgOld_Gallery.Destroy();
						imgOld_Gallery = null;
					}
				break;
				//} endregion
				
				//{ region FLASH
				case "flash":
					if (SwfGallery(pOld_thumbnail.getChildByName("swfGallery"))) 
					{
						var swfOld_Gallery : SwfGallery = SwfGallery(pOld_thumbnail.getChildByName("swfGallery"));
						pOld_thumbnail.galleryHolder = swfOld_Gallery;
						swfOld_Gallery.btn_mc.btnSignal.remove(SignalHandler);
						swfOld_Gallery.Destroy();
						swfOld_Gallery = null;
					}
				break;
				//} endregion
				
				//{ region AUDIO
				case "audio":
					pOld_thumbnail.buttonMode = true;
					if (AudioGallery(pOld_thumbnail.getChildByName("audioGallery"))) 
					{
						var audioOld_Gallery : AudioGallery = AudioGallery(pOld_thumbnail.getChildByName("audioGallery"));
						_detailView_settings.audio.initVolume = audioOld_Gallery.mcVolume.mcVolSlide.perc;
						
						if (audioOld_Gallery.autoPlay && !_detailView_settings.audio.autoPlay) 
						{
							_detailView_settings.audio.autoPlay = true;
						}
						
						pOld_thumbnail.galleryHolder = audioOld_Gallery;
						audioOld_Gallery.btn_mc.btnSignal.remove(SignalHandler);
						audioOld_Gallery.Destroy();
						audioOld_Gallery = null;
					}
				break;
				//} endregion
			}
			
			tumbnailDetailView_XMLchild = -1;
			if (_detailView_settings.hideOffLimitPicture) 
			{
				if (startXML <= pOld_thumbnail.xmlInd && pOld_thumbnail.xmlInd <= endXML) 
				{//move back to the correct position
					pOld_thumbnail.AnimateMe(true, 
					bg_mc.width, 
					bg_mc.height, 
					_detailView_settings.animation.sentToBackTime, 
					_detailView_settings.animation.sentToBackType);
				}else 
				{//move back to the correct position and destroy
					pOld_thumbnail.AnimateMe(false, 
					bg_mc.width, 
					bg_mc.height, 
					_detailView_settings.animation.sentToBackTime, 
					_detailView_settings.animation.sentToBackType);
				}
			}else 
			{//move back to the correct position
				pOld_thumbnail.AnimateMe(true, 
				bg_mc.width, 
				bg_mc.height, 
				_detailView_settings.animation.sentToBackTime, 
				_detailView_settings.animation.sentToBackType);
			}
			pOld_thumbnail = null;
		}
		//} endregion
		
		//{ region DO THUMBNAIL RESIZE
		private final function DoThumbnailResize(paramThumb : Thumbnails):void
		{
			thumbnailResize = Resize.compute(
			new Rectangle(0, 0, paramThumb.detailW, paramThumb.detailH), 
			new Rectangle(0, 0, int(bg_mc.width - 2 * _detailView_settings.margin), int(bg_mc.height - 2 * _detailView_settings.margin)),
			ResizeType.FIT);
			
			paramThumb.x = int(bg_mc.width * 0.5);
			paramThumb.y = int(bg_mc.height * 0.5);
			
			paramThumb.width = thumbnailResize.width;
			paramThumb.height = thumbnailResize.height;
			
			switch (paramThumb.thumbType) 
			{
				//{ region VIDEO
				case "video":
					switch (String(StringUtils.squeeze(_dataXML.content.item[paramThumb.xmlInd].detailView.source))) 
					{
						//{ region YOUTUBE
						case "youtube":
							if (YtGallery(paramThumb.getChildByName("ytGallery"))) 
							{
								var yt_Gallery : YtGallery = YtGallery(paramThumb.getChildByName("ytGallery"));
								yt_Gallery.cW = 
								yt_Gallery.cWidth = Math.round(paramThumb.bg_mc.width - 2 * paramThumb.settings.border.size);
									
								yt_Gallery.cH = 
								yt_Gallery.cHeight = Math.round(paramThumb.bg_mc.height - 2 * paramThumb.settings.border.size);
								
								yt_Gallery.x = Math.round(paramThumb.bg_mc.width * 0.5 - yt_Gallery.cWidth - paramThumb.settings.border.size);
								yt_Gallery.y = Math.round(paramThumb.bg_mc.height * 0.5 - yt_Gallery.cHeight - paramThumb.settings.border.size);
								yt_Gallery.resize(false);
								yt_Gallery = null;
							}
						break;
						//} endregion
						
						//{ region LOCAL
						case "local":
							if (LclVidGallery(paramThumb.getChildByName("lvGallery"))) 
							{
								var lv_Gallery : LclVidGallery = LclVidGallery(paramThumb.getChildByName("lvGallery"));
								lv_Gallery.cW = 
								lv_Gallery.cWidth = Math.round(paramThumb.bg_mc.width - 2 * paramThumb.settings.border.size);
								
								lv_Gallery.cH = 
								lv_Gallery.cHeight = Math.round(paramThumb.bg_mc.height - 2 * paramThumb.settings.border.size);
								
								lv_Gallery.x = Math.round(paramThumb.bg_mc.width * 0.5 - lv_Gallery.cWidth - paramThumb.settings.border.size);
								lv_Gallery.y = Math.round(paramThumb.bg_mc.height * 0.5 - lv_Gallery.cHeight - paramThumb.settings.border.size);
								lv_Gallery.resize(false);
								lv_Gallery = null;
							}
						break;
						//} endregion
					}
				break;
				//} endregion
				
				//{ region IMAGE
				case "image":
					if (ImgGallery(paramThumb.getChildByName("imgGallery"))) 
					{
						var img_Gallery : ImgGallery = ImgGallery(paramThumb.getChildByName("imgGallery"));
						img_Gallery.cW = 
						img_Gallery.cWidth = Math.round(paramThumb.bg_mc.width - 2 * paramThumb.settings.border.size);
						
						img_Gallery.cH = 
						img_Gallery.cHeight = Math.round(paramThumb.bg_mc.height - 2 * paramThumb.settings.border.size);
						
						img_Gallery.x = Math.round(paramThumb.bg_mc.width * 0.5 - img_Gallery.cWidth - paramThumb.settings.border.size);
						img_Gallery.y = Math.round(paramThumb.bg_mc.height * 0.5 - img_Gallery.cHeight - paramThumb.settings.border.size);
						img_Gallery.resize();
						img_Gallery = null;
					}
				break;
				//} endregion
				
				//{ region FLASH
				case "flash":
					if (SwfGallery(paramThumb.getChildByName("swfGallery"))) 
					{
						var swf_Gallery : SwfGallery = SwfGallery(paramThumb.getChildByName("swfGallery"));
						swf_Gallery.cW = 
						swf_Gallery.cWidth = Math.round(paramThumb.bg_mc.width - 2 * paramThumb.settings.border.size);
						
						swf_Gallery.cH = 
						swf_Gallery.cHeight = Math.round(paramThumb.bg_mc.height - 2 * paramThumb.settings.border.size);
						
						swf_Gallery.x = Math.round(paramThumb.bg_mc.width * 0.5 - swf_Gallery.cWidth - paramThumb.settings.border.size);
						swf_Gallery.y = Math.round(paramThumb.bg_mc.height * 0.5 - swf_Gallery.cHeight - paramThumb.settings.border.size);
						swf_Gallery.resize();
						swf_Gallery = null;
					}
				break;
				//} endregion
				
				//{ region AUDIO
				case "audio":
					var audio_Gallery : AudioGallery = AudioGallery(paramThumb.getChildByName("audioGallery"));
					audio_Gallery.cW = 
					audio_Gallery.cWidth = Math.round(paramThumb.bg_mc.width - 2 * paramThumb.settings.border.size);
					
					audio_Gallery.cH = 
					audio_Gallery.cHeight = Math.round(paramThumb.bg_mc.height - 2 * paramThumb.settings.border.size);
					
					audio_Gallery.x = Math.round(paramThumb.bg_mc.width * 0.5 - audio_Gallery.cWidth - paramThumb.settings.border.size);
					audio_Gallery.y = Math.round(paramThumb.bg_mc.height * 0.5 - audio_Gallery.cHeight - paramThumb.settings.border.size);
					audio_Gallery.resize();
					audio_Gallery = null;
				break;
				//} endregion
			}
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		internal function get dataXML():XML { return _dataXML; }
		internal function set dataXML(value:XML):void 
		{
			_dataXML = value;
		}
		
		internal function get compLayout():Layout { return _compLayout; }
		internal function set compLayout(value:Layout):void 
		{
			_compLayout = value;
		}
		//} endregion
	}
}