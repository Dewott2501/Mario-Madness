package;

import Controls;
import discord_rpc.DiscordRpc;
import flash.text.TextField;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.effects.FlxFlicker;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.app.Application;
import lime.utils.Assets;

using StringTools;
#if desktop
import Discord.DiscordClient;
#end

// TO DO: Redo the menu creation system for not being as dumb
// Yeah seems like a reasonable goal to me
class MMOptions extends MusicBeatSubstate
{
	var options:Array<String> = ['Notes', 'Controls', 'Preferences', 'Mario Options', 'Delete Data'];
	private var grpOptions:FlxTypedGroup<FlxText>;

	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	var cosotexto:Array<String> = ['idk', 'sexo'];
	var txtthing:String = Paths.txt('wea');
	var noway:FlxText;
	var noMan:FlxText;
	var splitHex:Array<String>;
	var splitName:Array<String>;
	var cambiotexto:Int = 0;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		FlxG.sound.playMusic(Paths.music('options'), 1);
        FlxG.camera.bgColor = 0x00FFFFFF;

        FlxG.camera.zoom = 0.95;
		MainMenuState.instance.lerpCamZoom = true;
		MainMenuState.instance.camZoomMulti = 0.94;
        
		FlxG.state.persistentDraw = true;

		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:FlxText = new FlxText(0, 0, 0, options[i], 32);
			optionText.setFormat(Paths.font("mariones.ttf"), 48, FlxColor.RED, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			optionText.borderSize = 4; optionText.ID = i;
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);

			optionText.x -= 600+(500*i);
			FlxTween.tween(optionText, {x: optionText.x + 600+(500*i)}, .4 +(0.2*i), {ease: FlxEase.circInOut});
		}
		changeSelection();

		var verText:FlxText = new FlxText(0, 680, 1280, "Mario's Madness\nv2.0.1", 16);
		verText.setFormat(Paths.font("mariones.ttf"), 16, FlxColor.RED, LEFT);
		verText.scrollFactor.set(0.2, 0.2);
		add(verText);

		verText.alpha = 0; verText.y += 20;
		FlxTween.tween(verText, {y: verText.y - 20, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: .5});

		super.create();
	}

	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();
		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.UP)
		{
			changeSelection(-1);
		}
		if (FlxG.keys.justPressed.DOWN)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.state.closeSubState();
			FlxG.mouse.visible = true;
			FlxG.sound.music.stop();
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 1);

			#if desktop
			DiscordClient.changePresence("In the Menus", null);
			#end
		}

		if (controls.ACCEPT)
		{
			for (item in grpOptions.members)
			{
				item.alpha = 0;
			}

			switch (options[curSelected])
			{
				case 'Notes':
					openSubState(new NotesSubstate());

				case 'Controls':
					openSubState(new ControlsSubstate());

				case 'Preferences':
					openSubState(new PreferencesSubstate());

				case 'Mario Options':
					openSubState(new MarioSubstate());
				case 'Delete Data':
					openSubState(new DeleteSubstate());
			}
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length-1);

		for (i=>item in grpOptions.members) {
			item.alpha = 0.4; item.color = 0xFF680F0F;
			if (item.ID == curSelected) {item.alpha = 1; item.color = 0xFFFF0000;}
		}
	}
}

class NotesSubstate extends MusicBeatSubstate
{
	private static var curSelected:Int = 0;
	private static var typeSelected:Int = 0;

	private var grpNumbers:FlxTypedGroup<Alphabet>;
	private var grpNotes:FlxTypedGroup<FlxSprite>;
	private var shaderArray:Array<ColorSwap> = [];
	var curValue:Float = 0;
	var holdTime:Float = 0;
	var hsvText:Alphabet;
	var nextAccept:Int = 5;

	var posX = 250;

	public function new()
	{
		super();

		grpNotes = new FlxTypedGroup<FlxSprite>();
		add(grpNotes);
		grpNumbers = new FlxTypedGroup<Alphabet>();
		add(grpNumbers);

		for (i in 0...ClientPrefs.arrowHSV.length)
		{
			var yPos:Float = (140 * i) + 85;
			for (j in 0...3)
			{
				var optionText:Alphabet = new Alphabet(0, yPos, Std.string(ClientPrefs.arrowHSV[i][j]));
				optionText.size = 24;
				optionText.x = posX + (225 * j) + 100 - ((optionText.lettersArray.length * 90) / 2);
				optionText.y = yPos+20;
				grpNumbers.add(optionText);
			}

			var note:FlxSprite = new FlxSprite(posX - 70, yPos);
			note.frames = Paths.getSparrowAtlas('Mario_NOTE_assets');
			switch (i)
			{
				case 0:
					note.animation.addByPrefix('idle', 'purple0');
				case 1:
					note.animation.addByPrefix('idle', 'blue0');
				case 2:
					note.animation.addByPrefix('idle', 'green0');
				case 3:
					note.animation.addByPrefix('idle', 'red0');
			}
			note.animation.play('idle');
			note.antialiasing = ClientPrefs.globalAntialiasing;
			note.scale.set(0.7, 0.7);
			note.updateHitbox();
			grpNotes.add(note);

			var newShader:ColorSwap = new ColorSwap();
			note.shader = newShader.shader;
			newShader.hue = ClientPrefs.arrowHSV[i][0] / 360;
			newShader.saturation = ClientPrefs.arrowHSV[i][1] / 100;
			newShader.brightness = ClientPrefs.arrowHSV[i][2] / 100;
			shaderArray.push(newShader);
		}
		hsvText = new Alphabet(0, 0, "Hue    Saturation  Brightness", false, false, 0, 0.65);
		hsvText.size = 18;
		add(hsvText);
		changeSelection();
	}

