package ;


import com.eclecticdesignstudio.motion.actuators.GenericActuator;
import com.eclecticdesignstudio.motion.easing.Linear;
import com.eclecticdesignstudio.motion.easing.Quad;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import flash.net.URLRequest;
import flash.text.TextField;
import haxe.Json;
import jeash.media.Sound;
import jeash.media.SoundChannel;
import jeash.utils.Timer;
import flash.geom.Matrix;
import com.eclecticdesignstudio.motion.Actuate;




/**
 * ...
 * @author GuyF
 */

class Codex  extends Sprite
{
	private var image:Sprite ;
	public var image_transcriptionMask:DisplayObject;
	public var image_transcriptionOverlay:DisplayObject;
	
	private var imageView:Bitmap;
	
	
	public var introduction:String;
	public var description:String;
	public var audio:String;
	public var audioPath:String;
	public var introductionAudio :String;
	public var descriptionAudio :String;
	
	private var lang:String;
	private var inversion:Bool;
	public var img:String;
	public var transcriptionMask:String;
	public var transcriptionOverlay:String;
	public var imgPath:String;
	public var transcriptions:Array<Dynamic>;
	private var _width:Int ;
	private var _height:Int ;
	private var _img_width:Int;
	private var _img_height:Int;
	
	private var massLoad:MassLoader;
	
	private var tf:DivText;
	private var tResizer:Timer;
	

	private var margeLeft:Int;
	private var margeRight:Int;
	private var hauteurZoneTexte:Int;
	
	private var _scale:Float;
	public var scale(getScale, setScale):Float;
	
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
	function new (img:String,introduction:String,description:String,transcriptionMask:String,transcriptionOverlay:String,transcriptions:Array<Dynamic>,imgPath:String,introductionAudio:String,descriptionAudio:String,inversion:Bool,lang:String,audioPath:String): Void {
		super();
		
		//Modernizr.
		//browserhx.Browser.traceAgent();

		if (!Modernizr.canvas || (!Modernizr.audio.mp3 && !Modernizr.audio.ogg)) {
		
			trace('browser does not have canvas2d or audio');
			return;
		}
		margeLeft = 110;
		margeRight = 80;
		hauteurZoneTexte = 150;
		//_width = 800;
		//_height = 800;
		this.lang = lang;
		this.inversion = inversion;
		bTrans = false;
		bInvers = false;
		this.img = toJpg(img);
		this.transcriptionMask = transcriptionMask;
		this.transcriptionOverlay = toJpg(transcriptionOverlay);
		this.introduction = introduction;
		this.description = description;
		this.imgPath = imgPath;
		this.introductionAudio = introductionAudio;
		this.descriptionAudio = descriptionAudio;
		this.audioPath = audioPath + lang + "/";
		this.transcriptions = transcriptions;
		trace(stage.stageWidth+"x"+stage.stageHeight);
	//	stage.height = stage.height;
		tResizer = new Timer(100,1);
		tResizer.addEventListener(TimerEvent.TIMER_COMPLETE, evt_do_resize, false, 0, true);
		
		var tf:DivText = new DivText();
		
		tf.SetHTMLText("<div id='img_chargement'><span>CHARGEMENT...</span></div>");
		addChild(tf);
		
		massLoad = new MassLoader(tf);
		massLoad.add(imgPath + this.img);
		if (transcriptionMask!="") {
			massLoad.add(imgPath + this.transcriptionMask);
		}
		if (transcriptionOverlay!="") {
			massLoad.add(imgPath + this.transcriptionOverlay);
		}
		massLoad.add("../img/"+ lang+"_icones.png");
		
		
		
		massLoad.addEventListener("COMPLETE", evt_massLoad, false, 0, true);
		
		
		
		_height =  Math.floor(stage.stageHeight);
		_width =  Math.floor(stage.stageWidth);
		_img_width = _width - margeLeft - margeRight;
		_img_height = _height - hauteurZoneTexte;
		clearNoScript();
		massLoad.start();
		
		
		//this.stage.addEventListener(Event.RESIZE, evtResize, false, 0, true);
		//resize (Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		//Lib.current.stage.addEventListener (Event.RESIZE, stage_onResize);
	}
	
