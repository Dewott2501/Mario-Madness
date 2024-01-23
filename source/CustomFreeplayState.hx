package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.NumTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.utils.Assets;
import openfl.Lib;
import openfl.filters.ShaderFilter;

using StringTools;

class CustomFreeplayState extends MusicBeatSubstate
{
	var options:Array<String> = ['Mainweek', 'Island', 'Woodland', 'Cosmos', 'Heights', 'Classified', 'Legacy', 'Extra'];
	public static var canciones:Array<Dynamic> = [];
	var opValid:Array<Bool> = [ClientPrefs.storySave[0], ClientPrefs.storySave[1], ClientPrefs.storySave[2], ClientPrefs.storySave[3], ClientPrefs.storySave[4], ClientPrefs.storySave[5], ClientPrefs.storySave[9], ClientPrefs.storySave[8]];
	
	private var grpOptions:FlxTypedGroup<FlxSprite>;

	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	public static var devsong:Bool = false;
	public static var ogsong:Bool = false;
	public static var onMenu:Bool = false;

	var cosotexto:Array<String> = ['idk', 'sexo'];

	public static var bg:FlxSprite;
	public static var estatica:FlxSprite;
	public static var freeplaytext:FlxSprite;

	public var showAnim:Bool = false;

	override function create()
	{
		FlxG.mouse.visible = true;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In Freeplay", null);
		if (FlxG.random.bool(0.05))
		{
			Lib.application.window.title = "cuanto valen los elaos de sien"; // COMO
		}
		else
		{
			Lib.application.window.title = "Friday Night Funkin': Mario's Madness";
		}
		#end

		grpOptions = new FlxTypedGroup<FlxSprite>();
		add(grpOptions);

		freeplaytext = new FlxSprite(299.85, 32.5);
		freeplaytext.frames = Paths.getSparrowAtlas('modstuff/freeplay/Freeplay_Assets');
		freeplaytext.animation.addByPrefix('Title', 'Title', 24, true);
		freeplaytext.animation.play('Title');
		freeplaytext.updateHitbox();
		freeplaytext.screenCenter(X);
		freeplaytext.x += 20;
		add(freeplaytext);

		freeplaytext.alpha = 0; freeplaytext.scale.set(0,0);
		FlxTween.tween(freeplaytext, {'scale.x': 1, 'scale.y': 1, alpha: 1}, .35, {ease: FlxEase.circInOut, startDelay: .2});
		trace(opValid);
		var imagePortrait:FlxSprite;
		for (i in 0...options.length)
		{
			imagePortrait = new FlxSprite();
			imagePortrait.frames = Paths.getSparrowAtlas('modstuff/freeplay/Freeplay_Assets');
			imagePortrait.animation.addByPrefix(options[i], options[i], 24, true);
			imagePortrait.animation.play(options[i]);
			imagePortrait.updateHitbox();
			imagePortrait.ID = i;
			if(opValid[i]) grpOptions.add(imagePortrait);

			switch(options[i]){
				case 'Mainweek':
					imagePortrait.setPosition(56.55, 130.5);
				
				case 'Island':
					imagePortrait.setPosition(257.35, 130.5);

				case 'Woodland':
					imagePortrait.setPosition(442.65, 130.5);

				case 'Cosmos':
					imagePortrait.setPosition(638.55, 130.5);

				case 'Heights':
					imagePortrait.setPosition(833.8, 130.5);

				case 'Classified':
					imagePortrait.setPosition(1028, 130.5);

				case 'Extra':
					imagePortrait.setPosition(736.35, 472.35);

				case 'Legacy':
					imagePortrait.setPosition(268.70, 472.35);

			}
			imagePortrait.x -= 25; imagePortrait.y -= 15;

			imagePortrait.color = 0xFF000000; imagePortrait.alpha = 0.9;
			imagePortrait.scale.set(0,0);
			imagePortrait.x -= 60+(20 * i);

			FlxTween.tween(imagePortrait, {'scale.x': 1, 'scale.y': 1, x: imagePortrait.x + 60+(20 * i)}, .35, {ease: FlxEase.circInOut, startDelay: 0.05*i});
		}

		(new FlxTimer()).start(.35 + (0.05 * grpOptions.members.length), function (t) showAnim = true);

		changeSelection();
		FlxG.camera.zoom = 0.75;
		MainMenuState.instance.lerpCamZoom = true;
		MainMenuState.instance.camZoomMulti = 0.94;

		//FlxTween.cancelTweensOf(MainMenuState.instance.estatica);
		trace(MainMenuState.instance.estatica.alpha);
		//FlxTween.color(MainMenuState.instance.estatica, .8, MainMenuState.instance.estatica.color, 0xFF5E1515);

		FlxG.state.persistentDraw = true;
	}

