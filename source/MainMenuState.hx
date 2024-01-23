package;

import TitleScreenShaders.NTSCGlitch;
import TitleScreenShaders.NTSCSFilter;
import editors.MasterEditorMenu;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouse;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.NumTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import haxe.io.Path;
import lime.app.Application;
import lime.graphics.Image;
import openfl.Lib;
import openfl.filters.ShaderFilter;
import openfl.ui.Mouse;
import sys.FileSystem;
import sys.io.File;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end

class MainMenuState extends MusicBeatState {
	public static var psychEngineVersion:String = '0.4.2'; // This is also used for Discord RPC

	var warpcoso:String = 'warpzone';

	public var bgFP:FlxSprite;
	public var fondo11:FlxBackdrop;
	public static var bgAm:Int = 0;
	public var estatica:FlxSprite;
	var tornado:FlxSprite;
	var submenu:FlxSprite;
	var fog:FlxSprite;
	var saveSign:FlxSprite;
	var beatSign:FlxSprite;

	var typin:String = ''; // for the secrets....
	var codeClearTimer:Float = 0;
	public static var canselectshit:Bool = true;

	public static var instance(get, never):MainMenuState;
	public static function get_instance():MainMenuState
		return FlxG.state != null && FlxG.state is MainMenuState ? cast(FlxG.state, MainMenuState) : null;

	// contains da levels of menu items -lunar
	public var menuInfo:Array<{group:Null<FlxTypedSpriteGroup<FlxSprite>>, choices:Array<String>, res:FlxPoint, scroll:FlxPoint}> = [
		{
			group: null,
			choices: ["Patch"],
			res: FlxPoint.get(555, 88.05),
			scroll: FlxPoint.get(1, .7)
		},
		{
			group: null,
			choices: ["MainGame"],
			res: FlxPoint.get(271, 275.5),
			scroll: FlxPoint.get(1.4, .95)
		},
		{
			group: null,
			choices: ["Options", "Credits"],
			res: FlxPoint.get(390, 131.05),
			scroll: FlxPoint.get(1, .7)
		}
	];

	// level => [FlxPoint.get(postion.x, postion.y), menu items gap]
	// -1 on the postion means it will screen center that axes
	public var menuLevelPostions:Map<Int, Array<Dynamic>> = [
		0 => [FlxPoint.get(1280 / 1.85, 5), 0],
		1 => [FlxPoint.get(1280 / 2.62, 170), 10],
		2 => [FlxPoint.get((1280 / 6.6) + 0.05, 520), 40]
	];

	public static var currentLevel:Int = 1;
	public static var curSelected:Int = 0;
	public var WEHOVERING:Bool = false;

	public var corners:Array<FlxSprite> = [];
	public var curButton:FlxSprite = null;

	public var menuGroups:Array<FlxTypedSpriteGroup<FlxSprite>>;

	public var cornerOffset:NumTween;

	public var stars:FlxTypedSpriteGroup<FlxSprite>;

	// ! FOR STAR DATAS, PUT THE SAVE IN CLIENTPREFS.HX IN THE ORDER YOU WANT THE STARS TO APPEAR -lunar
	var starData:Array<Bool> = [ClientPrefs.storySave[0], ClientPrefs.storySave[6], ClientPrefs.storySave[7], ClientPrefs.storySave[8]];

	public var bloom:BloomShader;
	public var ntsc:NTSCGlitch;

	var selectedSomethin:Bool = false;
	var canSelectSomethin:Bool = false;
	var smOpen:Bool = false;
	var showMsg:Int = 0;
	public static var beat:Bool = false;

	public var lerpCamZoom:Bool = false;
	public var camZoomMulti:Float = 1;

	// FNF Gorefield v2 leak????
	public var keyCombos:Map<String, Void->Void> = [
		"PEN" => function () {MainMenuState.instance.penk();},
		"PENK" => function () {MainMenuState.instance.penk();},
		"PENKA" => function () {MainMenuState.instance.penk();},
		"PENKAR" => function () {MainMenuState.instance.penk();},
		"PENKARU" => function () {MainMenuState.instance.penk();},
	];
	public var keyComboProgress:Map<String, Int> = [];
	public var canUseKeyCombos:Bool = true;

	override function create() {
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		Lib.application.window.title = "Friday Night Funkin': Mario's Madness";
		#end

		if (Main.fpsVar != null) {
			Main.fpsVar.visible = ClientPrefs.showFPS;
		}

		if(PlayState.curStage == 'piracy'){
			PlayState.curStage = '';
			Lib.current.scaleX = 1;
			Lib.current.scaleY = 1;
			if(PlayState.ogwinX == 0){
			PlayState.ogwinX = Lib.application.window.x;
			PlayState.ogwinY = Lib.application.window.y;
			}
			var win = Lib.application.window;
			win.move(PlayState.ogwinX, PlayState.ogwinY);
			FlxG.resizeWindow(1280, 720);
			FlxG.resizeGame(1280, 720);
			Lib.current.x = 0;
			Lib.current.y = 0;
			win.resizable = true;
		}
		
		Lib.application.window.resizable = lime._internal.backend.native.NativeApplication.fullscreenable = true;

		if(FlxG.sound.music == null){
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}else{
		if (!FlxG.sound.music.playing || FlxG.sound.music.length != 177230) //XDDDDDDDDDDDDDDDDDDD
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				FlxG.sound.music.play(true, 27706);
			}
		}
		

