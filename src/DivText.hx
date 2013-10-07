package ;
import jeash.display.Graphics;
import jeash.text.TextField;
import Html5Dom.HTMLCanvasElement;
import jeash.Lib;
import jeash.geom.Matrix;
/**
 * ...
 * @author GuyF
 */

class DivText extends TextField
{

	
	public override function jeashRender(parentMatrix:Matrix, ?inMask:Html5Dom.HTMLCanvasElement) {
		try{
			super.jeashRender(parentMatrix, inMask);
		}catch (e:Dynamic) {
			
		}
		
	
	}
	public function new() 
	{
		super();
		
	}
	override public function SetHTMLText(inHTMLText:String) {
		mParagraphs = new Paragraphs();
		mHTMLText = inHTMLText;
		
		
		if (!mHTMLMode) {
			var wrapper : Html5Dom.HTMLCanvasElement = cast js.Lib.document.createElement("div");
			wrapper.width = Math.round(width);
			wrapper.height = Math.round(height);
			//wrapper.setAttribute("width", ''+Math.round(width));
			//wrapper.setAttribute("height", ''+Math.round(height));
			
			wrapper.innerHTML = inHTMLText;
			
			var destination = new Graphics(wrapper);

			var jeashSurface = jeashGraphics.jeashSurface;
			if (Lib.jeashIsOnStage(jeashSurface)) {
				Lib.jeashAppendSurface(wrapper);
				Lib.jeashCopyStyle(jeashSurface, wrapper);
				Lib.jeashSwapSurface(jeashSurface, wrapper);
					Lib.jeashRemoveSurface(jeashSurface);
			}

		jeashGraphics = destination;
		jeashGraphics.jeashExtent.width = wrapper.width;
		jeashGraphics.jeashExtent.height = wrapper.height;
	} else {
		jeashGraphics.jeashSurface.innerHTML = inHTMLText;
	}

		mHTMLMode = true;
		RebuildText();
		

		jeashInvalidateBounds();

		return mHTMLText;
	}
	public override function RebuildText() {
		
		Rebuild();
		
	}
	
	override function Rebuild() {
		return;

	}
	
}