package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxSave;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['story_mode', 'freeplay', 'credits', 'options'];

	var warpcoso:String = 'warpzone';

	var fondo11:FlxBackdrop;
	var magenta:FlxSprite;
	var estatica:FlxSprite;
	var tornado:FlxSprite;
	var submenu:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
			{	
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		add(fondo11 = new FlxBackdrop(Paths.image('backmenu')));
		fondo11.scrollFactor.set();
		fondo11.velocity.set(-40, 0);

		estatica = new FlxSprite();
		estatica.frames = Paths.getSparrowAtlas('modstuff/estatica_uwu');
		estatica.animation.addByPrefix('idle', "Estatica papu", 15);
		estatica.animation.play('idle');
		estatica.antialiasing = false;
		estatica.alpha = 0.7;
		estatica.scrollFactor.set();
		estatica.updateHitbox();
		add(estatica);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
	//	add(magenta);
		// magenta.scrollFactor.set();

		if(ClientPrefs.storyFlaut){
		optionShit.push(warpcoso);
	    }

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 88 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/Mario_main_menu_assets_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.6));
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollowPos, null, 1);

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

		submenu = new FlxSprite(50, 570);
		submenu.frames = Paths.getSparrowAtlas('modstuff/cuadro');

		submenu.animation.addByPrefix('oculto', "cuadro hide", 20, false);
		submenu.animation.addByPrefix('abrir', "cuadro abrir", 20, false); //abrir sin la flauta
		submenu.animation.addByPrefix('abrirF', "cuadro Fabrir", 20, false); //abrir con la flauta
		submenu.animation.addByPrefix('cerrar', "cuadro cerrar", 20, false);

		submenu.animation.play('oculto');
		submenu.scrollFactor.set();
		submenu.setGraphicSize(Std.int(submenu.width * 5));
		submenu.visible = true;
		submenu.antialiasing = false;
		submenu.updateHitbox();
		add(submenu);



		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		PlayState.fpsthing = ClientPrefs.framerate;

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (!Achievements.achievementsUnlocked[achievementID][1] && leDate.getDay() == 5 && leDate.getHours() >= 18) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
			Achievements.achievementsUnlocked[achievementID][1] = true;
			giveAchievement();
			ClientPrefs.saveSettings();
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	var achievementID:Int = 0;
	function giveAchievement() {
		add(new AchievementObject(achievementID, camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement ' + achievementID);
	}
	#end

	var selectedSomethin:Bool = false;
	var smOpen:Bool = false;
	var tieneflauta:Bool = false;

	override function update(elapsed:Float)
	{

		if(PlayState.isStoryMode){
			PlayState.isStoryMode = false;
		}
		if (ClientPrefs.storyPass)
			{
				tieneflauta = true;
			}

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin && !smOpen)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else if (optionShit[curSelected] == 'freeplay' && !ClientPrefs.storyPass)
					{
						FlxG.sound.play(Paths.sound('cancelMenu'));
					}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new CustomFreeplayState());
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										MusicBeatState.switchState(new OptionsState());
									case 'warpzone':
										MusicBeatState.switchState(new WarpState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.justPressed.SEVEN && ClientPrefs.carPass)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end

			/*if (FlxG.keys.justPressed.C){
				trace("" + ClientPrefs.iHYPass, ClientPrefs.mXPass, ClientPrefs.warioPass, ClientPrefs.betaPass, ClientPrefs.finish1);
				ClientPrefs.mXPass = false;
			}

			else if (FlxG.keys.justPressed.C) //Usado para Testing
			{
				ClientPrefs.storyPass = false;
				ClientPrefs.storyFlaut = false;
				ClientPrefs.carPass = false;
				ClientPrefs.betaPass = false;
				ClientPrefs.iHYPass = false;
				ClientPrefs.mXPass = false;
				ClientPrefs.warioPass = false;
				ClientPrefs.saveSettings();
			}

			else if (FlxG.keys.justPressed.FOUR) //Usado para Testing
			{
					ClientPrefs.storyPass = true;
					ClientPrefs.storyFlaut = true;
				    ClientPrefs.carPass = true;
				    ClientPrefs.betaPass = true;
				    ClientPrefs.iHYPass = true;
				    ClientPrefs.mXPass = true;
				    ClientPrefs.warioPass = true;
					ClientPrefs.saveSettings();
			}

			else if (FlxG.keys.justPressed.NINE) //usado para testing too
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('flauta'));
					FlxG.sound.music.stop();

					FlxTween.tween(tornado, {x: -2560}, 2.5, {onComplete: function(twn:FlxTween)
						{
							MusicBeatState.switchState(new WarpState());
						}});

					menuItems.forEach(function(spr:FlxSprite)

					FlxTween.tween(spr, {alpha: 0}, 0.4, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)	{spr.kill();}
					}));
					//FlxTween.tween(sprite, { x: 600, y: 800 }, 2);
				} */
			
		}

		if(!smOpen)
			{
			 if (FlxG.keys.justPressed.B)
				{
				smOpen = true;
				FlxG.sound.play(Paths.sound('abrirsm'));

				if (!tieneflauta)
				{
			    submenu.animation.play('abrir');
			    }
				else
				submenu.animation.play('abrirF');

			    }
			}
		else
		{
			if (tieneflauta)
			{
             if(controls.ACCEPT)
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('flauta'));
					submenu.animation.play('cerrar');
					FlxG.sound.music.stop();

					FlxTween.tween(tornado, {x: -2560}, 2.5, {onComplete: function(twn:FlxTween)
						{
							ClientPrefs.storyFlaut = true;
							ClientPrefs.saveSettings();
							MusicBeatState.switchState(new WarpState());
						}});

					menuItems.forEach(function(spr:FlxSprite)

					FlxTween.tween(spr, {alpha: 0}, 0.4, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)	{spr.kill();}
					}));
				}
			}
			 if (FlxG.keys.justPressed.B)
				{
				smOpen = false;
				FlxG.sound.play(Paths.sound('abrirsm'));
				submenu.animation.play('cerrar');
				}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.scale.x = 0.6;
			spr.scale.y = 0.6;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				FlxTween.tween(spr.scale, {x: 0.8, y: 0.8}, 0.05, {ease: FlxEase.quadInOut});
				//spr.offset.x = 0.25 * (spr.frameWidth / 2 + 180);
				//spr.offset.y = 0.15 * spr.frameHeight;
				FlxG.log.add(spr.frameWidth);
			}
		});
	}
}
