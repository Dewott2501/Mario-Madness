package;

#if desktop
import Discord.DiscordClient;
#end
import TitleScreenShaders.NTSCGlitch;
import TitleScreenShaders.NTSCSFilter;
import TitleScreenShaders.TVStatic;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.mouse.FlxMouse;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.ValueException;
import lime.utils.Assets;
import openfl.filters.ShaderFilter;
import sys.io.File;

using StringTools;

class PatchNotes extends MusicBeatState
{
	var pageBar:FlxSprite;
	var bg:FlxSprite;
	var noteText:FlxText;
	var descText:FlxText;
	var mousey:Float = 0;
	var ogTexty:Float = 0;
	var wheely:Float = 0;
	var isdrag:Bool = false;
	var iswheel:Bool = false;
	var canScroll:Bool = false;

	var ntsc:NTSCGlitch;
	var staticShader:TVStatic;

	private var verBoxes:FlxTypedGroup<FlxSprite>;
	private var verSprites:FlxTypedGroup<FlxSprite>;

	var versions:Array<Dynamic> = [['2.0.1', '01/23/2024']/*, ['3.0.0', '01/08/2035']*/];

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		
		DiscordClient.changePresence("In the Menus", null);
		#end
		FlxG.mouse.visible = true;

		FlxG.camera.setFilters([new ShaderFilter(ntsc = new NTSCGlitch(0.4)), new ShaderFilter(staticShader = new TVStatic())]);

		bg = new FlxSprite(0, 0).loadGraphic(Paths.image('mainmenu/Patch/patch0'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.updateHitbox();
		bg.screenCenter(XY);
		add(bg);	

		pageBar = new FlxSprite().makeGraphic(20, 720, FlxColor.WHITE);
		pageBar.alpha = 0.7;
		pageBar.x += 1270;
		pageBar.visible = false;
		add(pageBar);

		noteText = new FlxText(500, 30, 700, "Example Text", 28);
		noteText.setFormat(Paths.font("ModernDOS.ttf"), 36, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(noteText); 
		noteText.visible = false;
		//noteText.text = 'Example Text\nExample Text';
		noteText.text = '';

		verSprites = new FlxTypedGroup<FlxSprite>();
		add(verSprites);

		verBoxes = new FlxTypedGroup<FlxSprite>();
		add(verBoxes);

		for(i in 0... versions.length){
			var verSquare = new FlxSprite(10, 20).loadGraphic(Paths.image('mainmenu/Patch/patch1'));
			verSquare.antialiasing = ClientPrefs.globalAntialiasing;
			verSquare.updateHitbox();
			verSquare.y += (verSquare.height * i) + 20;
			verSquare.ID = i;
			verSprites.add(verSquare);

			var format = new FlxTextFormat(FlxColor.RED, false, false, FlxColor.RED);
			format.leading = 10;

			var verText:FlxText = new FlxText(0, 680, 1280, "2.0.0\n01/01/2024", 16);
			verText.setFormat(Paths.font("mariones.ttf"), 24, FlxColor.RED, LEFT);
			verText.scrollFactor.set(0.2, 0.2);
			verText.ID = i;
			verText.setPosition(verSquare.x + 30, verSquare.y + 40);
			verText.text = versions[i][0] + '\n' + versions[i][1] + '\n ';
			add(verText);

			verText.addFormat(format);

			var box = new FlxSprite().makeGraphic(Std.int(verSquare.width), Std.int(verSquare.height), FlxColor.WHITE);
			box.ID = i;
			box.alpha = 0;
			box.setPosition(verSquare.x, verSquare.y);
			verBoxes.add(box);
		}
		//1 line 32
		//2 lines 60 				28
		descText = new FlxText(0, 0, 0, "Example Text", 16);
		//add(descText);

		var bgB = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bgB.alpha = 1;
		bgB.scrollFactor.set();
		add(bgB);

		FlxTween.tween(bgB, {alpha: 0}, 0.5);

		mousey = FlxG.mouse.screenY;
		ogTexty = noteText.y;
		wheely = noteText.y;
	}

	override function update(elapsed:Float)
	{
		descText.text = noteText.x + '\n' + noteText.y + '\n' + noteText.height + '\n' + iswheel + '\n';

		
		pageBar.y = ((noteText.y - 30) * -1) / 1.1;

		verBoxes.forEach(function(box:FlxSprite)
			{
				if(FlxG.mouse.overlaps(box)){
					verSprites.forEach(function(sprite:FlxSprite)
						{
							if(sprite.ID == box.ID) sprite.color = 0xFF0000;
						});
					if(FlxG.mouse.justPressed) changePatchNotes(box.ID);
				}else{
					verSprites.forEach(function(sprite:FlxSprite)
						{
							if(sprite.ID == box.ID) sprite.color = 0x690000;
						});
				}
			});

		if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}

		if(canScroll){
		if (FlxG.mouse.justPressed){
			mousey = FlxG.mouse.screenY;
			ogTexty = noteText.y;
			wheely = noteText.y;
			iswheel = false;
		}

		if(FlxG.mouse.pressed){
			wheely = ogTexty - (mousey - FlxG.mouse.y);
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 9, 0, 1);
			noteText.y = FlxMath.lerp(noteText.y, wheely, lerpVal);
			isdrag = true;
		}
		else{
			isdrag = false;
		}

		if(isdrag){
			if(noteText.y < (FlxG.height - (noteText.height + 30))){
				noteText.y = (FlxG.height - (noteText.height + 30));
			}
			else if(noteText.y > 30){
				noteText.y = 30;
			}
		}

		if(FlxG.mouse.justReleased){
			if(wheely < (FlxG.height - (noteText.height + 30)) && noteText.y > wheely){
				wheely = (FlxG.height - (noteText.height + 30));
			}
			else if(wheely > 30 && noteText.y < wheely){
				wheely = 30;
			}
		}

		if (FlxG.mouse.wheel != 0)
		{
			wheely += (FlxG.mouse.wheel * 50);

			if(wheely < (FlxG.height - (noteText.height + 30)) && noteText.y > wheely){
				wheely = (FlxG.height - (noteText.height + 30));
			}
			else if(wheely > 30 && noteText.y < wheely){
				wheely = 30;
			}
		}

		if(noteText.y >= wheely - 0.1 && noteText.y <= wheely + 0.1) iswheel = false;
		else iswheel = true;

		if(iswheel){
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 9, 0, 1);
			noteText.y = FlxMath.lerp(noteText.y, wheely, lerpVal);

		}
		}

		if(staticShader != null){
			staticShader.update(elapsed);
		}

		if(ntsc != null){
			ntsc.update(elapsed);
		}

		super.update(elapsed);
	}

	function changePatchNotes(ver:Int) {

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		noteText.text = File.getContent(Paths.txt('Patchs/' + ver));
		noteText.visible = true;
		noteText.y = 30;
		pageBar.visible = true;
		if(noteText.height > FlxG.height){
			if(noteText.height > 1390){
				pageBar.setGraphicSize(Std.int(pageBar.width), 50);
			}else{
				pageBar.setGraphicSize(Std.int(pageBar.width), Std.int(pageBar.height - (noteText.height - 720)));
				pageBar.y = 0;
				trace(pageBar.height - (noteText.height - 720));
			}
			pageBar.updateHitbox();
			canScroll = true;
		}else{
			pageBar.visible = false;
			canScroll = false;
		}

	}

}