	private function toJpg(img:String) :String {
		return img.split(".png").join(".jpg");
	}
	public function evt_do_resize( e:Event ) :Void {
		tResizer.stop();
		massLoad.start();
	}
	 public function rootResized( e:Dynamic ) :Void {
		tResizer.stop();
		tResizer.reset();
		tResizer.start();
		
	
	 }
	private function resize (newWidth:Int, newHeight:Int):Void {
		trace("resize "+newWidth+"x"+newHeight);
	}
	private function evt_massLoad(e:Event):Void {
		trace("MASSLOAD COMPLET");
				var base = js.Lib.document.getElementById("VisualizerCodex");
		var basej = js.Lib.document.getElementById("haxe:jeash");
		
		//var w = base.clientWidth;
		var w = Math.floor(Math.min(js.Lib.window.innerWidth*93/100,1000*95/100));
	//	var h = Math.floor(Math.min(js.Lib.window.innerHeight*59/100,950));
		var h = Math.floor(js.Lib.window.innerHeight*65/100);
		Lib.canvas.width = w;
		Lib.canvas.height = h;
		 while(numChildren>0) {
			removeChildAt(0);
		 }
		_width =  w;
		_height =  h;
		_img_width = _width - margeLeft - margeRight;
		_img_height = _height - hauteurZoneTexte;

		prepareInterface();
	}
	private function stage_onResize (event:Event):Void {
		
		resize (stage.stageWidth, stage.stageHeight);
		
	}
	
	private function clearNoScript():Void {
		var bImage = js.Lib.document.getElementById("noscript");
		if (bImage == null) return;
		/*
		while (bImage.firstChild) {
			bImage.removeChild(bImage.firstChild);
			
		}
		*/
		var inlinejeash = js.Lib.document.getElementById("inline_jeash");
		//inlinejeash.style.height = '500px';
		trace("clearNoScript");
		bImage.style.visibility = "hidden";// Attribute("hidden", "true");
		bImage.setAttribute("hidden", "true");
		bImage.parentNode.removeChild(bImage);
		
	}
	private var iconesLoader:Loader;
	private function prepareInterface():Void {
		trace("prepareInterface");
		var inlinejeash = js.Lib.document.getElementById("inline_jeash");
		inlinejeash.style.height = ''+_height+'px';

		var g = new Sprite();
		
		g.graphics.beginFill(0x8C837E);
		g.graphics.drawRoundRect(0, 0, _width, _height,0,0);
		g.graphics.endFill();
		addChild(g);
		
		g = new Sprite();
		
		g.graphics.beginFill(0x756E6A);
		g.graphics.drawRoundRect(0, 0, _img_width, _img_height,0,0);
		g.graphics.endFill();
		g.x = margeLeft;
		addChild(g);
		
		imageTranscription = new Sprite();
		imageMemory = new Sprite();
		/*
		var bitmapData = new BitmapData(_img_width, _img_height);
		imageView = new Bitmap(bitmapData);
		*/
		
		
		imageView = new Bitmap(new BitmapData(_img_width, _img_height));
		imageView.x = margeLeft;
		imageTranscription.x = imageView.x;
		addChild(imageView);
		addChild(imageTranscription);
		onLoaderReady(null);
	}
	private var initSize:Point;
	private var fitScale:Float;
	private var viewPort:Rectangle;
	private var imageMemory:Sprite;
	private var imageTranscription:Sprite;
	
	
	private function setScale(val:Float):Float {
		_scale = val;
		updateImage();
		return _scale;
	}
	private function getScale():Float {
		return _scale;
	}
	
