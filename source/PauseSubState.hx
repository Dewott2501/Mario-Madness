package;

import Controls.Control;
import TitleScreenShaders.TVStatic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Lib;

using StringTools;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart', 'Exit'];
	var difficultyChoices = [];
	var curSelected:Int = 0;
	var retromenu:Bool = false;
	var theleft:Bool = true;
	var luigitime:Bool = false; //PlayState.deathCounter >= 5;

	public static var muymalo:Int = 1;
	public static var tengo:String = "";

	var optionShit:Array<String> = ['credits', 'freeplay', 'Exit'];
	var menuItemslol:FlxTypedGroup<FlxSprite>;

	var bg:FlxSprite;
	var levelInfo:FlxText;
	var modetext:FlxText;
	var desctext:FlxText;
	var creditsTxt:FlxText;
	var line1:FlxSprite;
	var line2:FlxSprite;
	var descAll:FlxText;
	var ladobg:FlxSprite;
	var somaridesc:FlxSprite;
	var descArrow:FlxSprite;
	var levelDifficulty:FlxText;

	var arrowTime:Float = 0;
	var arrowOff:Int = 0;
	var arrowX:Int = 760;

	var pauseMusic:FlxSound;
	var botplayText:FlxText;

	public var tweensSC:Array<FlxTween> = [];
	public var tweens:Array<FlxTween> = [];

	public static var restsizeX:Int;
	public static var restsizeY:Int;
	public static var restX:Int;
	public static var restY:Int;

	public static var transCamera:FlxCamera;

	public static var pausemusic:String = 'breakfast1';
	var staticShader:TVStatic;

	public function new(x:Float, y:Float)
	{
		super();
		if(PlayState.deathCounter == 3 || (!PlayState.isStoryMode && !PlayState.isWarp)){
			luigitime = true;
		}
		if(luigitime){
			optionShit = ['credits', 'freeplay', 'options', 'Exit'];
			menuItemsOG = ['Resume', 'Restart', 'Botplay', 'Exit'];
		} 
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficultyStuff.length)
		{
			var diff:String = '' + CoolUtil.difficultyStuff[i][0];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		if(PlayState.curStage == 'directstream'){
			for (tween in tweensSC)
				{
					tween.cancel();
				}
			PlayState.ytbutton.animation.play('pause');
			PlayState.ytbutton.scale.set(0.8, 0.8);
			PlayState.ytbutton.alpha = 0.8;
			tweensSC.push(FlxTween.tween(PlayState.ytbutton.scale, {y: 1, x: 1}, 0.3));
			tweensSC.push(FlxTween.tween(PlayState.ytbutton, {alpha: 0}, 0.3));

			tweensSC.push(FlxTween.tween(PlayState.ytUI, {alpha: 1}, 0.4));
		} 

		var isgd:String = '';
		if(PlayState.curStage == 'bootleg') 
			isgd = 'GD/';
		if(PlayState.curStage == 'warioworld') 
			isgd = 'Wario/';
		// trace(pausemusic);
		pauseMusic = new FlxSound().loadEmbedded(Paths.music(isgd + pausemusic), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		if(PlayState.curStage == 'somari'){
			retromenu = true; //TURNING RETRO MODE TO ON (so retro)
		}

		somaridesc = new FlxSprite(260, 60).loadGraphic(Paths.image('modstuff/pause/imtiredofthisfuckingmenu'));
		somaridesc.setGraphicSize(Std.int(somaridesc.width * 0.9));
		somaridesc.alpha = 0;
		somaridesc.visible = retromenu;
		add(somaridesc);

		var ispixel:Array<String> = ['', '0', '150', '1', '0', '0', '215']; //file name - x offset - y offset - size - minioffset ladobg.y porq soy una mierda codificando - y offset sin botplay
		if(retromenu){
			ispixel[0] = 'PIXEL';
			ispixel[1] = '500';
			ispixel[2] = '130';
			ispixel[3] = '3.71';
			ispixel[4] = '-4';
			ispixel[5] = '1';
			ispixel[6] = '195';
		}
		
		modetext = new FlxText(566, 31, 0, "", 12);
		modetext.setFormat(Paths.font("mariones.ttf"), 17);
		add(modetext);

		line1 = new FlxSprite(566, modetext.y + 30).makeGraphic(630, 3, FlxColor.WHITE);
		add(line1);

		var txtdesc:String;
		if (muymalo > 1)
		{
			// trace('did desc ' + muymalo);
			txtdesc = Paths.txt('songData/' + tengo + '/desc' + muymalo);
		}
		else
		{
			// trace('did regular desc, muymalo is ' + muymalo);
			txtdesc = Paths.txt('songData/' + tengo + '/desc');
		}
		var muestralol:Array<String> = ['El pepe', 'ete sech'];

		muestralol = CoolUtil.coolTextFile(txtdesc);

		if (PlayState.isStoryMode)
		{
			modetext.text = "Story Mode";
		}
		else if (PlayState.isWarp)
		{
			modetext.text = "Warp Zone";
		}
		else
		{
			modetext.text = "Freeplay";
		}

		levelInfo = new FlxText(566, modetext.y + 40, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("mariones.ttf"), 22);
		levelInfo.updateHitbox();
		add(levelInfo);

		levelDifficulty = new FlxText(566, modetext.y + 80, 700, "", 32);
		levelDifficulty.text += PlayState.autor;
		levelDifficulty.text = levelDifficulty.text.replace('\n', ' ');
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('mariones.ttf'), 17);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		creditsTxt = new FlxText(566, levelDifficulty.y + 40, 700, "", 12);
		creditsTxt.text = muestralol[1];
		creditsTxt.setFormat(Paths.font("mariones.ttf"), 17);
		add(creditsTxt);

		desctext = new FlxText(566, creditsTxt.y + creditsTxt.height + 20, 0, "", 12);
		desctext.text = "Description";
		desctext.setFormat(Paths.font("mariones.ttf"), 17);
		add(desctext);

		line2 = new FlxSprite(566, desctext.y + 30).makeGraphic(630, 3, FlxColor.WHITE);
		add(line2);

		descAll = new FlxText(566, desctext.y + 40, 700, "", 12);
		descAll.text = muestralol[0];
		descAll.setFormat(Paths.font("mariones.ttf"), 17);
		add(descAll);

		var blueballedTxt:FlxText = new FlxText(566, 15 + 64, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('mariones.ttf'), 17);
		blueballedTxt.updateHitbox();
		// add(blueballedTxt);

		botplayText = new FlxText(20, FlxG.height - 40, 0, "BOTPLAY", 32);
		botplayText.scrollFactor.set();
		botplayText.setFormat(Paths.font('vcr.ttf'), 32);
		botplayText.x = FlxG.width - (botplayText.width + 20);
		botplayText.updateHitbox();
		botplayText.visible = PlayState.cpuControlled;
		add(botplayText);

		blueballedTxt.alpha = 0;
		modetext.alpha = 0;
		line1.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		desctext.alpha = 0;
		line2.alpha = 0;
		descAll.alpha = 0;
		creditsTxt.alpha = 0;
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		descArrow = new FlxSprite(arrowX, 350).loadGraphic(Paths.image('modstuff/pause/arrow'));
		descArrow.setGraphicSize(Std.int(descArrow.width * 3.71));
		descArrow.alpha = 0;
		descArrow.visible = retromenu;
		if(PlayState.curStage != 'piracy') add(descArrow);

		ladobg = new FlxSprite().loadGraphic(Paths.image('modstuff/pause/momichi' + ispixel[0]));
		ladobg.x = -550;
		ladobg.setGraphicSize(Std.int(ladobg.width * Std.parseFloat(ispixel[3])));
		ladobg.screenCenter(Y);
		ladobg.y += Std.parseFloat(ispixel[4]);
		add(ladobg);
		FlxTween.tween(ladobg, {x: -200 + Std.parseFloat(ispixel[1])}, 0.2, {ease: FlxEase.backOut});

		if(PlayState.curStage == 'piracy'){
			add(descArrow);
			descArrow.visible = true;
			descArrow.alpha = 1;
			descArrow.y = 670;
			arrowX = 40;
			descArrow.x = 40;
		}

		tweens.push(FlxTween.tween(bg, {alpha: 0.7}, 0.4, {ease: FlxEase.quartOut}));

		if(!retromenu){
			staticShader = new TVStatic();
			ladobg.shader = staticShader;
			if(PlayState.curStage == 'piracy'){
				var moveX:Int = 540;
				modetext.x -= moveX;
				line1.x -= moveX;
				levelInfo.x -= moveX;
				levelDifficulty.x -= moveX;

				desctext.x -= moveX;
				line2.x -= moveX;
				descAll.x -= moveX;
				creditsTxt.x -= moveX;
			}
		tweens.push(FlxTween.tween(modetext, {alpha: 1}, 0.4, {ease: FlxEase.quartOut, startDelay: 0.3}));
		tweens.push(FlxTween.tween(line1, {alpha: 1}, 0.4, {ease: FlxEase.quartOut, startDelay: 0.3}));
		tweens.push(FlxTween.tween(levelInfo, {alpha: 1}, 0.4, {ease: FlxEase.quartOut, startDelay: 0.3}));
		tweens.push(FlxTween.tween(levelDifficulty, {alpha: 1}, 0.4, {ease: FlxEase.quartOut, startDelay: 0.3}));

		tweens.push(FlxTween.tween(desctext, {alpha: 1}, 0.4, {ease: FlxEase.quartOut, startDelay: 0.6}));
		tweens.push(FlxTween.tween(line2, {alpha: 1}, 0.4, {ease: FlxEase.quartOut, startDelay: 0.6}));
		tweens.push(FlxTween.tween(descAll, {alpha: 1}, 0.4, {ease: FlxEase.quartOut, startDelay: 0.6}));
		tweens.push(FlxTween.tween(creditsTxt, {alpha: 1}, 0.4, {ease: FlxEase.quartOut, startDelay: 0.6}));
		tweens.push(FlxTween.tween(descArrow, {alpha: 1}, 0.4, {ease: FlxEase.quartOut, startDelay: 0.6}));
		}else{
			tweens.push(FlxTween.tween(somaridesc, {alpha: 0.5}, 0.4, {ease: FlxEase.quartOut, startDelay: 0.6}));
			tweens.push(FlxTween.tween(descArrow, {alpha: 1}, 0.4, {ease: FlxEase.quartOut, startDelay: 0.6}));
		}

		if (PlayState.SONG.song == "Paranoia")
		{
			levelDifficulty.color = FlxColor.RED;
			levelInfo.color = FlxColor.RED;
			desctext.color = FlxColor.RED;
			modetext.color = FlxColor.RED;
			line1.color = FlxColor.RED;
			line2.color = FlxColor.RED;
			descAll.color = FlxColor.RED;
			creditsTxt.color = FlxColor.RED;
		}

		menuItemslol = new FlxTypedGroup<FlxSprite>();
		add(menuItemslol);
		

		for (i in 0...optionShit.length)
		{
			var offset:Float = (88 - (Math.max(optionShit.length, 4) - 4) * 80) - (Std.parseFloat(ispixel[4]) * 5);
			var theY:String = ispixel[6];
			if(luigitime) theY = ispixel[2];
			var menuItemlol:FlxSprite = new FlxSprite(0, ((i * Std.parseFloat(theY)) + offset));
			menuItemlol.frames = Paths.getSparrowAtlas('mainmenu/pause/Mario_pause_' + menuItems[i] + ispixel[0]);
			menuItemlol.animation.addByPrefix('idle', optionShit[i] + " white", 24);
			menuItemlol.animation.addByPrefix('selected', optionShit[i] + " basic", 24);
			menuItemlol.animation.play('idle');
			menuItemlol.ID = i;
			menuItemlol.setGraphicSize(Std.int(menuItemlol.width * (0.5 + ((Std.parseFloat(ispixel[3]) * 0.8) * Std.parseFloat(ispixel[5])) )));
			menuItemslol.add(menuItemlol);
			if(retromenu){
				menuItemlol.antialiasing = false;
			}else{
			menuItemlol.antialiasing = ClientPrefs.globalAntialiasing;
			}
			menuItemlol.updateHitbox();
		}

		for (item in menuItemslol.members)
		{
			item.x = ladobg.x + 220;
			FlxTween.tween(item, {x: 20 + (Std.parseFloat(ispixel[1]) * 0.6)}, 0.2, {ease: FlxEase.backOut});
		}

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		// add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var selected:Bool = false;

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		
		if(staticShader != null){
			staticShader.update(elapsed);
		}

		if(retromenu || PlayState.curStage == 'piracy'){
			arrowTime += elapsed;

			if(arrowTime > 0.5){
				if(descArrow.x == arrowX + arrowOff){
					descArrow.x = (arrowX - 10) + arrowOff;
				}else{
					descArrow.x = arrowX + arrowOff;
				}
				arrowTime = 0;
			}
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;
		var accepted = controls.ACCEPT;

		if(retromenu || PlayState.curStage == 'piracy'){
			if (leftP)
			{
				toogleDesc(false);
			}
			if (rightP)
			{
				toogleDesc(true);
			}

			if (FlxG.keys.pressed.K)
				{
					descArrow.y -= 10;
				}
				else if (FlxG.keys.pressed.L)
				{
					descArrow.y += 10;
				}

			if (FlxG.keys.pressed.I)
				{
					descArrow.x -= 10;
				}
				else if (FlxG.keys.pressed.O)
				{
					descArrow.x += 10;
				}

			if(accepted){
				trace(descArrow.x, descArrow.y);
			}
		}

		if(theleft){
		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted && !selected)
		{
			var daSelected:String = menuItems[curSelected];
			for (i in 0...difficultyChoices.length - 1)
			{
				if (difficultyChoices[i] == daSelected)
				{
					var name:String = PlayState.SONG.song.toLowerCase();
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					CustomFadeTransition.nextCamera = transCamera;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.cpuControlled = false;
					return;
				}
			}

			switch (daSelected)
			{
				case "Resume":
					if (!ClientPrefs.pauseStart)
					{
						if(PlayState.curStage == 'directstream'){
							for (tween in tweensSC)
								{
									tween.cancel();
								}
							PlayState.ytbutton.animation.play('play');
							PlayState.ytbutton.scale.set(0.8, 0.8);
							PlayState.ytbutton.alpha = 0.8;
							tweensSC.push(FlxTween.tween(PlayState.ytbutton.scale, {y: 1, x: 1}, 0.3));
							tweensSC.push(FlxTween.tween(PlayState.ytbutton, {alpha: 0}, 0.3));

							tweensSC.push(FlxTween.tween(PlayState.ytUI, {alpha: 0}, 0.2));
							}
				
						close();
					}
					else
					{
						selected = true;
						var countText:FlxText = new FlxText(FlxG.width, FlxG.height, 0, "3", 32);
						countText.setFormat(Paths.font('vcr.ttf'), 72, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						countText.borderSize = 1.25;
						countText.visible = false;
						countText.screenCenter();
						add(countText);
						if (PlayState.SONG.song == "Paranoia")
						{
							countText.color = FlxColor.RED;
						}

						hideall();
						tweens.push(FlxTween.tween(descAll, {alpha: 0}, 0.4, {ease: FlxEase.quartOut}));
						tweens.push(FlxTween.tween(bg, {alpha: 0}, 1.6, {ease: FlxEase.quartOut}));

						new FlxTimer().start((1 * (1 / (Conductor.bpm / 60))), function(tmr:FlxTimer)
						{
							countText.visible = true;
							countText.text = "3";
							FlxG.sound.play(Paths.sound('Metronome_Tick'));
						});
						new FlxTimer().start((2 * (1 / (Conductor.bpm / 60))), function(tmr:FlxTimer)
						{
							countText.visible = true;
							countText.text = "2";
							FlxG.sound.play(Paths.sound('Metronome_Tick'));
						});
						new FlxTimer().start((3 * (1 / (Conductor.bpm / 60))), function(tmr:FlxTimer)
						{
							countText.visible = true;
							countText.text = "1";
							FlxG.sound.play(Paths.sound('Metronome_Tick'));
						});

						new FlxTimer().start((4 * (1 / (Conductor.bpm / 60))), function(tmr:FlxTimer)
						{
							if(PlayState.curStage == 'directstream'){
								for (tween in tweensSC)
									{
										tween.cancel();
									}
							PlayState.ytbutton.animation.play('play');
							PlayState.ytbutton.scale.set(0.8, 0.8);
							PlayState.ytbutton.alpha = 0.8;
							tweensSC.push(FlxTween.tween(PlayState.ytbutton.scale, {y: 1, x: 1}, 0.3));
							tweensSC.push(FlxTween.tween(PlayState.ytbutton, {alpha: 0}, 0.3));

							tweensSC.push(FlxTween.tween(PlayState.ytUI, {alpha: 0}, 0.2));
							}
							close();
						});
					}
				case "Restart":
					hideall();

					FlxG.sound.play(Paths.sound('RESTART'));
					tweens.push(FlxTween.tween(descAll, {alpha: 0}, 0.4, {ease: FlxEase.quartOut}));
					tweens.push(FlxTween.tween(bg, {alpha: 0}, 0.4, {
							ease: FlxEase.quartOut,
							onComplete: function(twn:FlxTween)
						{
						CustomFadeTransition.nextCamera = transCamera;
						Main.skipNextDump = true;
						MusicBeatState.resetState();
						FlxG.sound.music.volume = 0;

						if (PlayState.curStage == 'virtual')
						{
							Lib.application.window.fullscreen = false;
							Lib.application.window.maximized = false;
							Lib.application.window.resize(restsizeX, restsizeY);
							Lib.application.window.move(restX, restY);
							CppAPI.setWallpaper('old');
						}

						if (PlayState.getspeed != 0)
						{
							PlayState.SONG.speed = PlayState.getspeed;
						}
						}
					}));
					
				case 'Botplay':
						PlayState.cpuControlled = !PlayState.cpuControlled;
						PlayState.usedPractice = true;
						botplayText.visible = PlayState.cpuControlled;
				case "Exit":
					hideall();

					tweens.push(FlxTween.tween(descAll, {alpha: 0}, 0.4, {ease: FlxEase.quartOut}));
					tweens.push(FlxTween.tween(bg, {alpha: 0}, 0.4, {
						ease: FlxEase.quartOut,
						onComplete: function(twn:FlxTween)
						{
							PlayState.deathCounter = 0;
							PlayState.seenCutscene = false;
							CustomFadeTransition.nextCamera = transCamera;
							ClientPrefs.saveSettings();
							PlayState.virtualmode = false;
							if (PlayState.isWarp)
							{
								MusicBeatState.switchState(new WarpState());
							}
							else
							{
								MusicBeatState.switchState(new MainMenuState());
							}
							PlayState.usedPractice = false;
							PlayState.changedDifficulty = false;
							PlayState.cpuControlled = false;

							if (PlayState.curStage == 'piracy' || PlayState.curStage == 'somari'){
								if (ClientPrefs.showFPS){
									Main.fpsVar.visible = true;
								}
							}
						}
					}));

				case 'BACK':
					menuItems = menuItemsOG;
					regenMenu();
			}
		}
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function hideall()
	{
		for (tween in tweens)
		{
			tween.cancel();
		}
		tweens.push(FlxTween.tween(modetext, {alpha: 0}, 0.4, {ease: FlxEase.quartOut}));
		tweens.push(FlxTween.tween(line1, {alpha: 0}, 0.4, {ease: FlxEase.quartOut}));
		tweens.push(FlxTween.tween(levelInfo, {alpha: 0}, 0.4, {ease: FlxEase.quartOut}));
		tweens.push(FlxTween.tween(levelDifficulty, {alpha: 0}, 0.4, {ease: FlxEase.quartOut}));

		for (item in menuItemslol.members)
		{
			tweens.push(FlxTween.tween(item, {x: -550}, 0.2, {ease: FlxEase.backOut}));
		}



		tweens.push(FlxTween.tween(ladobg, {x: -750}, 0.2, {ease: FlxEase.backOut}));

		tweens.push(FlxTween.tween(desctext, {alpha: 0}, 0.4, {ease: FlxEase.quartOut}));
		tweens.push(FlxTween.tween(creditsTxt, {alpha: 0}, 0.4, {ease: FlxEase.quartOut}));
		tweens.push(FlxTween.tween(line2, {alpha: 0}, 0.4, {ease: FlxEase.quartOut}));
	}

	function hideallFAST()
	{
		modetext.visible = false;
		line1.visible = false;
		levelInfo.visible = false;
		levelDifficulty.visible = false;
		ladobg.visible = false;
		desctext.visible = false;
		line2.visible = false;
		menuItemslol.visible = false;
		descAll.visible = false;
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		menuItemslol.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.alpha = 0.9;
			spr.color = 0xFF878282;

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				spr.alpha = 1;
				spr.color = 0xFFFFFFFF;
			}
		});
	}

	function regenMenu():Void
	{
		for (i in 0...grpMenuShit.members.length)
		{
			this.grpMenuShit.remove(this.grpMenuShit.members[0], true);
		}
		for (i in 0...menuItems.length)
		{
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}

	function toogleDesc(mostrar:Bool) {
		var newX:Array<Float> = [500, -200];
		if(PlayState.curStage == 'piracy') newX = [0, -900];

		else{
		for (tween in tweens)
			{
				tween.cancel();
			}
		}

			theleft = !mostrar;
			if(mostrar){
				arrowOff = -400;
				if(PlayState.curStage == 'piracy') arrowOff = 0;
				descArrow.x = descArrow.x + arrowOff;
				descArrow.flipX = true;
				for (item in menuItemslol.members)
					{
						tweens.push(FlxTween.tween(item, {x: newX[1]}, 0.2, {ease: FlxEase.backOut}));
					}
				FlxTween.tween(ladobg, {x: newX[1]}, 0.2, {ease: FlxEase.backOut});
				tweens.push(FlxTween.tween(somaridesc, {alpha: 1}, 0.2, {ease: FlxEase.quartOut}));
			}else{
				descArrow.x = descArrow.x - arrowOff;
				arrowOff = 0;
				descArrow.flipX = false;
				FlxTween.tween(ladobg, {x: -200 + newX[0]}, 0.2, {ease: FlxEase.backOut});
				for (item in menuItemslol.members)
					{
						tweens.push(FlxTween.tween(item, {x: 20 + newX[0] * 0.6}, 0.2, {ease: FlxEase.backOut}));
					}
				tweens.push(FlxTween.tween(somaridesc, {alpha: 0.5}, 0.2, {ease: FlxEase.quartOut}));
			}
	}
}
