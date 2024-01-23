package;

import Controls;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

class ClientPrefs {
	// TO DO: Redo ClientPrefs in a way that isn't too stupid
	// yeah good idea? (its still stupid in the latest psych build)
	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var showFPS:Bool = true;
	public static var flashing:Bool = true;
	public static var globalAntialiasing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var lowQuality:Bool = false;
	public static var framerate:Int = 60;
	public static var cursing:Bool = true;
	public static var violence:Bool = true;
	public static var camZooms:Bool = true;
	public static var hideHud:Bool = false;
	public static var noteOffset:Int = 0;
	public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public static var ghostTapping:Bool = true;
	public static var hideTime:Bool = false;
	public static var vramSprites:Bool = true;

	public static var filtro85:Bool = true;
	public static var pauseStart:Bool = false;
	public static var noVirtual:Bool = true;
	public static var noDiscord:Bool = true;
	public static var menuBG:Int = 0;
	public static var menuUnlock:Int = 1;

	public static var storyPass:Bool = false;
	public static var storyFlaut:Bool = false;
	public static var iHYPass:Bool = false;
	public static var mXPass:Bool = false;
	public static var warioPass:Bool = false;
	public static var betaPass:Bool = false;
	public static var carPass:Bool = false;
	public static var finish1:Bool = false;

	public static var overworld:Bool = false;
	public static var deathIHY:Bool = false;
											//Story Mode[0] | World 1[1] | World 2[2] | World 3[3] | World 4[4] | World 5[5] | Overworld Done[6] | Ultra M Done[7] | Unbeatable Done[8] |Legacy Mode[9] 
	public static var storySave:Array<Bool> = [false, false, false, false, false, false, false, false, false, false];

	public static var worlds:Array<Int> = [0, 0, 0, 0, 0];
	public static var worldsALT:Array<Int> = [0, 0, 0, 0, 0]; 

	public static var defaultKeys:Array<FlxKey> = [
		        A,   LEFT, // Note Left
		        S,   DOWN, // Note Down
		        W,       UP, // Note Up
		        D, RIGHT, // Note Right
		        A,     LEFT, // UI Left
		        S,     DOWN, // UI Down
		        W,         UP, // UI Up
		        D,   RIGHT, // UI Right
		        R,       NONE, // Reset
		    ENTER,      NONE, // Accept
		BACKSPACE,      ESCAPE, // Back
		    ENTER,     ESCAPE, // Pause
		    SPACE,     NONE, // Dodge
	];
	// Every key has two binds, these binds are defined on defaultKeys! If you want your control to be changeable, you have to add it on ControlsSubState (inside OptionsState)'s list
	public static var keyBinds:Array<Dynamic> = [
		// Key Bind, Name for ControlsSubState
		[Control.NOTE_LEFT, 'Left'],
		[Control.NOTE_DOWN, 'Down'],
		[Control.NOTE_UP, 'Up'],
		[Control.NOTE_RIGHT, 'Right'],
		[Control.UI_LEFT, 'Left '], // Added a space for not conflicting on ControlsSubState
		[Control.UI_DOWN, 'Down '], // Added a space for not conflicting on ControlsSubState
		[Control.UI_UP, 'Up '], // Added a space for not conflicting on ControlsSubState
		[Control.UI_RIGHT, 'Right '], // Added a space for not conflicting on ControlsSubState
		[Control.RESET, 'Reset'],
		[Control.ACCEPT, 'Accept'],
		[Control.BACK, 'Back'],
		[Control.PAUSE, 'Pause'],
		[Control.DODGE, 'Dodge']
	];
	public static var lastControls:Array<FlxKey> = defaultKeys.copy();

