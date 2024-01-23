package;

import TitleScreenShaders.Abberation;
import TitleScreenShaders.NTSCGlitch;
import TitleScreenShaders.NTSCSFilter;
import TitleScreenShaders.TVStatic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxSpriteGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.scaleModes.BaseScaleMode;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.NumTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Lib;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;

using StringTools;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end

class TitleState extends MusicBeatState {
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;
	public static var mouse:FlxSprite;

	var lastKeysPressed:Array<FlxKey> = [];

	var bottomGroup:FlxSpriteGroup;
	var camHUD:FlxCamera;
	var camGame:FlxCamera;

	var ntsc:NTSCSFilter;
	var bloom:BloomShader;
	var staticShader:TVStatic;

	var windowTwn:FlxTween;

	var windowRes:FlxPoint;
	var windowPos:FlxPoint;
	var startTime:Float;

	override public function create():Void {
		persistentUpdate = false;

		if (!initialized) {
			FlxG.sound.muteKeys = muteKeys;
			FlxG.sound.volumeDownKeys = volumeDownKeys;
			FlxG.sound.volumeUpKeys = volumeUpKeys;

			PlayerSettings.init();

			mouse = new FlxSprite().loadGraphic(Paths.image('cursor'));
			FlxG.mouse.load(mouse.pixels, 2);
			FlxG.mouse.useSystemCursor = true;
		}
		
		if (!initialized) {
			FlxG.save.bind('funkin', 'ninjamuffin99');
			ClientPrefs.loadPrefs();

			#if CHARTING
			MusicBeatState.switchState(new ChartingState());
			#else

			#if desktop
			if (ClientPrefs.noDiscord) DiscordClient.initialize();
			Application.current.onExit.add(function(exitCode) {
				DiscordClient.shutdown();
			});
			#end
			/*
			if (!FlashingState.leftState) {
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				MusicBeatState.switchState(new FlashingState());
			}
			else {*/
				/*

				MusicBeatState.switchState(new MainMenuState());
				BaseScaleMode.ogSize = FlxPoint.get(1280, 720); // fuck you haxeflixel
				FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode();
		
				FlxG.resizeWindow(1280, 720);
				FlxG.resizeGame(1280, 720);
				return;
				#end
				*/

				startIntro();
			//}
			#end
		}
		else {
			startIntro();
		}

		super.create();
	}

	var logoBl:FlxSprite;
	var titleText:FlxSprite;
	var arms:FlxSprite;
	var floor:FlxSprite;
	var bf:FlxSprite;
	var gf:FlxSprite;
	var hands:Array<FlxSprite> = [];
	var curtain:FlxSprite;
	var enterSprite:FlxSprite;

	var baseCamPos:FlxPoint = FlxPoint.get((FlxG.width / 2) + 2.5, (FlxG.height / 2) - 50);
	var camFollow:FlxObject;

	var blackSprite:FlxSprite;
	var _static:FlxSprite;

	var handShaders:Array<NTSCGlitch> = [];

