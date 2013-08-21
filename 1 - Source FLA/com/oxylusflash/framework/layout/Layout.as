package com.oxylusflash.framework.layout 
{
	import com.oxylusflash.framework.core.DestructibleEventDispatcher;
	import com.oxylusflash.framework.events.LayoutEvent;
	import com.oxylusflash.framework.math.Percent;
	import flash.display.Stage;
	import flash.events.*;
	
	[Event(name = "sizeChange", type = "com.oxylusflash.framework.events.LayoutEvent")]
	
	/**
	 * Layout
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Layout extends DestructibleEventDispatcher
	{
		private var _stage:Stage;		
		private var _widthPercent:Percent;
		private var _heightPercent:Percent;
		private var _x:Number;
		private var _y:Number;
		private var _minWidth:Number;
		private var _minHeight:Number;		
		private var _width:Number;
		private var _height:Number;
		
		/**
		 * Create layout object
		 * @param	stage		Stage reference
		 * @param	widthInfo	Width as string
		 * @param	heightInfo	Height as string
		 * @param	minWidth	Minimum width
		 * @param	minHeight	Minimum height
		 * @param	offsetX		Horizontal offset
		 * @param	offsetY		Vertical offset
		 */
		public function Layout(stage:Stage, widthInfo:String = "100%", heightInfo:String = "100%", minWidth:Number = 0, minHeight:Number = 0, offsetX:Number = 0, offsetY:Number = 0)
		{
			this.minWidth = minWidth;
			this.minHeight = minHeight;
			this.x = offsetX;
			this.y = offsetY;
			
			if (widthInfo.indexOf("%") >= 0) this.widthPercent = new Percent(widthInfo);
			else this.width = Number(widthInfo);
			
			if (heightInfo.indexOf("%") >= 0) this.heightPercent = new Percent(heightInfo);
			else this.height = Number(heightInfo);
			
			_stage = stage;
			if (_widthPercent || _heightPercent) 
			{
				_stage.addEventListener(Event.RESIZE, stage_resizeHandler, false, 0, true);
				compute();
			}
		}
		
		/* Stage resize handler */
		private function stage_resizeHandler(e:Event):void { compute(); }
		
		/* Compute size */
		public function compute():void
		{
			if (_stage)
			{
				_width = Math.max(_minWidth, _widthPercent ? Math.round((_stage.stageWidth - _x) * _widthPercent.value) : _width);
				_height = Math.max(_minHeight, _heightPercent ? Math.round((_stage.stageHeight - _y) * _heightPercent.value) : _height);
				dispatchEvent(new LayoutEvent(LayoutEvent.SIZE_CHANGE, _width, _height));
			}
		}
		
		/// Properties
		
		/* Stage reference */
		public function get stage():Stage { return _stage; }
		
		/* Width percent */
		public function get widthPercent():Percent { return _widthPercent; }		
		public function set widthPercent(value:Percent):void 
		{
			if (_widthPercent != value)
			{
				if (value) _widthPercent = value;
				else { _widthPercent.destroy(); _widthPercent = null; }
				compute();
			}
		}
		
		/* Height percentage */
		public function get heightPercent():Percent { return _heightPercent; }		
		public function set heightPercent(value:Percent):void 
		{
			if (_heightPercent != value)
			{
				if (value) _heightPercent = value;
				else { _heightPercent.destroy(); _heightPercent = null; }
				compute();
			}
		}
		
		/* Layout offset x */
		public function get x():Number { return _x; }		
		public function set x(value:Number):void 
		{
			value = Math.max(0, value);
			if (_x != value)
			{
				_x = value;
				compute();
			}
		}
		
		/* Layout offset y */
		public function get y():Number { return _y; }		
		public function set y(value:Number):void 
		{
			value = Math.max(0, value);
			if (_y != value)
			{
				_y = value;
				compute();
			}
		}
		
		/* Lyout minimum width */
		public function get minWidth():Number { return _minWidth; }		
		public function set minWidth(value:Number):void 
		{
			value = Math.max(0, value);
			if (_minWidth != value)
			{
				_minWidth = value;
				compute();
			}
		}
		
		/* Layout minimum height */
		public function get minHeight():Number { return _minHeight; }		
		public function set minHeight(value:Number):void 
		{
			value = Math.max(0, value);
			if (_minHeight != value)
			{
				_minHeight = value;
				compute();
			}
		}
		
		/* Layout width */
		public function get width():Number { return _width; }		
		public function set width(value:Number):void 
		{
			value = Math.max(0, value);
			if (_width != value)
			{
				_width = value;
				if (_widthPercent) { _widthPercent.destroy(); _widthPercent = null; }
				compute();
			}
		}
		
		/* Layout height */
		public function get height():Number { return _height; }		
		public function set height(value:Number):void 
		{
			value = Math.max(0, value);
			if (_height != value)
			{
				_height = value;
				if (_heightPercent) { _heightPercent.destroy(); _heightPercent = null; }
				compute();
			}
		}
		
		/// Override
		
		/* Destroy layout object */
		override public function destroy():void 
		{
			_stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
			_stage = null;	
			this.width = this.height = 0;
			super.destroy();
		}
		
	}

}