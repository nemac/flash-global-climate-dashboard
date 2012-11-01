package old
{
	import spark.components.Group;
	
	public class GraphSlot extends Group
	{
		public var index:int;
		
		public function GraphSlot(index:int)
		{
			super();
			this.index = index;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			//graphics.beginFill(0xFFFFFF, 0.0);
            graphics.beginFill(0xFF0000, 0.0);
			graphics.drawRect(0,0,unscaledWidth,unscaledHeight);
		}
		
	}
}
