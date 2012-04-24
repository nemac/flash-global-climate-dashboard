package components
{
  import flash.display.CapsStyle;
  import flash.display.DisplayObject;
  import flash.display.GradientType;
  import flash.display.Graphics;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.geom.Matrix;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  
  import mx.controls.Label;
  import mx.core.UIComponent;
  import mx.events.SandboxMouseEvent;
  import mx.graphics.LinearGradient;
  import mx.managers.CursorManager;

  
  [Event(name="change", type="components.TimeSliderEvent")]
    
  public class TimeSlider extends UIComponent
  {
    private static const LEFT_GAP:int   = 0;
    private static const LEFT_EDGE:int  = 1;
    private static const MIDDLE:int     = 2;
    private static const RIGHT_EDGE:int = 3;
    private static const RIGHT_GAP:int  = 4;

    private static const NONE_HIGHLIGHTED:int   = 0;
    private static const LEFT_HIGHLIGHTED:int   = 1;
    private static const MIDDLE_HIGHLIGHTED:int = 2;
    private static const RIGHT_HIGHLIGHTED:int  = 3;
	
	/*
	 * labels can be either (a) an array of strings [S1,S2,...SN] or (b) a single string of the form "S1,S2,...SN".
	 * In both cases, each Si should be a string that can be interpreted as a number.  Each string is used
	 * as a label to be displayed in the timeline, and its numberical value is used to determine its
	 * horizontal position along the timeline.
	 */
    public var labels:Object;

    private static var _state:int = NONE_HIGHLIGHTED;
    private function set state(s:int):void {
      _state = s;
      invalidateDisplayList();
    }
    private function get state():int {
      return _state;
    }
        
    // percentage of the width of the selected region, on the INSIDE of each edge, that is used
    // as the hit area for the edge:
    private var _edgeInnerThresholdPercent:int = 15;

    // width of the hit area for each edge of the selected region that extends OUTSIDE each
    // edge, expressed in pixels:
    private var _edgeOuterThresholdPixels:int  = 10;

    // width of the bar used to highlight the edges:
    private var _edgeHighlightWidth:int        = 4;

    // minimum width of the selected area, in pixels:
    private var _minWidthPixels:int            = 1;
        
    private var _lastX:int;
    private var _mouseIsDown:Boolean = false;
    private var _grabLocation:int;
	
	private var _drawArrows:Boolean = false;
        
    public var minValue:Number = 0;
    public var maxValue:Number = 100;
    private var _selectedMinValue:Number = NaN;
    private var _selectedMaxValue:Number = NaN;
    private var _selectedMinPixel:Number = NaN;
    private var _selectedMaxPixel:Number = NaN;

    [Bindable]
    [Embed(source="../assets/drag_cursor.png")]
    private var DragCursor:Class;

    public function get selectedMinValue():Number {
        return _selectedMinValue;
    }
    public function get selectedMaxValue():Number {
        return _selectedMaxValue;
    }
    public function set selectedMinValue(value:Number):void {
      if (value < minValue) {
        value = minValue;
      }
	  if (!isNaN(_selectedMaxValue) && (value >= _selectedMaxValue)) {
		  value = _selectedMaxValue - 1;
	  }
	  _selectedMinValue = value;
      _selectedMinPixel = valueToPixel(value);
      invalidateDisplayList();
    } 
    public function set selectedMaxValue(value:Number):void {
      if (value > maxValue) {
        value = maxValue;
      }
	  if (!isNaN(_selectedMinValue) && (value <= _selectedMinValue)) {
		  value = _selectedMinValue + 1;
	  }
      _selectedMaxValue = value;
      _selectedMaxPixel = valueToPixel(value);
      invalidateDisplayList();
    }
    public function set selectedMinPixel(pixel:Number):void {
      if (pixel < 0) {
        pixel = 0;
      }
	  if (!isNaN(_selectedMaxPixel) && (pixel >= _selectedMaxPixel)) {
		  pixel = _selectedMaxPixel - 1;
	  }
      _selectedMinPixel = pixel;
      _selectedMinValue = pixelToValue(pixel);
      invalidateDisplayList();
    }
    public function set selectedMaxPixel(pixel:Number):void {
      if (pixel > width) {
        pixel = width;
      }
	  if (!isNaN(_selectedMinPixel) && (pixel <= _selectedMinPixel)) {
		  pixel = _selectedMinPixel + 1;
	  }
      _selectedMaxPixel = pixel;
      _selectedMaxValue = pixelToValue(pixel);
      invalidateDisplayList();
    }
        
    public function TimeSlider() {
      super();
      this.addEventListener(MouseEvent.MOUSE_OVER, handleMouseMove);
      this.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
      this.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
      this.addEventListener(MouseEvent.MOUSE_OUT,  handleMouseOut);
    }

    override protected function commitProperties():void {
      _selectedMinPixel = valueToPixel(_selectedMinValue);
      _selectedMaxPixel = valueToPixel(_selectedMaxValue);
    }
        
    private function valueToPixel(value:Number):Number {
      return this.width * (value - minValue) / (maxValue - minValue);
    }
    private function pixelToValue(pixel:Number):Number {
      return minValue + (maxValue - minValue) * pixel / this.width;
    }
        
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
            
      graphics.clear();

	  var gradientMatrix:Matrix = new Matrix;
	  gradientMatrix.createGradientBox(425,20,80,0,0);
	  
	  graphics.lineStyle(1, 0x182631, 1.0, false, "normal", CapsStyle.NONE);

	  //full slider color
      graphics.beginFill(0x1a2430, 1);
	  //graphics.beginGradientFill(GradientType.LINEAR,[0x262e35,0x2c3842],[1,1],[0,255],gradientMatrix);
      graphics.drawRect(0,0,unscaledWidth, unscaledHeight);
      graphics.endFill();
      
	  //track button color
      graphics.beginFill(0xcc9933, 0.3);
	  
	  //graphics.beginGradientFill(GradientType.LINEAR,[0x406879,0x5d7d8a],[1,1],[0,255],gradientMatrix);
	  //track outline color
      graphics.lineStyle(1, 0xcc9933, .5, false, "normal", CapsStyle.NONE);
      graphics.drawRect(_selectedMinPixel,0,_selectedMaxPixel-_selectedMinPixel, unscaledHeight);
      graphics.endFill();
	  
	  
      
      switch (_state) {
      case NONE_HIGHLIGHTED:
		  highlightLeftEdge(unscaledWidth,unscaledHeight,.5);
		  highlightRightEdge(unscaledWidth,unscaledHeight,.5);
        break;
      case LEFT_HIGHLIGHTED:
          highlightLeftEdge(unscaledWidth,unscaledHeight,1);
		  highlightRightEdge(unscaledWidth,unscaledHeight,.5);
        break;
      case RIGHT_HIGHLIGHTED:
          highlightRightEdge(unscaledWidth,unscaledHeight,1);
		  highlightLeftEdge(unscaledWidth,unscaledHeight,.5);
        break;
      case MIDDLE_HIGHLIGHTED:
          highlightLeftEdge(unscaledWidth,unscaledHeight,1);
          highlightRightEdge(unscaledWidth,unscaledHeight,1);
        break;
      }
	  
	  if (_drawArrows) {
		  graphics.lineStyle(1, 0xffffff);
		  drawArrow(this.width/4-20, this.height/2, -1, 15,  6, 6);
		  drawArrow(3*this.width/4+20, this.height/2, 1, 15, 6, 6);
	  }
	  
    }
	
	private function drawArrow(x:Number, y:Number, dir:int, length:Number, headWidth:Number, headLength:Number) {
		graphics.moveTo(x,y);
		graphics.lineTo(x + dir*length, y);
		graphics.moveTo(x + dir * (length - headLength), y + headWidth/2);
		graphics.lineTo(x + dir*length, y);
		graphics.lineTo(x + dir * (length - headLength), y - headWidth/2);
	}
    
    private function highlightLeftEdge(unscaledWidth:Number, unscaledHeight:Number, alpha:Number):void {
        graphics.beginFill(0xcc9933,alpha);
        graphics.drawRect(_selectedMinPixel, 0, _edgeHighlightWidth, unscaledHeight);
        graphics.endFill();
    }
    private function highlightRightEdge(unscaledWidth:Number, unscaledHeight:Number, alpha:Number):void {
        graphics.beginFill(0xcc9933,alpha);
        graphics.drawRect(_selectedMaxPixel - _edgeHighlightWidth, 0, _edgeHighlightWidth, unscaledHeight);
        graphics.endFill();
    }
        
    private function setHandCursor(v:Boolean):void {        
      this.buttonMode    = v;
      this.useHandCursor = v;
    }
        
    private function handleMouseOut(event:MouseEvent):void {
        if (!_mouseIsDown) {
            setHandCursor(false);
            setDragCursor(false);
            state = NONE_HIGHLIGHTED;
        }
    }
        
    private function handleMouseUp(event:MouseEvent):void {         
      if (_mouseIsDown) {
        handleMouseLeave(event);
        _mouseIsDown = false;
      } else {
        setHandCursor(false);
        setDragCursor(false);
        state = NONE_HIGHLIGHTED;
      }
    }
        
    private function findRegion(event:MouseEvent):int {
      if (event.localX < _selectedMinPixel - _edgeOuterThresholdPixels) {
          return LEFT_GAP;
      }
      if (event.localX <= _selectedMinPixel + _edgeInnerThresholdPercent * (_selectedMaxPixel - _selectedMinPixel) / 100) {
          return LEFT_EDGE;
      }
      if (event.localX < _selectedMaxPixel - _edgeInnerThresholdPercent * (_selectedMaxPixel - _selectedMinPixel) / 100) {
          return MIDDLE;
      }
      if (event.localX <= _selectedMaxPixel + _edgeOuterThresholdPixels) {
          return RIGHT_EDGE;
      }
      return RIGHT_GAP;
    }
        
    private function handleMouseDown(event:MouseEvent):void {
      _grabLocation = findRegion(event);
      switch (_grabLocation) {
      case LEFT_EDGE:
        break;
      case RIGHT_EDGE:
        break;
      case MIDDLE:
        break;
      default:
        return;
      }
      _lastX = event.stageX;
      _mouseIsDown = true;
      setDragCursor(true);
      var sbRoot:DisplayObject = systemManager.getSandboxRoot();
      sbRoot.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, true);
      sbRoot.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, true);
      // in case we go offscreen:
      sbRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, handleMouseLeave);
      systemManager.deployMouseShields(true);
            
    }
    private function handleMouseMove(event:MouseEvent):void {
      if (!_mouseIsDown) {
        var region:int = findRegion(event);
        switch (region) {
        case LEFT_EDGE:
          state = LEFT_HIGHLIGHTED;
          setHandCursor(true);
          break;
        case RIGHT_EDGE:
          state = RIGHT_HIGHLIGHTED;
          setHandCursor(true);
          break;
        case MIDDLE:
          state = MIDDLE_HIGHLIGHTED;
          setHandCursor(true);
          break;
        default:
          setHandCursor(false);
          state = NONE_HIGHLIGHTED;
        }
        return;
      }
      var dx:int = event.stageX - _lastX;
      var changed:Boolean = false;
      switch (_grabLocation) {
      case LEFT_EDGE:                   
        selectedMinPixel = _selectedMinPixel + dx;
        changed = true;
        break;
      case RIGHT_EDGE:
        selectedMaxPixel = _selectedMaxPixel + dx;
        changed = true;
        break;
      case MIDDLE:
        selectedMinPixel = _selectedMinPixel + dx;
        selectedMaxPixel = _selectedMaxPixel + dx;
        changed = true;
        break;
      }
      _lastX = event.stageX;
      if (changed) {
          invalidateDisplayList();
          this.dispatchEvent(new TimeSliderEvent(TimeSliderEvent.CHANGE, _selectedMinValue, _selectedMaxValue));
      }
    }
        
    private function handleMouseLeave(event:Event):void
    {
      _mouseIsDown = false;
      setDragCursor(false);
      var sbRoot:DisplayObject = systemManager.getSandboxRoot();
      sbRoot.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp, true);
      sbRoot.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, true);
      // in case we go offscreen:
      sbRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, handleMouseLeave);
      systemManager.deployMouseShields(false);
      state = NONE_HIGHLIGHTED;
    }
        
    
    private function setDragCursor(v:Boolean):void {
        if (v) {
            cursorManager.setCursor(DragCursor,2,-10,-4);
        } else {
            cursorManager.removeAllCursors();
        }
    }

	override protected function createChildren():void {
		var tf:TextFormat = new TextFormat();
		// Note: Multigraph embeds fonts "default" and "defaultBold" which is used (by default) for all its labels
		// This ensures that we use that font for the labels in the time slider:
		tf.font = "defaultBold";
		tf.size = 12;
		if (labels != null && labels != '') {
			var labelArray:Array = ((labels is String) ? (labels as String).split(",") : (labels as Array));
			if (labelArray != null) {
				for (var i:int=0; i<labelArray.length; ++i) {
					var text:String = labelArray[i];
					var value:Number = Number(text);
					// set r = relative location along timeline (x=0 is left end, x=1 is right end):
					var r:Number = (value - this.minValue) / (this.maxValue - this.minValue);
					
					var label:TextField     = new TextField();
					label.embedFonts        = true;
					label.defaultTextFormat = tf;
					label.text              = text;
					label.autoSize          = TextFieldAutoSize.LEFT;
					label.width             = label.textWidth;
					label.height            = label.textHeight;
					label.textColor         = 0xffffff;
					label.mouseEnabled      = false;
					label.x                 = r * this.width - r*label.width;
					label.y                 = this.height/2 - label.height/2;
					addChild(label);
				}
			}
		} else {
			_drawArrows = true;

			var r:Number            = 0.25;
			var label:TextField     = new TextField();
			label.embedFonts        = true;
			label.defaultTextFormat = tf;
			label.text              = "Earlier";
			label.autoSize          = TextFieldAutoSize.LEFT;
			label.width             = label.textWidth;
			label.height            = label.textHeight;
			label.textColor         = 0xffffff;
			label.mouseEnabled      = false;
			label.x                 = r * this.width - r*label.width;
			label.y                 = this.height/2 - label.height/2;
			addChild(label);

			r                       = 0.75;
			label                   = new TextField();
			label.embedFonts        = true;
			label.defaultTextFormat = tf;
			label.text              = "Later";
			label.autoSize          = TextFieldAutoSize.LEFT;
			label.width             = label.textWidth;
			label.height            = label.textHeight;
			label.textColor         = 0xffffff;
			label.mouseEnabled      = false;
			label.x                 = r * this.width - r*label.width;
			label.y                 = this.height/2 - label.height/2;
			addChild(label);

		}
	}
	
	
  }
}