	public static function saveSettings() {
		final starNeed:Array<Int> = [3, 7, 5, 6, 3];
		var isDone:Int = 0;
		for (i in 0...starNeed.length){
			if(worlds[i] >= starNeed[i]){
				worlds[i] = starNeed[i];
				storySave[(i + 1)] = true;
				isDone++;
			}else{
				storySave[(i + 1)] = false;
			}

			if(isDone == 5){storySave[6] = true;}
			else{storySave[6] = false;}
		}

		
		if(worlds[2] >= 4){
			storySave[9] = true;
		}
		
		
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.middleScroll = middleScroll;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.flashing = flashing;
		FlxG.save.data.globalAntialiasing = globalAntialiasing;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.framerate = framerate;
		FlxG.save.data.cursing = cursing;
		FlxG.save.data.violence = violence;
		FlxG.save.data.camZooms = camZooms;
		FlxG.save.data.noteOffset = noteOffset;
		FlxG.save.data.menuBG = menuBG;
		FlxG.save.data.menuUnlock = menuUnlock;
		FlxG.save.data.hideHud = hideHud;
		FlxG.save.data.arrowHSV = arrowHSV;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.hideTime = hideTime;
		FlxG.save.data.filtro85 = filtro85;
		FlxG.save.data.pauseStart = pauseStart;
		FlxG.save.data.noVirtual = noVirtual;
		FlxG.save.data.noDiscord = noDiscord;
		FlxG.save.data.storyPass = storyPass;
		FlxG.save.data.overworld = overworld;
		FlxG.save.data.deathIHY = deathIHY;
		FlxG.save.data.storySave = storySave;
		FlxG.save.data.worlds = worlds;
		FlxG.save.data.worldsALT = worldsALT;
		FlxG.save.data.vramSprites = vramSprites;

		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls', 'ninjamuffin99'); // Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = lastControls;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		
		if (FlxG.save.data.downScroll != null) {
			downScroll = FlxG.save.data.downScroll;
		}
		if (FlxG.save.data.middleScroll != null) {
			middleScroll = FlxG.save.data.middleScroll;
		}
		if (FlxG.save.data.showFPS != null) {
			showFPS = FlxG.save.data.showFPS;
			/*
				if (Main.fpsVar != null)
				{
					Main.fpsVar.visible = showFPS;
				}
			 */
		}
		if (FlxG.save.data.flashing != null) {
			flashing = FlxG.save.data.flashing;
		}
		if (FlxG.save.data.globalAntialiasing != null) {
			globalAntialiasing = FlxG.save.data.globalAntialiasing;
		}
		if (FlxG.save.data.noteSplashes != null) {
			noteSplashes = FlxG.save.data.noteSplashes;
		}
		if (FlxG.save.data.lowQuality != null) {
			lowQuality = FlxG.save.data.lowQuality;
		}
		if (FlxG.save.data.framerate != null) {
			framerate = FlxG.save.data.framerate;
			if (framerate > FlxG.drawFramerate) {
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			}
			else {
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = framerate;
			}
		}
		/*if(FlxG.save.data.cursing != null) {
				cursing = FlxG.save.data.cursing;
			}
			if(FlxG.save.data.violence != null) {
				violence = FlxG.save.data.violence;
		}*/
		if (FlxG.save.data.camZooms != null) {
			camZooms = FlxG.save.data.camZooms;
		}
		if (FlxG.save.data.hideHud != null) {
			hideHud = FlxG.save.data.hideHud;
		}
		if (FlxG.save.data.noteOffset != null) {
			noteOffset = FlxG.save.data.noteOffset;
		}
		if (FlxG.save.data.menuBG != null) {
			menuBG = FlxG.save.data.menuBG;
		}
		if (FlxG.save.data.menuUnlock != null) {
			menuUnlock = FlxG.save.data.menuUnlock;
		}
		if (FlxG.save.data.arrowHSV != null) {
			arrowHSV = FlxG.save.data.arrowHSV;
		}
		if (FlxG.save.data.ghostTapping != null) {
			ghostTapping = FlxG.save.data.ghostTapping;
		}
		if (FlxG.save.data.hideTime != null) {
			hideTime = FlxG.save.data.hideTime;
		}
		if (FlxG.save.data.overworld != null) {
			overworld = FlxG.save.data.overworld;
		}
		if (FlxG.save.data.storyPass != null) {
			storyPass = FlxG.save.data.storyPass;
		}
		if (FlxG.save.data.vramSprites != null) {
			vramSprites = FlxG.save.data.vramSprites;
		}
		if (FlxG.save.data.storySave != null) {
			storySave = FlxG.save.data.storySave;
		}
		if (FlxG.save.data.worlds != null) {
			worlds = FlxG.save.data.worlds;
		}
		if (FlxG.save.data.worldsALT != null) {
			worldsALT = FlxG.save.data.worldsALT;
		}
		if (FlxG.save.data.deathIHY != null) {
			deathIHY = FlxG.save.data.deathIHY;
		}
		if (FlxG.save.data.filtro85 != null) {
			filtro85 = FlxG.save.data.filtro85;
		}
		if (FlxG.save.data.pauseStart != null) {
			pauseStart = FlxG.save.data.pauseStart;
		}
		if (FlxG.save.data.noVirtual != null) {
			noVirtual = FlxG.save.data.noVirtual;
		}
		if (FlxG.save.data.noDiscord != null) {
			noDiscord = FlxG.save.data.noDiscord;
		}


		var save:FlxSave = new FlxSave();
		save.bind('controls', 'ninjamuffin99');
		if (save != null && save.data.customControls != null) {
			reloadControls(save.data.customControls);
		}
	}

	public static function reloadControls(newKeys:Array<FlxKey>) {
		ClientPrefs.removeControls(ClientPrefs.lastControls);
		ClientPrefs.lastControls = newKeys.copy();
		ClientPrefs.loadControls(ClientPrefs.lastControls);
	}

	private static function removeControls(controlArray:Array<FlxKey>) {
		for (i in 0...keyBinds.length) {
			var controlValue:Int = i * 2;
			var controlsToRemove:Array<FlxKey> = [];
			for (j in 0...2) {
				if (controlArray[controlValue + j] != NONE) {
					controlsToRemove.push(controlArray[controlValue + j]);
				}
			}
			if (controlsToRemove.length > 0) {
				PlayerSettings.player1.controls.unbindKeys(keyBinds[i][0], controlsToRemove);
			}
		}
	}

	private static function loadControls(controlArray:Array<FlxKey>) {
		for (i in 0...keyBinds.length) {
			var controlValue:Int = i * 2;
			var controlsToAdd:Array<FlxKey> = [];
			for (j in 0...2) {
				if (controlArray[controlValue + j] != NONE) {
					controlsToAdd.push(controlArray[controlValue + j]);
				}
			}
			if (controlsToAdd.length > 0) {
				PlayerSettings.player1.controls.bindKeys(keyBinds[i][0], controlsToAdd);
			}
		}
	}
}
