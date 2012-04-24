package components
{
  import flash.events.Event;
  
  import multigraph.AxisEvent;
  import multigraph.Multigraph;
	
  //
  // A silly little subclass of Multigraph that modifies its own mugl
  // to set the window border to 0.  We use this because the mugl
  // stored in sandbox.multigraph.org includes borders, for nice
  // display there, but we don't want borders here in the dashboard.
  // Ultimately, this probably won't be necessary, once the graph mugl
  // is being served from a dashboard-dedicated service (and can
  // omit the border in the first place).
  //
  [Event(name="change", type="multigraph.AxisEvent")]
	
    public class CustomizedMultigraph extends Multigraph
    {
      private var _mugloverrides:Object = null;
      private var _mugloverrides_set:Boolean = false;
      public function set mugloverrides(value:Object):void {
	_mugloverrides = value;
	_mugloverrides_set = true;
	if (_mugl_set && _mugloverrides_set) {
	  setMuglWithOverrides();
	}
      }

      private var _mugl:XML = null;
      private var _mugl_set:Boolean = false;
      override public function set mugl(value:Object):void {
	_mugl = value as XML;
	_mugl_set = true;
	if (_mugl_set && _mugloverrides_set) {
	  setMuglWithOverrides();
	}
      }
		
      private var _outlined:Boolean = false;
      public function set outlined(value:Boolean):void {
	this._outlined = value;
	invalidateDisplayList();
      }
		
      public function CustomizedMultigraph()
      {
	super();
      }
		
      private function setMuglWithOverrides():void {
	if (_mugloverrides != null) {
	  //alert('applying _mugloverrides now', 'ALERT');
	  _mugl = Dashboard.applyXMLOverrides(_mugl, _mugloverrides);
	} else {
	  //alert('no overrides to apply', 'ALERT');
	}
	super.mugl = _mugl;
	this.graphs[0].axes[0].addEventListener(AxisEvent.CHANGE, handleAxisEvent);
      }

      private function handleAxisEvent(event:AxisEvent):void {
	this.dispatchEvent(new AxisEvent(event.type, event.min, event.max));
      }
		
      override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
	super.updateDisplayList(unscaledWidth, unscaledHeight);
	if (_outlined) {
	  graphics.lineStyle(5, 0xcc9933);
	  graphics.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, 10, 10);
	}
      }
		
		
    }
}