	private function updateImage():Void {
//		trace("viewPort:" + viewPort.x + "x" + viewPort.y);
		if (btn_trans!=null) {
			btn_trans.isSelected = bTrans;
		}
		
		
		if (image_transcriptionOverlay!=null &&  bmp_transcriptionMask!=null) {
			image_transcriptionOverlay.visible = bTrans;
			bmp_transcriptionMask.visible = bTrans;
			imageTranscription.graphics.clear();
				while (imageTranscription.numChildren > 0) {
					imageTranscription.removeChildAt(0);
				}
			if (bTrans) {
				
				if (currentTrans!=null) {
					openTranscription(currentTrans);
				}
			}
		}
			
		if (_scale < fitScale) {
			Actuate.stop (this, "scale");
			_scale = fitScale;
		}
		
		imageMemory.scaleX = imageMemory.scaleY = _scale;
		
		if (bInvers) {
			imageMemory.scaleX = -Math.abs(imageMemory.scaleX);
			imageTranscription.scaleX = -Math.abs(imageTranscription.scaleX);
			imageTranscription.x =  _img_width+imageView.x;
		} else {
			imageMemory.scaleX = Math.abs(imageMemory.scaleX);
			imageTranscription.scaleX = Math.abs(imageTranscription.scaleX);
			
			imageTranscription.x = imageView.x;
		}
		
		if (bInvers) {
			imageMemory.x = _img_width  - viewPort.x*_scale/(fitScale)-_img_width/2*(1-_scale/(fitScale));
		} else {
			imageMemory.x = -viewPort.x*_scale/(fitScale)+_img_width/2*(1-_scale/(fitScale));
		}
		
		imageMemory.y = -viewPort.y*  _scale / (fitScale) + _img_height / 2 * (1 - _scale / (fitScale));
		
		
		
		imageView.bitmapData.fillRect(new Rectangle(0, 0, _img_width, _img_height), 0);
		imageView.bitmapData.draw(imageMemory);// , new Matrix(1, 0, 0, 1, 0, 0));
		
		
	}
	private var imageContent:DisplayObject;
	private function onLoaderReady(e:Event):Void  {  
		
		 js.Lib.window.onresize = rootResized;
		//imageMemory = imageLoader.content;
		imageContent = massLoad.get(imgPath + img);
		imageMemory.addChild(imageContent);
		initSize = new Point(imageMemory.width, imageMemory.height);
		fitScale = Math.min(_img_width / imageContent.width, _img_height / imageContent.height);
		viewPort = new Rectangle(0, 0, _img_width, _img_height);
		trace(fitScale);
		_scale = fitScale;
		viewPort.x = (imageContent.width*_scale-_img_width) / 2;
		viewPort.y = (imageContent.height*_scale-_img_height) / 2;
		imageView.addEventListener(MouseEvent.MOUSE_DOWN, evt_startDrag, false, 0, true);
		
		
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
		
		if (transcriptionMask != "") {
			onLoaderReady_transcriptionMask(imgPath+transcriptionMask);
			
		}
		if (transcriptionOverlay != "") {
			
			onLoaderReady_transcriptionOverlay(imgPath + transcriptionOverlay);
		}
		onLoaderIconesReady("../img/"+lang+"_icones.png");
		
		trace("iconesLoader.onLoaderIconesReady");
		
	}
	
	private var btn_intro:BtnSelect;
	private var btn_desc:BtnSelect;
	private var btn_invers:BtnSelect;
	private var btn_trans:BtnSelect;
	private var btn_plus:BtnOver;
	private var btn_moins:BtnOver;
	private var btn_son:BtnSelect;
	
