package multigraph
{
  import flash.events.Event;
  import flash.events.MouseEvent;
  
  import mx.core.UIComponent;
	
  public class Multigraph extends UIComponent
	{
      private var _mouseIsDown:Boolean;
      private var _graphs:Array;
      public function get graphs():Array { return _graphs; }		
      private var _trackAxis:Axis = null;

      private var _mouseBaseX:int;
      private var _mouseBaseY:int;
      private var _mouseLastX:int;
      private var _mouseLastY:int;
	  
	  private var _bgcolor:uint = 0xeeeeee;
	  public function set bgcolor(bgcolor:uint):void { _bgcolor = bgcolor; }
	  
	  private var _mugl:String;
	  public function set mugl(val:String):void { _mugl = val; }

	  private var _muglfile:String;
	  public function set muglfile(val:String):void { _muglfile = val; }

      public function Multigraph()
      {
        super();
        _mouseIsDown = false;
        addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void {
            _mouseIsDown = true;
            _mouseBaseX = event.localX;
            _mouseBaseY = event.localY;
            _mouseLastX = event.localX;
            _mouseLastY = event.localY;
          });
        addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):void {
            _mouseIsDown = false;
          });
        addEventListener(MouseEvent.MOUSE_OUT, function(event:MouseEvent):void {
            _mouseIsDown = false;
          });
        addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove); 
      }
	  
	private function handleMouseMove(event:MouseEvent):void {
		  if (_mouseIsDown) {
			  if (_trackAxis) {
                var dx:int = event.localX - _mouseLastX;
                if (event.shiftKey) {
				  _trackAxis.zoom(_mouseBaseX, dx);
                } else {
				  _trackAxis.pan(-dx);
                }
                this.invalidateDisplayList();
                _mouseLastX = event.localX;
                _mouseLastY = event.localY;
			  }
		  }
	  }
		
      override protected function createChildren():void {
        _graphs = [];
        var g:Graph = new Graph();
        _graphs.push(g);
        addChild(g);
        _trackAxis = _graphs[0].axes[0];
		_trackAxis.addEventListener(AxisEvent.CHANGE, function (event:Event):void {
			invalidateDisplayList();
		});
      }

      override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        var border:int = 3;
        var axispos:int = 35;
        var axisgap:int = 20;

        if (_trackAxis) {
          _trackAxis.pixelMin = border + axisgap;
          _trackAxis.pixelMax = unscaledWidth - border - axisgap;
        }

		this.graphics.lineStyle(0, 0x000000);
        this.graphics.beginFill(0x000000);
        this.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
        this.graphics.endFill();
        this.graphics.beginFill(_bgcolor);
        this.graphics.drawRect(border, border, unscaledWidth-2*border, unscaledHeight-2*border);
        this.graphics.endFill();

		this.graphics.lineStyle(2, 0x000000);
        var vx1:int = border + axispos;
        var vy1:int = border + axisgap;
        var vx2:int = border + axispos;
        var vy2:int = unscaledHeight - border - axisgap;

        var hx1:int = border + axisgap;
        var hy1:int = unscaledHeight - border - axispos;
        var hx2:int = unscaledWidth - border - axisgap;
        var hy2:int = unscaledHeight - border - axispos;

        this.graphics.moveTo(vx1, vy1);
        this.graphics.lineTo(vx2, vy2);
        this.graphics.moveTo(hx1, hy1);
        this.graphics.lineTo(hx2, hy2);

        var dx:int = 10;
        var amp:Number = (hy1 - vy1) / 2;
        var y0:Number = hy1 - amp;
        var x:Number = vx1;
        var y:Number = y0 + amp*Math.sin(3.14159 * (_trackAxis.pixelToDataValue(x) - 1800) / 25.0);
        graphics.moveTo(x,y);
        for (x=vx1+dx; x<=hx2; x+=dx) {
          y = y0 + amp*Math.sin(3.14159 * (_trackAxis.pixelToDataValue(x) - 1800) / 25.0);
          graphics.lineTo(x,y);
        }
			
      }
	}
}
