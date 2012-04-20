package multigraph
{
  import flash.events.EventDispatcher;
  
  import mx.formatters.NumberBase;

  public class Axis extends EventDispatcher
  {
    private var _pixelMin:Number;
    private var _pixelMax:Number;
    private var _dataMin:Number;
    private var _dataMax:Number;
    private var _panMin:Number;
    private var _panMax:Number;
    private var _zoomMin:Number;
    private var _zoomMax:Number;
    private var _axisToDataRatio:Number;
	private var _binding:AxisBinding;

    public function set pixelMin(val:Number):void { _pixelMin = val; }
    public function set pixelMax(val:Number):void { _pixelMax = val; }
      
    public function Axis(dataMin:Number, dataMax:Number,
                         panMin:Number, panMax:Number,
                         zoomMin:Number, zoomMax:Number) {
      internalSetRange(dataMin, dataMax);
      _panMin = panMin;
      _panMax = panMax;
      _zoomMin = zoomMin;
      _zoomMax = zoomMax;
	  _binding = AxisBinding.getAxisBinding();
	  _binding.addAxis(this);
    }
	
	public function pixelToDataValue(p:Number):Number {
		return _dataMin + (p - _pixelMin) * (_dataMax - _dataMin) / (_pixelMax - _pixelMin);
	}

    public function zoom(base:Number, pixelDisplacement:Number):void {
      var dataBase:Number = pixelToDataValue(base);
      var factor:Number = 10 * Math.abs(pixelDisplacement / (_pixelMax - _pixelMin));
      //if (_reversed) { factor = -factor; }
      var newMin:Number, newMax:Number;
      if (pixelDisplacement <= 0) {
        newMin = (_dataMin - dataBase) * ( 1 + factor ) + dataBase;
        newMax = (_dataMax - dataBase) * ( 1 + factor ) + dataBase;
      } else {
        newMin = (_dataMin - dataBase) * ( 1 - factor ) + dataBase;
        newMax = (_dataMax - dataBase) * ( 1 - factor ) + dataBase;
      }
      if (newMin < _panMin) {
        newMin = _panMin;
      }
      if (newMax > _panMax) {
        newMax = _panMax;
      }

      if ((_dataMin <= _dataMax && newMin < newMax)
          ||
          (_dataMin >= _dataMax && newMin > newMax)) {
		
		var d:Number
        if (newMax - newMin > _zoomMax) {
          d = (newMax - newMin - _zoomMax) / 2;
          newMax -= d;
          newMin += d;
        } else if (newMax - newMin < _zoomMin) {
          d = (_zoomMin - (newMax - newMin)) / 2;
          newMax += d;
          newMin -= d;
        }

        setRange( newMin, newMax );
      }
    }


    public function pan(pixelDisplacement:int):void {
		internalSetRange(_dataMin, _dataMax);
        var offset:Number = pixelDisplacement / _axisToDataRatio;
        var newMin:Number = _dataMin + offset;
        var newMax:Number = _dataMax + offset;
        if (pixelDisplacement < 0 && newMin < _panMin) {
        	newMax += (_panMin - newMin);
            newMin = _panMin;
        }
        if (pixelDisplacement > 0 && newMax > _panMax) {
        	newMin -= (newMax - _panMax);
            newMax = _panMax;
        }
        setRange( newMin, newMax );
    }


	public function setRangeNoBinding(min:Number, max:Number):void {
		internalSetRange(min,max);
		dispatchEvent(new AxisEvent(AxisEvent.CHANGE,min,max));
	}
	
	public function setRange(min:Number, max:Number):void {
		setRangeNoBinding(min, max);
		_binding.setRange(this, min, max);
	}
	
    private function internalSetRange(min:Number, max:Number):void {
      _dataMin = min;
      _dataMax = max;
      _axisToDataRatio = (_pixelMax - _pixelMin) / (_dataMax - _dataMin);
    }

  }
}
