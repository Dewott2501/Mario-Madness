package;

import editors.ChartingState;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import math.Vector3;

using StringTools;

class Note extends FlxSprite
{
	public var vec3Cache:Vector3 = new Vector3(); // for vector3 operations in modchart code
	public var defScale:FlxPoint = FlxPoint.get(); // for modcharts to keep the scaling

	override function destroy()
	{
		defScale.put();
		super.destroy();
	}	
	public var typeOffsetX:Float = 0; // used to offset notes, mainly for note types. use in place of offset.x and offset.y when offsetting notetypes
	public var typeOffsetY:Float = 0;
	public var mAngle:Float = 0;
	public var bAngle:Float = 0;
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;

	private var earlyHitMult:Float = 0.5;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	// Lua shit
	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;

	public var botplaySkin:Bool = true;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;

	public var bullet:Bool = false;

	private function set_texture(value:String):String
	{
		if (texture != value)
		{
			reloadNote('', value);
		}
		texture = value;
		return value;
	}

	private function set_noteType(value:String):String
	{
		noteSplashTexture = PlayState.SONG.splashSkin;
		colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
		colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
		colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;

		if (PlayState.curStage == 'endstage' || (PlayState.curStage == 'landstage' && PlayState.SONG.song != 'Golden Land Old'))
		{
			colorSwap.saturation = -100;
		}

		if (noteData > -1 && noteType != value)
		{
			switch (value)
			{
				case 'Hurt Note':
					ignoreNote = mustPress;
					reloadNote('HURT');
					noteSplashTexture = 'HURTnoteSplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					if (isSustainNote)
					{
						missHealth = 0.1;
					}
					else
					{
						missHealth = 0.3;
					}
					hitCausesMiss = true;
					botplaySkin = false;

				case 'Nota veneno':
					ignoreNote = mustPress;
					reloadNote('poison');
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					hitCausesMiss = true;
					botplaySkin = false;

				case 'Ring Note':
					reloadNote('ring');
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					botplaySkin = false;

				case 'Nota boo':
					reloadNote('boo');

				case 'Coin Note':
					reloadNote('coin');
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					ignoreNote = mustPress;
					botplaySkin = false;

				case 'Water Note':
					reloadNote('water');
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					noAnimation = true;
					botplaySkin = false;

				case 'Nota bomba':
					ignoreNote = mustPress;
					reloadNote('bomb');
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					hitCausesMiss = true;
					botplaySkin = false;

				case 'Bullet':
					reloadNote('Bullet');
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					botplaySkin = false;

				case 'jumpscareM':
					ignoreNote = mustPress;
					reloadNote('JM');
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					hitCausesMiss = true;
					botplaySkin = false;

				case 'No Animation':
					noAnimation = true;

				case 'Bullet Bill':
					reloadNote('BulletBill');
					// ignoreNote = mustPress;
					noteSplashTexture = 'BulletBillMario_NOTE_assets';
					noAnimation = true;
					bullet = true;
					if(ClientPrefs.downScroll){
						flipY = true;
						offsetY -= height - 50;
					}
					// offsetX -= (Std.int(445/4));
					// offsetY += 10;
					offsetX -= 50;
					offsetY += 10;
					botplaySkin = false;
				case 'Yoshi Note':
					if (PlayState.curStage == 'exesequel' || PlayState.curStage == 'betamansion' || PlayState.curStage == 'nesbeat'){
						reloadNote('invisible');
						botplaySkin = false;
						// noteSplashTexture = 'invisibleMario_NOTE_assets';
					}
					
				case 'Bullet2':
					reloadNote('BulletBill');
					// ignoreNote = mustPress;
					noteSplashTexture = 'BulletBillMario_NOTE_assets';
					noAnimation = true;
					offsetX -= 163;
					offsetY += 10;
					botplaySkin = false;
					if(ClientPrefs.downScroll){
						flipY = true;
						offsetY -= height - 50;
					}
					
				case 'Bad Poison':
					reloadNote('bad');
					ignoreNote = mustPress;
					noAnimation = true;
					hitCausesMiss = true;
					botplaySkin = false;
			}
			noteType = value;
		}
		noteSplashHue = colorSwap.hue;
		noteSplashSat = colorSwap.saturation;
		noteSplashBrt = colorSwap.brightness;
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;

		x += (ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if (!inEditor)
			this.strumTime += ClientPrefs.noteOffset;

		this.noteData = noteData;

		if (noteData > -1)
		{
			texture = '';
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;

			x += swagWidth * (noteData % 4);
			if (!isSustainNote)
			{ // Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				if (noteType != 'Bullet Bill')
				switch (noteData % 4)
					{
						case 0:
							animToPlay = 'purple';
						case 1:
							animToPlay = 'blue';
						case 2:
							animToPlay = 'green';
						case 3:
							animToPlay = 'red';
					}
				else
				{
					animToPlay = 'bullet bill note';
				}
					
				animation.play(animToPlay + 'Scroll');
			}
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			if (PlayState.curStage != 'somari')
			{
				alpha = 0.6;
				multAlpha = 0.6;
			}

			offsetX += width / 2;
			copyAngle = false;

			switch (noteData)
			{
				case 0:
					animation.play('purpleholdend');
				case 1:
					animation.play('blueholdend');
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
			}
			
			defScale.copyFrom(scale);
			updateHitbox();

			offsetX -= width / 2;

			if (PlayState.isPixelStage){
				if(PlayState.curStage == 'virtual'){
					offsetX += ClientPrefs.downScroll ? -100 : 4;
				}
				else if(PlayState.curStage == 'piracy'){
					offsetX += ClientPrefs.downScroll ? -15 : 30;
				}
				else{
					offsetX += 30;
				}
			}


			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05 * PlayState.SONG.speed;
				if (PlayState.isPixelStage)
				{
					prevNote.scale.y *= 1.19;
				}
				prevNote.updateHitbox();
				prevNote.defScale.copyFrom(prevNote.scale);
				// prevNote.setGraphicSize();
			}

			if (PlayState.isPixelStage)
			{
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
		}
		else if (!isSustainNote)
		{
			earlyHitMult = 1;
		}
		defScale.copyFrom(scale);
		x += offsetX;
	}

	public function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '')
	{
		if (prefix == null)
			prefix = '';
		if (texture == null)
			texture = '';
		if (suffix == null)
			suffix = '';

		var skin:String = texture;
		if (texture.length < 1)
		{
			skin = PlayState.SONG.arrowSkin;
			if (skin == null || skin.length < 1)
			{
				skin = 'Mario_NOTE_assets';
			}
		}

		var animName:String = null;
		if (animation.curAnim != null)
		{
			animName = animation.curAnim.name;
		}

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length - 1] = prefix + arraySkin[arraySkin.length - 1] + suffix;

