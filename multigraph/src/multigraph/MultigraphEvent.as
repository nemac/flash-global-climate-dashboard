package multigraph
{
  import flash.events.Event;

  public class MultigraphEvent extends Event
  {
    public static const PARSE_MUGL:String = "parseMugl";

    public function MultigraphEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
    {
      super(type, bubbles, cancelable);
    }
  }
}
