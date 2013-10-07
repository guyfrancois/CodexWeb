package ;


import flash.display.Stage;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Loader;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.Lib;
import haxe.Json;
import flash.net.URLRequest;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import jeash.display.MovieClip;
import jeash.text.TextFormatAlign;
import js.Dom;

import flash.text.TextField;



/**
 * ...
 * @author GuyF
 */

class Codex  extends Sprite
{
	private var imageLoader:Loader ;
	public var imageLoader_transcriptionMask:Loader;
	public var imageLoader_transcriptionOverlay:Loader;
	
	private var imageView:Bitmap;
	
	
	public var introduction:String;
	public var description:String;
	public var audio:String;
	
	public var img:String;
	public var transcriptionMask:String;
	public var transcriptionOverlay:String;
	public var imgPath:String;
	public var transcriptions:Array<Dynamic>;
	private var _width:Int ;
	private var _height:Int ;
	private var _img_width:Int;
	private var _img_height:Int;
	
	/**
	 * 
	 * @param	img   : image du codex
	 * @param	introduction   : texte d'introduction (context)
	 * @param	description   : texte de description
	 * @param	transcriptionMask   : zones de clic des transcription
	 * @param	transcriptionOverlay   : images avec les contenu transcris affichés
	 * @param	transcriptions   : structure json des transcriptions
	 * @param	imgPath   : chemin vers les ressources images
	 * @param	audio   : chemin vers le fichier son (sans extentions)
	 */
	function new (img:String,introduction:String,description:String,transcriptionMask:String,transcriptionOverlay:String,transcriptions:Array<Dynamic>,imgPath:String,audio:String): Void {
		super();
		//_width = 800;
		//_height = 800;
		bTrans = false;
		bInvers = false;
		this.img = img;
		this.transcriptionMask = transcriptionMask;
		this.transcriptionOverlay = transcriptionOverlay;
		this.introduction = introduction;
		this.description = description;
		this.imgPath = imgPath;
		this.audio = audio;
		this.transcriptions = transcriptions;
		trace(stage.height+"x"+stage.width);
	//	stage.height = stage.height;
		_height = Math.floor(stage.height);
		_width = Math.floor(stage.width);
		_img_width = _width - 80 - 80;
		_img_height = _height;
		clearNoScript();
		prepareInterface();
		//this.stage.addEventListener(Event.RESIZE, evtResize, false, 0, true);
	}
	private function evtResize(e:Event) {
		trace("evtResize "+stage.height+"x"+stage.width);
	}
	
	private function clearNoScript():Void {
		var bImage = js.Lib.document.getElementById("noscript");
		/*
		while (bImage.firstChild) {
			bImage.removeChild(bImage.firstChild);
			
		}
		*/
		bImage.style.visibility = "hidden";// Attribute("hidden", "true");
		bImage.setAttribute("hidden", "true");
		bImage.parentNode.removeChild(bImage);
	}
	private function prepareInterface():Void {
		var g = new Sprite();
		
		g.graphics.beginFill(0x8C837E);
		g.graphics.drawRoundRect(0, 0, _width, _height,10,10);
		g.graphics.endFill();
		addChild(g);
		
		imageTranscription = new Sprite();
		imageMemory = new Sprite();
		imageLoader = new Loader();
		var bitmapData = new BitmapData(_img_width, _img_height);
		imageView = new Bitmap(bitmapData);
       imageView.x = 80;
		imageTranscription.x = imageView.x;
		
		imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderReady);
		var fileRequest:URLRequest = new URLRequest(imgPath+img);
		imageLoader.load(fileRequest);
		
		addChild(imageView);
		addChild(imageTranscription);
		