	private function onLoaderIconesReady(path:String) {
		trace("onLoaderIconesReady");
		
		var bitmapData = new BitmapData(Math.floor(massLoad.get(path).width), Math.floor(massLoad.get(path).height));
		bitmapData.draw(massLoad.get(path));
		
		
		
		
		var iL:Int = 0;
		btn_intro = createBtn(bitmapData, 0, 0, iL * margeLeft);
		iL++;
		btn_intro.addEventListener(flash.events.MouseEvent.CLICK, evtClickIntro, false, 1, true);
		btn_desc = createBtn(bitmapData, 1, 0, iL * margeLeft);
		iL++;
		btn_desc.addEventListener(flash.events.MouseEvent.CLICK, evtClickDesc, false, 1, true);
		if (inversion) {
			btn_invers = createBtn(bitmapData, 2, 0, iL * margeLeft);
			iL++;
			btn_invers.addEventListener(flash.events.MouseEvent.CLICK, evtClickInv, false, 1, true);
		}
		
		if (image_transcriptionOverlay!=null) {
			btn_trans = createBtn(bitmapData, 3, 0, iL * margeLeft);
			iL++;
			btn_trans.addEventListener(flash.events.MouseEvent.CLICK, evtClickTrans, false, 1, true);
		}
		
		btn_son = createBtnXY(bitmapData,4 , _img_width+margeLeft, 0);
		btn_son.addEventListener(flash.events.MouseEvent.CLICK, evtClickSon, false, 1, true);
		
		var bzoom:Bitmap = new Bitmap();
		bzoom.bitmapData =	helper_getBmpXY(bitmapData, 0, 740, margeRight, 130);
		bzoom.x = _img_width + margeLeft;
		bzoom.y = 130;
		
		addChild(bzoom);
		btn_plus = createBtnOver(bitmapData,5 , _img_width + margeLeft, 140);
		btn_plus.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, evtClickPlus, false, 1, true);
		
