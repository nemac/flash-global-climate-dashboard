package dashboard {
	
	import flash.events.Event;
	
	public class TimeSliderEvent extends Event
	{
		public static const CHANGE:String = "change";
		
		private var _min:Number;
		private var _max:Number;
		/**
		 * The new data value corresponding to the minimum endpoint of the axis.
		 */
		public function get min():Number { return _min; }
		public function set min(val:Number):void { _min = val; }
		/**
		 * The new data value corresponding to the maximum endpoint of the axis.
		 */
		public function get max():Number { return _max; }
		public function set max(val:Number):void { _max = val; }

		public function TimeSliderEvent(type:String, min:Number, max:Number,
								  		bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_min = min;
			_max = max;
		}
	}
}
