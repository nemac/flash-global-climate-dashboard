package multigraph
{
	import flash.events.Event;
	
	public class AxisEvent extends Event
	{
		public static const CHANGE:String = "change";
		
		private var _min:Number;
		private var _max:Number;
		public function get min():Number { return _min; }
		public function set min(val:Number):void { _min = val; }
		public function get max():Number { return _max; }
		public function set max(val:Number):void { _max = val; }
		public function AxisEvent(type:String, min:Number, max:Number,
										bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_min = min;
			_max = max;
		}
	}
}