		var lastScaleY:Float = scale.y;
		var blahblah:String = arraySkin.join('/');

		if (PlayState.isPixelStage)
		{
			var pixelzoom:Float = PlayState.daPixelZoom;
			if (PlayState.curStage == 'virtual')
			{
				blahblah = "Virtual_NOTE_assets";
				pixelzoom = 3.5;
			}
			if (PlayState.curStage == 'landstage' && PlayState.SONG.song != 'Golden Land Old')
			{
				blahblah = "GB_NOTE_assets";
			}
			if (PlayState.curStage == 'somari')
			{
				blahblah = "NES_NOTE_assets";
			}
			if (PlayState.curStage == 'piracy')
				{
					blahblah = "DS_NOTE_assets";
					pixelzoom = 2.6;
				}

			if (isSustainNote)
			{
				loadGraphic(Paths.image('pixelUI/' + prefix + blahblah + 'ENDS'));
				width = width / 4;
				height = height / 2;
				loadGraphic(Paths.image('pixelUI/' + prefix + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
			}
			else
			{
				loadGraphic(Paths.image('pixelUI/' + prefix + blahblah));
				width = width / 4;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/' + prefix + blahblah), true, Math.floor(width), Math.floor(height));
			}

			setGraphicSize(Std.int(width * pixelzoom));
			loadPixelNoteAnims();
			antialiasing = false;
		}
		else
		{
			loadNoteAnims(blahblah);
			antialiasing = ClientPrefs.globalAntialiasing;
		}
		if (isSustainNote)
		{
			scale.y = lastScaleY;
		}
		defScale.copyFrom(scale);
		updateHitbox();

		if (animName != null)
			animation.play(animName, true);

		if (inEditor)
		{
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
	}

	public function loadNoteAnims(blahblah:String)
	{
		frames = Paths.getSparrowAtlas(blahblah);
		var loop:Bool = noteType == 'Bullet Bill';
		if(loop)
			trace('yes!!');

		animation.addByPrefix('greenScroll', 'green0', 30, loop);
		animation.addByPrefix('redScroll', 'red0', 30, loop);
		animation.addByPrefix('blueScroll', 'blue0', 30, loop);
		animation.addByPrefix('purpleScroll', 'purple0', 30, loop);

		if (isSustainNote)
		{
			animation.addByPrefix('purpleholdend', 'pruple end hold');
			animation.addByPrefix('greenholdend', 'green hold end');
			animation.addByPrefix('redholdend', 'red hold end');
			animation.addByPrefix('blueholdend', 'blue hold end');

			animation.addByPrefix('purplehold', 'purple hold piece');
			animation.addByPrefix('greenhold', 'green hold piece');
			animation.addByPrefix('redhold', 'red hold piece');
			animation.addByPrefix('bluehold', 'blue hold piece');
		}

		if(!bullet)
			setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	function loadPixelNoteAnims()
	{
		if (isSustainNote)
		{
			animation.add('purpleholdend', [PURP_NOTE + 4]);
			animation.add('greenholdend', [GREEN_NOTE + 4]);
			animation.add('redholdend', [RED_NOTE + 4]);
			animation.add('blueholdend', [BLUE_NOTE + 4]);

			animation.add('purplehold', [PURP_NOTE]);
			animation.add('greenhold', [GREEN_NOTE]);
			animation.add('redhold', [RED_NOTE]);
			animation.add('bluehold', [BLUE_NOTE]);
		}
		else
		{
			animation.add('greenScroll', [GREEN_NOTE + 4]);
			animation.add('redScroll', [RED_NOTE + 4]);
			animation.add('blueScroll', [BLUE_NOTE + 4]);
			animation.add('purpleScroll', [PURP_NOTE + 4]);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// ok river
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