	function startIntro() {
		camGame = new FlxCamera();		
		camFollow = new FlxObject((FlxG.width / 2) + 2.5, (FlxG.height / 2) - 50, 1, 1);
		camGame.target = camFollow;
		FlxCamera.defaultCameras = [camGame];

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		camGame.focusOn(baseCamPos);
		camGame.shake(0.000005, 999999999999);
		camGame.zoom = 0.875 * 1.1;

		Conductor.changeBPM(45.593);

		bloom = new BloomShader();
		bloom.Size.value = [3.0];

		camHUD.setFilters([new ShaderFilter(ntsc = new NTSCSFilter()), new ShaderFilter(bloom)]);
		@:privateAccess var shadersButCooler:Array<BitmapFilter> = [for (shader in camHUD._filters) shader]; // W NAMING!!!!
		shadersButCooler.push(new ShaderFilter(staticShader = new TVStatic()));
		FlxG.camera.setFilters(shadersButCooler);

		blackSprite = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		blackSprite.updateHitbox();
		blackSprite.screenCenter();

		_static = new FlxSprite(0,-350);
		_static.frames = Paths.getSparrowAtlas('modstuff/estatica_uwu');
		_static.animation.addByPrefix('idle', "Estatica papu", 15);
		_static.animation.play('idle');
		_static.alpha = 0.33;
		_static.cameras = [FlxG.camera];
		_static.color = FlxColor.RED;
		_static.screenCenter(X);
		add(_static);

		bottomGroup = new FlxSpriteGroup();
		bottomGroup.cameras = [FlxG.camera];
		add(bottomGroup);

		floor = new FlxSprite(0, 0).loadGraphic(Paths.image('title/floor'));
		floor.antialiasing = ClientPrefs.globalAntialiasing;
		floor.scale.set(0.95, 0.95);
		floor.updateHitbox();
		floor.setPosition(-40.0567375886525, 360); // bros being specific
		bottomGroup.add(floor);

		for (i in 0...2) {
			var hand:FlxSprite = new FlxSprite(96 + (601 * i), 125);
			hand.antialiasing = ClientPrefs.globalAntialiasing;
			hand.frames = Paths.getSparrowAtlas("title/titleAssets");
			hand.animation.addByPrefix("idle", "Spookihand", 24, true);
			hand.animation.play("idle", true);
			hand.scale.set(0.75, 0.75);
			hand.updateHitbox();
			bottomGroup.add(hand);

			handShaders.push(cast hand.shader = new NTSCGlitch(0.2));

			hand.flipX = i == 1; // WHAT NO WAY!!

			hand.ID = i;
			hands.push(hand);
		}

		bf = new FlxSprite(303, 312);
		bf.antialiasing = ClientPrefs.globalAntialiasing;
		bf.frames = Paths.getSparrowAtlas("title/titleAssets");
		bf.animation.addByPrefix("idle", "BF", 24, false);
		bf.animation.play("idle", true);
		bf.scale.set(0.75, 0.75);
		bf.updateHitbox();
		bottomGroup.add(bf);

		gf = new FlxSprite(705, 230);
		gf.antialiasing = ClientPrefs.globalAntialiasing;
		gf.frames = Paths.getSparrowAtlas("title/titleAssets");
		gf.animation.addByPrefix("idle", "GF", 24, false);
		gf.animation.play("idle", true);
		gf.scale.set(0.75, 0.75);
		gf.updateHitbox();
		bottomGroup.add(gf);

		camGame.zoom = 0.875;

		logoBl = new FlxSprite(0, 60).loadGraphic(Paths.image('title/MMv2LogoFINAL'));
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.setGraphicSize(Std.int(logoBl.width * (0.295 * 0.9)));
		logoBl.updateHitbox();
		logoBl.screenCenter(X);
		logoBl.cameras = [camHUD];
		add(logoBl);

		enterSprite = new FlxSprite(0, 560);
		enterSprite.frames = Paths.getSparrowAtlas("title/enter");
		enterSprite.animation.addByPrefix("idle", "EnterLoop", 24, false);
		enterSprite.animation.addByPrefix("press", "EnterBegin", 24, false);
		enterSprite.animation.play("idle");
		enterSprite.cameras = [camHUD];
		enterSprite.updateHitbox();
		enterSprite.screenCenter(X);
		enterSprite.x -= 2;
		add(enterSprite);

		curtain = new FlxSprite().loadGraphic(Paths.image('title/duh'));
		curtain.antialiasing = ClientPrefs.globalAntialiasing;
		curtain.scale.set(1.289 * 0.9, 1.286 * 0.9);
		curtain.updateHitbox();
		curtain.screenCenter();
		curtain.cameras = [camHUD];
		curtain.y = -682.501606766917 * 0.25;
		add(curtain);

		blackSprite.cameras = [camHUD];
		add(blackSprite);

		bottomGroup.setPosition(-170, -26.5);

		camGame.zoom += 0.015;

		(new FlxTimer()).start(Conductor.stepCrochet/1000 * 2, (_) -> {
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn((Conductor.stepCrochet/1000 * 16) * 2, 0, 1.2);

			FlxTween.tween(blackSprite, {alpha: 0}, Conductor.stepCrochet/1000 * 6, {onComplete: (_) -> {
				transitioning = false;

				blackSprite.alpha = 0.05;
				FlxFlicker.flicker(blackSprite, 999999999999);
			}});
			
			FlxTween.tween(curtain, {y: -682.501606766917}, Conductor.stepCrochet/1000 * 4, {ease: FlxEase.circOut, startDelay: (Conductor.stepCrochet/1000) / 8});
			camGame.zoom += 0.075;
			FlxTween.tween(camGame, {zoom: camGame.zoom - 0.075}, (Conductor.stepCrochet/1000 * 12), {ease: FlxEase.circOut});

			persistentUpdate = true;
		});
	}

