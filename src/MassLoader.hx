package ;
import jeash.display.DisplayObject;
import jeash.display.Loader;
import flash.net.URLRequest;
import jeash.events.Event;
import jeash.events.EventDispatcher;
import jeash.events.ProgressEvent;

/**
 * ...
 * @author GuyF
 */

class MassLoader extends EventDispatcher
{
	private  var total:Int;
	private  var completed:Int;
	
	public  var loaders:Hash <Loader>;
	public var listLinks:Array<String>;
	
	private var tf:DivText;
	
	public function new(tf:DivText) 
	{
		super();
		listLinks = new Array<String>();
		this.tf = tf;
		loaders = new Hash <Loader> ();
		total = 0;
		completed = 0;
	}
	public function add(file:String) {
		trace("MassLoader.add " + file);
		listLinks.push(file);
		var loader:Loader = new Loader ();
		loaders.set (file, loader);
		total++;
	}
	
	public function get(file:String):DisplayObject {
		var loader:Loader = loaders.get(file);
		return loader.content;
	}
	
	public function start():Void {
		if (completed == total) {
			
			onComplete ();
			
		} else {
			
				var loader:Loader = loaders.get (listLinks[completed]);
				loader.contentLoaderInfo.addEventListener ("complete", loader_onComplete);
				loader.load (new URLRequest (listLinks[completed]));
			
			
		}
	}
	
	private  function loader_onComplete (event:Event):Void {
		
		completed ++;
		trace("completed " + completed);
	//	tf.SetHTMLText("<div id='img_chargement'><span>CHARGEMENT..."+completed+"/"+total+"</span></div>");
		if (completed == total) {
			
			onComplete ();
			
		} else {
			var loader:Loader = loaders.get (listLinks[completed]);
				loader.contentLoaderInfo.addEventListener ("complete", loader_onComplete);
				loader.load (new URLRequest (listLinks[completed]));
		}
	   
	}
	private function onComplete() {
		tf.SetHTMLText("");
		dispatchEvent(new Event("COMPLETE"));
	}
	private function loarderProgess(event:ProgressEvent) {
	//	tf.SetHTMLText("<div id='img_chargement'><span>CHARGEMENT..."+event.bytesLoaded+"</span></div>");
	}
	
}