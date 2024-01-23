package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnImg:FlxSprite;

	override function create()
	{
		super.create();

		warnImg = new FlxSprite().loadGraphic(Paths.image("warningscreen"));
		warnImg.antialiasing = false;
		warnImg.updateHitbox();
		warnImg.screenCenter();
		add(warnImg);

		
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