	override function closeSubState()
	{
		super.closeSubState();
		changeSelection();
		freeplaytext.visible = true;
	}

	var tottalTime:Float = 0;
	override function update(elapsed:Float)
	{
		tottalTime += elapsed;

		freeplaytext.offset.y = (Math.floor(8 * Math.sin(tottalTime + 3.432))/8) * -8;

		MainMenuState.instance.WEHOVERING = false;
		grpOptions.forEach(function(spr:FlxSprite)
		{
			spr.offset.y = (Math.floor(8 * Math.sin(tottalTime + (.2 * spr.ID)))/8) * 6;
			spr.offset.y += FlxG.random.float(0.4, .8) * FlxG.random.sign();
			spr.offset.x = FlxG.random.float(0.4, .8) * FlxG.random.sign();

			var cosowea:Int;
			cosowea = curSelected;

			if (FlxG.mouse.overlaps(spr))
			{
				MainMenuState.instance.WEHOVERING = true;
				if(curSelected != spr.ID){
					curSelected = spr.ID;
					changeSelection(0);
				}
			}

			if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(spr)){
				goToState();
			}
		});
			
		super.update(elapsed);

		// if (controls.UI_UP_P || controls.UI_LEFT_P)
		// {
		// 	changeSelection(-1);
		// }
		// if (controls.UI_DOWN_P || controls.UI_RIGHT_P)
		// {
		// 	changeSelection(1);
		// }

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.state.closeSubState();
		}

		if (controls.ACCEPT)
		{
			goToState();
		}

		if(!onMenu){
		FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (FlxG.mouse.screenX-(FlxG.width/2)) * 0.01, (1/30)*240*elapsed);
		FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (FlxG.mouse.screenY-6-(FlxG.height/2)) * 0.01, (1/30)*240*elapsed);
		}

	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		for (item in grpOptions.members)
		{
			item.color = 0xFF505050;
			item.alpha = 0.9;
			if (item.ID == curSelected && showAnim)
			{
				item.color = 0xFFFFFFFF;
				item.alpha = 1;
			}
		}
	}

	function goToState()
	{
		MainMenuState.instance.WEHOVERING = false;
		for (item in grpOptions.members)
		{
			item.alpha = 0;
			freeplaytext.visible = false;
		}
		onMenu = true;
		FlxG.camera.scroll.x = 0;
		FlxG.camera.scroll.y = 0;

		switch (options[curSelected])
		{
			case 'Mainweek':
				canciones = [
					["It's a me", 'its-a-me', '26'],
					["Starman Slaughter", 'starman-slaughter', '34'],
				];
				if(ClientPrefs.storySave[7]){
					canciones.push(['All-Stars', 'all-stars', '9']);
				}
			case 'Island':
				canciones = [
					['So Cool', 'so-cool', '8'],
					['Nourishing Blood', 'nourishing-blood', '16'],
					['MARIO SING AND GAME RYTHM 9', 'mario-sing-and-game-rythm-9', '13']
				];
			case 'Woodland':
				canciones = [
					['Alone', 			'alone', 			'22'],
					['Oh God No', 		'oh-god-no', 		'21'],
					['I Hate You', 		'i-hate-you', 		'25'],
					['Thalassophobia',	'thalassophobia',   '31'],
					['Apparition', 		'apparition', 		'24'],
					['Last Course',		'last-course',      '18'],
					['Dark Forest', 	'dark-forest', 		'17']
				];			

			case 'Cosmos':
				canciones = [
					['Bad Day', 		'bad-day', 		'12'],
					['Day Out', 		'day-out', 		'10'],
					['Dictator', 		'dictator', 	'11'],
					['Race-traitors', 	'racetraitors', '20'],
					['No Hope',			'no-hope',      '19']
				];
			case 'Heights':
				canciones = [
					['Golden Land', 'golden-land', '28'],
					['No Party',		'no-party',         '30'],
					['Paranoia', 'paranoia', '41'],
					['Overdue',		'overdue',         '35'],
					['Powerdown', 'powerdown', '27'],
					['Demise', 'demise', '23']
				];

			case 'Classified':
				canciones = [
					['Promotion', 'promotion', 	'15'],
					['Abandoned', 'abandoned', 	'32'],
					['The End', 'the-end', 		'33']
				];
			
			case 'Legacy':
				canciones = [
					["It's a me (Original)", 'its-a-me-old', 		'1'],
					['Golden Land (Original)', 'golden-land-old', 	'2'],
					['I Hate You (Original)', 'i-hate-you-old', 	'3'],
					['Powerdown (Original)', 'powerdown-old', 		'4'],
					['Apparition (Original)', 'apparition-old', 	'5'],
					['Forbidden Star', 'forbidden-star', 			'39'],
					['Alone (Original)', 'alone-old', 				'6'],
					['Race-traitors (Original)', 'racetraitors-old', '7']
				];

			case 'Extra':
				canciones = [
					['Unbeatable', 'unbeatable', '14'],
					['Dictator (Original)', 		'dictator-old', 	'42'],
					['No Party (Original)', 'no-party-old', '36'],
					['Overdue (Original)', 'overdue-old', '37'],
					['Time Out (Demise Original)', 'demise-old', '40'],
					['All Stars Act 1 (Original)', 'all-stars-old', '38']
				];				
		}
		openSubState(new FreeplaySubState());
	}
}

