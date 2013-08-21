package com.oxylusflash.framework.resize 
{
	import flash.geom.Rectangle;
	/**
	 * Resize
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Resize
	{
		/* Resize class */
		public function Resize() 
		{
			throw new Error("Resize class has static methods. No need for instatiation.");
		}
		
		/**
		 * Compute reisze parameters
		 * @param	objectRect		Object rectangle
		 * @param	containerRect	Container rectangle
		 * @param	resizeType		Resize type
		 * @param	alignType		Align type
		 * @return	Size rectangle
		 */
		public static function compute(objectRect:Rectangle, containerRect:Rectangle, resizeType:String = "noResize", alignType:String = "topLeft"):Rectangle
		{
			var sizeRect:Rectangle = containerRect.clone();
			
			// Resize
			if (resizeType != ResizeType.STRETCH)
			{
				if (resizeType == ResizeType.NO_RESIZE || (resizeType == ResizeType.FIT && objectRect.width <= containerRect.width && objectRect.height <= containerRect.height))
				{
					sizeRect.width = objectRect.width;
					sizeRect.height = objectRect.height;
				}
				else
				{
					var objectRatio:Number = objectRect.width / objectRect.height;
					var containerRatio:Number = containerRect.width / containerRect.height;
					var ratioFlag:Boolean = objectRatio < containerRatio;
					
					if (resizeType == ResizeType.FILL && !ratioFlag || (resizeType == ResizeType.FIT || resizeType == ResizeType.FIT_FORCED) && ratioFlag)
					{
						sizeRect.width = Math.round(containerRect.height * objectRatio);
						sizeRect.height = containerRect.height;
					}
					else
					{
						sizeRect.width = containerRect.width;
						sizeRect.height = Math.round(containerRect.width / objectRatio);
					}
				}
			}
			
			// Align
			if (alignType != AlignType.TOP_LEFT)
			{
				switch(alignType)
				{
					case AlignType.TOP:				
					case AlignType.CENTER:
					case AlignType.BOTTOM: sizeRect.x += Math.round((containerRect.width - sizeRect.width) * 0.5); break;					
					case AlignType.TOP_RIGHT:
					case AlignType.RIGHT:
					case AlignType.BOTTOM_RIGHT: sizeRect.x += containerRect.width - sizeRect.width; break;
				}
				
				switch(alignType)
				{
					case AlignType.LEFT:
					case AlignType.CENTER:
					case AlignType.RIGHT: sizeRect.y += Math.round((containerRect.height - sizeRect.height) * 0.5); break;						
					case AlignType.BOTTOM_LEFT:
					case AlignType.BOTTOM:				
					case AlignType.BOTTOM_RIGHT: sizeRect.y += containerRect.height - sizeRect.height; break;
				}
			}
			
			return sizeRect;
		}
		
	}

}