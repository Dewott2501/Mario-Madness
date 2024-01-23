package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import math.*;

using StringTools;

class StrumNote extends FlxSprite
{
	public var vec3Cache:Vector3 = new Vector3(); // for vector3 operations in modchart code
	public var defScale:FlxPoint = FlxPoint.get(); // for modcharts to keep the scaling

	override function destroy()
	{
		defScale.put();
		super.destroy();
	}	
	public var sustainReduce:Bool = true;
	private var colorSwap:ColorSwap;

	public var resetAnim:Float = 0;

	public var noteData:Int = 0;

	private var player:Int;

	private var initWidth:Float;

	public function new(x:Float, y:Float, leData:Int, player:Int)
	{
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);

		var skin:String = 'Mario_NOTE_assets';
		if (PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1)
			skin = PlayState.SONG.arrowSkin;

		if (PlayState.isPixelStage)
		{
			var pixelzoom:Float = PlayState.daPixelZoom;
			if (PlayState.curStage == 'landstage' && PlayState.SONG.song != 'Golden Land Old')
			{
				loadGraphic(Paths.image('pixelUI/GB_NOTE_assets'));
				width = width / 4;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/GB_NOTE_assets'), true, Math.floor(width), Math.floor(height));
			}
			else if (PlayState.curStage == 'virtual')
			{
				pixelzoom = 3.5;
				loadGraphic(Paths.image('pixelUI/Virtual_NOTE_assets'));
				width = width / 4;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/Virtual_NOTE_assets'), true, Math.floor(width), Math.floor(height));
			}
			else if (PlayState.curStage == 'somari')
			{
				loadGraphic(Paths.image('pixelUI/NES_NOTE_assets'));
				width = width / 4;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/NES_NOTE_assets'), true, Math.floor(width), Math.floor(height));
			}
			else if (PlayState.curStage == 'piracy')
				{
					pixelzoom = 2.6;
					loadGraphic(Paths.image('pixelUI/DS_NOTE_assets'));
					width = width / 4;
					height = height / 5;
					loadGraphic(Paths.image('pixelUI/DS_NOTE_assets'), true, Math.floor(width), Math.floor(height));
				}
			else
			{
				loadGraphic(Paths.image('pixelUI/' + skin));
				width = width / 4;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/' + skin), true, Math.floor(width), Math.floor(height));
			}
			animation.add('green', [6]);
			animation.add('red', [7]);
			animation.add('blue', [5]);
			animation.add('purple', [4]);

			antialiasing = false;
			setGraphicSize(Std.int(width * pixelzoom));

			switch (Math.abs(leData))
			{
				case 0:
					animation.add('static', [0]);
					animation.add('pressed', [8], 12, false);
					animation.add('confirm', [12, 16], 24, false);
				case 1:
					animation.add('static', [1]);
					animation.add('pressed', [9], 12, false);
					animation.add('confirm', [13, 17], 24, false);
				case 2:
					animation.add('static', [2]);
					animation.add('pressed', [10], 12, false);
					animation.add('confirm', [14, 18], 12, false);
				case 3:
					animation.add('static', [3]);
					animation.add('pressed', [11], 12, false);
					animation.add('confirm', [15, 19], 24, false);
			}
		}
		else
		{
			updateNoteSkin(skin);
		}
		defScale.copyFrom(scale);

		updateHitbox();
		scrollFactor.set();
	}

	public function updateNoteSkin(skin:String){
		this.frames = Paths.getSparrowAtlas(skin);
		this.animation.addByPrefix('green', 'arrowUP');
		this.animation.addByPrefix('blue', 'arrowDOWN');
		this.animation.addByPrefix('purple', 'arrowLEFT');
		this.animation.addByPrefix('red', 'arrowRIGHT');

		this.antialiasing = ClientPrefs.globalAntialiasing;
		setGraphicSize(Std.int(width * 0.7));

		switch (Math.abs(noteData))
		{
			case 0:
				this.animation.addByPrefix('static', 'arrowLEFT');
				this.animation.addByPrefix('pressed', 'left press', 24, false);
				this.animation.addByPrefix('confirm', 'left confirm', 24, false);
			case 1:
				this.animation.addByPrefix('static', 'arrowDOWN');
				this.animation.addByPrefix('pressed', 'down press', 24, false);
				this.animation.addByPrefix('confirm', 'down confirm', 24, false);
			case 2:
				this.animation.addByPrefix('static', 'arrowUP');
				this.animation.addByPrefix('pressed', 'up press', 24, false);
				this.animation.addByPrefix('confirm', 'up confirm', 24, false);
			case 3:
				this.animation.addByPrefix('static', 'arrowRIGHT');
				this.animation.addByPrefix('pressed', 'right press', 24, false);
				this.animation.addByPrefix('confirm', 'right confirm', 24, false);
		}
		updateHitbox();
		playAnim('static');
	}

	public function postAddedToGroup()
	{
		playAnim('static');
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
		ID = noteData;
	}

	override function update(elapsed:Float)
	{
		if (resetAnim > 0)
		{
			resetAnim -= elapsed;
			if (resetAnim <= 0)
			{
				playAnim('static');
				resetAnim = 0;
			}
		}

		/*if(animation.curAnim.name == 'confirm' && !PlayState.isPixelStage) {
			updateConfirmOffset();
		}*/

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false)
	{
		animation.play(anim, force);
		centerOffsets();
		if (animation.curAnim == null || animation.curAnim.name == 'static')
		{
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
		}
		else
		{
			colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;

			if (animation.curAnim.name == 'confirm' && !PlayState.isPixelStage)
			{
				updateConfirmOffset();
			}
			if (animation.curAnim.name == 'pressed' && !PlayState.isPixelStage)
			{
				updatePressedOffset();
			}
		}

		if (PlayState.curStage == 'endstage')
		{
			colorSwap.saturation = -100;
		}
	}

	function updateConfirmOffset()
	{ // TO DO: Find a calc to make the offset work fine on other angles
		centerOffsets();
		// offset.x -= 7;
		// offset.y -= 7;
	}

	function updatePressedOffset()
	{ // TO DO: Find a calc to make the offset work fine on other angles
		centerOffsets();
		// offset.x += 7;
		// offset.y += 7;
	}
}
