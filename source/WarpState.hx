package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import lime.utils.Assets;

using StringTools;

class WarpState extends MusicBeatState
{
	var tween:FlxTween;
	var tween2:FlxTween;
	var curSelected:Int = 0;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];

	private static var canciones:Array<Dynamic> = [ //Name, song name
		['World 2',		'i-hate-you'],
		['World 3',		'alone'],
		['World 4',		'apparition'],
		['World 5',		'powerdown'],
	];

	var bg:FlxSprite;
	var pibemapa:FlxSprite;
	var cartel:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	override function create()
	{
		FlxG.updateFramerate = PlayState.fpsthing;
		FlxG.drawFramerate = PlayState.fpsthing; 
		ClientPrefs.framerate = PlayState.fpsthing;
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Warp Zone", null);
		#end
		FlxG.sound.playMusic(Paths.music('warp theme'), 0.7);

		bg = new FlxSprite(800, 250).loadGraphic(Paths.image('warpworld/warpmap'));
		bg.setGraphicSize(Std.int(bg.width * 5));
		bg.antialiasing = false;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...canciones.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, canciones[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			//optionText.yMult = 90;
			optionText.targetY = i;
			//grpOptions.add(optionText);
		}

		cartel = new FlxSprite(570, 620).loadGraphic(Paths.image('warpworld/textwarp'));
		cartel.setGraphicSize(Std.int(cartel.width * 5));
		cartel.antialiasing = false;
		add(cartel);

		descText = new FlxText(50, 620, 1180, "", 32);
		descText.setFormat(Paths.font("mario2.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 4.4;
		add(descText);

		pibemapa = new FlxSprite(347, 316);
		pibemapa.frames = Paths.getSparrowAtlas('warpworld/mariomap');
		pibemapa.animation.addByPrefix('idle', "mario pose", 4);
		pibemapa.animation.play('idle');
		pibemapa.setGraphicSize(Std.int(pibemapa.width * 5));
		pibemapa.antialiasing = false;
		pibemapa.updateHitbox();
		add(pibemapa);

		changeSelection();
		super.create();
	}

	var quieto:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UI_LEFT_P;
		var downP = controls.UI_RIGHT_P;

        if(!quieto)
		{

		if (upP)
		{
			changeSelection(-1);
			caminar();
			quieto = true;
		}
		if (downP)
		{
			changeSelection(1);
			caminar();
			quieto = true;
		}
		if(controls.ACCEPT) {
			quieto = true;
			PlayState.isWarp = true;
			FlxG.sound.play(Paths.sound('gotolevel'));
			PlayState.SONG = Song.loadFromJson(canciones[curSelected][1], canciones[curSelected][1]);
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(0.55, function(tmr:FlxTimer)
			  {
				  LoadingState.loadAndSwitchState(new PlayState());
				  FlxG.sound.music.volume = 0;
				  FreeplayState.destroyFreeplayVocals();
			  });	
		}
	    }

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			PlayState.isWarp = false;
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
	      super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('bros3pass'), 1); //LO QUE HACE EL JUEGO ES MANDARTE AL I HATE YOU SI LO PONES EN 0, TEN EN CUENTA ESTO

		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = 0;
			if (curSelected >= canciones.length)
				curSelected = canciones.length - 1;

		} while(unselectableCheck(curSelected));

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}
		descText.text = canciones[curSelected][0];
	}
	
	private function unselectableCheck(num:Int):Bool {
		return canciones[num].length <= 0;
	}

	private function caminar()
	{
		switch(curSelected){
			case 0:
				tween = FlxTween.tween(pibemapa, {x: 347}, 0.2, {onComplete: function(twn:FlxTween)
					{
						quieto = false;
					}});
			case 1:
				tween = FlxTween.tween(pibemapa, {x: 507}, 0.2, {onComplete: function(twn:FlxTween)
					{
						quieto = false;
					}});
			case 2:
				tween = FlxTween.tween(pibemapa, {x: 667}, 0.2, {onComplete: function(twn:FlxTween)
					{
						quieto = false;
					}});
			case 3:
				tween = FlxTween.tween(pibemapa, {x: 827}, 0.2, {onComplete: function(twn:FlxTween)
					{
						quieto = false;
					}});
			case 4:
				tween = FlxTween.tween(pibemapa, {x: 987}, 0.2, {onComplete: function(twn:FlxTween)
					{
						quieto = false;
					}});
		  	case 5:
				tween = FlxTween.tween(pibemapa, {x: 1147}, 0.2, {onComplete: function(twn:FlxTween)
					{
						quieto = false;
					}});
		}
		do {

		} while(unselectableCheck(curSelected));
	}
}