class FreeplaySubState extends MusicBeatSubstate
{
	var tween:FlxTween;
	var tween2:FlxTween;

	var coord:Float;

	private var grpOptions:FlxTypedGroup<Alphabet>;

	private static var curSelected:Int = 0;
	private var iconArray:Array<AttachedSprite> = [];
	
	var fuck:Int = 1;
	var obo:Bool = false;

	var boxgrp:FlxTypedSpriteGroup<FlxSprite>;

	var estatica:FlxSprite;
	var cartel:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var nextAccept:Int = 5;

	var arrowR:FlxSprite;
	var arrowL:FlxSprite;
	var degR:FlxSprite;
	var degL:FlxSprite;
	var checkRight:FlxObject;
	var checkLeft:FlxObject;
	var checkBack:FlxObject;
	var side:Int;

	public var bloom:BloomShader;

	public function new()
	{
		super();
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		//CustomFreeplayState.estatica.animation.play('idle');
		curSelected = 0;

		bloom = MainMenuState.instance.bloom;
		bloom.Size.value = [0];
//		FlxTween.tween(FlxG.camera, {zoom: 0.75}, 1, {ease: FlxEase.quadOut});

		boxgrp = new FlxTypedSpriteGroup<FlxSprite>();
		for (i in 0...CustomFreeplayState.canciones.length)
		{
			var char:FlxSprite = new FlxSprite(430 * fuck, 100).loadGraphic(Paths.image('modstuff/freeplay/charicon/Char' + CustomFreeplayState.canciones[i][2]));
			char.antialiasing = ClientPrefs.globalAntialiasing;
			char.x -= char.width / 2;
			char.y += 270 - (char.height / 2);
			char.ID = i;
			if(i != curSelected) char.color = 0x00610000;
			boxgrp.add(char);

			fuck += 1;
			// trace('width of char' + fuck +": " + (char.width / 2));
		}
		add(boxgrp);
		coord = (-430 * curSelected) + 210;
		boxgrp.x = coord;
		boxgrp.y = 120;
		boxgrp.alpha = 0;
		tween = FlxTween.tween(boxgrp, {y: 0, alpha: 1}, 0.2, {ease: FlxEase.quadInOut});

		arrowL = new FlxSprite(0, 0).loadGraphic(Paths.image('modstuff/freeplay/arrow'));
		arrowL.color = FlxColor.RED;
		arrowL.antialiasing = ClientPrefs.globalAntialiasing;
		arrowL.scale.set(0.6, 0.6);
		arrowL.flipX = true;
		add(arrowL);

		arrowR = new FlxSprite(1200, 0).loadGraphic(Paths.image('modstuff/freeplay/arrow'));
		arrowR.color = FlxColor.RED;
		arrowR.antialiasing = ClientPrefs.globalAntialiasing;
		arrowR.scale.set(0.6, 0.6);
		add(arrowR);

		cartel = new FlxSprite(0, 20).loadGraphic(Paths.image('modstuff/freeplay/HUD_Freeplay_1'));
		cartel.updateHitbox();
		cartel.screenCenter(X);
		cartel.antialiasing = ClientPrefs.globalAntialiasing;
		cartel.scrollFactor.set(0.4, 0.4);
		add(cartel);
		tween = FlxTween.tween(cartel, {y: 0}, 3, {ease: FlxEase.quadInOut, type: PINGPONG});

		descText = new FlxText(50, 620, 1180, "", 32);
		descText.setFormat(Paths.font("Mario64.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set(0.4, 0.4);
		descText.updateHitbox();
		descText.screenCenter(X);
		descText.borderSize = 4.4;
		add(descText);

		checkLeft = new FlxObject(-173.4, 0, 600, 1200);
		checkLeft.scrollFactor.set(0, 0);
		add(checkLeft);

		checkRight = new FlxObject(853, 0, 600, 1200);
		checkRight.scrollFactor.set(0, 0);
		add(checkRight);

		checkLeft = new FlxObject(-173.4, 0, 600, 1200);
		checkLeft.scrollFactor.set(0, 0);
		add(checkLeft);

		changeSelection();

		descText.color = FlxColor.RED;
		boxgrp.color = FlxColor.RED;
		cartel.color = FlxColor.RED;
		PlayState.getspeed = 0;
		descText.alpha = 0;
		cartel.alpha = 0;
		tween = FlxTween.tween(descText, {alpha: 1}, 0.3, {ease: FlxEase.quadOut});
		tween = FlxTween.tween(cartel, {alpha: 1}, 0.3, {ease: FlxEase.quadOut});
	}

	var quieto:Bool = false;

	override function update(elapsed:Float)
	{
		if (!obo)
		{
			caminar();
			obo = true;
		}

		arrowL.screenCenter(Y);
		arrowR.screenCenter(Y);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;

			var cosowea:Int;
			cosowea = curSelected;

			if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(checkLeft) && !quieto)
			{
				changeSelection(-1);
				caminar();
				quieto = true;
				arrowL.scale.set(0.9, 0.9);
				arrowR.scale.set(0.6, 0.6);
				FlxTween.cancelTweensOf(arrowL.scale);
				FlxTween.tween(arrowL.scale, {x: 0.6, y: 0.6}, 0.5, {ease: FlxEase.expoOut});
			}
			else if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(checkRight) && !quieto)
			{
				changeSelection(1);
				caminar();
				quieto = true;
				arrowR.scale.set(0.9, 0.9);
				arrowL.scale.set(0.6, 0.6);
				FlxTween.cancelTweensOf(arrowR.scale);
				FlxTween.tween(arrowR.scale, {x: 0.6, y: 0.6}, 0.5, {ease: FlxEase.expoOut});
			}
			else if (FlxG.mouse.justPressed && !quieto)
			{
				goToSong();
			}

		if (!quieto)
		{
			if (upP || leftP)
			{
				changeSelection(-1);
				caminar();
				quieto = true;
			}
			if (downP || rightP)
			{
				changeSelection(1);
				caminar();
				quieto = true;
			}
			if (controls.ACCEPT && nextAccept <= 0)
			{
				goToSong();
			}
		}

		if (controls.BACK && !quieto)
		{
			curSelected = 0;
			CustomFreeplayState.onMenu = false;
			close();
		}
		if (nextAccept > 0)
		{
			nextAccept -= 1;
		}
		super.update(elapsed);

		if(!quieto){
			if(FlxG.mouse.overlaps(checkLeft) && side != 0){
				FlxTween.cancelTweensOf(arrowL);
				FlxTween.tween(arrowL, {x: 30}, 0.5, {ease: FlxEase.expoOut});

				FlxTween.cancelTweensOf(arrowR);
				FlxTween.tween(arrowR, {x: 1200}, 0.5, {ease: FlxEase.expoOut});

				side = 0;
			}else if(FlxG.mouse.overlaps(checkRight) && side != 2){
				FlxTween.cancelTweensOf(arrowL);
				FlxTween.tween(arrowL, {x: 0}, 0.5, {ease: FlxEase.expoOut});

				FlxTween.cancelTweensOf(arrowR);
				FlxTween.tween(arrowR, {x: 1170}, 0.5, {ease: FlxEase.expoOut});

				side = 2;
			}else if(!FlxG.mouse.overlaps(checkRight) && !FlxG.mouse.overlaps(checkLeft) && side != 1){
				FlxTween.cancelTweensOf(arrowL);
				FlxTween.tween(arrowL, {x: 0}, 0.5, {ease: FlxEase.expoOut});

				FlxTween.cancelTweensOf(arrowR);
				FlxTween.tween(arrowR, {x: 1200}, 0.5, {ease: FlxEase.expoOut});

				side = 1;
			}
			MainMenuState.instance.WEHOVERING = side != 1;
			if (side == 1) MainMenuState.instance.WEHOVERING = FlxG.mouse.overlaps(boxgrp.members[curSelected]);
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 1);

		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = CustomFreeplayState.canciones.length - 1;
			if (curSelected >= CustomFreeplayState.canciones.length)
				curSelected = 0;
		}
		while (unselectableCheck(curSelected));

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!unselectableCheck(bullShit - 1))
			{
				item.alpha = 0.6;
				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}
		}
		descText.text = CustomFreeplayState.canciones[curSelected][0];
	}

	function goToSong()
	{
		FlxG.sound.play(Paths.sound('FREEPLAY_START'), 1);
		quieto = true;
		tween.cancel();
		PlayState.ogwinX = Lib.application.window.x;
		PlayState.ogwinY = Lib.application.window.y;

		#if FREEPLAY
		PlayState.cpuControlled = !PlayState.cpuControlled;
		#end

		if (ClientPrefs.flashing && bloom != null) {
			bloom.Size.value = [2];
			bloom.dim.value = [0.1];

			var twn1:NumTween;
			var twn2:NumTween;

			twn1 = FlxTween.num(2, 0, 0.5, {
				onUpdate: (_) -> {
					bloom.Size.value = [twn1.value];
				}
			});

			twn2 = FlxTween.num(0.1, 2, 0.5, {
				onUpdate: (_) -> {
					bloom.dim.value = [twn2.value];
				}
			});

			FlxG.camera.shake(0.002, 0.2);
		}

		boxgrp.forEach(function(char:FlxSprite)
			{
				if (char.ID != curSelected)
				{
					FlxTween.tween(char, {alpha: 0}, 1, {ease: FlxEase.quadIn});
				}else{
					FlxTween.tween(char, {alpha: 0}, 2, {startDelay: 1, ease: FlxEase.quadIn});
				}
			});

		FlxG.mouse.visible = false;
		tween = FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.2}, 2, {ease: FlxEase.cubeOut, onComplete: function(twn:FlxTween)
			{
				tween = FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.2}, 10, {ease: FlxEase.cubeInOut});
			}});
		tween = FlxTween.tween(descText, {alpha: 0}, 1, {ease: FlxEase.quadIn});
		tween = FlxTween.tween(cartel, {alpha: 0}, 1, {ease: FlxEase.quadIn});
		FlxTween.tween(arrowL, {alpha: 0}, 1, {ease: FlxEase.quadIn});
		FlxTween.tween(arrowR, {alpha: 0}, 1, {ease: FlxEase.quadIn});
		tween = FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.2, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween){FlxG.sound.music.stop();}});
		tween = FlxTween.tween(MainMenuState.instance.fondo11, {alpha: 0}, 0.1, {ease: FlxEase.quadIn});
		tween = FlxTween.tween(MainMenuState.instance.bgFP, {alpha: 0}, 2, {ease: FlxEase.quadIn});
		tween = FlxTween.tween(MainMenuState.instance.estatica, {alpha: 0}, 2, {
			startDelay: 1, 
			ease: FlxEase.quadIn,
			onComplete: function(twn:FlxTween)
			{
				var dewottchart:String = '';
				if (FlxG.keys.pressed.H && CustomFreeplayState.canciones[curSelected][1] == 'demise')
					dewottchart = 'DONTUSE';
				PlayState.SONG = Song.loadFromJson(CustomFreeplayState.canciones[curSelected][1] + dewottchart, CustomFreeplayState.canciones[curSelected][1]);
				PauseSubState.tengo = CustomFreeplayState.canciones[curSelected][1];
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
				PlayState.isStoryMode = false;
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
				CustomFreeplayState.onMenu = true;
			}
		});
	}

	private function unselectableCheck(num:Int):Bool
	{
		return CustomFreeplayState.canciones[num].length <= 0;
	}

	private function caminar(lag:Bool = false)
	{
		// trace((-430 * curSelected) - (boxgrp.members[0].width / 2));
		coord = (-430 * curSelected) + 210;
		tween = FlxTween.tween(boxgrp, {x: coord}, 0.2, {
			ease: FlxEase.expoOut,
			onComplete: function(twn:FlxTween)
			{
				quieto = false;
			}
		});

		boxgrp.forEach(function(char:FlxSprite)
			{
				if (char.ID == curSelected)
				{
					FlxTween.tween(char, {y: 100 + (270 - (char.height / 2))}, 0.2, {ease: FlxEase.expoOut});
					FlxTween.color(char, 0.2, 0xBE610000, FlxColor.RED, {ease: FlxEase.expoOut});
				}
				else{
					if(char.color != 0xBE610000){
					FlxTween.tween(char, {y: 150 + (270 - (char.height / 2))}, 0.2, {ease: FlxEase.expoOut});
					FlxTween.color(char, 0.2, FlxColor.RED, 0xBE610000, {ease: FlxEase.expoOut});
					}
				}
			});
	}
}