	var changingNote:Bool = false;
	var hsvTextOffsets:Array<Float> = [240, 10];

	override function update(elapsed:Float)
	{
		if (changingNote)
		{
			if (holdTime < 0.5)
			{
				if (FlxG.keys.justPressed.LEFT)
				{
					updateValue(-1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				else if (FlxG.keys.justPressed.RIGHT)
				{
					updateValue(1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				else if (controls.RESET)
				{
					resetValue(curSelected, typeSelected);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				if (FlxG.keys.justReleased.RIGHT || FlxG.keys.justReleased.RIGHT)
				{
					holdTime = 0;
				}
				else if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
				{
					holdTime += elapsed;
				}
			}
			else
			{
				var add:Float = 90;
				switch (typeSelected)
				{
					case 1 | 2:
						add = 50;
				}
				if (FlxG.keys.pressed.LEFT)
				{
					updateValue(elapsed * -add);
				}
				else if (FlxG.keys.pressed.RIGHT)
				{
					updateValue(elapsed * add);
				}
				if (FlxG.keys.justReleased.RIGHT || FlxG.keys.justReleased.RIGHT)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					holdTime = 0;
				}
			}
		}
		else
		{
			if (FlxG.keys.justPressed.UP)
			{
				changeSelection(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (FlxG.keys.justPressed.DOWN)
			{
				changeSelection(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (FlxG.keys.justPressed.LEFT)
			{
				changeType(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (FlxG.keys.justPressed.RIGHT)
			{
				changeType(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.RESET)
			{
				for (i in 0...3)
				{
					resetValue(curSelected, i);
				}
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.ACCEPT && nextAccept <= 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changingNote = true;
				holdTime = 0;
				for (i in 0...grpNumbers.length)
				{
					var item = grpNumbers.members[i];
					item.alpha = 0;
					if ((curSelected * 3) + typeSelected == i)
					{
						item.alpha = 1;
					}
				}
				for (i in 0...grpNotes.length)
				{
					var item = grpNotes.members[i];
					item.alpha = 0;
					if (curSelected == i)
					{
						item.alpha = 1;
					}
				}
				super.update(elapsed);
				return;
			}
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
		for (i in 0...grpNotes.length)
		{
			var item = grpNotes.members[i];
			var intendedPos:Float = posX - 70;
			if (curSelected == i)
			{
				item.x = FlxMath.lerp(item.x, intendedPos + 100, lerpVal);
			}
			else
			{
				item.x = FlxMath.lerp(item.x, intendedPos, lerpVal);
			}
			for (j in 0...3)
			{
				var item2 = grpNumbers.members[(i * 3) + j];
				item2.x = item.x + 265 + (225 * (j % 3)) - (30 * item2.lettersArray.length) / 2;
				if (ClientPrefs.arrowHSV[i][j] < 0)
				{
					item2.x -= 20;
				}
			}

			if (curSelected == i)
			{
				hsvText.setPosition(item.x + hsvTextOffsets[0], item.y - hsvTextOffsets[1]);
			}
		}

		if (controls.BACK || (changingNote && controls.ACCEPT))
		{
			changeSelection();
			if (!changingNote)
			{
				grpNumbers.forEachAlive(function(spr:Alphabet)
				{
					spr.alpha = 0;
				});
				grpNotes.forEachAlive(function(spr:FlxSprite)
				{
					spr.alpha = 0;
				});
				close();
			}
			changingNote = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		if (nextAccept > 0)
		{
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = ClientPrefs.arrowHSV.length - 1;
		if (curSelected >= ClientPrefs.arrowHSV.length)
			curSelected = 0;

		curValue = ClientPrefs.arrowHSV[curSelected][typeSelected];
		updateValue();

		for (i in 0...grpNumbers.length)
		{
			var item = grpNumbers.members[i];
			
			item.alpha = 0.4; item.color = 0xFF2E1010;
			if ((curSelected * 3) + typeSelected == i) {item.alpha = 1; item.color = 0xFF982B2B;}
		}
		for (i in 0...grpNotes.length)
		{
			var item = grpNotes.members[i];
			item.alpha = 0.4; item.color = 0xFF680F0F;
			item.scale.set(.8,.8);
			if (curSelected == i)
			{
				item.alpha = 1; item.color = 0xFFFF0000;
				item.scale.set(.9, .9);
				hsvText.setPosition(item.x + hsvTextOffsets[0], item.y - hsvTextOffsets[1]);
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function changeType(change:Int = 0)
	{
		typeSelected += change;
		if (typeSelected < 0)
			typeSelected = 2;
		if (typeSelected > 2)
			typeSelected = 0;

		curValue = ClientPrefs.arrowHSV[curSelected][typeSelected];
		updateValue();

		for (i in 0...grpNumbers.length)
		{
			var item = grpNumbers.members[i];
			item.alpha = 0.4; item.color = 0xFF680F0F;
			if ((curSelected * 3) + typeSelected == i)
			{
				item.alpha = 1; item.color = 0xFFFF0000;
			}
		}
	}

	function resetValue(selected:Int, type:Int)
	{
		curValue = 0;
		ClientPrefs.arrowHSV[selected][type] = 0;
		switch (type)
		{
			case 0:
				shaderArray[selected].hue = 0;
			case 1:
				shaderArray[selected].saturation = 0;
			case 2:
				shaderArray[selected].brightness = 0;
		}
		grpNumbers.members[(selected * 3) + type].changeText('0');
	}

	function updateValue(change:Float = 0)
	{
		curValue += change;
		var roundedValue:Int = Math.round(curValue);
		var max:Float = 180;
		switch (typeSelected)
		{
			case 1 | 2:
				max = 100;
		}

		if (roundedValue < -max)
		{
			curValue = -max;
		}
		else if (roundedValue > max)
		{
			curValue = max;
		}
		roundedValue = Math.round(curValue);
		ClientPrefs.arrowHSV[curSelected][typeSelected] = roundedValue;

		switch (typeSelected)
		{
			case 0:
				shaderArray[curSelected].hue = roundedValue / 360;
			case 1:
				shaderArray[curSelected].saturation = roundedValue / 100;
			case 2:
				shaderArray[curSelected].brightness = roundedValue / 100;
		}
		grpNumbers.members[(curSelected * 3) + typeSelected].changeText(Std.string(roundedValue));
		//changeSelection(0);
	}
}

class ControlsSubstate extends MusicBeatSubstate
{
	private static var curSelected:Int = 1;
	private static var curAlt:Bool = false;

	private static var defaultKey:String = 'Reset to Default Keys';

	var optionShit:Array<String> = [
		'NOTES', ClientPrefs.keyBinds[0][1], ClientPrefs.keyBinds[1][1], ClientPrefs.keyBinds[2][1], ClientPrefs.keyBinds[3][1], '', 'UI',
		ClientPrefs.keyBinds[4][1], ClientPrefs.keyBinds[5][1], ClientPrefs.keyBinds[6][1], ClientPrefs.keyBinds[7][1], '', ClientPrefs.keyBinds[8][1],
		ClientPrefs.keyBinds[9][1], ClientPrefs.keyBinds[10][1], ClientPrefs.keyBinds[11][1], ClientPrefs.keyBinds[12][1], '', defaultKey
	];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var grpInputs:Array<AttachedText> = [];
	private var controlArray:Array<FlxKey> = [];
	var rebindingKey:Int = -1;
	var nextAccept:Int = 5;

	public function new()
	{
		super();
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		controlArray = ClientPrefs.lastControls.copy();
		for (i in 0...optionShit.length)
		{
			var isCentered:Bool = false;
			var isDefaultKey:Bool = (optionShit[i] == defaultKey);
			if (unselectableCheck(i, true))
			{
				isCentered = true;
			}

			var optionText:Alphabet = new Alphabet(0, (10 * i), optionShit[i], (!isCentered || isDefaultKey), false);
			optionText.isMenuItem = true;
			if (isCentered)
			{
				optionText.screenCenter(X);
				optionText.forceX = optionText.x;
				optionText.yAdd = -55;
			}
			else
			{
				optionText.forceX = 200;
			}
			optionText.yMult = 60;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if (!isCentered)
			{
				addBindTexts(optionText);
			}
		}
		changeSelection();
	}

	var leaving:Bool = false;
	var bindingTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (rebindingKey < 0)
		{
			if (FlxG.keys.justPressed.UP)
			{
				changeSelection(-1);
			}
			if (FlxG.keys.justPressed.DOWN)
			{
				changeSelection(1);
			}
			if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
			{
				changeAlt();
			}

			if (controls.BACK)
			{
				ClientPrefs.reloadControls(controlArray);
				grpOptions.forEachAlive(function(spr:Alphabet)
				{
					spr.alpha = 0;
				});
				for (i in 0...grpInputs.length)
				{
					var spr:AttachedText = grpInputs[i];
					if (spr != null)
					{
						spr.alpha = 0;
					}
				}
				close();
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}

			if (controls.ACCEPT && nextAccept <= 0)
			{
				if (optionShit[curSelected] == defaultKey)
				{
					controlArray = ClientPrefs.defaultKeys.copy();
					reloadKeys();
					changeSelection();
					FlxG.sound.play(Paths.sound('confirmMenu'));
				}
				else
				{
					bindingTime = 0;
					rebindingKey = getSelectedKey();
					if (rebindingKey > -1)
					{
						grpInputs[rebindingKey].visible = false;
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					else
					{
						FlxG.log.warn('Error! No input found/badly configured');
						FlxG.sound.play(Paths.sound('cancelMenu'));
					}
				}
			}
		}
		else
		{
			var keyPressed:Int = FlxG.keys.firstJustPressed();
			if (keyPressed > -1)
			{
				controlArray[rebindingKey] = keyPressed;
				var opposite:Int = rebindingKey + (rebindingKey % 2 == 1 ? -1 : 1);
				trace('Rebinded key with ID: ' + rebindingKey + ', Opposite is: ' + opposite);
				if (controlArray[opposite] == controlArray[rebindingKey])
				{
					controlArray[opposite] = NONE;
				}

				reloadKeys();
				FlxG.sound.play(Paths.sound('confirmMenu'));
				rebindingKey = -1;
			}

			bindingTime += elapsed;
			if (bindingTime > 5)
			{
				grpInputs[rebindingKey].visible = true;
				FlxG.sound.play(Paths.sound('scrollMenu'));
				rebindingKey = -1;
				bindingTime = 0;
			}
		}

		if (nextAccept > 0)
		{
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = optionShit.length - 1;
			if (curSelected >= optionShit.length)
				curSelected = 0;
		}
		while (unselectableCheck(curSelected));

		var bullShit:Int = 0;

		for (i in 0...grpInputs.length)
		{
			grpInputs[i].alpha = 0.4; grpInputs[i].color = 0xFF680F0F;
		}

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!unselectableCheck(bullShit - 1))
			{
				item.alpha = 0.4; item.color = 0xFF680F0F;
				if (item.targetY == 0)
				{
					item.alpha = 1; item.color = 0xFFFF0000;
					for (i in 0...grpInputs.length)
					{
						if (grpInputs[i].sprTracker == item && grpInputs[i].isAlt == curAlt)
						{
							grpInputs[i].alpha = 1; grpInputs[i].color = 0xFFFF0000;
						}
					}
				}
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function changeAlt()
	{
		curAlt = !curAlt;
		for (i in 0...grpInputs.length)
		{
			if (grpInputs[i].sprTracker == grpOptions.members[curSelected])
			{
				grpInputs[i].alpha = 0.4; grpInputs[i].color = 0xFF680F0F;
				if (grpInputs[i].isAlt == curAlt)
				{
					grpInputs[i].alpha = 1; grpInputs[i].color = 0xFFFF0000;
				}
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	private function unselectableCheck(num:Int, ?checkDefaultKey:Bool = false):Bool
	{
		if (optionShit[num] == defaultKey)
		{
			return checkDefaultKey;
		}

		for (i in 0...ClientPrefs.keyBinds.length)
		{
			if (ClientPrefs.keyBinds[i][1] == optionShit[num])
			{
				return false;
			}
		}
		return true;
	}

	private function getSelectedKey():Int
	{
		var altValue:Int = (curAlt ? 1 : 0);
		for (i in 0...ClientPrefs.keyBinds.length)
		{
			if (ClientPrefs.keyBinds[i][1] == optionShit[curSelected])
			{
				return i * 2 + altValue;
			}
		}
		return -1;
	}

	private function addBindTexts(optionText:Alphabet)
	{
		var text1 = new AttachedText(InputFormatter.getKeyName(controlArray[grpInputs.length]), 400, 0);
		text1.setPosition(optionText.x + 400, optionText.y - 55);
		text1.sprTracker = optionText;
		grpInputs.push(text1);
		add(text1);

		var text2 = new AttachedText(InputFormatter.getKeyName(controlArray[grpInputs.length]), 650, 0);
		text2.setPosition(optionText.x + 650, optionText.y - 55);
		text2.sprTracker = optionText;
		text2.isAlt = true;
		grpInputs.push(text2);
		add(text2);
	}

	function reloadKeys()
	{
		while (grpInputs.length > 0)
		{
			var item:AttachedText = grpInputs[0];
			grpInputs.remove(item);
			remove(item);
		}

		for (i in 0...grpOptions.length)
		{
			if (!unselectableCheck(i, true))
			{
				addBindTexts(grpOptions.members[i]);
			}
		}

		var bullShit:Int = 0;
		for (i in 0...grpInputs.length)
		{
			grpInputs[i].alpha = 0.6;
		}

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
					for (i in 0...grpInputs.length)
					{
						if (grpInputs[i].sprTracker == item && grpInputs[i].isAlt == curAlt)
						{
							grpInputs[i].alpha = 1;
						}
					}
				}
			}
		}
	}
}

class PreferencesSubstate extends MusicBeatSubstate
{
	private static var curSelected:Int = 0;
	static var unselectableOptions:Array<String> = ['GRAPHICS', 'GAMEPLAY'];
	static var noCheckbox:Array<String> = ['Framerate', 'Note Delay'];

	static var options:Array<String> = [
		'GRAPHICS',
		'Low Quality',
		'Anti-Aliasing',
		'VRAM-Sprites',
		#if !html5
		'Framerate', // Apparently 120FPS isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		#end
		'GAMEPLAY',
		'Downscroll',
		'Middlescroll',
		'Ghost Tapping',
		'Note Delay',
		'Note Splashes',
		'Hide HUD',
		'Hide Song Length',
		'Flashing Lights',
		'Camera Zooms'
		#if !mobile, 'FPS Counter' #end
	];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxArray:Array<CheckboxThingie> = [];
	private var checkboxNumber:Array<Int> = [];
	private var grpTexts:FlxTypedGroup<AttachedText>;
	private var textNumber:Array<Int> = [];

	private var showCharacter:Character = null;
	private var descText:FlxText;

	public function new()
	{
		super();
		// avoids lagspikes while scrolling through menus!
		showCharacter = new Character(840, 170, 'bfnew', true);
		showCharacter.setGraphicSize(Std.int(showCharacter.width * 0.8));
		showCharacter.updateHitbox();
		showCharacter.dance();
		add(showCharacter);
		showCharacter.visible = false;

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		for (i in 0...options.length)
		{
			var isCentered:Bool = unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, options[i], false, false);
			optionText.isMenuItem = true;
			if (isCentered)
			{
				optionText.screenCenter(X);
				optionText.forceX = optionText.x;
			}
			else
			{
				optionText.x += 300;
				optionText.forceX = 300;
			}
			optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if (!isCentered)
			{
				var useCheckbox:Bool = true;
				for (j in 0...noCheckbox.length)
				{
					if (options[i] == noCheckbox[j])
					{
						useCheckbox = false;
						break;
					}
				}

				if (useCheckbox)
				{
					var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, false);
					checkbox.sprTracker = optionText;
					checkboxArray.push(checkbox);
					checkboxNumber.push(i);
					add(checkbox);
				}
				else
				{
					var valueText:AttachedText = new AttachedText('0', optionText.width + 80);
					valueText.sprTracker = optionText;
					grpTexts.add(valueText);
					textNumber.push(i);
				}
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		for (i in 0...options.length)
		{
			if (!unselectableCheck(i))
			{
				curSelected = i;
				break;
			}
		}
		changeSelection();
		reloadValues();
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.UP)
		{
			changeSelection(-1);
		}

		if (FlxG.keys.justPressed.DOWN)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			grpOptions.forEachAlive(function(spr:Alphabet)
			{
				spr.alpha = 0;
			});
			grpTexts.forEachAlive(function(spr:AttachedText)
			{
				spr.alpha = 0;
			});
			for (i in 0...checkboxArray.length)
			{
				var spr:CheckboxThingie = checkboxArray[i];
				if (spr != null)
				{
					spr.alpha = 0;
				}
			}
			if (showCharacter != null)
			{
				showCharacter.alpha = 0;
			}
			descText.alpha = 0;
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		var usesCheckbox = true;
		for (i in 0...noCheckbox.length)
		{
			if (options[curSelected] == noCheckbox[i])
			{
				usesCheckbox = false;
				break;
			}
		}

		if (usesCheckbox)
		{
			if (controls.ACCEPT && nextAccept <= 0)
			{
				switch (options[curSelected])
				{
					case 'FPS Counter':
						ClientPrefs.showFPS = !ClientPrefs.showFPS;
						if (Main.fpsVar != null)
							Main.fpsVar.visible = ClientPrefs.showFPS;

					case 'Low Quality':
						ClientPrefs.lowQuality = !ClientPrefs.lowQuality;

					case 'Anti-Aliasing':
						ClientPrefs.globalAntialiasing = !ClientPrefs.globalAntialiasing;
						showCharacter.antialiasing = ClientPrefs.globalAntialiasing;
						for (item in grpOptions)
						{
							item.antialiasing = ClientPrefs.globalAntialiasing;
						}
						for (i in 0...checkboxArray.length)
						{
							var spr:CheckboxThingie = checkboxArray[i];
							if (spr != null)
							{
								spr.antialiasing = ClientPrefs.globalAntialiasing;
							}
						}
					case 'VRAM-Sprites':
						ClientPrefs.vramSprites = !ClientPrefs.vramSprites;
					case 'Note Splashes':
						ClientPrefs.noteSplashes = !ClientPrefs.noteSplashes;

					case 'Flashing Lights':
						ClientPrefs.flashing = !ClientPrefs.flashing;

					case 'Violence':
						ClientPrefs.violence = !ClientPrefs.violence;

					case 'Swearing':
						ClientPrefs.cursing = !ClientPrefs.cursing;

					case 'Downscroll':
						ClientPrefs.downScroll = !ClientPrefs.downScroll;

					case 'Middlescroll':
						ClientPrefs.middleScroll = !ClientPrefs.middleScroll;

					case 'Ghost Tapping':
						ClientPrefs.ghostTapping = !ClientPrefs.ghostTapping;

					case 'Camera Zooms':
						ClientPrefs.camZooms = !ClientPrefs.camZooms;

					case 'Hide HUD':
						ClientPrefs.hideHud = !ClientPrefs.hideHud;

					case 'Hide Song Length':
						ClientPrefs.hideTime = !ClientPrefs.hideTime;
				}
				FlxG.sound.play(Paths.sound('scrollMenu'));
				reloadValues();
			}
		}
		else
		{
			if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
			{
				var add:Int = FlxG.keys.pressed.LEFT ? -1 : 1;
				if (holdTime > 0.5 || FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
					switch (options[curSelected])
					{
						case 'Framerate':
							ClientPrefs.framerate += add;
							if (ClientPrefs.framerate < 60)
								ClientPrefs.framerate = 60;
							else if (ClientPrefs.framerate > 240)
								ClientPrefs.framerate = 240;

							if (ClientPrefs.framerate > FlxG.drawFramerate)
							{
								FlxG.updateFramerate = ClientPrefs.framerate;
								FlxG.drawFramerate = ClientPrefs.framerate;
							}
							else
							{
								FlxG.drawFramerate = ClientPrefs.framerate;
								FlxG.updateFramerate = ClientPrefs.framerate;
							}
						case 'Note Delay':
							var mult:Int = 1;
							if (holdTime > 1.5)
							{ // Double speed after 1.5 seconds holding
								mult = 2;
							}
							ClientPrefs.noteOffset += add * mult;
							if (ClientPrefs.noteOffset < 0)
								ClientPrefs.noteOffset = 0;
							else if (ClientPrefs.noteOffset > 500)
								ClientPrefs.noteOffset = 500;
					}
				reloadValues();

				if (holdTime <= 0)
					FlxG.sound.play(Paths.sound('scrollMenu'));
				holdTime += elapsed;
			}
			else
			{
				holdTime = 0;
			}
		}

		if (showCharacter != null && showCharacter.animation.curAnim.finished)
		{
			showCharacter.dance();
		}

		if (nextAccept > 0)
		{
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = options.length - 1;
			if (curSelected >= options.length)
				curSelected = 0;
		}
		while (unselectableCheck(curSelected));

		var daText:String = '';
		switch (options[curSelected])
		{
			case 'Framerate':
				daText = "Pretty self explanatory, isn't it?\nDefault value is 60.";
			case 'Note Delay':
				daText = "Changes how late a note is spawned.\nUseful for preventing audio lag from wireless earphones.";
			case 'FPS Counter':
				daText = "If unchecked, hides FPS Counter.";
			case 'Low Quality':
				daText = "If checked, disables some background details,\ndecreases loading times and improves performance.";
			case 'Persistent Cached Data':
				daText = "If checked, images loaded will stay in memory\nuntil the game is closed, this increases memory usage,\nbut basically makes reloading times instant.";
			case 'Anti-Aliasing':
				daText = "If unchecked, disables anti-aliasing, increases performance\nat the cost of the graphics not looking as smooth.";
			case 'VRAM-Sprites':
				daText = "If checked, bitmaps will be stored on vram instead of both the vram and ram, good for preformance.";
			case 'Downscroll':
				daText = "If checked, notes go Down instead of Up, simple enough."; // SI LO PROBÓ VAMOS LOS PIBEEES
			case 'Middlescroll':
				daText = "If checked, hides Opponent's notes and your notes get centered.\nBut Enabling this will disable a lot of modcharts";
			case 'Ghost Tapping':
				daText = "If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.";
			case 'Swearing':
				daText = "If unchecked, your mom won't be angry at you.";
			case 'Violence':
				daText = "If unchecked, you won't get disgusted as frequently.";
			case 'Note Splashes':
				daText = "If unchecked, hitting \"Sick!\" notes won't show particles.";
			case 'Flashing Lights':
				daText = "Uncheck this if you're sensitive to flashing lights!";
			case 'Camera Zooms':
				daText = "If unchecked, the camera won't zoom in on a beat hit.";
			case 'Hide HUD':
				daText = "If checked, hides most HUD elements.";
			case 'Hide Song Length':
				daText = "If checked, the bar showing how much time is left\nwill be hidden.";
		}
		descText.text = daText;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!unselectableCheck(bullShit - 1))
			{
				item.alpha = 0.4; item.color = 0xFF680F0F;
				if (item.targetY == 0)
				{
					item.alpha = 1; item.color = 0xFFFF0000;
				}

				for (j in 0...checkboxArray.length)
				{
					var tracker:FlxSprite = checkboxArray[j].sprTracker;
					if (tracker == item)
					{
						checkboxArray[j].alpha = item.alpha;
						break;
					}
				}
			}
		}
		for (i in 0...grpTexts.members.length)
		{
			var text:AttachedText = grpTexts.members[i];
			if (text != null)
			{
				text.alpha = 0.4; text.color = 0xFF680F0F;
				if (textNumber[i] == curSelected)
				{
					text.alpha = 1; text.color = 0xFFFF0000;
				}
			}
		}

		showCharacter.visible = (options[curSelected] == 'Anti-Aliasing');
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function reloadValues()
	{
		for (i in 0...checkboxArray.length)
		{
			var checkbox:CheckboxThingie = checkboxArray[i];
			if (checkbox != null)
			{
				var daValue:Bool = false;
				switch (options[checkboxNumber[i]])
				{
					case 'FPS Counter':
						daValue = ClientPrefs.showFPS;
					case 'Low Quality':
						daValue = ClientPrefs.lowQuality;
					case 'Anti-Aliasing':
						daValue = ClientPrefs.globalAntialiasing;
					case 'VRAM-Sprites':
						daValue = ClientPrefs.vramSprites;
					case 'Note Splashes':
						daValue = ClientPrefs.noteSplashes;
					case 'Flashing Lights':
						daValue = ClientPrefs.flashing;
					case 'Downscroll':
						daValue = ClientPrefs.downScroll;
					case 'Middlescroll':
						daValue = ClientPrefs.middleScroll;
					case 'Ghost Tapping':
						daValue = ClientPrefs.ghostTapping;
					case 'Swearing':
						daValue = ClientPrefs.cursing;
					case 'Violence':
						daValue = ClientPrefs.violence;
					case 'Camera Zooms':
						daValue = ClientPrefs.camZooms;
					case 'Hide HUD':
						daValue = ClientPrefs.hideHud;
					case 'Hide Song Length':
						daValue = ClientPrefs.hideTime;
				}
				checkbox.daValue = daValue;
			}
		}
		for (i in 0...grpTexts.members.length)
		{
			var text:AttachedText = grpTexts.members[i];
			if (text != null)
			{
				var daText:String = '';
				switch (options[textNumber[i]])
				{
					case 'Framerate':
						daText = '' + ClientPrefs.framerate;
					case 'Note Delay':
						daText = ClientPrefs.noteOffset + 'ms';
				}
				var lastTracker:FlxSprite = text.sprTracker;
				text.sprTracker = null;
				text.changeText(daText);
				text.sprTracker = lastTracker;
			}
		}
	}

	private function unselectableCheck(num:Int):Bool
	{
		for (i in 0...unselectableOptions.length)
		{
			if (options[num] == unselectableOptions[i])
			{
				return true;
			}
		}
		return options[num] == '';
	}
}

class MarioSubstate extends MusicBeatSubstate
{
	private static var curSelected:Int = 0;
	static var unselectableOptions:Array<String> = ['GRAPHICS'];
	static var noCheckbox:Array<String> = ['Menu BG'];

	static var options:Array<String> = [
		'GRAPHICS',
		'Enable TV Effect',
		'Enable Resume Wait',
		'Menu BG',
		'Enable Mr Virtual Mechanics',
		'Enable Discord Rich Presence'
	];

	static var bglist:Array<String> = [
		'Mushroom Kingdom',
	];

	final unlockBG:Array<Bool> = [ClientPrefs.storySave[1], true, ClientPrefs.storySave[1], ClientPrefs.storySave[1], ClientPrefs.storySave[2], ClientPrefs.storySave[2], ClientPrefs.storySave[4], ClientPrefs.storySave[8]];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxArray:Array<CheckboxThingie> = [];
	private var checkboxNumber:Array<Int> = [];
	private var grpTexts:FlxTypedGroup<AttachedText>;
	private var textNumber:Array<Int> = [];

	private var descText:FlxText;

	public function new()
	{
		super();
		// avoids lagspikes while scrolling through menus!

			//if()
			bglist = ['Random', 'Mushroom Kingdom'];
			var curList:Array<String> = [
				'Bedrock City',
				'Green Hill Zone',
				'Bowser Castle',
				'Hackrom Forest',
				'Gameboy Land',
				'Hunting Area'
			];
			for (i in 0... curList.length){
			if(unlockBG[(i + 2)]){
				bglist.push(curList[i]);
			}
			}

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);
		

		for (i in 0...options.length)
		{
			var isCentered:Bool = unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, options[i], false, false);
			optionText.isMenuItem = true;
			if (isCentered)
			{
				optionText.screenCenter(X);
				optionText.forceX = optionText.x;
			}
			else
			{
				optionText.x += 200;
				optionText.forceX = 200;
			}
			optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);
			

			if (!isCentered)
			{
				var useCheckbox:Bool = true;
				for (j in 0...noCheckbox.length)
					{
						if (options[i] == noCheckbox[j])
						{
							useCheckbox = false;
							break;
						}
					}
				if (useCheckbox)
				{
					var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, false);
					checkbox.sprTracker = optionText;
					checkboxArray.push(checkbox);
					checkboxNumber.push(i);
					add(checkbox);
				}
				else
				{
					var valueText:AttachedText = new AttachedText('<Example Text>', optionText.width + 80);
					valueText.color = 0xCECECE;
					valueText.sprTracker = optionText;
					grpTexts.add(valueText);
					textNumber.push(i);
				}
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		for (i in 0...options.length)
		{
			if (!unselectableCheck(i))
			{
				curSelected = i;
				break;
			}
		}
		changeSelection();
		reloadValues();
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.UP)
		{
			changeSelection(-1);
		}
		if (FlxG.keys.justPressed.DOWN)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			grpOptions.forEachAlive(function(spr:Alphabet)
			{
				spr.alpha = 0;
			});
			grpTexts.forEachAlive(function(spr:AttachedText)
			{
				spr.alpha = 0;
			});
			for (i in 0...checkboxArray.length)
			{
				var spr:CheckboxThingie = checkboxArray[i];
				if (spr != null)
				{
					spr.alpha = 0;
				}
			}
			descText.alpha = 0;
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		var usesCheckbox = true;

		if (usesCheckbox)
		{
			if (controls.ACCEPT && nextAccept <= 0)
			{
				switch (options[curSelected])
				{
					case 'Enable TV Effect':
						ClientPrefs.filtro85 = !ClientPrefs.filtro85;
					case 'Enable Resume Wait':
						ClientPrefs.pauseStart = !ClientPrefs.pauseStart;
					case 'Enable Mr Virtual Mechanics':
						ClientPrefs.noVirtual = !ClientPrefs.noVirtual;
					case 'Enable Discord Rich Presence':
						ClientPrefs.noDiscord = !ClientPrefs.noDiscord;
						if (ClientPrefs.noDiscord)
						{
							DiscordClient.start();
						}
						else
						{
							DiscordClient.shutdown();
						}
				}
				FlxG.sound.play(Paths.sound('scrollMenu'));
				reloadValues();
			}
			else
				{
					if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
					{
						var add:Int = FlxG.keys.justPressed.LEFT ? -1 : 1;
							switch (options[curSelected])
							{
								case 'Menu BG':
									var mult:Int = 1;
									ClientPrefs.menuBG += add;
									if (ClientPrefs.menuBG < 0)
										ClientPrefs.menuBG = bglist.length - 1;
									else if (ClientPrefs.menuBG > bglist.length - 1)
										ClientPrefs.menuBG = 0;
							}
						reloadValues();
					}
				}
			}

		if (nextAccept > 0)
		{
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = options.length - 1;
			if (curSelected >= options.length)
				curSelected = 0;
		}
		while (unselectableCheck(curSelected));

		var daText:String = '';
		switch (options[curSelected])
		{
			case 'Enable TV Effect':
				daText = "Pretty self explanatory, isn't it?";
			case 'Enable Resume Wait':
				daText = "when you resume a song from the pause menu,\nthere will be a countdown before resuming";
			case 'Menu BG':
				daText = "Change the Main Menu Background or make it random";
			case 'Enable Mr Virtual Mechanics':
				daText = "Disabling this will remove the extremely weird mechanic\nthat could be annoying for some people, specially when recording";
			case 'Enable Discord Rich Presence':
				daText = "Enables the Game appearing in your Discord Status";
		}
		descText.text = daText;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!unselectableCheck(bullShit - 1))
			{
				item.alpha = 0.4; item.color = 0xFF680F0F;
				if (item.targetY == 0)
				{
					item.alpha = 1; item.color = 0xFFFF0000;
				}

				for (j in 0...checkboxArray.length)
				{
					var tracker:FlxSprite = checkboxArray[j].sprTracker;
					if (tracker == item)
					{
						checkboxArray[j].alpha = item.alpha;
						break;
					}
				}
			}
		}
		for (i in 0...grpTexts.members.length)
		{
			var text:AttachedText = grpTexts.members[i];
			if (text != null)
			{
				text.alpha = 0.4; text.color = 0xFF680F0F;
				if (textNumber[i] == curSelected)
				{
					text.alpha = 1; text.color = 0xFFFF0000;
				}
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function reloadValues()
	{
		for (i in 0...checkboxArray.length)
		{
			var checkbox:CheckboxThingie = checkboxArray[i];
			if (checkbox != null)
			{
				var daValue:Bool = false;
				switch (options[checkboxNumber[i]])
				{
					case 'Enable TV Effect':
						daValue = ClientPrefs.filtro85;
					case 'Enable Resume Wait':
						daValue = ClientPrefs.pauseStart;
					case 'Enable Mr Virtual Mechanics':
						daValue = ClientPrefs.noVirtual;
					case 'Enable Discord Rich Presence':
						daValue = ClientPrefs.noDiscord;
				}
				checkbox.daValue = daValue;
			}
		}
		for (i in 0...grpTexts.members.length)
			{
				var text:AttachedText = grpTexts.members[i];
				if (text != null)
				{
					var daText:String = '';
					switch (options[textNumber[i]])
					{
						case 'Menu BG':
							daText = "<" + bglist[ClientPrefs.menuBG] + ">";
					}
					var lastTracker:FlxSprite = text.sprTracker;
					text.sprTracker = null;
					text.changeText(daText);
					text.sprTracker = lastTracker;
				}
			}
	}

	private function unselectableCheck(num:Int):Bool
	{
		for (i in 0...unselectableOptions.length)
		{
			if (options[num] == unselectableOptions[i])
			{
				return true;
			}
		}
		return options[num] == '';
	}
}

class DeleteSubstate extends MusicBeatSubstate
{
	var delPhase:Int = 0;
	var timer:Float = 1;
	var text:FlxText;
	var cat:FlxSprite;
	var rotButton:FlxSprite;
	var darkbg:FlxSprite;

	public function new()
		{
			super();

			darkbg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			darkbg.scrollFactor.set(0, 0);
			darkbg.setGraphicSize(Std.int(darkbg.width * 3));
			darkbg.alpha = 0.2;
			add(darkbg);

			text = new FlxText(0, 0, 1000, 'Do you want to delete all your progress?\n\n\nPress Enter to continue', 32);
			text.setFormat(Paths.font("mariones.ttf"), 36, FlxColor.RED, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.screenCenter(XY);
			add(text);

			cat = new FlxSprite().loadGraphic(Paths.image('modstuff/deleteImgs/cat' + FlxG.random.int(0, 3)));
			cat.setGraphicSize(300, 300);
			cat.screenCenter(XY);
			cat.y += 150;
			cat.visible = false;
			add(cat);

			rotButton = new FlxSprite().loadGraphic(Paths.image('modstuff/deleteImgs/rotate'));
			rotButton.screenCenter(XY);
			rotButton.y += 150;
			rotButton.x += 400;
			rotButton.visible = false;
			add(rotButton);

		}

	override function update(elapsed:Float)
		{
			if(timer > 0){
				timer -= elapsed;
			}else{
				timer = 0;
			}
			if (controls.BACK && delPhase != 4)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxG.mouse.visible = false;
					close();
				}
			
			if(controls.ACCEPT && delPhase <= 3 && timer == 0 && cat.angle == 0){
				switch(delPhase){
					case 0:
						timer = 1;
						text.text = 'to make it clear, you will lose all your progress in the mod\n\nPress enter if you REALLY want to delete it';
						text.screenCenter(XY);
					case 1:
						FlxG.mouse.visible = true;
						timer = 1;
						text.text = 'Rotate the cat to the right direction and press enter if you are going to delete your progress';
						text.y = 100;
						cat.angle = 90 * FlxG.random.int(1, 3);
						cat.visible = true;
						rotButton.visible = true;
					case 2:
						FlxG.mouse.visible = false;
						timer = 1;
						text.y = 0;
						text.text = 'Press enter For real this time to delete your progress';
						text.screenCenter(XY);
						cat.visible = false;
						rotButton.visible = false;
					case 3:
						ClientPrefs.worlds = [0, 0, 0, 0, 0];
						ClientPrefs.worldsALT = [0, 0, 0, 0, 0];
						ClientPrefs.storySave = [for(i in 0... 10) false];
						ClientPrefs.saveSettings();
						text.text = 'All your data was succesfully deleted\n\nrestart the game to continue';
						text.screenCenter(XY);
				}
				delPhase++;
				FlxG.sound.music.volume -= 0.3;
				darkbg.alpha += 0.2;
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if(FlxG.mouse.overlaps(rotButton)){
				rotButton.scale.set(1.2, 1.2);
				if(FlxG.mouse.justReleased){
					FlxG.sound.play(Paths.sound('scrollMenu'));
					cat.angle += 90;
					if(cat.angle >= 360) cat.angle = 0;
				}
			}else{
				rotButton.scale.set(1, 1);
			}
		}
}