		btn_moins = createBtnOver(bitmapData,6 , _img_width+margeLeft, 200);
		btn_moins.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, evtClickMoins, false, 1, true);
		
		
		
		tf = new DivText();
		tf.y = _img_height + 20;
		addChild(tf);
		//updateImage();
		evtClickDesc(null);
	}

	
	
	var bmpD_transcriptionMask:BitmapData;
	var bmp_transcriptionMask:Bitmap;
	private function onLoaderReady_transcriptionMask(path:String):Void  {  
		//imageMemory = imageLoader.content;
		var image = massLoad.get(path);
		
		bmpD_transcriptionMask = new BitmapData(Math.floor(image.width), Math.floor(image.height));
		bmpD_transcriptionMask.draw(image);
		bmp_transcriptionMask = new Bitmap(bmpD_transcriptionMask);
		var inter:Sprite = new Sprite();
		inter.addChild(bmp_transcriptionMask);
		inter.width = imageContent.width;
		inter.scaleY = inter.scaleX;
		bmp_transcriptionMask.visible = false;
		imageMemory.addChild(inter);
		
	}
	private function onLoaderReady_transcriptionOverlay(path:String):Void  {  
		//imageMemory = imageLoader.content;
		image_transcriptionOverlay = massLoad.get(path);
		image_transcriptionOverlay.width = imageContent.width;
		image_transcriptionOverlay.scaleY = image_transcriptionOverlay.scaleX;
		imageMemory.addChild(image_transcriptionOverlay);
		image_transcriptionOverlay.visible = false;
	}
	
	private function onLoaderReady_transItem(e:Event):Void {
		imageTranscription.buttonMode = true;
		imageTranscription.useHandCursor = true;
		imageTranscription.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, evtClickCloseTransItem, false, 1, true);
		var fitScale = Math.min(_img_width / loaderTrans.content.width, _img_height / loaderTrans.content.height);
		loaderTrans.content.scaleX = loaderTrans.content.scaleY = Math.min(fitScale,1);
		loaderTrans.content.x = (_img_width - loaderTrans.content.width) / 2;
		loaderTrans.content.y = (_img_height - loaderTrans.content.height) / 2;
		var g = new Sprite();
		
		g.graphics.beginFill(0x000000, 0.3);
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
	public override function jeashRender(parentMatrix:Matrix, ?inMask:Html5Dom.HTMLCanvasElement) {
		try{
			super.jeashRender(parentMatrix, inMask);
		}catch (e:Dynamic) {
			
		}
		
	
	}
	
	private function evtClickCloseTransItem(e:MouseEvent):Void {
		currentTrans = null;
		updateImage();
		
	}
	private function tryCloseTranItem():Void {
		currentTrans = null;
		updateImage();
	}
	var currentTrans:Dynamic;
	private function evt_startDrag(e:MouseEvent):Void {
		if (bTrans) {
			trace("codex pos :" + this.x + " " + this.y);
			var p = bmp_transcriptionMask.globalToLocal(new Point(e.stageX-imageView.x, e.stageY-imageView.y));
			var posx = Math.floor(p.x);
			var posy =  Math.floor(p.y);
			trace("clic pos :" + posx + " " + posy);
			var px = bmpD_transcriptionMask.getPixel(posx, posy);
			if (px != 0) {
				// zone de transcription trouvée
				for (transcription in transcriptions) {
					if (Std.parseInt(transcription.refColor) == px) {
						currentTrans = transcription;
						updateImage();
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
	private function continuePlus() {
		if (btn_plus.isSelected) {
			Actuate.tween (this, 0.3, { scale: scale * 1.1 } ).onComplete (continuePlus).ease (Linear.easeNone);
		}
	}
	private function continueMoins() {
		if (btn_moins.isSelected) {
			Actuate.tween (this, 0.3, { scale: scale * 0.9 } ).onComplete (continueMoins).ease (Linear.easeNone);
		}
	}
	
	private function evtClickPlus(e:MouseEvent):Void {
		Actuate.stop (this, "scale");
		tryCloseTranItem();
		//_scale += .1*fitScale;
		Actuate.tween (this, 0.3, { scale: scale*1.1 } ).onComplete (continuePlus).ease (Quad.easeIn);
		//updateImage();
		
	}
	private function evtClickMoins(e:MouseEvent):Void {
		Actuate.stop (this, "scale");
		currentTrans = null;
		//_scale-= .1*fitScale;
		//updateImage();
		 Actuate.tween (this, 0.3, { scale: scale*0.9 } ).onComplete (continueMoins).ease (Quad.easeIn);
		
	}
	private var bInvers:Bool;
	private function evtClickInv(e:MouseEvent):Void {
		bInvers = !bInvers;
		btn_invers.isSelected = bInvers;
		viewPort.x = -viewPort.x;
		updateImage();
	}
	private var bTrans:Bool;
	private function evtClickTrans(e:MouseEvent):Void {
		currentTrans = null;
		bTrans = !bTrans;
		
		writeTexte("");
		updateImage();
		btn_intro.isSelected = false;
		btn_desc.isSelected = false;
		// TODO afficher du texte
	}
	private function evtClickIntro(e:MouseEvent):Void {
		bTrans = false;
		audio = introductionAudio;
		evtSoundComplet(null);
		btn_intro.isSelected = true;
		btn_desc.isSelected = false;
		
		writeTexte(introduction);
		currentTrans = null;
		updateImage();
		
	}
	private function evtClickDesc(e:MouseEvent):Void {
		bTrans = false;
		audio = descriptionAudio;
		evtSoundComplet(null);
		btn_desc.isSelected = true;
		btn_intro.isSelected = false;
		
		writeTexte(description);
		currentTrans = null;
		updateImage();
		
	}
	
	private var sh:SoundChannel;
	private function evtClickSon(e:MouseEvent):Void {
		if (sh!=null) {
			sh.stop();
			sh = null;
			btn_son.isSelected = false;
			return;
		}
		var s:Sound ;
		if (Sound.jeashCanPlayType("mp3")) {
			s = new Sound(new URLRequest(audioPath+audio+".mp3"));
			sh = s.play();
			btn_son.isSelected = true;
		} else if (Sound.jeashCanPlayType("ogg")) {
			s = new Sound(new URLRequest(audioPath+audio+".ogg"));
			sh = s.play();
			btn_son.isSelected = true;
		}
		sh.addEventListener(Event.COMPLETE, evtSoundComplet,false,0,true);
		
		
		
		
	}
	private function evtSoundComplet(e:Event) {
		if (sh!=null) {
			sh.stop();
			sh = null;
			btn_son.isSelected = false;
			return;
		}
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
			var fileRequest = new URLRequest(imgPath+toJpg(transcription.overlayImg));
			loaderTrans.load(fileRequest);
			writeTexte(transcription.texte);
			evtSoundComplet(null);
			audio = transcription.audio;
			
	}
	private function writeTexte(texte:String) {
		tf.name = "texte";
		
		
		tf.SetHTMLText("<div id='text_codex'>"+texte+"</div>");
		/*
		var d = js.Lib.document.getElementById("haxe:texte");
		
			if( d != null )
				d.innerHTML = texte;
				*/
	}
	
	private function helper_getBmp(bitmapData:BitmapData,w:Int,h:Int,i:Int,j:Int):BitmapData {
		var _bitmapData = new BitmapData(w, h);
		var rec:Rectangle = new Rectangle(i * w, j * h,  w, h);
		trace(rec);
		_bitmapData.copyPixels(bitmapData, rec, new Point());
		return _bitmapData;
	}
	private function helper_getBmpXY(bitmapData:BitmapData, x:Int, y:Int, w:Int, h:Int):BitmapData {
		var _bitmapData = new BitmapData(w, h);
		var rec:Rectangle = new Rectangle(x, y,  w, h);
		trace(rec);
		_bitmapData.copyPixels(bitmapData, rec, new Point());
		return _bitmapData;
	}
	private function createBtn(bitmapData:BitmapData,index:Int, posx, posy):BtnSelect {
		var s:BtnSelect = new BtnSelect(
			helper_getBmp(bitmapData, margeLeft, margeLeft, 0, index),
			helper_getBmp(bitmapData, margeLeft, margeLeft, 1, index),
			helper_getBmp(bitmapData, margeLeft, margeLeft, 2, index)
			);
		
		s.x = posx;
		s.y = posy;
		s.useHandCursor = true;
		addChild(s);
		return s;
	}
	private function createBtnXY(bitmapData:BitmapData,index:Int, posx, posy):BtnSelect {
		var s:BtnSelect = new BtnSelect(
			helper_getBmpXY(bitmapData, 0 * margeLeft, index * margeLeft, margeRight, 50),
			helper_getBmpXY(bitmapData, 1 * margeLeft, index * margeLeft, margeRight, 50),
			helper_getBmpXY(bitmapData, 2 * margeLeft, index * margeLeft, margeRight, 50)
		);
	
		s.x = posx;
		s.y = posy;
		s.useHandCursor = true;
		addChild(s);
		return s;
	}
	
	private function createBtnOver(bitmapData:BitmapData,index:Int, posx, posy):BtnOver {
		var s:BtnOver = new BtnOver(
			helper_getBmpXY(bitmapData, 0 * margeLeft, index * margeLeft, margeRight, 50),
			helper_getBmpXY(bitmapData, 1 * margeLeft, index * margeLeft, margeRight, 50),
			helper_getBmpXY(bitmapData, 2 * margeLeft, index * margeLeft, margeRight, 50)
		);
	
		s.x = posx;
		s.y = posy;
		s.useHandCursor = true;
		addChild(s);
		return s;
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
		
		//Lib.current.stage.backgroundColor = 0xFF0000;
		setData(null, null, null, null, null, null, null, null,null,null,null,null);
	}
	

	public static function setData(img:String, introduction:String, description:String, transcriptionMask:String, transcriptionOverlay:String, jstxt:String, imgPath:String, introductionAudio:String, descriptionAudio:String, inversion:Bool, lang:String, audioPath:String) {
		
		if (img == null) {
			return;
		}
		Lib.current.graphics.clear();
		trace("setData");
		//js.Lib.alert(js.Lib.window.location.href);
		jstxt = jstxt.split("&#91;").join('[');
		
		var jsO = Json.parse(jstxt);
		
		Lib.current.stage.jeashSetBackgroundColour(0xFFFF00);
        
        var app = new Codex(img,introduction,description,transcriptionMask,transcriptionOverlay,jsO,imgPath,introductionAudio,descriptionAudio,inversion,lang,audioPath);
       
        Lib.current.stage.addChild( app );
		
		
		
	}
	
}