		var btn = createBtn("plus", _img_width+80, 80);
		btn.addEventListener(flash.events.MouseEvent.CLICK, evtClickPlus, false, 1, true);
		btn = createBtn("moins", _img_width+80, 120);
		btn.addEventListener(flash.events.MouseEvent.CLICK, evtClickMoins, false, 1, true);
		btn = createBtn("intro", 0, 40);
		btn.addEventListener(flash.events.MouseEvent.CLICK, evtClickIntro, false, 1, true);
		btn = createBtn("desc", 0, 100);
		btn.addEventListener(flash.events.MouseEvent.CLICK, evtClickDesc, false, 1, true);
		btn = createBtn("inv", 0, 160);
		btn.addEventListener(flash.events.MouseEvent.CLICK, evtClickInv, false, 1, true);
		btn = createBtn("trans", 0, 220);
		btn.addEventListener(flash.events.MouseEvent.CLICK, evtClickTrans, false, 1, true);
		
		
	}
	private var initSize:Point;
	private var fitScale:Float;
	private var viewPort:Rectangle;
	private var imageMemory:Sprite;
	private var imageTranscription:Sprite;
	
	private var scale:Float;
	private function updateImage():Void {
		
			
		if (scale < fitScale) scale = fitScale;
		
		imageMemory.scaleX = imageMemory.scaleY = scale;
		if (bInvers) {
			imageMemory.scaleX = -Math.abs(imageMemory.scaleX);
			imageTranscription.scaleX = -Math.abs(imageTranscription.scaleX);
			imageTranscription.x =  _img_width+imageView.x;
		} else {
			imageMemory.scaleX = Math.abs(imageMemory.scaleX);
			imageTranscription.scaleX = Math.abs(imageTranscription.scaleX);
			
			imageTranscription.x = imageView.x;
		}
		/*
		if (viewPort.x < 0) viewPort.x = 0;
		if (viewPort.y < 0) viewPort.y = 0;
		if (imageLoader.width - viewPort.x < _img_width) viewPort.x = _width-imageLoader.width ;
		if (imageLoader.height - viewPort.y < _height) viewPort.y = _height - imageLoader.height ;
		*/
		//trace( "size:"+imageMemory.width + "x" + imageMemory.height);
		/*
		if (Math.abs(imageMemory.width) <= _img_width) {
			viewPort.x = -(_img_width - Math.abs(imageMemory.width)) / 4;
		}
		if (imageLoader.content.height <= _img_height) {
			viewPort.y = -(_img_height - imageMemory.height) / 4;
		}
		if (viewPort.y + imageLoader.content.height < _img_height) {
			viewPort.y = _img_height - imageMemory.height;
		}
		*/
		//trace("viewPort.x" + viewPort.x);
		//imageMemory = new BitmapData(Math.floor(initSize.x), Math.floor(initSize.y));
		//imageMemory.draw(imageLoader,new Matrix(1,0,0,1,viewPort.x,viewPort.y);
		imageView.bitmapData = new BitmapData(_img_width, _img_height);
		if (bInvers) {
			imageMemory.x = -viewPort.x-imageMemory.width;
		} else {
			imageMemory.x = -viewPort.x;
		}
		
		imageMemory.y = -viewPort.y;
		imageView.bitmapData.draw(imageMemory);// , new Matrix(1, 0, 0, 1, 0, 0));
		//trace("pos:"+ imageMemory.x + "x" + imageMemory.y);
		
	}
	private function onLoaderReady(e:Event):Void  {  
		//imageMemory = imageLoader.content;
		imageMemory.addChild(imageLoader.content);
		initSize = new Point(imageMemory.width, imageMemory.height);
		fitScale = Math.min(_img_width / imageLoader.width, _img_height / imageLoader.height);
		viewPort = new Rectangle(0, 0, _img_width, _img_height);
		trace(fitScale);
		scale = fitScale;
		viewPort.x = (imageLoader.content.width*scale-_img_width) / 2;
		viewPort.y = (imageLoader.content.height*scale-_img_height) / 2;
		updateImage();
		
		/*
		// pas de prise en charge des caracteres speciaux
		var format = new flash.text.TextFormat();
		format.font = "Calibri";
		var txt:TextField = new TextField();
		txt.defaultTextFormat = format;
		txt.selectable = false;
		txt.embedFonts = true;
		txt.htmlText="test";
		txt.y = imageLoader.height;
		addChild(txt);
		*/
		var fileRequest:URLRequest;
		imageView.addEventListener(MouseEvent.MOUSE_DOWN, evt_startDrag, false, 0, true);
		if (transcriptionMask != "") {
			imageLoader_transcriptionMask = new Loader();
			imageLoader_transcriptionMask.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderReady_transcriptionMask);
			fileRequest = new URLRequest(imgPath+transcriptionMask);
			imageLoader_transcriptionMask.load(fileRequest);
		}
		if (transcriptionOverlay != "") {
			imageLoader_transcriptionOverlay = new Loader();
			imageLoader_transcriptionOverlay.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderReady_transcriptionOverlay);
			fileRequest = new URLRequest(imgPath+transcriptionOverlay);
			imageLoader_transcriptionOverlay.load(fileRequest);
		}
	}
	var bmpD_transcriptionMask:BitmapData;
	var bmp_transcriptionMask:Bitmap;
	private function onLoaderReady_transcriptionMask(e:Event):Void  {  
		//imageMemory = imageLoader.content;
		
		
		bmpD_transcriptionMask = new BitmapData(Math.floor(imageLoader_transcriptionMask.content.width), Math.floor(imageLoader_transcriptionMask.content.height));
		bmpD_transcriptionMask.draw(imageLoader_transcriptionMask.content);
		bmp_transcriptionMask = new Bitmap(bmpD_transcriptionMask);
		var inter:Sprite = new Sprite();
		inter.addChild(bmp_transcriptionMask);
		inter.width = imageLoader.content.width;
		inter.scaleY = inter.scaleX;
		bmp_transcriptionMask.visible = false;
		imageMemory.addChild(inter);
		
	}
	private function onLoaderReady_transcriptionOverlay(e:Event):Void  {  
		//imageMemory = imageLoader.content;
		imageLoader_transcriptionOverlay.content.width = imageLoader.content.width;
		imageLoader_transcriptionOverlay.content.scaleY = imageLoader_transcriptionOverlay.content.scaleX;
		imageMemory.addChild(imageLoader_transcriptionOverlay.content);
		imageLoader_transcriptionOverlay.content.visible = false;
	}
	
	private function onLoaderReady_transItem(e:Event):Void {
		imageTranscription.buttonMode = true;
		imageTranscription.useHandCursor = true;
		imageTranscription.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, evtClickCloseTransItem, false, 1, true);
		var fitScale = Math.min(_img_width / loaderTrans.content.width, _img_height / loaderTrans.content.height);
		loaderTrans.content.scaleX = loaderTrans.content.scaleY = fitScale;
		loaderTrans.content.x = (_img_width - loaderTrans.content.width) / 2;
		loaderTrans.content.y = (_img_height - loaderTrans.content.height) / 2;
		var g = new Sprite();
		
		g.graphics.beginFill(0xcccccc, 0.5);
		g.graphics.drawRect(0, 0, _img_width, _img_height);
		g.graphics.endFill();
		var compo = new Sprite();
		compo.addChild(g);
		compo.addChild(loaderTrans.content);
		
		var bd = new BitmapData(_img_width, _img_height);
		bd.draw(compo);
		var bmp = new Bitmap(bd);
		
		imageTranscription.addChild(bmp);
		//imageTranscription.addChild(loaderTrans.content);
		
		
	}
	private function evtClickCloseTransItem(e:MouseEvent):Void {
		tryCloseTranItem();
	}
	private function tryCloseTranItem():Void {
		imageTranscription.graphics.clear();
		while (imageTranscription.numChildren > 0) {
			imageTranscription.removeChildAt(0);
		}
	}
	
	private function evt_startDrag(e:MouseEvent):Void {
		if (bTrans) {
			var p = bmp_transcriptionMask.globalToLocal(new Point(e.stageX-imageView.x, e.stageY-imageView.y));
			var posx = Math.floor(p.x);
			var posy =  Math.floor(p.y);
			
			var px = bmpD_transcriptionMask.getPixel(posx, posy);
			if (px != 0) {
				// zone de transcription trouvée
				for (transcription in transcriptions) {
					if (Std.parseInt(transcription.refColor) == px) {
						openTranscription(transcription);
						break;
					}
				}
				return;
			} 
			/*
			var rec = bmpD_transcriptionMask.getColorBoundsRect(0xFFFFFF, px);
			bmpD_transcriptionMask.setPixel(posx, posy, 0xFFFFFF);
			trace("px :" + StringTools.hex(px) + " " + posx + "x" + posy + " " + bmp_transcriptionMask.width + " " + bmp_transcriptionMask.height);
			trace("rec : " + rec.x+" "+rec.y+" "+rec.width+" "+rec.height);
			*/
		}
		this.addEventListener(MouseEvent.MOUSE_UP, evt_stopDrag, false, 0, true);
		this.addEventListener(MouseEvent.MOUSE_MOVE, evt_move, false, 0, true);
		//trace("evt_startDrag");
		//trace("evt_startDrag" + e.localX + " " + e.localY);
		lx = e.stageX;
		ly = e.stageY;
		if (!e.buttonDown) {
			evt_stopDrag(null);
		}
		updateImage();
	}
	private function evt_stopDrag(e:MouseEvent):Void {
		this.removeEventListener(MouseEvent.MOUSE_UP, evt_stopDrag);
		this.removeEventListener(MouseEvent.MOUSE_MOVE, evt_move);
		//trace("evt_stopDrage");
	}
	private var lx:Float;
	private var ly:Float;
	private function evt_move(e:MouseEvent):Void {
		var dx = lx - e.stageX;
		var dy = ly - e.stageY;
		lx = e.stageX;
		ly = e.stageY;
		viewPort.x += dx;
		viewPort.y += dy;
		
		
	//	trace("evt_move" + e.localX + " " + e.localY);
		if (!e.buttonDown) {
			evt_stopDrag(null);
		}
		updateImage();
		
	}
	
	private function evtClickPlus(e:MouseEvent):Void {
		tryCloseTranItem();
		scale += .1;
		
		updateImage();
		
	}
	private function evtClickMoins(e:MouseEvent):Void {
		tryCloseTranItem();
		scale-= .1;
		updateImage();
		
	}
	private var bInvers:Bool;
	private function evtClickInv(e:MouseEvent):Void {
		bInvers = !bInvers;
		updateImage();
	}
	private var bTrans:Bool;
	private function evtClickTrans(e:MouseEvent):Void {
		tryCloseTranItem();
		bTrans = !bTrans;
		imageLoader_transcriptionOverlay.content.visible = bTrans;
		bmp_transcriptionMask.visible = bTrans;
		updateImage();
		// TODO afficher du texte
	}
	private function evtClickIntro(e:MouseEvent):Void {
		writeTexte(introduction);
	}
	private function evtClickDesc(e:MouseEvent):Void {
		writeTexte(description);
	}
	
	
	private var loaderTrans:Loader;
	private function openTranscription(transcription:Dynamic):Void {
		trace(StringTools.hex(transcription.refColor) + " " + transcription.overlayImg + " " + transcription.overlayX + " " + transcription.overlayY);
			var px = Std.parseInt(transcription.refColor);
			//var rec = bmpD_transcriptionMask.getColorBoundsRect(0xFFFFFF, px);
			if (loaderTrans == null) {
				loaderTrans = new Loader();
				loaderTrans.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderReady_transItem);
			}
			var fileRequest = new URLRequest(imgPath+transcription.overlayImg);
			loaderTrans.load(fileRequest);
			writeTexte(transcription.texte);
			
	}
	private function writeTexte(texte:String) {
		var d = js.Lib.document.getElementById("haxe:texte");
		
			if( d != null )
				d.innerHTML = texte;
	}
	
	private function createBtn(name:String, posx, posy):DisplayObject {
		var imageLoader = new Loader();
		var fileRequest:URLRequest = new URLRequest("../img/"+name+".png");
		imageLoader.load(fileRequest);
		imageLoader.x = posx;
		imageLoader.y = posy;
		var s:MovieClip = new MovieClip();
		s.addChild(imageLoader);
		s.useHandCursor = true;
		return addChild(s);
	}
	private function createLabel(text:String, posx, posy):DisplayObject {
		var imageLoader = new TextField();
		//imageLoader.text = text;
		imageLoader.x = posx;
		imageLoader.y = posy;
		imageLoader.width = 75;
		imageLoader.htmlText = "<div ><strong>"+text+"</strong></div>";
		imageLoader.SetType(flash.text.TextFieldType.INPUT) ;
		
		imageLoader.text = text;
		return addChild(imageLoader);
	}
	
	static function main() 
	{
		
		
	}

	public static function setData(img:String,introduction:String,description:String,transcriptionMask:String,transcriptionOverlay:String,jstxt:String,imgPath:String,audio:String) {
		trace("setData");
		//js.Lib.alert(js.Lib.window.location.href);
		jstxt = jstxt.split("&#91;").join('[');
		var stage:Stage;
		var jsO = Json.parse(jstxt);
		
		
        
        var app = new Codex(img,introduction,description,transcriptionMask,transcriptionOverlay,jsO,imgPath,audio);
       
        Lib.current.stage.addChild( app );
		
		
		
	}
	
}