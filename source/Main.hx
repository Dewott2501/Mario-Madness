package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.system.System;
#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end

class Main extends Sprite {
	public static var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	public static var gameWidth:Int = initialState == TitleState ? 921 : 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var gameHeight:Int = initialState == TitleState ? 691 : 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var fpsVar:FPS;

	public static var skipNextDump:Bool = false;
	public static var forceNoVramSprites:Bool = #if (desktop && !web) false #else true #end;

	public static function main():Void {
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		if (stage != null) {
			init();
		}
		else {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void {
		if (hasEventListener(Event.ADDED_TO_STAGE)) {
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	public function setupGame():Void {
		Lib.application.window.onClose.add(PlayState.onWinClose);

		#if !debug
		initialState = TitleState;
		#end
		FlxTransitionableState.skipNextTransOut = true;
		#if !mobile
		fpsVar = new FPS(10, 4, 0xFFFFFF);

		if (fpsVar != null) {
			fpsVar.visible = false;
		}
		#end
		addChild(new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen));

		FlxG.signals.preStateSwitch.add(function () {
			if (!Main.skipNextDump) {
				Paths.clearStoredMemory(true);
				FlxG.bitmap.dumpCache();
			}
			clearMajor();
		});
		FlxG.signals.postStateSwitch.add(function () {
			Paths.clearUnusedMemory();
			clearMajor();
			Main.skipNextDump = false;
		});

		#if !mobile
		addChild(fpsVar);
		#end
		#if html5
		FlxG.autoPause = false;
		#end

		FlxG.signals.gameResized.add(onResizeGame);
	}

	function onResizeGame(w:Int, h:Int) {
		fixShaderSize(this);
		if (FlxG.game != null) fixShaderSize(FlxG.game);

		if (FlxG.cameras == null) return;
		for (cam in FlxG.cameras.list) {
			@:privateAccess
			if (cam != null && (cam._filters != null || cam._filters != []))
				fixShaderSize(cam.flashSprite);
		}	
	}

	function fixShaderSize(sprite:Sprite) // Shout out to Ne_Eo for bringing this to my attention
	{
		@:privateAccess {
			if (sprite != null)
			{
				sprite.__cacheBitmap = null;
				sprite.__cacheBitmapData = null;
				sprite.__cacheBitmapData2 = null;
				sprite.__cacheBitmapData3 = null;
				sprite.__cacheBitmapColorTransform = null;
			}
		}
	}

	public static function clearMajor() {
		#if cpp
		Gc.run(true);
		Gc.compact();
		#elseif hl
		Gc.major();
		#elseif (java || neko)
		Gc.run(true);
		#end
	}
}

