package;

import flash.system.System;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;
	var gfwea:FlxSprite;
	var head:AttachedSprite;
	var hand:AttachedSprite;
	var bfsuff:AttachedSprite;
	var cont:AttachedSprite;
	var timerNumb:Int;
	var timerText:FlxText;
	var shakeEnable:Bool = false;
	var fuckOff:Bool = false;
	var shakeTIMER:Float = 0;
	var endFadeTime:Float = 2;

	var blackBarThingie:FlxSprite;
	var facelessM:BGSprite;
	var cdBF:BGSprite;
	var badMario:BGSprite;
	var badPoof:BGSprite;
	var pibehallyboo:FlxSprite;
	var pibehallytwo:FlxSprite;
	var tvTransition:FlxSprite;
	var soCoolButton:FlxSprite;

	var stageSuffix:String = "";

	var lePlayState:PlayState;

	var timers:Array<FlxTimer> = [];
	var voiceline:FlxSound;

	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOverNew';
	public static var endSoundName:String = 'gameOverEndNew';
	
	public static var customGameOver:Bool = false;
	public static var pngGameOver:Bool = false;
	public static var songFadeOut:Bool = false;
	public static var hasVA:Bool = false;
	public static var vaCount:Int = 1;

	public static function resetVariables()
	{
		characterName = 'bf';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOverNew';
		endSoundName = 'gameOverEndNew';
		customGameOver = false;
		pngGameOver = false;
		songFadeOut = false;
		hasVA = false;
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float, state:PlayState)
	{
		lePlayState = state;
		state.setOnLuas('inGameOver', true);
		super();

		Conductor.songPosition = 0;
		Conductor.changeBPM(50);

		voiceline = new FlxSound().loadEmbedded(Paths.sound(PlayState.curStage + '/line' + FlxG.random.int(1, vaCount)));

		bf = new Boyfriend(x, y, characterName);
		add(bf);

		if(PlayState.curStage == 'luigiout'){
			endSoundName = 'LDOgameover';
			loopSoundName = 'LDOconfirm';
		}
			
		switch(characterName)
		{
			case 'bfPowerdeath':
				bf.x -= 200;
				bf.y -= 200;
			case 'bfASdeath':
				bf.x -= 250;
				bf.y -= 370;
			case 'gfASdeath':
				bf.x += 250;
				bf.y -= 420;
			case 'luigi-ldo':
				deathSoundName = 'LDOLuigideath';
				bf.flipX = false;
				bf.x += 780;
				bf.y -= 200;
			case 'bfbaddeath':
				deathSoundName = 'bad_loss';
				endSoundName = 'badoverEND';
				loopSoundName = 'badover';
				Conductor.changeBPM(75);
				bf.x -= 85;
				bf.y -= 85;
			case 'bfexenewdeath':
				loopSoundName = 'mario_gameovernew';
				endSoundName = 'mario_retry';
				Conductor.changeBPM(120);
				bf.x -= 175;
				bf.y -= 260;
			case 'bf_PDdeath':
				loopSoundName = 'MXgameover';
				deathSoundName = 'MXdeathpowerdown';
				endSoundName = 'MXconfirm';
				Conductor.changeBPM(106);
				bf.x -= 400;
				bf.y -= 450;
			case 'bf_demisedeath':
				loopSoundName = 'MXgameover';
				deathSoundName = 'MXdeathdemise';
				endSoundName = 'MXconfirm';
				Conductor.changeBPM(106);
				bf.x -= 600;
				bf.y -= 150;
			case 'bfsecretgameover':
				customGameOver = true;
				deathSoundName = 'fnf_loss_sfx2';
				loopSoundName = 'SHgameover';
				// endSoundName = 'SHconfirm';
				bf.x -= 600;
				bf.y -= 360;
		}

		//this is actually the worst fucking class in this whole game i hate it so much
			
		if (PlayState.curStage != 'warioworld' 
			&& PlayState.curStage != 'racing' 
			&& PlayState.curStage != 'virtual' 
			&& PlayState.curStage != 'promoshow'
			&& PlayState.curStage != 'wetworld'
			&& PlayState.curStage != 'endstage'
			&& PlayState.curStage != 'nesbeat'
			&& PlayState.curStage != 'piracy'
			&& PlayState.SONG.song != 'Oh God No'
			&& PlayState.curStage !='forest')
			camFollow = new FlxPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y);

		if(PlayState.curStage == 'meatworld')
			camFollow = new FlxPoint(bf.getGraphicMidpoint().x - 1000, bf.getGraphicMidpoint().y - 300);
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		if (PlayState.curStage == 'warioworld')
		{
			pngGameOver = true;

			var pibewario:FlxSprite = new FlxSprite().loadGraphic(Paths.image('modstuff/gameovers/wariodeath'));
			pibewario.updateHitbox();
			pibewario.screenCenter();
			add(pibewario);
		}
		else if (PlayState.curStage == 'directstream')
		{
			pngGameOver = true;

			deathSoundName = 'fnf_loss_sfx2';
			loopSoundName = 'SCgameover';

			var soCool:FlxSprite = new FlxSprite().loadGraphic(Paths.image('modstuff/gameovers/so_cool_gameover'));
			soCool.updateHitbox();
			soCool.screenCenter();
			add(soCool);

			soCoolButton = new FlxSprite().loadGraphic(Paths.image('modstuff/gameovers/so_cool_button'));
			soCoolButton.updateHitbox();
			soCoolButton.setPosition(soCool.x + 540, soCool.y + 545);
			soCoolButton.alpha = 0;
			add(soCoolButton);

			blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
			add(blackBarThingie);

			timers.push(new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					coolStartDeath();
					FlxG.mouse.visible = true;
					FlxTween.tween(blackBarThingie, {alpha: 0}, 5, {ease: FlxEase.sineInOut});
				}));
		}
		else if (PlayState.curStage == 'superbad')
		{
			customGameOver = true;
			
			deathSoundName = 'fnf_loss_sfx2';
			endSoundName = 'badoverEND';
			loopSoundName = 'badover';

			endFadeTime = 4;

			badMario = new BGSprite('mario/BadMario/HUD_Mario_Blue', bf.x - 270, bf.y + 70, ['mario walk'], true);
			badMario.animation.addByIndices('stand', 'mario walk', [0], "", 12, true);
			badMario.animation.addByPrefix('walk', 'mario walk', 12, true);
			badMario.animation.addByPrefix('run', 'mario run', 12, true);
			badMario.animation.addByPrefix('jump', 'jump', 12, true);
			badMario.animation.addByPrefix('fall', 'fall', 12, true);
			badMario.animation.addByPrefix('spin', 'mario spin jump', 18, true);
			badMario.animation.addByPrefix('peace', 'peace', 12, true);
			badMario.antialiasing = false;
			badMario.scale.set(4, 4);
			add(badMario);
			badMario.animation.play('stand');

			badPoof = new BGSprite('mario/BadMario/HUD_Mario_Blue', badMario.x + 60, badMario.y + 130, ['dust cloud'], false);
			badPoof.animation.addByPrefix('poof', 'dust cloud', 12, false);
			badPoof.antialiasing = false;
			badPoof.visible = false;
			badPoof.scale.set(6, 6);
			add(badPoof);
			badPoof.animation.play('poof');

			bf.playAnim('firstDeath');
			
			timers.push(new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					doCustomGameOver();
				}));
		}
		else if (PlayState.curStage == 'forest')
		{
			pngGameOver = true;

			loopSoundName = 'CDgameover';
			deathSoundName = 'CDdeath';
			endSoundName = 'CDconfirm';

			endFadeTime = 4;

			var cdGlitch1:FlxBackdrop = new FlxBackdrop(Paths.image('modstuff/gameovers/coro/glitches_back'), XY);
			cdGlitch1.velocity.set(-500, 400);
			cdGlitch1.updateHitbox();
			cdGlitch1.scale.set(0.5, 0.5);
			cdGlitch1.alpha = 0.5;
			add(cdGlitch1);

			var cdGlitch2:FlxBackdrop = new FlxBackdrop(Paths.image('modstuff/gameovers/coro/glitches_back'), XY);
			cdGlitch2.velocity.set(-350, 280);
			cdGlitch2.updateHitbox();
			add(cdGlitch2);

			var cdSky = new BGSprite('modstuff/gameovers/coro/cd_sky', ['sky'], true);
			cdSky.updateHitbox();
			cdSky.screenCenter();
			add(cdSky);

			var cdGround = new BGSprite('modstuff/gameovers/coro/cd_gameover_ground', ['floor and ceiling'], true);
			cdGround.updateHitbox();
			cdGround.screenCenter();
			cdGround.y -= 15;
			add(cdGround);

			cdBF = new BGSprite('modstuff/gameovers/coro/cd_gameover_bf', ['bf idle'], true);
			cdBF.animation.addByPrefix('idle', 'bf idle', 24, true);
			cdBF.animation.addByPrefix('turn', 'bf confirm', 24, false);
			cdBF.updateHitbox();
			cdBF.screenCenter();
			cdBF.x += 67;
			cdBF.y += 79;
			add(cdBF);
			cdBF.animation.play('idle');

			var cdGlitch3:FlxBackdrop = new FlxBackdrop(Paths.image('modstuff/gameovers/coro/glitches_front'), XY);
			cdGlitch3.velocity.set(-180, 0);
			cdGlitch3.updateHitbox();
			add(cdGlitch3);

			var cdGrad:FlxSprite = new FlxSprite().loadGraphic(Paths.image('modstuff/gameovers/coro/cd_gradient'));
			cdGrad.updateHitbox();
			cdGrad.screenCenter();
			add(cdGrad);

			blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
			add(blackBarThingie);

			timers.push(new FlxTimer().start(2.5, function(tmr:FlxTimer)
				{
					coolStartDeath();
					FlxTween.tween(blackBarThingie, {alpha: 0}, 10, {ease: FlxEase.sineInOut});
				}));

			FlxTween.tween(cdGlitch3, {y: cdGlitch3.y + 150}, 1.3, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
				{
					timers.push(new FlxTimer().start(2.1, function(tmr:FlxTimer)
						{
							FlxTween.tween(cdGlitch3, {y: cdGlitch3.y - 75}, 0.8, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
								{
									FlxTween.tween(cdGlitch3, {y: cdGlitch3.y + 150}, 1.3, {ease: FlxEase.quadInOut});
								}});
						}, 0));
				}});
			
		}
		else if (PlayState.curStage == 'piracy')
		{
			pngGameOver = true;
			hasVA = true;
			vaCount = 6;
			Conductor.changeBPM(170);

			loopSoundName = 'hallyboogameover'; //no loop sound yet boowomp
			deathSoundName = 'hallyboostart';
			endSoundName = 'hallybooretry';

			var bgH1:FlxBackdrop = new FlxBackdrop(Paths.image('mario/piracy/HallyBG4'), XY);
			bgH1.alpha = 0.3;
			bgH1.scale.set(1.6, 1.6);
			bgH1.updateHitbox();
			bgH1.velocity.set(-40, -40);
			bgH1.antialiasing = false;
			add(bgH1);

			pibehallyboo = new FlxSprite().loadGraphic(Paths.image('modstuff/gameovers/hallyboodeath'));
			pibehallyboo.scale.set(0.3, 0.3);
			pibehallyboo.updateHitbox();
			pibehallyboo.screenCenter();
			pibehallyboo.y = 0;
			pibehallyboo.x -= 400;
			add(pibehallyboo);

			pibehallytwo = new FlxSprite().loadGraphic(Paths.image('modstuff/gameovers/hallyboodeath2'));
			pibehallytwo.updateHitbox();
			pibehallytwo.screenCenter();
			pibehallytwo.y = 0;
			pibehallytwo.x -= 400;
			pibehallytwo.scale.set(0.95, 0.95);
			add(pibehallytwo);

			if (ClientPrefs.downScroll)
				pibehallyboo.y += 344;
			else
				pibehallytwo.y += 384;

			blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
			add(blackBarThingie);

			timers.push(new FlxTimer().start(2.5, function(tmr:FlxTimer)
				{
					FlxG.mouse.visible = true;
					coolStartDeath();
					FlxTween.tween(blackBarThingie, {alpha: 0}, 10, {ease: FlxEase.sineInOut});
				}));

		}
		else if (PlayState.curStage == 'landstage' && PlayState.SONG.song != 'Golden Land Old')
		{
			bf.visible = false;
			FlxG.camera.zoom = 0.8;

			songFadeOut = true;

			var pibeGL:FlxSprite = new FlxSprite().loadGraphic(Paths.image('modstuff/gameovers/golden_land_gameover'));
			pibeGL.scale.set(3, 3);
			pibeGL.updateHitbox();
			pibeGL.screenCenter();
			pibeGL.y -= 90;
			pibeGL.alpha = 0;
			add(pibeGL);
			
			deathSoundName = 'GBdeath';
			loopSoundName = 'GBgameover';
			endSoundName = 'GBconfirm';

			timers.push(new FlxTimer().start(1.5, function(tmr:FlxTimer)
				{
					coolStartDeath();
					FlxTween.tween(pibeGL, {alpha: 1}, 20, {ease: FlxEase.sineInOut});
					FlxTween.tween(FlxG.camera, {zoom: 1}, 20, {ease: FlxEase.sineInOut});
				}));
		}
		else if (PlayState.curStage == 'hatebg' && PlayState.SONG.song == 'Oh God No')
		{
			pngGameOver = true;
			songFadeOut = true;

			var pibeOGN:FlxSprite = new FlxSprite().loadGraphic(Paths.image('modstuff/gameovers/OGNdeath'));
			pibeOGN.updateHitbox();
			pibeOGN.screenCenter();
			pibeOGN.alpha = 0;
			add(pibeOGN);
			
			loopSoundName = 'OGN_gameover';
			deathSoundName = 'OGN_die';
			endSoundName = 'OGN_gameoverretry';

			timers.push(new FlxTimer().start(7.5, function(tmr:FlxTimer)
				{
					coolStartDeath();
					FlxTween.tween(pibeOGN, {alpha: 1}, 15, {ease: FlxEase.sineInOut});
				}));
		}
		else if (PlayState.curStage == 'nesbeat')
		{
			pngGameOver = true;

			deathSoundName = 'UBdeath';
			loopSoundName = 'UBgameover';
			endSoundName = 'UBconfirm';

			Conductor.changeBPM(108);

			var pibeYCBU = new BGSprite('modstuff/gameovers/YCBU_GameOver_Assets', ['color screen'], true);
			pibeYCBU.screenCenter();
			// pibeYCBU.y -= 15;
			add(pibeYCBU);

			var pibeYCB2 = new BGSprite('modstuff/gameovers/YCBU_GameOver_Assets', ['text'], true);
			pibeYCB2.screenCenter();
			pibeYCB2.x -= 75;
			pibeYCB2.y += 330;
			add(pibeYCB2);
			
			blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
			blackBarThingie.visible = false;
			add(blackBarThingie);

			tvTransition = new BGSprite('mario/promo/tv_trans', 0, 0, ['transition'], false);
			tvTransition.animation.addByPrefix('dothething', 'transition', 24, false);
			tvTransition.antialiasing = ClientPrefs.globalAntialiasing;
			tvTransition.screenCenter();
			tvTransition.visible = false;
			add(tvTransition);

			timers.push(new FlxTimer().start(1.5, function(tmr:FlxTimer)
				{
					coolStartDeath();
				}));
		}
		else if (PlayState.curStage == 'racing')
		{
			gfwea = new FlxSprite().loadGraphic(Paths.image('modstuff/gameovers/gfsosboluda'));
			gfwea.setGraphicSize(Std.int(gfwea.width * 1.5));
			gfwea.screenCenter();
			gfwea.visible = false;
			add(gfwea);

			bf.visible = false;

			endBullshit();
		}
		else if (PlayState.curStage == 'virtual')
		{
			head = new AttachedSprite('mario/virtual/MrVGameover2');
			head.setGraphicSize(Std.int(head.width * 1.2));
			head.updateHitbox();
			head.screenCenter(Y);
			head.x += 800;
			head.alpha = 0;
			add(head);

			hand = new AttachedSprite('mario/virtual/MrVGameover3');
			hand.setGraphicSize(Std.int(hand.width * 1.2));
			hand.updateHitbox();
			hand.screenCenter(Y);
			hand.alpha = 0;
			hand.x -= 100;
			add(hand);
			bfsuff = new AttachedSprite('mario/virtual/MrVGameover1');
			bfsuff.setGraphicSize(Std.int(bfsuff.width * 1.2));
			bfsuff.updateHitbox();
			bfsuff.screenCenter();
			bfsuff.alpha = 0;
			add(bfsuff);

			bf.visible = false;

			timerText = new FlxText(248, 20, 400, "TIME", 62);
			timerText.setFormat(Paths.font("ModernDOS.ttf"), 62, FlxColor.RED, CENTER);
			timerText.screenCenter(X);
			timerText.y = 765;
			timerText.antialiasing = false;
			timerText.visible = false;
			add(timerText);

			cont = new AttachedSprite('mario/virtual/MrVGameover4');
			cont.screenCenter(X);
			cont.y = timerText.y - 119;
			cont.visible = false;
			add(cont);

			timerNumb = 24;
			timerlook();
		}
		else if (PlayState.curStage == 'promoshow' || PlayState.curStage == 'wetworld' || PlayState.curStage == 'endstage')
		{
			facelessM = new BGSprite('mario/promo/Greenio_GameOver_Assets', ['faceless hang'], true);
			facelessM.animation.addByPrefix('hang', 'faceless hang', 24, true);
			facelessM.animation.addByPrefix('scare', 'faceless scare', 24, false);
			facelessM.updateHitbox();
			facelessM.screenCenter();
			facelessM.alpha = 0;
			facelessM.scale.set(0.5, 0.5);
			add(facelessM);
			facelessM.animation.play('hang');

			FlxG.camera.zoom = 0.8;

			deathSoundName = 'fnf_loss_sfx2';
			bf.visible = false;

			timerNumb = 35;
			timerlook();
		}
		else
		{
			bf.playAnim('firstDeath');
		}

		var exclude:Array<Int> = [];

		FlxG.sound.play(Paths.sound(deathSoundName));
		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
		//trace('quiere ser ' + camFollow + ' pero debe ser ' + camFollowPos);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(PlayState.curStage == 'piracy')
		{
			if (FlxG.mouse.overlaps(pibehallyboo) && FlxG.mouse.justPressed)
			{
				FlxG.mouse.visible = false;
				acceptConfirm();
			}
		}

		if(PlayState.curStage == 'directstream')
		{
			if (FlxG.mouse.overlaps(soCoolButton))
			{
				soCoolButton.alpha = 1;

				if(FlxG.mouse.justPressed){
					FlxG.mouse.visible = false;
					acceptConfirm();
				}
			}
			else{
				soCoolButton.alpha = 0;
			}
		}

		if(lePlayState.oldFX != null && ClientPrefs.filtro85){
		lePlayState.oldFX.update(elapsed);
		}

		if(lePlayState.staticShader != null){
			lePlayState.staticShader.update(elapsed);
		}

		lePlayState.callOnLuas('onUpdate', [elapsed]);
		if (updateCamera)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			if (PlayState.curStage == 'secretbg'){
				lerpVal = CoolUtil.boundTo(elapsed * 1, 0, 1);
				FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1.1, lerpVal);
			}
			if (characterName == 'luigi-ldo'){
				lerpVal = CoolUtil.boundTo(elapsed * 1.6, 0, 1);
			}
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (PlayState.curStage == 'virtual')
		{
			timerText.text = timerNumb + '';

			if (shakeEnable)
			{
				FlxG.camera.shake(shakeTIMER, 0.08);
			}
		}

		if (controls.ACCEPT && PlayState.curStage != 'racing')
		{
			acceptConfirm();
		}

		if (controls.BACK)
		{
			if (timers != null)
				{
					for (timer in timers)
					{
						timer.cancel();
					}
				}
				
			ClientPrefs.saveSettings();
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			if (PlayState.isStoryMode)
			{
				MusicBeatState.switchState(new StoryMenuState());
			}
			else if (PlayState.isWarp)
			{
				MusicBeatState.switchState(new WarpState());
			}
			else
			{
				MusicBeatState.switchState(new MainMenuState());
			}

			// FlxG.sound.playMusic(Paths.music('freakyMenu'));
			lePlayState.callOnLuas('onGameOverConfirm', [false]);
		}

		if (!pngGameOver){
			if (bf.animation.curAnim.name == 'firstDeath')
			{
				{
					if (characterName != 'bf-goomba')
					{
						if (bf.animation.curAnim.curFrame == 12)
						{
							FlxG.camera.follow(camFollowPos, LOCKON, characterName != 'luigi-ldo' ? 1 : 0.2);
							updateCamera = true;
						}

						if (bf.animation.curAnim.finished && characterName != 'luigi-ldo' && !fuckOff)
							{
								if (!customGameOver){
									coolStartDeath();
								}
								else{
									doCustomGameOver();
									// trace('fuck off');
								}
							}
					}
					else
					{
						FlxG.camera.follow(camFollowPos, LOCKON, 0.25);
						updateCamera = true;
						if (bf.animation.curAnim.finished && !fuckOff)
						{
							fuckOff = true;
							timers.push(new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								bf.alpha = 0;
								FlxTween.tween(bf, {alpha: 1}, 7, {ease: FlxEase.quadInOut});
								coolStartDeath();
							}));
						}
					}
				}
			}
		}
		else{
			bf.visible = false;
			FlxG.camera.zoom = 1;
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		lePlayState.callOnLuas('onUpdatePost', [elapsed]);
	}

	function acceptConfirm()
	{
		if (timers != null)
			{
				for (timer in timers)
				{
					timer.cancel();
				}
			}

		if (PlayState.curStage == 'virtual')
		{
			Main.skipNextDump = true;
			MusicBeatState.resetState();
		}
		else
		{
			if (PlayState.curStage == 'superbad')
				badMario.visible = false;
			if (characterName != 'bf-goomba')
				endBullshit();
			else if (bf.startedDeath)
				endBullshit();
		}
	}

	function doCustomGameOver()
	{
		switch(characterName){
			case 'bfbaddeath':
				// jump to mic
				fuckOff = true;
				badMario.animation.play('walk', true);
				FlxTween.tween(badMario, {x: badMario.x + 30}, 0.15, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
					{
						if(!isEnding){
							badMario.animation.play('spin', true);
							FlxG.sound.play(Paths.sound('bad-day/smw_spinjump'), 0.8);
						}
						FlxTween.tween(badMario, {x: badMario.x + 300}, 0.6, {ease: FlxEase.linear});
						FlxTween.tween(badMario, {y: badMario.y - 100}, 0.25, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
							{
								FlxTween.tween(badMario, {y: badMario.y + 150}, 0.35, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
									{
										if(!isEnding){
											FlxG.sound.play(Paths.sound('bad-day/smw_shell_kick'), 0.8);
											FlxG.sound.play(Paths.sound('fnf_loss_sfx3'), 0.4);
											bf.playAnim('secondDeath');
											badPoof.setPosition(badMario.x + 70, badMario.y + 145);
											badPoof.animation.play('poof');
											badPoof.visible = true;
										}
										//jump to balls
										FlxTween.tween(badMario, {x: badMario.x + 180}, 0.55, {ease: FlxEase.linear});
										FlxTween.tween(badMario, {y: badMario.y - 40}, 0.15, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
											{
												FlxTween.tween(badMario, {y: badMario.y + 160}, 0.4, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
													{
														if(!isEnding){
															FlxG.sound.play(Paths.sound('bad-day/smw_break_block'), 0.8);
															bf.playAnim('thirdDeath');
															badPoof.setPosition(badMario.x + 65, badMario.y + 130);
															badPoof.animation.play('poof');
														}
														//jump to floor
														FlxTween.tween(badMario, {x: badMario.x + 130}, 0.45, {ease: FlxEase.linear});
														FlxTween.tween(badMario, {y: badMario.y - 40}, 0.15, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
															{
																FlxTween.tween(badMario, {y: badMario.y + 160}, 0.3, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
																	{
																		badMario.animation.play('walk', true);
																		//walk away
																		FlxTween.tween(badMario, {x: badMario.x + 130}, 0.6, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
																			{
																				badMario.animation.play('peace', true);
																				if(!isEnding){
																					FlxG.sound.play(Paths.sound('bad-day/smw_item_reserve'), 0.4);
																					FlxG.sound.play(Paths.sound('bad-day/line' + FlxG.random.int(1, 6)), 0.7);
																					bf.playAnim('fourthDeath');
																				}
																				timers.push(new FlxTimer().start(0.75, function(tmr:FlxTimer)
																					{
																						badMario.animation.play('walk', true);
																						//play bf retry here
																						if(!isEnding)
																							coolStartDeath();
																						FlxTween.tween(badMario, {x: badMario.x + 240}, 1, {ease: FlxEase.linear});
																						FlxTween.tween(badMario, {alpha: 0}, 1, {ease: FlxEase.quadIn});
																					}));
																			}});
																	}});
															}});
													}});
											}});
									}});
							}});
					}});
			
			case 'bfsecretgameover':
				FlxG.camera.follow(camFollowPos, LOCKON, 0.25);
				updateCamera = true;
				if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished){
					fuckOff = true;
					timers.push(new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							FlxG.sound.play(Paths.sound('SHtalk'));				
							timers.push(new FlxTimer().start(4.1, function(tmr:FlxTimer) // timer will be length of the voiceline
								{
									if(bf != null) bf.playAnim('secondDeath');
									FlxG.sound.play(Paths.sound('SHdeath'));
									timers.push(new FlxTimer().start(3, function(tmr:FlxTimer)
										{
											coolStartDeath();
										}));
								}));
						}));
				}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		// FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		if (PlayState.curStage != 'warioworld' && PlayState.curStage != 'racing' && PlayState.curStage != 'virtual')
		{
			FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
			bf.startedDeath = true;
			if (!isEnding && bf.animOffsets.exists('deathLoop')){
				bf.playAnim('deathLoop', true);
			}
			timers.push(new FlxTimer().start(Math.floor(1 + (Conductor.bpm / 60)), function(tmr:FlxTimer)
				{
					if (!isEnding && bf.animOffsets.exists('deathLoop'))
						bf.playAnim('deathLoop', true);
					if(!isEnding && PlayState.curStage == 'piracy'){
						pibehallytwo.scale.set(1, 1);
						FlxTween.tween(pibehallytwo.scale, {x: 0.95, y: 0.95}, 0.4, {ease: FlxEase.quadOut});
					}
					if(!isEnding && PlayState.curStage == 'nesbeat'){
						FlxG.camera.zoom = 1.1;
						FlxTween.tween(FlxG.camera, {zoom: 1}, 0.4, {ease: FlxEase.quadOut});
					}
				}, 0));
		}
		playVoiceline();
	}

	function playVoiceline(time:Float = 2.5):Void
	{
		if (hasVA)
			{
				trace('hasVA is ' + hasVA + ', playing voiceline');
				timers.push(new FlxTimer().start(time, function(tmr:FlxTimer)
					{
						var startingVolume:Float = FlxG.sound.music.volume;
						FlxTween.tween(FlxG.sound.music, {volume: startingVolume / 2}, 1, {onComplete: function(twn:FlxTween)
						{
							voiceline.volume = 0.7;
							voiceline.play();
							// var voiceline = new FlxSound().Paths.sound(PlayState.curStage + '/line' + FlxG.random.int(1, vaCount));
							timers.push(new FlxTimer().start(voiceline.length / 1000, function(tmr:FlxTimer){
								FlxTween.tween(FlxG.sound.music, {volume: startingVolume}, 1);
							}));
						}});
					}));
			}
	}

	function timerlook():Void
	{
		switch (PlayState.curStage)
		{
			case 'virtual':
				switch (timerNumb)
				{
					case 20:
						cont.visible = true;
						timerText.visible = true;
						FlxG.sound.playMusic(Paths.music('mrvover'), 1);
						playVoiceline(1.5);

					case 15:
						FlxTween.tween(hand, {alpha: 1}, 5);
						FlxTween.tween(head, {alpha: 1}, 5);

					case 4:
						shakeEnable = true;
						FlxTween.tween(bfsuff, {alpha: 1}, 3);
						FlxTween.tween(this, {shakeTIMER: 0.05}, 3, {ease: FlxEase.quadIn});

					case 1:
						shakeEnable = false;
						FlxG.camera.zoom = FlxG.camera.zoom * 1.5;

					case 0:
						FlxG.sound.music.stop();
						System.exit(0);
				}

			case 'promoshow' | 'wetworld' | 'endstage':
				switch (timerNumb){

					case 34:
						FlxG.sound.playMusic(Paths.music('greenioover'), 1);
					case 30:
						FlxTween.tween(facelessM, {alpha: 0.75}, 25);
						FlxTween.tween(facelessM.scale, {x: 1.2, y: 1.2}, 25);
					case 1:
						facelessM.animation.play('scare');
						facelessM.updateHitbox();
						facelessM.screenCenter();
						facelessM.scale.set(1, 1);
						facelessM.y += 70;
						facelessM.x += 80;
						timers.push(new FlxTimer().start(0.373, function(tmr:FlxTimer){
							facelessM.alpha = 0;
							Main.skipNextDump = true;
							MusicBeatState.resetState();
						}));
				}
				
		}
		timers.push(new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			if (timerNumb > 0 && !isEnding)
			{
				timerNumb--;
				timerlook();
			}
		}));
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			if (PlayState.curStage == 'racing')
			{
				isEnding = true;
				if (PlayState.getspeed != 0)
				{
					PlayState.SONG.speed = PlayState.getspeed;
				}

				timers.push(new FlxTimer().start(0.7, function(tmr:FlxTimer)
				{
					FlxG.camera.flash(FlxColor.BLACK, 0.5);
					gfwea.visible = true;
				}));

				timers.push(new FlxTimer().start(1.8, function(tmr:FlxTimer)
				{
					if(PlayState.deathCounter == 3 && (PlayState.isStoryMode || PlayState.isWarp)){
						MusicBeatState.switchState(new BotplayState());
					}else{
						Main.skipNextDump = true;
						MusicBeatState.resetState();
					}
				}));
			}
			else
			{
				isEnding = true;
				if (bf.animOffsets.exists('deathConfirm'))
					bf.playAnim('deathConfirm', true);
				if(PlayState.curStage == 'castlestar'){
					FlxTween.tween(FlxG.sound.music, {volume: 0}, 4, {startDelay: 2});
					endFadeTime = 6;
				}
				if(PlayState.curStage == 'nesbeat'){
					if(ClientPrefs.flashing){
						tvTransition.visible = true;
						blackBarThingie.visible = true;
						tvTransition.animation.play('dothething', true);
					}
				}
				if(PlayState.curStage == 'forest'){
					cdBF.animation.play('turn', true);
					cdBF.x -= 41;
				}
				if(!songFadeOut)
					FlxG.sound.music.stop();
				else
					FlxTween.tween(FlxG.sound.music, {volume: 0}, 2.5);
				if(hasVA)
					voiceline.stop();
				FlxG.sound.play(Paths.music(endSoundName));
				if(PlayState.curStage == 'landstage')
					FlxG.sound.play(Paths.music('GBchuckle'));
				
				timers.push(new FlxTimer().start(endFadeTime * 0.35, function(tmr:FlxTimer)
				{
					FlxG.camera.fade(FlxColor.BLACK, endFadeTime * 0.65, false, function()
					{
						if(PlayState.deathCounter == 3 && (PlayState.isStoryMode || PlayState.isWarp)){
							MusicBeatState.switchState(new BotplayState());
						}else{
							Main.skipNextDump = true;
							MusicBeatState.resetState();
						}
					});
				}));
				lePlayState.callOnLuas('onGameOverConfirm', [true]);
			}
		}
	}
}
