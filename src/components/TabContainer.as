package components
{
	import multigraph.Axis;
	import multigraph.AxisEvent;
	import multigraph.Multigraph;
	import multigraph.format.DateFormatter;
	
	import mx.containers.VBox;
	import mx.events.FlexEvent;


	public class TabContainer extends VBox
	{

		public var mainContainer:Object;
		[Bindable]public var timelineMugl:XML;

			[Bindable]public var timeSliderMin:Number;
			[Bindable]public var timeSliderMax:Number;
			[Bindable]public var timeSliderSelectedMin:Number;
			[Bindable]public var timeSliderSelectedMax:Number;
			[Bindable]public var timeSliderLabels:String = null;
			[Bindable]public var dragHandleVisible:Boolean = true;
			[Bindable]public var helpHandleVisible:Boolean = true;

			protected var _graphWidth:int           = 425;
			protected var _graphHeight:int          = 110;
			protected var _graphCollapsedHeight:int = 20;
			protected var _graphProxyHeight:int     = 20;
			protected var _leftPad:int			  = 17;
			
			public var graphSlots:Array;
			public var _graphCount:int            = 0;

			protected var multigraphDateFormatter : DateFormatter = new DateFormatter("%Y");

			public var _graphContainers:Array = [];

			public var _numberOfExpandedSlots:int = 3;
			public var _totalNumberOfSlots:int    = 10;

			public var timeslider:TimeSlider;
			
			public function TabContainer() {
				super();
				this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			}

			private function onCreationComplete(event:FlexEvent):void {
				// I'm not sure which of these is actually needed, but having one or more of them
				// here seems to fix (I hope!) the problem of the time slider sometimes not being
				// correctly initialized. --mbp
				executeBindings(true);
				executeChildBindings(true);
				this.timeslider.executeBindings(true);
			}
			
			private function axisDateValueToYearInt( axisValue : Number ) : int {
				return parseInt( multigraphDateFormatter.format( axisValue ) );
			}
			private function yearIntToAxisDateValue( year : int ) : Number {
				return multigraphDateFormatter.parse( year+'' );
			}
			

			private function handleAxisChange(event:AxisEvent):void {
				//hslider1.values = [, axisDateValueToYearInt(event.max)];
				var a:Number = axisDateValueToYearInt(event.min);
				var b:Number = axisDateValueToYearInt(event.max);
				//trace('axisEvent('+event.min+', '+event.max+')  ==> slider values ('+a+', '+b+')');
				//xyzzy
				timeslider.selectedMinValue = a;
				timeslider.selectedMaxValue = b;
			}

			public function addGraph(title:String=null, helpText:String=null, rmLink:String=null):GraphContainer {
				var graphContainer:GraphContainer = new GraphContainer();
				graphContainer.helpHandleVisible = this.helpHandleVisible;
				graphContainer.dragHandleVisible = this.dragHandleVisible;
				graphContainer.width = _graphWidth;
				graphContainer.height = _graphHeight;
				graphContainer.horizontalCenter = 0;
				graphContainer.top = 0;
				graphContainer.leftPad = _leftPad;
				graphContainer.tabContainer = this;
				if (_graphCount==0) {
					graphContainer.addEventListener(AxisEvent.CHANGE, handleAxisChange);
				}
				if (_graphCount>=_numberOfExpandedSlots) {
					graphContainer.currentState = "collapsed";
				}
				graphSlots[_graphCount].addElement(graphContainer);
				++_graphCount;
				graphContainer.titleString = title;
				graphContainer.helpString  = helpText;
				_graphContainers.push(graphContainer);
				//graphContainer.helpBorderContainerHeight = 400;
				//graphContainer.helpContentHeight = 300;
				return graphContainer;
			}

			protected function sliderChange(event:TimeSliderEvent) {
				//trace('sliderChange('+event.min+', '+event.max+') => axisValues('+a+', '+b+')');
				var a:Number = yearIntToAxisDateValue(event.min);
				var b:Number = yearIntToAxisDateValue(event.max);
				for each (var graphContainer:GraphContainer in _graphContainers) {
					var mg:Multigraph = graphContainer.getMultigraph();
					if (mg != null) {
						var graphs:Array = mg.graphs;
						var axes:Array = graphs[0].axes;
						var axis:Axis = axes[0];
						axis.setDataRange(a, b,false);
						// note: 'false' as the 3rd arg tells setDataRange not to dispatch an AxisEvent, which is important
						// here to prevent an adverse feedback loop coming from the fact that we're listening for those
						// events here in this class and calling this function (sliderChange) in response to them.
						break; 
						// only set the data range on the first graph in this tab!!!  The others
				        // will autoadjust to it via the axis bindings in Multigraph.
					}
				}
				//trace('slider set to: ' + event.min + ', ' + event.max);
			}

	}
}
