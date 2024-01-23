package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

class GrandDadRunners extends FlxSprite
{
	var animsArray:Array<String> = [
		"buff luigi run",
		"bulk bogan run",
		"fella and nozomi",
		"garfield stuff",
		"marcianito",
		"pantherk walk",
		"protegent",
		"skeletor run",
		"painting",
		"bob ross stuff",
		"pacman run"
	];

	var charName:String;
	var runSpeed:Float = 1;
	var distancePosistion:Int;
	var playedFunnyAnim:Bool = false;
	public function new(x:Float, y:Float, distancePos:Int, animPosRand:Int)
	{
		charName = animsArray[animPosRand];
		switch(charName){
			case "bob ross stuff":
				x += 2200;
				y += 100;
			case 'bulk bogan run':
				x += 2200;
				y -= -56;
			case "buff luigi run":
				x += 2200;
			case "garfield stuff":
				x += 2200;
				y -= -120;
			case 'protegent':
				x += 2200;
				y -= 110;
			case 'skeletor run':
				x += 2200;
				y -= 90;
			case "fella and nozomi":
				x -= 2200;
				y -= 41;
			case "marcianito":
				x -= 2200;
				y -= 260;
			case 'pacman run':
				x -= 2200;
				y -= -521;
			case 'pantherk walk':
				x -= 2200;	
				y -= 50;
			case "painting":
				x += 2200;
				y += 100;
				distancePos++;
		}

		y += height * ((distancePos * 0.08));
		super(x, y);

		frames = Paths.getSparrowAtlas("mario/dad7/GrandDad_BGCameo_Assets");
		switch(charName){
			case 'boutta fuggin nut SHIT':
				animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
			case 'painting':
				animation.addByPrefix('paint', 'bob ross easel', 24, true);
				animation.addByPrefix('bob ross stuff', 'bob ross stuff', 24, true);
				animation.play('bob ross stuff', true, false, 0);
				alpha = 0;
			default:
				animation.addByPrefix(charName, charName, 24, true);
				animation.play(charName, false, false, FlxG.random.int(1, 10));
				if(charName == 'bob ross stuff') animation.play(charName, true, false, 0);
		}

		scale.set(0.3 + (distancePos * 0.08), 0.3 + (distancePos * 0.08));
		updateHitbox();


		distancePosistion = distancePos;
		
		antialiasing = ClientPrefs.globalAntialiasing;

		runSpeed = 1 * ((distancePosistion + 4) * 0.6);
		if(charName == 'protegent') runSpeed = runSpeed * 1.5;
		trace(charName, x, y, distancePos);
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		if(PlayState.gdRunners.visible){
			switch(charName){
				case "bob ross stuff" | 'bulk bogan run' | "buff luigi run" | "garfield stuff" | 'protegent' | 'skeletor run'| 'painting':
					x -= (runSpeed * elapsed) * 60;		
				case "fella and nozomi" | "marcianito" | 'pacman run' | 'pantherk walk':
					x += (runSpeed * elapsed) * 60;		
			}
		}

		if(charName == 'bob ross stuff' || charName == 'painting'){
			if(animation.curAnim.curFrame == 16){
				if(!playedFunnyAnim && 600 > x){
					runSpeed = 0;
					offset.y = 150;
					offset.x = 270;
					new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							playedFunnyAnim = true;
						});
				}
				else{
					animation.curAnim.curFrame = 0;
				}
			}
			if(playedFunnyAnim && animation.curAnim.curFrame == 80){
				//x -= 220;
				offset.x = 0;
				offset.y = 0;
				animation.curAnim.curFrame = 0;
				if(charName == 'painting'){
					animation.play('paint', true);
					alpha = 1;
					offset.y = -66;
					offset.x = 165;
				}
			}
			if(animation.curAnim.curFrame == 0 && animation.curAnim.name != 'paint'){
				runSpeed = 1 * ((distancePosistion + 2) * 0.9);
			}
		}
		if(charName == 'garfield stuff'){
			if(animation.curAnim.curFrame == 26){
				if(!playedFunnyAnim && 1000 > x){
					runSpeed = 0;
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						playedFunnyAnim = true;
					});
				}
				else{
					animation.curAnim.curFrame = 0;
				}
			}
			if(animation.curAnim.curFrame == 0){
				runSpeed = 1 * ((distancePosistion + 2) * 0.6);
			}
		}
	}
}
