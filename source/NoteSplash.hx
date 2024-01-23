package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;

	private var idleAnim:String;
	private var textureLoaded:String = null;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0)
	{
		super(x, y);

		var skin:String = 'noteSplashes';
		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
			skin = PlayState.SONG.splashSkin;

		loadAnims(skin);

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0)
	{
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 0.6;
		if(texture == 'BulletBillMario_NOTE_assets'){
			// setPosition((x - 455 * 0.95) - (112 * 0.5), (y - Note.swagWidth) + (942 * -0.5));
			if (!ClientPrefs.downScroll){
				setPosition(x - 370, y - 340);
				alpha = 1;
			}
			else{
				setPosition(x - 370, y - 620);
				flipY = true;
				alpha = 1;
			}
		}

		if (texture == null)
		{
			texture = 'noteSplashes';
			if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
				texture = PlayState.SONG.splashSkin;
		}

		if (textureLoaded != texture)
		{
			loadAnims(texture);
		}
		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
		offset.set(10, 10);

		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	function loadAnims(skin:String)
	{
		if (PlayState.curStage == 'somari')
		{
			loadGraphic(Paths.image('pixelUI/splash-NES'));
			width = width / 4;
			height = height / 4;
			loadGraphic(Paths.image('pixelUI/splash-NES'), true, Math.floor(width), Math.floor(height));
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			antialiasing = false;
		}
		else
		{
			frames = Paths.getSparrowAtlas(skin);
		}
		if (PlayState.curStage == 'virtual')
		{
			for (i in 1...3)
			{
				animation.addByPrefix("note1-" + i, "note splash red " + i, 24, false);
				animation.addByPrefix("note2-" + i, "note splash red " + i, 24, false);
				animation.addByPrefix("note0-" + i, "note splash red " + i, 24, false);
				animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
			}
		}
		else if (PlayState.curStage == 'somari')
		{
			for (i in 1...3)
			{
				animation.add("note1-" + i, [1, 5, 9, 13], 24, false);
				animation.add("note2-" + i, [2, 6, 10, 14], 24, false);
				animation.add("note0-" + i, [0, 4, 8, 12], 24, false);
				animation.add("note3-" + i, [3, 7, 11, 15], 24, false);
			}
		}
		else if (skin == 'BulletBillMario_NOTE_assets'){
			for(i in 1...3){
				animation.addByPrefix("note1-" + i, "notesplash", 24, false);
				animation.addByPrefix("note2-" + i, "notesplash", 24, false);
				animation.addByPrefix("note0-" + i, "notesplash", 24, false);
				animation.addByPrefix("note3-" + i, "notesplash", 24, false);
			}
		}
		else
			for (i in 1...3)
			{
				animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
				animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
				animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
				animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
			}
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}
}
