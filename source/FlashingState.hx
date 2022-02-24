package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;
	public static var warningmario:Bool = false;
	public static var segundaPan:Bool = false;

    var warnImg:FlxSprite;
	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnImg = new FlxSprite().loadGraphic(Paths.image('modstuff/warning'));
		warnImg.screenCenter();
		warnImg.alpha = 0;
		add(warnImg);

		warnText = new FlxText(0, 0, FlxG.width,
			"Hey, watch out!\n
			This Mod contains some flashing lights!\n
			Press ENTER to disable them now or go to Options Menu.\n
			Press ESCAPE to ignore this message.\n
			(by deactivating it some game-enhancing effects will not be seen).\n
			You've been warned!",
			32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var back:Bool = controls.BACK;
			if(!segundaPan){
			if (controls.ACCEPT || back) {
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if(!back) {
					ClientPrefs.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							segundaPan = true;
							FlxTween.tween(warnImg, {alpha: 1}, 0.5);
							FlxTween.tween(warnText, {alpha: 0}, 1);
						});
					});
				} else {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(warnText, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
							segundaPan = true;
							FlxTween.tween(warnImg, {alpha: 1}, 0.5);
							//MusicBeatState.switchState(new TitleState());
						}
					});
				}
			}
		  }
		  else{
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
			leftState = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxTween.tween(warnImg, {alpha: 0}, 0.5, {onComplete: function (twn:FlxTween) {
				new FlxTimer().start(2, function (tmr:FlxTimer) {
					MusicBeatState.switchState(new TitleState());
				});	
	        }});
	     }}
		}
		super.update(elapsed);
	}
}
