package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import lime.utils.Assets;

using StringTools;

class CustomFreeplayState extends MusicBeatState
{
	var tween:FlxTween;
	var tween2:FlxTween;
	private static var curSelected:Int = 0;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	
	private var iconArray:Array<AttachedSprite> = [];
	private static var canciones:Array<Dynamic> = [];

	private static var canciones0:Array<Dynamic> = [
		['Its a me',		'its-a-me',         '1'],
		['Golden Land',		'golden-land',      '2']
	];

	private static var canciones1:Array<Dynamic> = [
		['Its a me',		'its-a-me', '1'],
		['Golden Land',		'golden-land', '2'],
		['I Hate You',		'i-hate-you', '3'],
		['Powerdown',		'powerdown', '4'],
		['Apparition',		'apparition', '5'],
		['Alone',		'alone', '6'],
		['???',		'racetraitors', '0']
	];

	private static var canciones2:Array<Dynamic> = [ 
		['Its a me',		'its-a-me', '1'],
		['Golden Land',		'golden-land', '2'],
		['I Hate You',		'i-hate-you', '3'],
		['Powerdown',		'powerdown', '4'],
		['Apparition',		'apparition', '5'],
		['Alone',		'alone', '6'],
		['Race-traitors',		'racetraitors', '7']
	];

	var fuck:Int = 1;
	var obo:Bool = false;

	var boxgrp:FlxTypedSpriteGroup<FlxSprite>;

	var bg:FlxSprite;
	var cartel:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var estatica:FlxSprite;

	override function create()
	{
		FlxG.updateFramerate = PlayState.fpsthing;
		FlxG.drawFramerate = PlayState.fpsthing; 
		ClientPrefs.framerate = PlayState.fpsthing;
		
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In Freeplay", null);
		#end

		if (!FlxG.sound.music.playing)
			{	
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}

		bg = new FlxSprite(0, 0).loadGraphic(Paths.image('modstuff/freeplay/HUD_Freeplay_2'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.updateHitbox();
		bg.screenCenter(XY);
		add(bg);

		estatica = new FlxSprite();
		estatica.frames = Paths.getSparrowAtlas('modstuff/estatica_uwu');
		estatica.animation.addByPrefix('idle', "Estatica papu", 15);
		estatica.animation.play('idle');
		estatica.antialiasing = false;
		estatica.alpha = 0.3;
		estatica.scrollFactor.set();
		estatica.updateHitbox();
		add(estatica);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		if (ClientPrefs.iHYPass && ClientPrefs.mXPass && ClientPrefs.warioPass && ClientPrefs.betaPass && !ClientPrefs.carPass)
			{
				canciones = canciones1;
			}

		else if (ClientPrefs.iHYPass && ClientPrefs.mXPass && ClientPrefs.warioPass && ClientPrefs.betaPass && ClientPrefs.carPass)
			{
				canciones = canciones2;
			}
        else
			{
				canciones = canciones0;
			}

		boxgrp = new FlxTypedSpriteGroup<FlxSprite>();
				for (i in 0...canciones.length)
				{
	
					var char:FlxSprite = new FlxSprite(420 * fuck , 100).loadGraphic(Paths.image('modstuff/freeplay/charicon/Char' + canciones[i][2]));
					boxgrp.add(char);

					fuck += 1;
					
				}
		add(boxgrp);


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

		cartel = new FlxSprite(0, 20).loadGraphic(Paths.image('modstuff/freeplay/HUD_Freeplay_1'));
		cartel.updateHitbox();
		cartel.screenCenter(X);
		cartel.antialiasing = ClientPrefs.globalAntialiasing;
		add(cartel);
		tween = FlxTween.tween(cartel, {y: 0}, 3, {ease: FlxEase.quadInOut, type: PINGPONG});

		descText = new FlxText(50, 620, 1180, "", 32);
		descText.setFormat(Paths.font("Mario64.ttf"), 32, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.updateHitbox();
		descText.screenCenter(X);
		descText.borderSize = 4.4;
		add(descText);

		changeSelection();
		super.create();
	}

	var quieto:Bool = false;

	override function update(elapsed:Float)
	{
		if(!obo)
			{
				caminar();
				obo = true;
			}
		estatica.animation.play('idle');

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
			tween.cancel();
			FlxG.sound.music.volume = 0;
			PlayState.SONG = Song.loadFromJson(canciones[curSelected][1], canciones[curSelected][1]);
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			LoadingState.loadAndSwitchState(new PlayState());
			FlxG.sound.music.volume = 0;
			FreeplayState.destroyFreeplayVocals();
			  };
	    }

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
	      super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 1); 

		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = canciones.length - 1;
			if (curSelected >= canciones.length)
				curSelected = 0;

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
		tween = FlxTween.tween(boxgrp, {x: 0 - curSelected*420}, 0.2, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
		{
			quieto = false;
		}});
		
		do {

		} while(unselectableCheck(curSelected));
	}
}