	var transitioning:Bool = true;
	override function update(elapsed:Float) {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (ntsc != null)
			ntsc.uFrame.value = [Conductor.songPosition];

		if (staticShader != null)
			staticShader.iTime.value = [Conductor.songPosition];

		var currentBeat = (Conductor.songPosition / 1000) * (Conductor.bpm / 60);

		if (bloom != null && !transitioning) {
			bloom.Size.value = [1.0 + (0.5 * FlxMath.fastSin(currentBeat * 2))];
		}

		for (hand in hands) {
			if (hand != null) {
				hand.y = 125 + 20 * FlxMath.fastCos((currentBeat / 2) * Math.PI);
				hand.offset.x = 80.125 + FlxG.random.float(-3.5, 3.5);

				hand.angle = 10 * (hand.ID == 1 ? -1 : 1) * FlxMath.fastSin((currentBeat / 2) * Math.PI);
			}
		}

		for (shader in handShaders)
			shader.time.value = [Conductor.songPosition];

		if (logoBl != null) 
			logoBl.y = 60 + 7.5 * FlxMath.fastCos((currentBeat / 3.) * Math.PI);
		
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		if (FlxG.keys.justPressed.F) {
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		#if mobile
		for (touch in FlxG.touches.list) {
			if (touch.justPressed) {
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null) {
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning) {
			transitioning = true;
			FlxG.mouse.visible = false;
			
			if (titleText != null)
				titleText.animation.play('press');

			if (ClientPrefs.flashing && bloom != null) {
				bloom.Size.value = [18 * 2];
				bloom.dim.value = [0.25];

				var twn1:NumTween;
				var twn2:NumTween;

				twn1 = FlxTween.num(18.0 * 2, 3.0, 1.5, {
					onUpdate: (_) -> {
						bloom.Size.value = [twn1.value];
					}
				});

				twn2 = FlxTween.num(0.25, 2.0, 1.5, {
					onUpdate: (_) -> {
						bloom.dim.value = [twn2.value];
					}
				});
			}

			for (obj in [camGame, curtain, blackSprite])
				FlxTween.cancelTweensOf(obj);

			FlxTween.tween(camGame, {zoom: camGame.zoom + 0.075}, Conductor.stepCrochet/1000 * 4, {ease: FlxEase.circOut});
			FlxG.sound.play(Paths.sound('confirmMenu'));

			enterSprite.offset.set(127, 85);
			enterSprite.animation.play("press", true);

			enterSprite.animation.finishCallback = (_) -> {enterSprite.visible = false;};

			new FlxTimer().start(Conductor.stepCrochet/1000 * 2, function(tmr:FlxTimer) {
				FlxTween.tween(curtain, {y: curtain.y - 40}, (Conductor.stepCrochet/1000), {
					ease: FlxEase.circInOut,
					onComplete: (_) -> {
						FlxTween.tween(curtain, {y: 3}, Conductor.stepCrochet/1000 * 4.6, {ease: FlxEase.quintOut, startDelay: 0.03});

						FlxFlicker.stopFlickering(blackSprite); 
						blackSprite.alpha = 0; blackSprite.visible = true;

						FlxTween.tween(blackSprite, {alpha: 1}, Conductor.stepCrochet/1000 * 2, {
							startDelay: 0.04,
							onComplete: (_) -> {
								FlxG.updateFramerate = 30; // Makes it smoother and consistant

								windowRes = FlxPoint.get(Lib.application.window.width, Lib.application.window.height);
								windowPos = CoolUtil.getCenterWindowPoint();
								startTime = Sys.time();
								
								windowTwn = FlxTween.tween(windowRes, {x: 1280, y: 720}, 0.3 * 4, {ease: FlxEase.circInOut, onUpdate: (_) -> {
									FlxG.resizeWindow(Std.int(windowRes.x), Std.int(windowRes.y));
									CoolUtil.centerWindowOnPoint(windowPos);
									if ((Sys.time() - startTime) > 1.35) {
										windowTwn.cancel();
										completeWindowTwn();
									}
								}, onComplete: function(twn:FlxTween)
									{
										completeWindowTwn();
									}
								});

								FlxG.camera.visible = false;
								camHUD.visible = false;
							}
						});
					}
				});
			});
		}

		super.update(elapsed);
	}

	function completeWindowTwn(){
		FlxG.updateFramerate = ClientPrefs.framerate;
		BaseScaleMode.ogSize = FlxPoint.get(1280, 720); // fuck you haxeflixel

		FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode();

		FlxG.resizeWindow(1280, 720);
		FlxG.resizeGame(1280, 720);
		CoolUtil.centerWindowOnPoint(windowPos);
		
		windowPos.put(); windowPos.put(); baseCamPos.put();

		FlxG.mouse.visible = true;
		MusicBeatState.switchState(new MainMenuState());
	};

	override function stepHit() {
		super.stepHit();

		if (enterSprite != null && curStep % 8 == 0 && enterSprite.animation.name != "press")
			enterSprite.animation.play("idle", true);

		if (bf != null && curStep % 4 == 0)
			bf.animation.play("idle", true);

		if (gf != null && curStep % 4 == 0)
			gf.animation.play("idle", true);

		if (curStep % 4 == 0) {
			for (hand in hands) {
				if (hand != null)
					hand.animation.play("idle");
			}
		}

		if (curStep % 8 == 0) {
			for (shader in handShaders) {
				FlxTween.cancelTweensOf(shader);
				
				FlxTween.num(FlxG.random.float(1, 2), 0.5, (Conductor.stepCrochet / 1000) * 6, {onUpdate: (_:FlxTween) -> {
					shader.setGlitch(cast(_, NumTween).value);
				}});
			}
		}
	}

	override function destroy() {
		super.destroy();
	}
}
