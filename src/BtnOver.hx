package ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;

/**
 * ...
 * @author GuyF
 */

class BtnOver extends Sprite
{
	private var idle:Bitmap;
	private var over:Bitmap;
	private var selected:Bitmap;
	
	public var isSelected(default, setSelected):Bool;
	public var isOver(default, setOver):Bool;
	private var current:DisplayObject;

	public function new(idle:BitmapData,over:BitmapData,selected:BitmapData) 
	{
		super();
		
		this.idle = new Bitmap();
		this.idle.bitmapData = idle;
		this.over = new Bitmap();
		this.over.bitmapData = over;
		this.selected = new Bitmap();
		this.selected.bitmapData = selected;
		addChild(this.selected);
		addChild(this.over);
		addChild(this.idle);
		this.selected.visible = false;
		this.over.visible = false;
		this.idle.visible = false;
		this.isSelected = false;
		this.addEventListener(flash.events.MouseEvent.MOUSE_OVER, evt_over, false, 0, true);
		this.addEventListener(flash.events.MouseEvent.MOUSE_OUT, evt_out, false, 0, true);
		this.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, evt_press, false, 0, true);
		this.addEventListener(flash.events.MouseEvent.MOUSE_UP, evt_release, false, 0, true);
	//	this.jeashGraphics.jeashSurface.setAttribute("alt", 'plus');
		
		update();
	}
	private function evt_press(e:flash.events.MouseEvent) {
		isSelected = true;
	}
	private function evt_release(e:flash.events.MouseEvent) {
		isSelected = false;
	}
	
	private function evt_over(e:flash.events.MouseEvent) {
		isOver = true;
	}
	private function evt_out(e:flash.events.MouseEvent) {
		isSelected = false;
		isOver = false;
		
	}
	function setSelected(bselect:Bool) {
		if (bselect == this.isSelected) return bselect;
		this.isSelected = bselect;
		update();
		return bselect;
	}
	function setOver(bover:Bool) {
		if (bover == this.isOver) return bover;
		this.isOver = bover;
		update();
		return bover;
	}
	
	function update() {

		if (isSelected) {
			idle.visible = false;
			over.visible = false;
			selected.visible = true;
		
		} else {
			if (isOver) {
				idle.visible = false;
				over.visible = true;
				selected.visible = false;
			} else {
				idle.visible = true;
				over.visible = false;
				selected.visible = false;
			}
		}
	}
	
}