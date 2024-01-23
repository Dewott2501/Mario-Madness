package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;

class BotplayState extends MusicBeatState
{
    var msg:FlxSprite;
	var msgText:FlxText;
	var buttons:FlxTypedGroup<FlxSprite>;
	var edges:FlxSpriteGroup;
	var edgeTweens:Array<FlxTween> = [];

	var format1 = new FlxTextFormat(0xFFFFFF, false, false, 0x00FFFFFF);

	var canSelect:Bool = false;
	var curSelect:Int = 0;
	override function create()
	{
		if (FlxG.sound.music != null) FlxG.sound.music.stop();

        msg = new FlxSprite(0, -720).loadGraphic(Paths.image('modstuff/luigi/luigiMSG'));
        add(msg);

		buttons = new FlxTypedGroup<FlxSprite>();
		add(buttons);

		format1.leading = -5;

		msgText = new FlxText(175, 169 - 720, 1180, "Ugh, you seriously can't do this on your own?!\nFine, I'll help you. but only\nbecause watching you try and\nfail again and again is physically\npaining me to watch.", 32);
		msgText.setFormat(Paths.font("URW.ttf"), 32, FlxColor.WHITE, LEFT);
		msgText.addFormat(format1);
		add(msgText);

		var buttonpos:Array<Dynamic> = [[297, 497], [659, 497], [478, 583]];
		for(i in 0... 3){
			var button:FlxSprite = new FlxSprite(buttonpos[i][0], buttonpos[i][1] - 720);
			button.frames = Paths.getSparrowAtlas('modstuff/luigi/luigiSelect');
			button.animation.addByPrefix('idle', 'luigiSelect ' + i + '0000', 24, false);
			button.animation.addByPrefix('select', 'luigiSelect ' + i + '0001', 24, false);
			button.animation.play('idle');
			button.updateHitbox();
			button.antialiasing = true;
			button.ID = i;
			FlxTween.tween(button, {y: buttonpos[i][1]}, 0.4, {ease: FlxEase.bounceOut});

			button.scale.set(0.9, 0.9);

			buttons.add(button);

		}


		edges = new FlxSpriteGroup(295, 495);
		var edgepos:Array<Dynamic> = [[0, 0, -1, -1], [310, 0, 1, -1], [310, 44, 1, 1], [0, 44, -1, 1]];
		for(i in 0... 4){
			var edge:FlxSprite = new FlxSprite(edgepos[i][0], edgepos[i][1]).loadGraphic(Paths.image('modstuff/luigi/edge'));
			edge.updateHitbox();
			edge.angle += 90 * i;
			edge.ID = i;
			edges.add(edge);
			edgeTweens.push(FlxTween.tween(edge, {x: edge.x + (4 * edgepos[i][2]), y: edge.y + (4 * edgepos[i][3])}, 0.4, {ease: FlxEase.quadInOut, type: PINGPONG}));


		}
		add(edges);
		edges.visible = false;

		FlxTween.tween(msg, {y: 0}, 0.4, {ease: FlxEase.bounceOut});
		FlxTween.tween(msgText, {y: 169}, 0.4, {ease: FlxEase.bounceOut, onComplete: function(twn:FlxTween)
			{
				edges.visible = true;
				canSelect = true;
			}});

		select(0);
	}

	override function update(elapsed:Float)
	{
		if(canSelect){
		buttons.forEach(function(spr:FlxSprite)
			{
				if (FlxG.mouse.overlaps(spr))
				{				
					select(spr.ID);
				}

				if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(spr)){
					//goToState();
					canSelect = false;
					FlxTween.tween(spr.scale, {x: 0.9, y: 0.9}, 0.05, {ease: FlxEase.cubeIn, onComplete: function(twn:FlxTween){
						spr.animation.play('select');
						edges.visible = false;
						FlxTween.tween(spr.scale, {x: 1, y: 1}, 0.25, {ease: FlxEase.cubeOut, onComplete: function(twn:FlxTween){
							selected(spr.ID);
						}});
					}});
				}else{

				}
			});
		}
		super.update(elapsed);
	}

	function select(selected:Int){
		if(selected != curSelect){
			curSelect = selected;
			for (tween in edgeTweens)
			{
				tween.cancel();
			}

			buttons.forEach(function(spr:FlxSprite)
				{
					if(selected == spr.ID){
						spr.scale.set(1, 1);
					}else{
						spr.scale.set(0.9, 0.9);
					}
				});

			switch(selected){
				case 0:
					edges.setPosition(298, 496);
				case 1:
					edges.setPosition(660, 496);
				case 2:
					edges.setPosition(479, 582);
			}

			var edgepos:Array<Dynamic> = [[0, 0, -1, -1], [310, 0, 1, -1], [310, 44, 1, 1], [0, 44, -1, 1]];
			edges.forEach(function(edge:FlxSprite)
			{
				var i:Int = edge.ID;
				edge.setPosition((edgepos[i][0] + edges.x), (edgepos[i][1] + edges.y));
				edgeTweens.push(FlxTween.tween(edge, {x: edge.x + (4 * edgepos[i][2]), y: edge.y + (4 * edgepos[i][3])}, 0.4, {ease: FlxEase.quadInOut, type: PINGPONG}));
			});
		}
	}

	function selected(selected:Int) {
		FlxTween.tween(msg, {y: msg.y + 720}, 0.4, {ease: FlxEase.cubeIn});
		buttons.forEach(function(spr:FlxSprite){
			FlxTween.tween(spr, {y: spr.y + 720}, 0.4, {ease: FlxEase.cubeIn});
		});
		FlxTween.tween(msgText, {y: msgText.y + 720}, 0.4, {ease: FlxEase.cubeIn, onComplete: function(twn:FlxTween){
			switch(selected){
				case 0:
					loadSong(false);
				case 1:
					if (PlayState.isWarp)
						{
							MusicBeatState.switchState(new WarpState());
					}else{
						MusicBeatState.switchState(new MainMenuState());
					}
				case 2:
					loadSong(true);
			}
		}});
	}

	function loadSong(luigi:Bool){
		PlayState.cpuControlled = luigi;
		LoadingState.loadAndSwitchState(new PlayState());
	}
}
