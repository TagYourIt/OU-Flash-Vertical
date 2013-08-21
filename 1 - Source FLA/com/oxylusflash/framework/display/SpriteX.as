package com.oxylusflash.framework.display
{
	import com.oxylusflash.framework.core.IDestructible;
	import com.oxylusflash.framework.misc.StageReference;
	import flash.display.*;
	
	/**
	 * Sprite extended
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class SpriteX extends Sprite implements IDestructible
	{
		private var _destroyed:Boolean = false;
		
		/* Sprite extended */
		public function SpriteX() { }
		
		/* Destroy object */
		public function destroy():void
		{
			if (this.parent) this.parent.removeChild(this);
			_destroyed = true;
		}
		
		/* Check if object is destroyed */
		public function get destroyed():Boolean { return _destroyed; }
		
		/* Get stage reference */
		override public function get stage():Stage { return StageReference.stage || super.stage; }
		
	}

}
