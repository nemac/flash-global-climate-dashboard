package multigraph
{
	import mx.core.UIComponent;
	
	public class Graph extends UIComponent
	{
		private var _axes:Array;
		public function get axes():Array { return _axes; }
		private function addAxis(axis:Axis):void {
			_axes.push(axis);
		}
		public function Graph()
		{
			super();
			_axes = [];
			addAxis(new Axis(1900, 2000, 1800, 2100, 1, 300));
		}
	}
}
