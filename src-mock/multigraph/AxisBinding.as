package multigraph
{
	public class AxisBinding
	{
		private static var _singletonAxisBinding:AxisBinding = null;
		private var _axes:Array;
		
		public static function getAxisBinding():AxisBinding {
			if (!_singletonAxisBinding) {
				_singletonAxisBinding = new AxisBinding();	
			}
			return _singletonAxisBinding;
		}
		public function AxisBinding()
		{
			_axes = [];
		}
		public function addAxis(axis:Axis):void {
			for (var i:int=0; i<_axes.length; ++i) {
				if (_axes[i]==axis) { return; }
			}
			_axes.push(axis);
		}
		public function setRange(initiator:Axis, min:Number, max:Number):void {
			for (var i:int=0; i<_axes.length; ++i) {
				if (_axes[i]!=initiator) {
					_axes[i].setRangeNoBinding(min,max);
				}
			}
		}
	}
}