		// trace(FlxG.sound.music);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		if(!ClientPrefs.storySave[9] && ClientPrefs.storyPass){
			ClientPrefs.storySave[9] = true;
			ClientPrefs.saveSettings();
			showMsg = 1;
		}

		if(beat){
			showMsg = 2;
			beat = false;
		}

		if(ClientPrefs.storySave[9] || ClientPrefs.storySave[0]){
			menuInfo[1].choices.insert(1, "Freeplay");
			menuLevelPostions[1][0].x -= 149.75;
		}
		if (ClientPrefs.storySave[0]) {
			menuInfo[1].choices.insert(1, "WarpZone");
			menuLevelPostions[1][0].x -= 149.75;
		}

		FlxG.camera.pixelPerfectRender = false;

		bloom = new BloomShader();
		bloom.Size.value = [1];
		FlxG.camera.setFilters([new ShaderFilter(ntsc = new NTSCGlitch(0.4)), new ShaderFilter(bloom)]);

		var stagenumb:Int = ClientPrefs.menuBG - 1;

		var unlockBG:Array<Bool> = [ClientPrefs.storySave[1], true, ClientPrefs.storySave[1], ClientPrefs.storySave[1], ClientPrefs.storySave[2], ClientPrefs.storySave[2], ClientPrefs.storySave[4], ClientPrefs.storySave[8]];
		var amount:Int = 0;
		for (i in 0... unlockBG.length){
			if(unlockBG[i]){
				amount++;
			}
			}
		fondo11 = new FlxBackdrop(Paths.image(('mainmenu/bgs/bg1')), X);
		add(fondo11);
		reloadBG();
		//add(fondo11 = new FlxBackdrop(Paths.image('backmenu')));
		//fondo11.scrollFactor.set();
		//fondo11.velocity.set(-40, 0);

		bgFP = new FlxSprite(0, 0).loadGraphic(Paths.image('modstuff/freeplay/HUD_Freeplay_2'));
		bgFP.scale.set(1.4, 1.4);
		bgFP.antialiasing = ClientPrefs.globalAntialiasing;
		bgFP.updateHitbox();
		bgFP.screenCenter(XY);
		bgFP.alpha = 0;
		bgFP.scrollFactor.set(0, 0);
		bgFP.color = 0x00FF0000;
		add(bgFP);

		estatica = new FlxSprite();
		estatica.frames = Paths.getSparrowAtlas('modstuff/estatica_uwu');
		estatica.animation.addByPrefix('idle', "Estatica papu", 15);
		estatica.animation.play('idle');
		estatica.antialiasing = false;
		estatica.color = FlxColor.RED;
		estatica.alpha = 0.7;
		estatica.scrollFactor.set();
		estatica.updateHitbox();
		add(estatica);

		fog = new FlxSprite().loadGraphic(Paths.image('modstuff/126'));
		fog.alpha = 0.9;
		fog.scrollFactor.set();
		fog.updateHitbox();
		fog.screenCenter();
		add(fog);

		tornado = new FlxSprite(2280, -90);
		tornado.frames = Paths.getSparrowAtlas('modstuff/adios');
		tornado.animation.addByPrefix('idle', "adios pose", 4);
		tornado.animation.play('idle');
		tornado.scrollFactor.set();
		tornado.setGraphicSize(Std.int(tornado.width * 45));
		tornado.visible = true;
		tornado.antialiasing = false;
		tornado.updateHitbox();
		add(tornado);

		for (info in menuInfo)
		{
			var levelIdx = menuInfo.indexOf(info);

			if (info.choices == [])
				continue;

			info.group = new FlxTypedSpriteGroup();
			info.group.scrollFactor.set(info.scroll.x, info.scroll.y);

			for (choice in info.choices) {
				var menuIdx = info.choices.indexOf(choice);

				var button:FlxSprite = new FlxSprite();
				button.frames = Paths.getSparrowAtlas("mainmenu/MM_Menu_Assets");
				button.animation.addByPrefix("idle", choice + "Normal", 30, true); // Selected
				button.animation.addByPrefix("selected", choice + "Selected", 30, true); // Selected
				button.animation.play("idle");
				

				button.updateHitbox();
				button.setPosition((button.width * menuIdx) + (menuLevelPostions[levelIdx][1] * menuIdx), 0);

				button.ID = menuIdx;
				info.group.add(button);
			}

			add(info.group);

			var pos:FlxPoint = menuLevelPostions[levelIdx][0];

			if (pos.x == -1)
				info.group.screenCenter(X);
			else
				info.group.x = pos.x;

			if (pos.y == -1)
				info.group.screenCenter(Y);
			else
				info.group.y = pos.y;

			pos.put();
		}

		for (i in 1...5) {
			var corner:FlxSprite = new FlxSprite();
			corner.frames = Paths.getSparrowAtlas("mainmenu/MM_Menu_Assets");
			corner.animation.addByPrefix("idle", 'Corner$i', 24);
			corner.animation.play("idle");

			corner.updateHitbox();
			corner.visible = false;
			corner.ID = i - 1;

			add(corner);

			corners.push(corner);
		}

		cornerOffset = FlxTween.num(0, 7.5, 1.5, {
			ease: FlxEase.circInOut,
			type: PINGPONG,
			onUpdate: (_) -> {
				for (corner in corners) {
					if (corner != null) {
						switch (corner.ID) {
							case 0:
								corner.offset.set(cornerOffset.value, cornerOffset.value);
							case 1:
								corner.offset.set(-cornerOffset.value, cornerOffset.value);
							case 2:
								corner.offset.set(cornerOffset.value, -cornerOffset.value);
							case 3:
								corner.offset.set(-cornerOffset.value, -cornerOffset.value);
						}
					}
				}
			}
		});

		stars = new FlxTypedSpriteGroup<FlxSprite>();
		add(stars);

		var unlocked:Int = 0;

		for (i in 0...starData.length) {
			var star:FlxSprite = new FlxSprite();
			star.frames = Paths.getSparrowAtlas("mainmenu/MM_Menu_Assets");
			star.animation.addByPrefix("idle", "Star", 30, true);
			star.animation.play("idle");

			star.updateHitbox();
			star.y += star.height * i;
			stars.x -= star.width;
			star.alpha = 0;
			star.visible = false;

			if (starData[i]) {
				star.visible = true;
				star.ID = i;

				FlxTween.tween(star, {x: Math.PI, alpha: 0.9}, 1, {
					ease: FlxEase.circOut,
					startDelay: 0.15 * unlocked,
					onComplete: (_) -> {
						FlxTween.tween(star.offset, {y: 7.5}, 1.5, {type: PINGPONG, loopDelay: 0.25});
					}
				});
				unlocked++;
			}

			star.scrollFactor.set(0.6, 1);
			stars.add(star);
		}

		stars.screenCenter(Y);

		submenu = new FlxSprite(50, 570);
		submenu.frames = Paths.getSparrowAtlas('modstuff/cuadro');

		submenu.animation.addByPrefix('oculto', "cuadro hide", 20, false);
		submenu.animation.addByPrefix('abrir', "cuadro abrir", 20, false); // abrir sin la flauta
		submenu.animation.addByPrefix('abrirF', "cuadro Fabrir", 20, false); // abrir con la flauta
		submenu.animation.addByPrefix('cerrar', "cuadro cerrar", 20, false);

		submenu.animation.play('oculto');
		submenu.scrollFactor.set();
		submenu.setGraphicSize(Std.int(submenu.width * 5));
		submenu.visible = true;
		submenu.antialiasing = false;
		submenu.updateHitbox();
		add(submenu);

		saveSign = new FlxSprite().loadGraphic(Paths.image('save'));
		saveSign.scrollFactor.set();
		saveSign.updateHitbox();
		saveSign.screenCenter();
		saveSign.scale.set(0.8, 0.8);
		add(saveSign); saveSign.visible = false;
		saveSign.y -= 720;

		beatSign = new FlxSprite().loadGraphic(Paths.image('credits/unbeatable'));
		beatSign.scrollFactor.set();
		beatSign.updateHitbox();
		beatSign.screenCenter();
		beatSign.scale.set(0.8, 0.8);
		add(beatSign); beatSign.visible = false;
		beatSign.y -= 720;

		if(showMsg != 0){
			selectedSomethin = saveSign.visible = true;
			new FlxTimer().start(1.5, function(tmr:FlxTimer)
				{
					FlxG.sound.play(Paths.sound('message'));
				});

			if(showMsg == 1){
				FlxTween.tween(saveSign.scale, {x: 1, y: 1}, 1, {ease: FlxEase.cubeInOut, startDelay: 1.5});
				FlxTween.tween(saveSign, {y: saveSign.y + 720}, 1, {ease: FlxEase.expoOut, startDelay: 1.5, onComplete: function(twn:FlxTween)
					{
						smOpen = true;
					}});
			}else{
				beatSign.visible = true;
				FlxTween.tween(beatSign.scale, {x: 1, y: 1}, 1, {ease: FlxEase.cubeInOut, startDelay: 1.5});
				FlxTween.tween(beatSign, {y: beatSign.y + 720}, 1, {ease: FlxEase.expoOut, startDelay: 1.5, onComplete: function(twn:FlxTween)
					{
						smOpen = true;
					}});
			}
		}

		menuGroups = [for (info in menuInfo) info.group];

		changeItem();

		FlxG.camera.zoom += 0.1;

		FlxTween.tween(FlxG.camera, {zoom: 1}, 1.3, {ease: FlxEase.circInOut});
		if (showMsg == 0) (new FlxTimer()).start(0.6, function (t:FlxTimer) {canSelectSomethin = lerpCamZoom = true;});

		if(bgAm != 0 && bgAm < amount){
			newBG(amount);
		}
		bgAm = amount;

		super.create();
		FlxG.mouse.visible = true;
	}

	var tieneflauta:Bool = false;
	var fullTimer:Float = 0;
	override function update(elapsed:Float) {
		fullTimer += elapsed;

		if (FlxG.sound.music.volume < 0.8 && !selectedSomethin)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (FlxG.mouse.screenX-(FlxG.width/2)) * 0.015, (1/30)*240*elapsed);
		FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (FlxG.mouse.screenY-6-(FlxG.height/2)) * 0.015, (1/30)*240*elapsed);

		if (lerpCamZoom) // Check out my ouper duper code -lunar
			FlxG.camera.zoom = FlxMath.lerp(
				FlxG.camera.zoom, camZoomMulti * (.98 - 
				(Math.abs(((FlxG.mouse.screenX*0.4) + 
				(FlxMath.remapToRange(FlxG.mouse.screenY, 0, FlxG.height, 0, FlxG.width)*0.6))
				-(FlxG.width/2)) * 0.00002)), 
			(1/30)*240*elapsed);

		fog.scale.set(1/FlxG.camera.zoom, 1/FlxG.camera.zoom);
		estatica.scale.set(1/FlxG.camera.zoom, 1/FlxG.camera.zoom);

		if (ntsc != null) ntsc.time.value = [fullTimer];

		if (!selectedSomethin && !smOpen) {
			
			var lastPressed = FlxG.keys.firstJustPressed();
			if (lastPressed != -1 && canUseKeyCombos)
				for (fullPhrase => func in keyCombos) {
					if (!keyComboProgress.exists(fullPhrase)) keyComboProgress.set(fullPhrase, 0);
					if (lastPressed == fullPhrase.charCodeAt(keyComboProgress.get(fullPhrase))) {
						var progress = keyComboProgress.get(fullPhrase) == null ? 0 : keyComboProgress.get(fullPhrase);
						keyComboProgress.set(fullPhrase, progress+1);
						if (fullPhrase.length == keyComboProgress.get(fullPhrase)) {
							keyComboProgress.set(fullPhrase, 0);
							if (func != null) func();
						}
					}
				}
				
			/*
			if (FlxG.keys.justPressed.P) {
				MusicBeatState.switchState(new YCBUShaderTester());
			}
			if (FlxG.keys.justPressed.O) {
				MusicBeatState.switchState(new BotplayState());
			}
			if (FlxG.keys.justPressed.L) {
				CppAPI.setTransparency(Lib.application.window.title, 0x001957);

				var virtuabg:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width / 2), Std.int(FlxG.height / 2), 0xFF571900);
				virtuabg.scrollFactor.set(0, 0);
				virtuabg.alpha = 1;
				add(virtuabg);
			}

			if (FlxG.keys.justPressed.K) {
				CppAPI.reset();
			}
			*/

			//if (FlxG.keys.justPressed.FOUR && FlxG.keys.pressed.CONTROL) {
			//	FlxG.switchState(new DSBIOSSState());
			//}

			if(codeClearTimer>0)codeClearTimer-=elapsed;
			if(codeClearTimer<=0)typin='';
			if(codeClearTimer<0)codeClearTimer=0;

			if(FlxG.keys.firstJustPressed()!=-1){
				codeClearTimer = 1 ; // 1 second to press next key in the code
				var key:FlxKey = FlxG.keys.firstJustPressed();
				typin += keyInput(key);
				// i think we need to do stuff here? not sure
				trace(typin);
				switch(typin){
					case 'garlic':
						typin = '';
						canselectshit = false;

						FlxG.sound.music.pause();
						openSubState(new VideoSubState('garlic'));				
					case 'v3':
						typin = '';
						canselectshit = false;

						FlxG.sound.music.pause();
						openSubState(new VideoSubState('V3'));			
					case 'peepy':
						CoolUtil.browserLoad('https://itemlabel.com/products/peepy');
					case 'natetdom':
						typin = '';
						canselectshit = false;

						FlxG.sound.music.pause();
						openSubState(new VideoSubState('nate'));
					case 'unbeatable':
						typin = '';
						canselectshit = false;

						FlxG.sound.music.pause();
						openSubState(new VideoSubState('i hate this'));			
					case 'scrubb':
						typin = '';
						canselectshit = false;

						FlxG.sound.music.pause();
						openSubState(new VideoSubState('scrubb'));
				}
			}

			WEHOVERING = false;
			if(canselectshit){
				for (group in menuGroups) {
					if (group == null) continue;
	
					var hovering:Bool = false;
					group.forEach((button) ->
					{
						var groupLevel:Int = findGroupLevel(group);
	
						button.offset.y = 8*(Math.floor(8 * FlxMath.fastSin((fullTimer/2) + ((.5*button.ID)+(2*groupLevel))))/8);
						button.offset.x = 4*(Math.floor(8 * FlxMath.fastSin((fullTimer/8) + ((2/8)*groupLevel)))/8);
	
						if (FlxG.mouse.overlaps(button)) {
							hovering = WEHOVERING = true;
							
							if ((currentLevel != groupLevel) || (curSelected != button.ID)) {
								currentLevel = groupLevel;
								changeLevel(0, false);
	
								curSelected = button.ID;
								changeItem(0, false);
	
								FlxG.sound.play(Paths.sound('scrollMenu'));
							}
						}
					});
	
					if (FlxG.mouse.justReleased && hovering && canSelectSomethin) goToState();
				}	
			}
			if (curButton != null) postionCorners(curButton);

			#if desktop
			else if (FlxG.keys.justPressed.SEVEN) {
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end

			#if debug
			if (FlxG.keys.justPressed.FOUR) {
				ClientPrefs.worlds = [3, 7, 5, 6, 3];
				ClientPrefs.worldsALT = [0, 2, 0, 3, 0];
				ClientPrefs.storySave = [for(i in 0... 10) true];
				ClientPrefs.saveSettings();
			}

			if (FlxG.keys.justPressed.FIVE) {
				ClientPrefs.worlds = [0, 0, 0, 0, 0];
				ClientPrefs.worldsALT = [0, 0, 0, 0, 0];
				ClientPrefs.storySave = [for(i in 0... 10) false];
				ClientPrefs.saveSettings();
			}
			#end
		}

		Mouse.cursor = WEHOVERING ? BUTTON : ARROW;
		if (controls.ACCEPT && smOpen) {
			smOpen = false;
			FlxG.sound.play(Paths.sound('accept'));
			if(showMsg == 1){
			FlxTween.tween(saveSign, {y: saveSign.y + 720}, 1, {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween)
				{
					canSelectSomethin = true;
					selectedSomethin = false;
				}});
			}else{
				FlxTween.tween(beatSign, {y: beatSign.y + 720}, 1, {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween)
					{
						selectedSomethin = false;
						canSelectSomethin = true;
					}});
			}
		}

		super.update(elapsed);
	}

	override function destroy() {
		super.destroy();
		Mouse.cursor = ARROW;
	}

	var oldButton:FlxSprite;
	var oldPos:FlxPoint;
	function goToState() {
		selectedSomethin = true; WEHOVERING = false;
		FlxG.sound.play(Paths.sound('confirmMenu'));

		if (ClientPrefs.flashing && bloom != null) {
			bloom.Size.value = [45];
			bloom.dim.value = [0.3];

			var twn1:NumTween;
			var twn2:NumTween;

			twn1 = FlxTween.num(4.0, 0.0, .5, {
				onUpdate: (_) -> {
					bloom.Size.value = [twn1.value];
				}
			});

			twn2 = FlxTween.num(0.1, 2.0, .5, {
				onUpdate: (_) -> {
					bloom.dim.value = [twn2.value];
				}
			});
		}

		for (star in stars) {
			if (star == null)
				continue;
			FlxTween.cancelTweensOf(star);

			FlxTween.tween(star.offset, {x: 0}, 0.1);
			FlxTween.tween(star, {x: star.x + (star.width * 1.25), alpha: 0}, 0.76, {ease: FlxEase.circOut, startDelay: 0.1 + (0.1 * star.ID)});
		}

		lerpCamZoom = false; FlxTween.tween(FlxG.camera, {zoom: 1.1}, 1.3, {ease: FlxEase.circOut});

		for (group in menuGroups) {
			group.forEachAlive((_) -> {
				if (findGroupLevel(group) != currentLevel || _.ID != curSelected)
					FlxTween.tween(_, {alpha: 0}, 0.3, {
						ease: FlxEase.circInOut
					});
			});
		}

		for (corner in corners) {
			FlxTween.tween(corner, {alpha: 0}, 0.6, {ease: FlxEase.circInOut, startDelay: 0.1 * corner.ID});
		}

		if(menuInfo[currentLevel].choices[curSelected] == 'WarpZone' || menuInfo[currentLevel].choices[curSelected] == 'Credits' || menuInfo[currentLevel].choices[curSelected] == 'Options'){
			FlxG.sound.music.fadeOut(0.5, 0);
			FlxG.mouse.visible = false;
		}

		if(menuInfo[currentLevel].choices[curSelected] == "Freeplay"){
			FlxTween.color(bgFP, 0.6, bgFP.color, FlxColor.RED, {startDelay: 0.5});
			FlxTween.tween(estatica, {alpha: 0.3}, 0.6, {startDelay: 0.5});
		}

		var nextcoords:Array<String> = ['', ''];
		nextcoords[0] = Std.string((FlxG.width - menuInfo[currentLevel].group.members[curSelected].width) / 2);
		nextcoords[1] = Std.string((FlxG.height - menuInfo[currentLevel].group.members[curSelected].height) / 2);

		oldButton = menuInfo[currentLevel].group.members[curSelected];
		oldPos = FlxPoint.get(oldButton.x, oldButton.y);
		
		FlxTween.tween(menuInfo[currentLevel].group.members[curSelected], {x: nextcoords[0], y: nextcoords[1]}, 0.6,
			{ease: FlxEase.circOut});

		if (ClientPrefs.flashing) 
			FlxFlicker.flicker(menuInfo[currentLevel].group.members[curSelected], 1, 0.06, false, false);
		
		if (!ClientPrefs.flashing || menuInfo[currentLevel].choices[curSelected] == "MainGame")
			FlxTween.tween(menuInfo[currentLevel].group.members[curSelected], {alpha: 0}, .4);

		if (menuInfo[currentLevel].choices[curSelected] == "MainGame")
			for (spr in [fondo11, estatica]) {
				FlxTween.cancelTweensOf(spr);
				FlxTween.tween(spr, {alpha: 0}, .4, {ease: FlxEase.circInOut, startDelay: .3});
			}

		new FlxTimer().start(.6, (_) -> {
			var choice:String = menuInfo[currentLevel].choices[curSelected];
			switch (currentLevel) {
				case 0:
					switch (choice) {
						case "Patch":
							MusicBeatState.switchState(new PatchNotes());
					}
				case 1:
					switch (choice) {
						case "MainGame":
							new FlxTimer().start(0.4, function(tmr:FlxTimer) {FlxG.state.persistentDraw = true; openSubState(new StoryMenuState());});
						case "WarpZone":
							new FlxTimer().start(0.4, function(tmr:FlxTimer)
							{
								MusicBeatState.switchState(new WarpState());
							});
							
						case "Freeplay":
							new FlxTimer().start(0.4, function(tmr:FlxTimer) {FlxG.state.persistentDraw = false; openSubState(new CustomFreeplayState());});
					}
				case 2:
					switch (choice) {
						case "Options":
							new FlxTimer().start(0.4, function(tmr:FlxTimer) {FlxG.state.persistentDraw = false; openSubState(new MMOptions());});
						case "Credits":
							CreditsState.autoscroll = false;
							MusicBeatState.switchState(new CreditsState());
					}
			}
		});
	}

	private function findGroupLevel(grp:FlxTypedSpriteGroup<FlxSprite>):Int {
		for (info in menuInfo) {
			if (info.group == grp)
				return menuInfo.indexOf(info);
		}
		return 0;
	}

	private function fadeMenuIn() {
		for (group in menuGroups)
			group.forEachAlive((_) -> {
				FlxTween.tween(_, {alpha: 1}, 0.3, {ease: FlxEase.circInOut});
			});
		for (corner in corners) {
			FlxTween.tween(corner, {alpha: 1}, 0.2, {ease: FlxEase.circInOut, startDelay: 0.1 * corner.ID});
		}
		for (star in stars) {
			if (star == null)
				continue;
			FlxTween.cancelTweensOf(star);
			
			star.x = Math.PI + (star.width * 1.25); star.alpha = 0; // TO STOP STUPID FUCKING GLITCH
			FlxTween.tween(star, {x: star.x - (star.width * 1.25), alpha: 1}, 0.4, {ease: FlxEase.circOut, startDelay: 0.1 + (0.1 * star.ID)});
		}
		FlxG.camera.setFilters([new ShaderFilter(ntsc), new ShaderFilter(bloom)]);

		for (spr in [fondo11, estatica]) {
			if (spr.alpha >= 0.99) return;
			FlxTween.cancelTweensOf(spr);
			FlxTween.tween(spr, {alpha: spr == estatica ? 0.7 : 1}, 0.3, {ease: FlxEase.circInOut});
		}
	}

	override function closeSubState() {
		super.closeSubState();
		if (FlxG.state.subState is CustomFreeplayState || FlxG.state.subState is MMOptions || FlxG.state.subState is StoryMenuState) {
			reloadBG();
			oldButton.alpha = 1; oldButton.visible = true;
			oldButton.setPosition(oldPos.x, oldPos.y);
			oldButton = null; oldPos.put(); camZoomMulti = 1;
			FlxTween.cancelTweensOf(estatica);
			FlxTween.tween(bgFP, {alpha: 0}, 0.6);
			FlxTween.tween(estatica, {alpha: 0.7}, 0.6);
			
			lerpCamZoom = true; FlxG.camera.zoom += .2; fadeMenuIn(); canSelectSomethin = selectedSomethin = false;
			(new FlxTimer()).start(.7, function (t:FlxTimer) canSelectSomethin = true);
		}
	}

	function changeItem(?huh:Int = 0, ?arrowCheck:Bool = true) {
		curSelected += huh;

		if (arrowCheck) {
			if (curSelected >= menuInfo[currentLevel].group.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuInfo[currentLevel].group.length - 1;
		}

		for (group in menuGroups) {
			group.forEachAlive((_) -> {
				if (findGroupLevel(group) == currentLevel && _.ID == curSelected) {
					_.animation.play("selected", true);
					curButton = _;
					postionCorners(_);
				}
				else
					_.animation.play("idle", true);
			});
		}
	}

	function keyInput(k:FlxKey): String{
		var asString = k.toString().toLowerCase();
		switch(asString){
			case 'zero' | 'numpadzero': return '0';
			case 'one' | 'numpadone': return '1';
			case 'two' | 'numpadtwo': return '2';
			case 'three' | 'numpadthree': return '3';
			case 'four' | 'numpadfour': return '4';
			case 'five' | 'numpadfive': return '5';
			case 'six' | 'numpadsix': return '6';
			case 'seven' | 'numpadseven': return '7';
			case 'eight' | 'numpadeight': return '8';
			case 'nine' | 'numpadnine': return '9';
			case 'backslash': return '\\';
			case 'any' | 'none' | 'printscreen' | 'pageup' | 'pagedown' | 'home' | 'end' | 'insert' | 'escape' | 'delete' | 'backspace' | 'capslock' | 'enter' | 'shift' | 'control' | 'alt' | 'f1' | 'f2' | 'f3' | 'f4' | 'f5' | 'f6' | 'f7' | 'f8' | 'f9' | 'f0' | 'tab' | 'up' | 'down' | 'left' | 'right': return '';
			case 'space': return ' ';
			case 'slash': return '/';
			case 'period' | 'numpadperiod': return '.';
			case 'comma': return ',';
			case 'lbracket': return '[';
			case 'rbracket': return ']';
			case 'semicolon': return ';';
			case 'colon': return ':';
			case 'plus' | 'numpadplus': return '+';
			case 'minus' | 'numpadminus': return '-';
			case 'asterisk' | 'numpadmultiply': return '*';
			case 'graveaccent': return '`';
			case 'quote': return '"';
			default: return asString;
		}
	}

	function changeLevel(?duh:Int = 0, ?arrowCheck:Bool = true) {
		var lastGroup = menuGroups[currentLevel];

		currentLevel += duh;

		if (arrowCheck) {
			if (currentLevel >= menuInfo.length)
				currentLevel = 0;
			if (currentLevel < 0)
				currentLevel = menuInfo.length - 1;

			
			if (curSelected == lastGroup.members.length-1) {
				curSelected = menuGroups[currentLevel].members.length-1;
			}
		}

		changeItem();
	}

	function newBG(newAm:Int){
		var sign:String = 'New BG Unlocked!\n';

		switch(newAm){
			case 4:
				sign = 'New BGs Unlocked!\nBedrock City\nGreen Hill Zone';
			case 6:
				sign = 'New BGs Unlocked!\nBowser Castle\nHackroom Forest';
			case 7:
				sign += 'Gameboy Land';
			case 8:
				sign += 'Hunting Area\n\nExtra Songs Unlocked!';
		}
		var screenText:FlxText = new FlxText(-250, 10, 1280, sign, 16);
		screenText.setFormat(Paths.font("mariones.ttf"), 24, FlxColor.RED, CENTER);
		add(screenText);

		FlxTween.tween(screenText, {alpha: 0}, 1, {startDelay: 3, onComplete: function(twn:FlxTween)
			{
				screenText.destroy();
			}});
	}

	function reloadBG(){
		remove(fondo11);
		var unlockBG:Array<Bool> = [ClientPrefs.storySave[1], true, ClientPrefs.storySave[1], ClientPrefs.storySave[1], ClientPrefs.storySave[2], ClientPrefs.storySave[2], ClientPrefs.storySave[4], ClientPrefs.storySave[8]];
		var amount:Int = 0;
		for (i in 0... unlockBG.length){
			if(unlockBG[i]){
				amount++;
			}
			}
		var stagenumb:Int = ClientPrefs.menuBG - 1;
		if(stagenumb < 0){ //make random or if you get -1
			stagenumb = FlxG.random.int(0, amount - 2);
			if(stagenumb < 0) stagenumb = 0; //somehow you get -1 so to make sure you dont get the FLIXELBG then uses 1-1 stage
		}

		if(stagenumb == 2 || stagenumb == 3){
			fondo11.frames = Paths.getSparrowAtlas('mainmenu/bgs/bg' + stagenumb);
			fondo11.animation.addByPrefix('idle', "bg", 5, true);
			fondo11.animation.play('idle', true);
		}else{
			fondo11 = new FlxBackdrop(Paths.image(('mainmenu/bgs/bg' + stagenumb)), X);
		}
		fondo11.updateHitbox();
		fondo11.scale.set(4, 4);
		fondo11.scrollFactor.set();
		fondo11.velocity.set(-40, 0);
		fondo11.screenCenter(Y);
		fondo11.y -= 40;
		fondo11.color = FlxColor.RED;
		add(fondo11);
		fondo11.x = FlxG.random.float(0, fondo11.width * 2);
	}

	function postionCorners(obj:FlxSprite, ?space:FlxPoint) {
		if (space == null)
			space = FlxPoint.get(12.5, 12.5);

		var res:FlxPoint = menuInfo[currentLevel].res;
		var postions:Map<Int, FlxPoint> = [
			0 => FlxPoint.get((obj.x-obj.offset.x) - space.x, (obj.y-obj.offset.y) - space.y),
			1 => FlxPoint.get(((obj.x-obj.offset.x) + res.x) + space.x, (obj.y-obj.offset.y) - space.y),
			2 => FlxPoint.get((obj.x-obj.offset.x) - space.x, ((obj.y-obj.offset.y) + res.y) + space.y),
			3 => FlxPoint.get(((obj.x-obj.offset.x) + res.x) + space.x, ((obj.y-obj.offset.y) + res.y) + space.y)
		];

		for (corner in corners) {
			if (corner == null)
				continue;

			var postion:FlxPoint = postions[corner.ID];

			if (postion == null)
				continue;

			corner.setPosition(postion.x, postion.y);
			corner.visible = true;

			switch (corner.ID) // I swear im not weird - lunar
			{
				case 1:
					corner.x -= corner.width / 1.9;
				case 2:
					corner.y -= corner.height / 1.75;
				case 3:
					corner.x -= corner.width / 1.9;
					corner.y -= corner.height / 1.75;
			}

			postion.put();
		}

		space.put();
	}

	// Easter eggs lol

	// Cool Penkaru by 
	public var penkImageList:Array<String> = [];
	public var tempImageList:Array<String> = [];
	public var penkStage:Int = 0;
	
	public function penk() {
		keyCombos.remove(switch (penkStage) {
			default: "PEN";
			case 1:	"PENK";
			case 2:	"PENKA";
			case 3:	"PENKR";
			case 4:	"PENKARU";
		});
		
		if (penkStage == 0) {
			for (file in FileSystem.readDirectory("assets/images/eastereggs/penk")) 
				if (Path.extension(file) == "png") penkImageList.push(Path.withoutExtension(file));
			tempImageList = penkImageList.copy();
		}

		for (i in 0...((penkStage+1)+FlxG.random.int(0, (2 * Std.int(penkStage/4))))) {
			var imageString:String = tempImageList[FlxG.random.int(0, tempImageList.length-1)];
			tempImageList.remove(imageString);
			if (tempImageList.length == 0) tempImageList = penkImageList.copy();

			var image = new FlxSprite().loadGraphic(Paths.image("eastereggs/penk/" + imageString));
			image.setPosition(FlxG.random.float(0 + 100, FlxG.width - image.width - ((100)*FlxG.random.float(.5, 1))), FlxG.random.float(0 + 100, FlxG.height -  image.height - ((100)*FlxG.random.float(.5, 1))));
			image.scrollFactor.set(FlxG.random.float(0.6, 1.4), FlxG.random.float(0.6, 1.4));
			add(image);

			image.scale.set(0, 0);
			FlxTween.tween(image.scale, {x: 1, y: 1}, .4 + FlxG.random.float(0, 0.1), {ease: FlxEase.bounceOut, startDelay: i*0.1});
			(new FlxTimer()).start(i*0.1, (_) -> FlxG.sound.play(Paths.sound("vineboom"), FlxG.random.float(0.8, 1)));
		}

		if (penkStage == 4) {
			selectedSomethin = true;
			new FlxTimer().start(.4, (_) -> {
				FlxG.sound.play(Paths.sound('riser'), 1);
				
				var twn1:NumTween;
				var twn2:NumTween;
		
				twn1 = FlxTween.num(1, 2, 2, {
					onUpdate: (_) -> {
						bloom.Size.value = [twn1.value];
					}
				});
		
				twn2 = FlxTween.num(2.0, 0.1, 2, {
					onUpdate: (_) -> {
						bloom.dim.value = [twn2.value];
					}
				});
		
				for (i in 0...10){
					new FlxTimer().start(0.2 * i, function(tmr:FlxTimer)
						{
							FlxG.camera.shake(0.0006 * i, 0.2);
						});
				}
				lerpCamZoom = false;
				FlxTween.tween(FlxG.camera, {zoom: 1.6}, 2, {ease: FlxEase.circIn});
				FlxTween.tween(Main.fpsVar, {alpha: 0}, .5, {ease: FlxEase.circIn});
				FlxTween.tween(FlxG.sound.music, {volume: 0}, 2, {ease: FlxEase.circIn});

				new FlxTimer().start(2, function(tmr:FlxTimer) {
					FlxG.camera.alpha = 0;
					new FlxTimer().start(1, function (tmr:FlxTimer) {
							#if VIDEOS_ALLOWED
							var foundFile:Bool = false;
							var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + "penkaru" + '.' + Paths.VIDEO_EXT); #else ''; #end
							#if sys
							if (FileSystem.exists(fileName))
							{
								foundFile = true;
							}
							#end

							if (!foundFile) {
								fileName = Paths.video("penkaru");
								if (#if sys FileSystem.exists(fileName) #else OpenFlAssets.exists(fileName) #end)
									foundFile = true;

								if (foundFile) {
									Lib.application.window.title = "*  You look inside the drawer and find a old vhs of a dance you used to do in highschool. *  Did this ever exist? When did you take this video?";
									Lib.application.window.resizable = false;
									FlxG.resizeWindow(1280, 720);

									FlxG.sound.volume = 1;
									FlxG.sound.soundTray.visual = false;
									FlxG.sound.soundTray.show(true);

									// Am I Evil??? (i do not care about streamer mode)
									CppAPI.removeWindowIcon();
									FlxG.fullscreen = FlxG.autoPause = false;
									Lib.application.window.onClose.add(function () {
										Lib.application.window.onClose.cancel();
									});
									
									(new FlxVideo(fileName)).finishCallback = function() {Sys.exit(0);}
									(new FlxTimer()).start(52, function (tmr:FlxTimer) {
										CppAPI._setWindowLayered();
					
										var numTween:NumTween = FlxTween.num(1, 0, 3, {
											onComplete: function(twn:FlxTween) {
												Sys.exit(0);
										}});
					
										numTween.onUpdate = function(twn:FlxTween)
										{
											#if windows
											CppAPI.setWindowOppacity(numTween.value);
											#end
										}
									});
								}
								else
									FlxG.log.warn('Couldnt find video file: ' + fileName);
								#end
						}
					});
				});
			});
		}

		penkStage++;
	}
}

class VideoSubState extends MusicBeatSubstate
{
	public function new(file:String){
		(new FlxVideo(Paths.video('secrets/$file'))).finishCallback = function(){
			FlxG.sound.music.resume();
			MainMenuState.canselectshit = true;

			close();
		}
		super();
	}
}