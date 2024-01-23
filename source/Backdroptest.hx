package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Timer;

using flixel.util.FlxSpriteUtil;

class Backdroptest extends MusicBeatState
{
	var coso:FlxBackdrop;

	override function create()
	{

		coso = new FlxBackdrop(X, -1170);
		coso.frames = Paths.getSparrowAtlas('Too_Late_Luigi_Hallway');
		coso.animation.addByPrefix('idle', "tll idle",   24, false);
		coso.animation.addByPrefix('up', "tll up", 	 24, false);
		coso.animation.addByPrefix('down', "tll down",   24, false);
		coso.animation.addByPrefix('left', "tll left",   24, false);
		coso.animation.addByPrefix('right', "tll right", 24, false);
		coso.animation.play('idle', true);
		coso.scrollFactor.set();
		coso.scale.set(0.4, 0.4);
		coso.updateHitbox();
		coso.antialiasing = true;
		coso.velocity.set(-1000, 0);
		coso.y = -50;
		add(coso);

		FlxG.mouse.visible = true;

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.NOTE_UP)
			{
				coso.animation.play('up', true);
				// coso.spacing.set(-216, 0);
				// coso.offset.x = 75;
				// coso.offset.y = 367;
			}
			else if (controls.NOTE_DOWN)
			{
				coso.animation.play('down', true);
				// coso.spacing.set(-124, 0);
				// coso.offset.x = 124;
				// coso.offset.y = -140;
			}

			if (controls.NOTE_LEFT)
			{
				coso.animation.play('left', true);
				// coso.spacing.set(-1196, 0);
				// coso.offset.x = 353;
				// coso.offset.y = -51;
			}
			else if (controls.NOTE_RIGHT)
			{
				coso.animation.play('right', true);
				// coso.spacing.set(-1016, 0);
				// coso.offset.x = -18;
				// coso.offset.y = 29;
			}

			if(coso.animation.curAnim.finished && coso.animation.curAnim.name != 'idle')
			{
				coso.animation.play('idle', true);
				// coso.spacing.set(0, 0);
				// coso.offset.x = 0;
				// coso.offset.y = 0;
			}

		if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}

		super.update(elapsed);
	}
}
