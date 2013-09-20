package com.oxylusflash.mmgallery 
{
	//{ region IMPORT CLASSES
	import com.oxylusflash.framework.util.StringUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	import caurina.transitions.Tweener;
	
	import org.osflash.signals.Signal;
	//} endregion
	/**
	 * ...
	 * @author ciprian chichirita, ciprian@oxylus.ro
	 */
	public class Thumbnail extends Sprite
	{
		//{ region FIELDS
		public var sign_mc : MmSign;
		public var h_mc : MovieClip;
		public var bg_mc : MovieClip;
		public var innerBrd_sp : Sprite = new Sprite();
		
		private var _initY : int = 0;
		private var _initX : int = 0;
		
		private var _initW : int = 0;
		private var _initH : int = 0;
		
		/*Tu*/
		private var _randomY : int = 0;
		private var _ituneLink : String ;
		
		private var _thumbnailSignal : Signal;
		private var _settings : Object;
		private var _xmlInd : uint = 0;
		private var _thumbRotation : Number = 0;
		private var _rotateMe : Number = 0;
		private var _thumbChildInd : int = 0;
		
		private var _cW : int = 0;
		private var _cH : int = 0;
		
		private var _detailW : int = 0;
		private var _detailH : int = 0;
		
		private var _delayTime : int = 0;
		
		private var _dataLoader : Loader;
		private var _urlREQ : URLRequest;
		
		private var thumbShadow : DropShadowFilter;
		private var color_colTran : ColorTransform;
		private var pic_bitMapD : BitmapData;
		private var pic_bitMap : Bitmap;
		//} endregion
		
		
		
		//{ region CONSTRUCTOR
		public function Thumbnail()
		{
			this.mouseEnabled = false;
			this.visible = false;
			this.alpha = 0;
			
			bg_mc.width = 
			bg_mc.height = 
			
			h_mc.x = 
			h_mc.y = 
			bg_mc.x = 
			bg_mc.y = 0;
			
			h_mc.visible = false;
			h_mc.alpha = 0;
			
			bg_mc.visible = false;
			bg_mc.alpha = 0;
			
			innerBrd_sp.visible = false;
			innerBrd_sp.alpha = 0;
		}
		//} endregion
		
		//{ region EVENT HANDLERS///////////////////////////////////////////////////////////////////////
		
		//{ region ROLL OVER HANDLER
		internal function rollOverHandler(e:MouseEvent = null):void 
		{
			innerBrd_sp.visible = true;
			Tweener.addTween(innerBrd_sp, { alpha: _settings.innerBorder.alpha, time: 0.3, transition: "easeoutquad" } );
			
			if (sign_mc) 
			{
				Tweener.addTween(sign_mc, { alpha: _settings.fileTypeIcon.overAlpha, time: 0.3, transition: "easeoutquad" });
			}
		}
		//} endregion
		
		//{ region ROLL OUT HANDLER
		internal function rollOutHandler(e:MouseEvent = null):void 
		{
			Tweener.addTween(innerBrd_sp, { alpha: 0, time: 0.3, transition: "easeoutquad", onComplete: function ():void 
			{
				innerBrd_sp.visible = false;
			} } );
			
			if (sign_mc) 
			{
				Tweener.addTween(sign_mc, { alpha: _settings.fileTypeIcon.normalAlpha, time: 0.3, transition: "easeoutquad" });
			}
		}
		//} endregion
		
		//{ region CLICK HANDLER
		internal function clickHandler(e:MouseEvent):void 
		{
			//...
		}
		//} endregion
		
		//{ region DATA LOADER IO ERROR HANDLER
		internal function dataLoader_IoErrorHandler(e:IOErrorEvent):void 
		{
			dataLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, dataLoader_IoErrorHandler);
			dataLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, dataLoader_CompleteHandler);
			
			trace("data loader IOError, class Thumbnail.as", e);
			
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
		internal function dataLoader_CompleteHandler(e:Event):void 
		{
			dataLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, dataLoader_IoErrorHandler);
			dataLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, dataLoader_CompleteHandler);
			
			urlREQ = null;
			
			//pic_bitMapD = new BitmapData(dataLoader.content.width, dataLoader.content.height, true, 0x000000);
			//Tu
			pic_bitMapD = new BitmapData(800, 450, true, 0x000000);
			pic_bitMapD.draw(dataLoader.content);
			pic_bitMap = new Bitmap(pic_bitMapD, "auto", true);
			
			try 
			{
				
		
				
				h_mc.addChild(pic_bitMap);
				//Tu
				h_mc.scaleX = 0.20;
				h_mc.scaleY = 0.20;
				
				
				//Tu
				initW = bg_mc.width = int(h_mc.width + 2 * _settings.border.size);
				
				initH = bg_mc.height = int(h_mc.height + 2 * _settings.border.size);
				
				bg_mc.x = Math.round(bg_mc.width * 0.5 - bg_mc.width);
				bg_mc.y = Math.round(bg_mc.height * 0.5 - bg_mc.height);
				
				h_mc.x = Math.round(bg_mc.x + _settings.border.size);
				h_mc.y = Math.round(bg_mc.y + _settings.border.size);
				
				h_mc.cacheAsBitmap = true;
				this.cacheAsBitmap = true;
				
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
			
			SetData();
		}
		//} endregion
		
		//} endregion
		
		//{ region METHODS//////////////////////////////////////////////////////////////////////////////
		
		//{ region SET DATA
		internal function SetData():void 
		{
			//color
			color_colTran = new ColorTransform();
			color_colTran.color = _settings.border.color;
			bg_mc.transform.colorTransform = color_colTran;
			
			//create shadow
			if (_settings.shadow.visible) 
			{
				thumbShadow = new DropShadowFilter();
				thumbShadow.color = _settings.shadow.color;
				thumbShadow.alpha = _settings.shadow.alpha;
				thumbShadow.blurX = 
				thumbShadow.blurY = _settings.shadow.blur;
				thumbShadow.distance = _settings.shadow.distance;
				thumbShadow.angle = _settings.shadow.angle;
				thumbShadow.quality = 3;
				this.filters = [thumbShadow];
				//this.filters = [];
			}
			
			innerBrd_sp.graphics.lineStyle(_settings.innerBorder.size, _settings.innerBorder.color, 1, 
			true, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER);
			
			innerBrd_sp.graphics.drawRect(int(_settings.innerBorder.size * 0.5), int(_settings.innerBorder.size * 0.5), int(h_mc.width - _settings.innerBorder.size), 
			int(h_mc.height - _settings.innerBorder.size));
			
			innerBrd_sp.x = Math.round(h_mc.x);
			innerBrd_sp.y = Math.round(h_mc.y);
			
			this.addChild(innerBrd_sp);
			innerBrd_sp.name = "innerBrd_sp";
			innerBrd_sp.cacheAsBitmap = true;
			
			this.buttonMode = true;
			this.mouseChildren = false;
			this.hitArea = bg_mc;
			
			StartMe();
		}
		//} endregion
		
		//{ region LOAD ME
		internal function LoadMe(pTitle : XMLList, pThumbURL : XMLList, pType : XMLList, pDetailView : XMLList, pXmlInd : uint):void 
		{
			try 
			{
				urlREQ = new URLRequest(String(pThumbURL));
				dataLoader = new Loader();
				dataLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, dataLoader_IoErrorHandler, false, 0, true);
				dataLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, dataLoader_CompleteHandler, false, 0, true);
				dataLoader.load(urlREQ);
			}catch (err:Error)
			{
				trace("Load XML Error, class Thumbnail.as", err);
			}
		}
		//} endregion
		
		//{ region START ME
		internal function StartMe():void 
		{
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, 0, true);
			this.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			
			
			if (this.x + 0.5 * bg_mc.width > cW)
			{
				this.x = int(cW - this.x + 0.5 * bg_mc.width);
			}
			
			if (this.x - 0.5 * bg_mc.width <= 0) 
			{
				this.x = int(this.x + 0.5 * bg_mc.width);
			}
			
			if (this.y + 0.5 * bg_mc.height > cH)
			{
				this.y = int(cH - this.y + 0.5 * bg_mc.height);
			}
			
			if (this.y - 0.5 * bg_mc.height <= 0) 
			{
				this.y = int(this.y + 0.5 * bg_mc.height);
			}
			
			
			this.scaleX = 0;
			this.scaleY = 0;
			
			h_mc.visible = 
			bg_mc.visible = 
			this.visible = true;
			
			h_mc.alpha = 
			bg_mc.alpha = 
			this.alpha = 1;
			
			Tweener.addTween(this, { scaleX: 1, scaleY: 1, time: 0.3, delay: Math.random() * delayTime * 0.03, transition: "easeoutquad", onComplete: function ():void 
			{
				this.mouseEnabled = true;
			} } );
		}
		//} endregion
		
		//{ region DISABLE MOUSE EVENTS
		internal function DisableMouseEvents(pDisable : Boolean = true):void 
		{
			if (pDisable) 
			{
				if (this.mouseChildren) 
				{
					this.mouseChildren = false;
				}
				
				if (Tweener.isTweening(innerBrd_sp)) 
				{
					Tweener.removeTweens(innerBrd_sp);
					innerBrd_sp.visible = false;
					innerBrd_sp.alpha = 0;
				}
				
				this.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
				this.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
				this.removeEventListener(MouseEvent.CLICK, clickHandler);
			}else 
			{
				this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, false, 0, true);
				this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, 0, true);
				this.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			}
		}
		//} endregion
		
		//{ region DESTROY
		internal function Destroy():void 
		{
			this.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			this.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			this.removeEventListener(MouseEvent.CLICK, clickHandler);
			
			if (Tweener.isTweening(this)) 
			{
				Tweener.removeTweens(this);
			}
			
			if (h_mc && this.contains(h_mc)) 
			{
				this.removeChild(h_mc);
				//h_mc = null;
			}
			
			if (bg_mc && this.contains(bg_mc)) 
			{
				this.removeChild(bg_mc);
				//bg_mc = null;
			}
			
			if (innerBrd_sp && this.contains(innerBrd_sp)) 
			{
				this.removeChild(innerBrd_sp);
				//innerBrd_sp = null;
			}
		}
		//} endregion
		
		//} endregion
		
		//{ region PROPERTIES
		internal function get initY():int { return _initY; }
		internal function set initY(value:int):void 
		{
			_initY = value;
		}
		
		internal function get initX():int { return _initX; }
		internal function set initX(value:int):void 
		{
			_initX = value;
		}
		
		internal function get thumbnailSignal():Signal { return _thumbnailSignal; }
		internal function set thumbnailSignal(value:Signal):void 
		{
			_thumbnailSignal = value;
		}
		
		internal function get xmlInd():uint { return _xmlInd; }
		internal function set xmlInd(value:uint):void 
		{
			_xmlInd = value;
		}
		
		public function get settings():Object { return _settings; }
		public function set settings(value:Object):void 
		{
			_settings = value;
		}
		
		protected function get urlREQ():URLRequest { return _urlREQ; }
		protected function set urlREQ(value:URLRequest):void 
		{
			_urlREQ = value;
		}
		
		protected function get dataLoader():Loader { return _dataLoader; }
		protected function set dataLoader(value:Loader):void 
		{
			_dataLoader = value;
		}
		
		internal function get thumbRotation():Number { return _thumbRotation; }
		internal function set thumbRotation(value:Number):void 
		{
			_thumbRotation = value;
		}
		
		internal function get cH():int { return _cH; }
		internal function set cH(value:int):void 
		{
			_cH = value;
		}
		
		internal function get cW():int { return _cW; }
		internal function set cW(value:int):void 
		{
			_cW = value;
		}
		
		internal function get delayTime():int { return _delayTime; }
		internal function set delayTime(value:int):void 
		{
			_delayTime = value;
		}
		
		internal function get thumbChildInd():int { return _thumbChildInd; }
		internal function set thumbChildInd(value:int):void 
		{
			_thumbChildInd = value;
		}
		
		internal function get rotateMe():Number { return _rotateMe; }
		internal function set rotateMe(value:Number):void 
		{
			_rotateMe = value;
		}
		
		override public function set width(value:Number):void 
		{
			bg_mc.width = value;
			bg_mc.x = Math.round( -value * 0.5);
			h_mc.x = Math.round(bg_mc.x + _settings.border.size);
			h_mc.width = Math.round(bg_mc.width - 2 * _settings.border.size);
		}
		
		override public function set height(value:Number):void 
		{
			bg_mc.height = value;
			bg_mc.y = Math.round( -value * 0.5);
			h_mc.y = Math.round(bg_mc.y + _settings.border.size);
			h_mc.height = Math.round(bg_mc.height - 2 * _settings.border.size);
		}
		
		internal function get initH():int { return _initH; }
		internal function set initH(value:int):void 
		{
			_initH = value;
		}
		
		internal function get initW():int { return _initW; }
		internal function set initW(value:int):void 
		{
			_initW = value;
		}
		/*Tu*/
		internal function get randomYSpeed():int { return _randomY; }
		internal function set randomYSpeed(value:int):void 
		{
			_randomY = value;
		}
		
		/*Tu*/
		internal function get ituneLink():String { return _ituneLink; }
		internal function set ituneLink(value:String):void 
		{
			_ituneLink = value;
		}
		
		internal function get detailH():int { return _detailH; }
		internal function set detailH(value:int):void 
		{
			_detailH = value;
		}
		
		internal function get detailW():int { return _detailW; }
		internal function set detailW(value:int):void 
		{
			_detailW = value;
		}
		//} endregion
	}
}