package;

import ButtonShit;
import PaletteSprite;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxSpriteAniRot;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Lib;
import openfl.display.BitmapData;

using flixel.util.FlxSpriteUtil;

enum DSState
{
	Welcome;
	BIOS;
	BIOSSettings;
	FlashCart;
}

class DSBIOSSState extends FlxState
{
	public var topScreen:FlxSprite;
	public var topCanvas:FlxSprite;
	public var clock:FlxSprite;
	public var clockHands:FlxSprite;
	public var topBar:PaletteSprite;
	public var blackLine:FlxSprite;
	public var currFav:Int = 10;
	public var nameText:PaletteText;
	public var timeText:PaletteText;
	public var dateText:PaletteText;
	public var calendar:FlxSprite;
	public var calendarTextGroup:FlxGroup;
	public var oldDay:Int = -1;
	public var mainCam:FlxCamera;
	public var bottomScreen:FlxSprite;
	public var bottomCanvas:FlxSprite;
	public var palette:FlxSprite;
	public var fadeOut:Array<String>;
	public var fadeIn1:Array<String>;
	public var fadeIn2:Array<String>;
	public var moveIn:Array<String>;
	public var dayIndicator:PaletteSprite;
	public var separators:FlxSprite;
	public var intro:DSVideo;
	public var introStatic:FlxSprite;
	public var broWait:FlxSprite;
	public var touch:FlxText;
	public var state:DSState;
	public var touchTimer:FlxTimer;
	public var lazyAss:FlxTimer;
	public var doItYourself:Bool = false;
	public var activeGroup:ButtonGroup;
	public var mainMenuGroup:ButtonGroup;
	public var game:Button;
	public var pictochat:Button;
	public var exit:Button;
	public var gamePak:FlxSprite;
	public var brightness:Button;
	public var settings:Button;
	public var alarm:Button;
	public var overlay:FlxSprite;
	public var message:FlxSprite;
	public var shutdown:FlxText;

	override function create()
	{
		FlxG.sound.music.stop();
		FlxG.sound.soundTrayEnabled = false;

		if (FlxG.save.data.dbuser == null)
		{
			FlxG.save.data.dbuser = Sys.getEnv("username").substr(0, 10);
		}

		state = DSState.Welcome;

		fadeOut = ["introStatic", "touch"];
		fadeIn1 = ["topCanvas", "bottomCanvas", "clock", "clockHands", "calendar", "dayIndicator"];
		fadeIn2 = ["game", "pictochat", "exit", "gamePak", "brightness", "settings", "alarm"];
		moveIn = ["topBar", "nameText", "timeText", "dateText", "separators", "blackLine"];

		// this is the color palette so it shouldnt be added, just loaded so we can use the pixel data
		palette = new FlxSprite(0, 0).loadGraphic(Paths.image('palette'));

		mainCam = new FlxCamera(0, -600, 256, 384, 2);
		mainCam.pixelPerfectRender = true;
		var win = Lib.application.window; // just to make this following line shorter
		win.move(win.x + Std.int((win.width - 512) / 2), win.y + Std.int((win.height - 768) / 2));
		win.resize(512, 768);
		Lib.current.x = 0;
		Lib.current.y = 0;
		Lib.current.scaleX = 2.5;
		Lib.current.scaleY = 2.5;
		Main.fpsVar.visible = false;
		FlxG.mouse.load(TitleState.mouse.pixels, 0.8);
		
		FlxG.cameras.add(mainCam);

		topScreen = new FlxSprite(0, 0).makeGraphic(256, 192, 0xFFFFFFFF, true);
		topScreen.cameras = [mainCam];
		add(topScreen);

		bottomScreen = new FlxSprite(0, 192).makeGraphic(256, 192, 0xFFFFFFFF, true);
		bottomScreen.cameras = [mainCam];
		add(bottomScreen);

		topCanvas = new FlxSprite(0, 0).makeGraphic(256, 192, 0x00000000, true);
		topCanvas.antialiasing = false;
		topCanvas.cameras = [mainCam];
		add(topCanvas);

		bottomCanvas = new FlxSprite(0, 192).makeGraphic(256, 192, 0x00000000, true);
		bottomCanvas.antialiasing = false;
		bottomCanvas.cameras = [mainCam];
		add(bottomCanvas);

		for (i in 0...192)
		{
			var lineCol:FlxColor = 0x00000000;
			if ((i + 1) % 16 == 0)
			{
				lineCol = 0xFFC0C0C0;
			}
			else if ((i + 1) % 2 == 1)
			{
				lineCol = 0xFFFFFFFF;
			}
			else
			{
				lineCol = 0xFFE0E0E0;
			}
			var lineCol2:FlxColor = lineCol;
			if ((i + 25) % 48 != 0 && (lineCol2 == 0xFFC0C0C0 || lineCol2 == 0xFF000000))
			{
				lineCol2 = 0xFFE0E0E0;
			}
			if ((i + 25) % 48 == 0)
			{
				lineCol2 = 0xFFC0C0C0;
			}
			for (j in 0...256)
			{
				topCanvas.pixels.setPixel32(j, i, lineCol);
				bottomCanvas.pixels.setPixel32(j, i, lineCol2);
				// holy shit this fucking boolean expression
				if ((((i + 26) % 48 == 0 || (i + 24) % 48 == 0) && ((j + 18) % 48 == 0 || (j + 16) % 48 == 0)))
				{
					bottomCanvas.pixels.setPixel32(j, i, 0xFFC0C0C0);
				}
				if ((((j + 18) % 48 == 0 || (j + 16) % 48 == 0) && (3 <= (i + 26) % 48 && (i + 26) % 48 <= 7)))
				{
					bottomCanvas.pixels.setPixel32(j, i, 0xFFFFFFFF);
				}
			}
		}
		for (i in 1...17)
		{
			var x = i * 16 - 1;
			for (j in 0...192)
			{
				topCanvas.pixels.setPixel32(x, j, 0xFFC0C0C0);
				if ((i + 1) % 3 == 0)
				{
					bottomCanvas.pixels.setPixel32(x, j, 0xFFC0C0C0);
				}
			}
		}

		clock = new FlxSprite(14, 46).loadGraphic(Paths.image('dsclock'));
		clock.antialiasing = false;
		clock.cameras = [mainCam];
		add(clock);

		clockHands = new FlxSprite(14, 46).makeGraphic(99, 99, 0x00000000, true);
		clockHands.antialiasing = false;
		clockHands.cameras = [mainCam];
		add(clockHands);

		topBar = new PaletteSprite(0, -16);
		topBar.loadGraphic(Paths.image('topBar'), false, 0, 0, true);
		topBar.antialiasing = false;
		topBar.cameras = [mainCam];
		add(topBar);

		blackLine = new FlxSprite(0, -1).makeGraphic(256, 1, 0xFF000000);
		blackLine.cameras = [mainCam];
		add(blackLine);

		nameText = new PaletteText(0, -18, 0, FlxG.save.data.dbuser, 16);
		nameText.setFormat(Paths.font("BIOSSmall.ttf"), 16, 0xFFFFFFFF, FlxTextAlign.LEFT);
		nameText.antialiasing = false;
		removeSpacers(nameText);
		nameText.cameras = [mainCam];
		add(nameText);

		timeText = new PaletteText(143, -18, 32, "00:00", 16);
		timeText.setFormat(Paths.font("BIOSSmall.ttf"), 16, 0xFFFFFFFF, FlxTextAlign.CENTER);
		timeText.antialiasing = false;
		removeSpacers(timeText);
		timeText.cameras = [mainCam];
		add(timeText);

		dateText = new PaletteText(174, -18, 32, "00/00", 16);
		dateText.setFormat(Paths.font("BIOSSmall.ttf"), 16, 0xFFFFFFFF, FlxTextAlign.CENTER);
		dateText.antialiasing = false;
		removeSpacers(dateText);
		dateText.cameras = [mainCam];
		add(dateText);

		separators = new FlxSprite(143, -16).loadGraphic(Paths.image('separators'));
		separators.antialiasing = false;
		separators.cameras = [mainCam];
		add(separators);

		calendar = new FlxSprite(126, 31).loadGraphic(Paths.image('calendar'));
		calendar.antialiasing = false;
		calendar.cameras = [mainCam];
		add(calendar);

		dayIndicator = new PaletteSprite(0, 0);
		dayIndicator.loadGraphic(Paths.image('dayIndicator'));
		dayIndicator.antialiasing = false;
		dayIndicator.cameras = [mainCam];
		add(dayIndicator);

		calendarTextGroup = new FlxGroup();
		setUpDays(calendarTextGroup, 126, 31);
		calendarTextGroup.cameras = [mainCam];
		add(calendarTextGroup);

		gamePak = new FlxSprite(33, 313).loadGraphic(Paths.image('gamePak'));
		gamePak.antialiasing = false;
		gamePak.cameras = [mainCam];
		add(gamePak);

		game = new Button(33, 217, Paths.image('game'), Paths.image('gamePressed'), Paths.image('gameAway'), false, false);
		game.antialiasing = false;
		game.cameras = [mainCam];
		game.onClick = function(b:Button)
		{
			// TODO: add in anims
			FlxG.switchState(new YSState());
		}

		pictochat = new Button(33, 265, Paths.image('pictochat'), Paths.image('pictochatPressed'), Paths.image('pictochatAway'), false, false);
		pictochat.antialiasing = false;
		pictochat.cameras = [mainCam];
		pictochat.onClick = function(b:Button)
		{
			trace("button pressed: pictochat");
		}

		exit = new Button(129, 265, Paths.image('exitBios'), Paths.image('exitBiosPressed'), Paths.image('exitBiosAway'), false, false);
		exit.antialiasing = false;
		exit.cameras = [mainCam];
		exit.onClick = function(b:Button)
		{
			activeGroup.movable = false;
			game.pressable = false;
			pictochat.pressable = false;
			exit.pressable = false;
			brightness.pressable = false;
			settings.pressable = false;
			alarm.pressable = false;
			FlxTween.tween(message, {y: message.y - 192 + 63}, 0.2);
			FlxTween.tween(shutdown, {y: shutdown.y - 192 + 63}, 0.2);
		}

		brightness = new Button(10, 367, Paths.image('brightness'), null, null, true, false);
		brightness.antialiasing = false;
		brightness.cameras = [mainCam];
		brightness.cursorOffsets = [-7, -6, 9, -6, 9, 5, -7, 5];
		brightness.onClick = function(b:Button)
		{
			switch overlay.alpha
			{
				case 0.9:
					overlay.alpha = 0.7;
				case 0.7:
					overlay.alpha = 0.4;
				case 0.4:
					overlay.alpha = 0;
				case 0:
					overlay.alpha = 0.9;
			}
		}

		settings = new Button(117, 362, Paths.image('settings'), Paths.image('settingsPressed'), Paths.image('settingsAway'), false, false);
		settings.antialiasing = false;
		settings.cameras = [mainCam];
		settings.cursorOffsets = [-2, -1, 3, -1, 3, 0, -2, 0];
		settings.onClick = function(b:Button)
		{
			trace("button pressed: settings");
		}

		alarm = new Button(235, 367, Paths.image('alarm'), null, null, true, false);
		alarm.antialiasing = false;
		alarm.cameras = [mainCam];
		alarm.cursorOffsets = [-7, -6, 9, -6, 9, 5, -7, 5];
		alarm.onClick = function(b:Button)
		{
			trace("button pressed: alarm");
		}

		var cursor = new PaletteSprite(0, 0);
		cursor.loadGraphic(Paths.image('dsCursor'));
		cursor.antialiasing = false;
		cursor.cameras = [mainCam];

		mainMenuGroup = new ButtonGroup(0, new FlxPoint(0, 0), cursor, "FF8100FFFFFF0FF900F09601FFFFFF18F702FF6F0321AF046FFF05FF7F0339BF047FFF05",
			[game, pictochat, exit, brightness, settings, alarm], new FlxPoint(3, 4));
		mainMenuGroup.movable = false;
		add(mainMenuGroup);

		activeGroup = mainMenuGroup;

		forEachOfType(PaletteSprite, function(p:PaletteSprite)
		{
			p.setPalette(palette, currFav);
		});
		forEachOfType(PaletteText, function(p:PaletteText)
		{
			p.setPalette(palette, currFav);
		});
		activeGroup.cursorGroup.topleft.setPalette(palette, currFav); // the rest of the group is just copies of the top left

		message = new FlxSprite(25, 384).loadGraphic(Paths.image("dsmessage"));
		message.antialiasing = false;
		message.cameras = [mainCam];
		add(message);

		shutdown = new FlxText(0, 0, 0, "The system will now shut down.");
		shutdown.setFormat(Paths.font("BIOSNormal.ttf"), 16);
		shutdown.antialiasing = false;
		shutdown.x = (message.width - shutdown.width) / 2 + 25;
		shutdown.y = (message.height - shutdown.height) / 2 + 384;
		shutdown.cameras = [mainCam];
		add(shutdown);

		overlay = new FlxSprite(0, 0).makeGraphic(256, 384, 0xFF000000);
		overlay.alpha = 0;
		overlay.cameras = [mainCam];
		add(overlay);

		broWait = new FlxSprite(0, 0).makeGraphic(256, 384, 0xFFFFFFFF);
		broWait.cameras = [mainCam];
		add(broWait);

		introStatic = new FlxSprite(0, 0).loadGraphic(Paths.image('dsintrostatic'));
		introStatic.antialiasing = false;
		introStatic.cameras = [mainCam];
		introStatic.alpha = 0;
		add(introStatic);

		touch = new FlxText(0, 357, 256, "Touch the Touch Screen to continue.", 16);
		touch.setFormat(Paths.font("BIOSNormal.ttf"), 16, 0xFF000000, FlxTextAlign.CENTER);
		touch.alpha = 0;
		touch.antialiasing = false;
		touch.cameras = [mainCam];
		add(touch);

		intro = new DSVideo(Paths.video('dsintro'), mainCam, this);
		add(intro);

		lazyAss = new FlxTimer();
		lazyAss.start(60, function(timer:FlxTimer)
		{
			doItYourself = true;
		});

		super.create();
	}

	public inline function fadeInAndOut(text:FlxText)
	{
		FlxTween.tween(text, {alpha: 1}, 0.5).then(FlxTween.tween(text, {alpha: 0}, 0.5));
	}

	override function update(elapsed:Float)
	{
		FlxG.stage.quality = flash.display.StageQuality.LOW;
		if (state == DSState.Welcome)
		{
			if (touchTimer == null && intro.finished)
			{
				introStatic.alpha = 1;
				touchTimer = new FlxTimer();
				fadeInAndOut(touch);
				touchTimer.start(1, function(timer:FlxTimer)
				{
					fadeInAndOut(touch);
				}, 0);
			}
			if ((FlxG.mouse.justPressed && touchTimer != null) || doItYourself)
			{
				var position = FlxG.mouse.getPositionInCameraView(mainCam);
				lazyAss.cancel();
				if (position.y >= 192 && position.y <= 383 && position.x >= 0 && position.x <= 255)
				{
					state = DSState.BIOS;
					forEachReflect(fadeOut, "fadeShitOut", 0, false);
					touchTimer.cancel();
					new FlxTimer().start(0.25, function(timer:FlxTimer)
					{
						hideAll(0, activeGroup.cursorGroup.topleft);
						hideAll(0, activeGroup.cursorGroup.topright);
						hideAll(0, activeGroup.cursorGroup.bottomright);
						hideAll(0, activeGroup.cursorGroup.bottomleft);
						forEachReflect(fadeIn2, "hideAll", 0, false);
						forEachReflect(fadeIn1, "fadeShitIn", 0, false);
						calendarTextGroup.forEachAlive(function(text)
						{
							fadeShitIn(0, text);
						});
						broWait.alpha = 0;
					});
					new FlxTimer().start(0.5, function(timer:FlxTimer)
					{
						fadeShitIn(0, activeGroup.cursorGroup.topleft);
						fadeShitIn(0, activeGroup.cursorGroup.topright);
						fadeShitIn(0, activeGroup.cursorGroup.bottomright);
						fadeShitIn(0, activeGroup.cursorGroup.bottomleft);
						forEachReflect(fadeIn2, "fadeShitIn", 0, false);
						forEachReflect(moveIn, "moveShitIn", 0, false);
					});
					new FlxTimer().start(0.75, function(timer:FlxTimer)
					{
						activeGroup.movable = true;
						game.pressable = true;
						pictochat.pressable = true;
						exit.pressable = true;
						brightness.pressable = true;
						settings.pressable = true;
						alarm.pressable = true;
					});
				}
			}
		}
		else if (state == DSState.BIOS)
		{
			if (FlxG.keys.justPressed.C)
			{
				currFav++;
				if (currFav == 16)
				{
					currFav = 0;
				}
				forEachOfType(PaletteSprite, function(p:PaletteSprite)
				{
					p.setPalette(palette, currFav);
				});
				forEachOfType(PaletteText, function(p:PaletteText)
				{
					p.setPalette(palette, currFav);
				});
				activeGroup.cursorGroup.topleft.setPalette(palette, currFav);
			}
			else if (FlxG.keys.justPressed.LEFT)
			{
				activeGroup.move(0);
			}
			else if (FlxG.keys.justPressed.UP)
			{
				activeGroup.move(1);
			}
			else if (FlxG.keys.justPressed.RIGHT)
			{
				activeGroup.move(2);
			}
			else if (FlxG.keys.justPressed.DOWN)
			{
				activeGroup.move(3);
			}

			var now = Date.now();
			var secs = now.getSeconds();
			var mins = now.getMinutes();
			var hours = now.getHours() + (mins / 60);
			var day = now.getDate();
			var month = now.getMonth() + 1;

			if (oldDay != -1 && oldDay != day)
			{
				setUpDays(calendarTextGroup, 126, 31);
			}

			oldDay = day;

			var ms = Sys.time() % 1;
			var delim = "";
			if (ms <= 0.5)
			{
				delim = ":";
			}
			else
			{
				delim = "|";
			}

			timeText.text = "";
			addLeading(timeText, Std.int(hours));
			timeText.text += Std.string(Std.int(hours));
			timeText.text += delim;
			addLeading(timeText, mins);
			timeText.text += Std.string(mins);
			removeSpacers(timeText);

			dateText.text = "";
			addLeading(dateText, month);
			dateText.text += Std.string(month);
			dateText.text += "/";
			addLeading(dateText, day);
			dateText.text += Std.string(day);
			removeSpacers(dateText);

			clockHands.fill(FlxColor.TRANSPARENT);

			clockHandFix(32, (2 * Math.PI / 60) * mins - Math.PI / 2, 0xFF787878);
			clockHandFix(24, (2 * Math.PI / 12) * hours - Math.PI / 2, 0xFF787878);
			clockHandFix(36, (2 * Math.PI / 60) * secs - Math.PI / 2, palette.pixels.getPixel32(7, currFav));

			for (x in 47...52)
			{
				for (y in 47...52)
				{
					clockHands.pixels.setPixel(x, y, 0xFF484848);
				}
			}
		}

		super.update(elapsed);
	}

	// dear haxeflixel:
	// STOP FUCKING SMOOTHING MY LINES IM GOING TO FUCKING KILL YOU
	// sincerely: atpx8
	public function cleanLine(startX, startY, endX, endY, color, image:BitmapData):Float
	{
		var slope = (endY - startY) / (endX - startX);
		if (slope == Math.POSITIVE_INFINITY)
		{
			for (i in 0...(endY - startY))
			{
				image.setPixel32(startX, i + startY, color);
			}
		}
		else if (slope >= -1 && slope <= 1)
		{
			for (i in Std.int(Math.min(0, (endX - startX)))...Std.int(Math.max(0, (endX - startX))))
			{
				image.setPixel32(i + startX, Math.round(slope * i) + startY, color);
			}
		}
		else
		{
			for (i in Std.int(Math.min(0, (endY - startY)))...Std.int(Math.max(0, (endY - startY))))
			{
				image.setPixel32(Math.round(Math.pow(slope, -1) * i) + startX, i + startY, color);
			}
		}
		return slope;
	}

	// very much hard coded for the clock hands, thankfully i can pretty much just use images for everything else
	public function clockHandFix(length, angle, color):Void
	{
		var slope = cleanLine(49, 49, Math.round(49 + length * Math.cos(angle)), Math.round(49 + length * Math.sin(angle)), color, clockHands.pixels);
		var offset = new FlxPoint(0, 0);
		if (slope == Math.POSITIVE_INFINITY)
		{
			if (Math.sin(angle) < 1)
			{
				offset.x = -1;
			}
			else
			{
				offset.x = 1;
			}
		}
		else if (slope >= -1 && slope <= 1)
		{
			if (Math.cos(angle) < 1)
			{
				offset.y = -1;
			}
			else
			{
				offset.y = 1;
			}
		}
		else
		{
			if (Math.sin(angle) < 1)
			{
				offset.x = -1;
			}
			else
			{
				offset.x = 1;
			}
		}
		// 192 chars, this is some of the worst code ive ever written
		cleanLine(49 + Std.int(offset.x), 49 + Std.int(offset.y), Math.round(49 + offset.x + length * Math.cos(angle)),
			Math.round(49 + offset.y + length * Math.sin(angle)), color, clockHands.pixels);
		return;
	}

	public inline function removeSpacers(text:FlxText, depth:Int = 13):Void
	{
		for (i in 0...Std.int(text.width))
		{
			text.pixels.setPixel32(i, depth, 0x00000000);
		}
	}

	public inline function addLeading(text:FlxText, num:Int):Void
	{
		if (num < 10)
		{
			text.text += "0";
		}
	}

	// elem 0: charging (0 if no, 1 if yes)
	// elem 1: percentage (-1 if no battery, 0-100 if battery);
	public function getBattery():Array<Int>
	{
		var charging = new sys.io.Process("wmic path Win32_Battery Get BatteryStatus", null);
		var ret = [0, -1];
		if (charging.stderr.readAll().toString().split("\n")[0] != "")
		{
			return ret;
		}
		var val:Int = Std.parseInt(charging.stdout.readAll().toString().split("\n")[1]);
		if (val == 1 || (val >= 3 && val <= 5) || val == 10)
		{
			ret[0] = 0;
		}
		else
		{
			ret[0] = 1;
		}
		var battery = Std.parseInt(new sys.io.Process("WMIC PATH Win32_Battery Get EstimatedChargeRemaining",
			null).stdout.readAll().toString().split("\n")[1]);
		ret[1] = battery;
		return ret;
	}

	public function spaceNum(i:Int, digs:Int):String
	{
		var ret = "";
		for (id in 0...digs)
		{
			ret = "'" + Std.string(Std.int(i / (Math.pow(10, id))) % 10) + ret;
		}
		return ret.substr(1);
	}

	public function setUpDays(group:FlxGroup, offx, offy):Void
	{
		group.forEachExists(function(a)
		{
			group.remove(a);
			a.destroy();
		});

		var temp;
		var now = Date.now();
		var dayOfWeek = now.getDay();
		var month = now.getMonth() + 1;
		var day = now.getDate();
		var year = now.getFullYear();

		temp = new FlxText(offx, offy - 1, 114, "", 16);
		temp.setFormat(Paths.font("BIOSNormal.ttf"), 16, 0xFF000000, FlxTextAlign.CENTER);
		if (month < 10)
		{
			temp.text += "0'" + Std.string(month);
		}
		else
		{
			temp.text += spaceNum(month, 2);
		}
		temp.text += "\"/\"" + spaceNum(year, 4);
		temp.antialiasing = false;
		removeSpacers(temp, 15);
		group.add(temp);

		var dayOffset = dayOfWeek + 1 - day + 7 * Math.ceil(day / 7) - 7;
		while (dayOffset < 0)
		{
			dayOffset += 7;
		}
		if (dayOffset + DateTools.getMonthDays(now) > 35)
		{
			calendar.loadGraphic(Paths.image('calendartall'));
		}
		else
		{
			calendar.loadGraphic(Paths.image('calendar'));
		}

		for (i in dayOffset...dayOffset + DateTools.getMonthDays(now))
		{
			// offy + 32
			// offx + 1
			temp = new FlxText(offx + 1 + (16 * (i % 7)), offy + 31 + 16 * Std.int(i / 7), 16, Std.string(i - dayOffset + 1), 16);
			var col = 0xFF303030;
			if (i % 7 == 0)
			{
				col = 0xFF780000;
			}
			else if (i % 7 == 6)
			{
				col = 0xFF000080;
			}
			if (i - dayOffset + 1 == day)
			{
				dayIndicator.x = (16 * (i % 7)) + 3 + offx;
				dayIndicator.y = (16 * Std.int(i / 7)) + 34 + offy;
			}
			temp.setFormat(Paths.font("BIOSSmall.ttf"), 16, col, FlxTextAlign.CENTER);
			temp.antialiasing = false;
			removeSpacers(temp);
			group.add(temp);
		}
	}

	public inline function fadeShitIn(index:Int, sprite:Dynamic)
	{
		sprite.alpha = 0;
		FlxTween.tween(sprite, {alpha: 1}, 0.25);
	}

	public inline function hideAll(index:Int, sprite:Dynamic)
	{
		sprite.alpha = 0;
	}

	public inline function fadeShitOut(index:Int, sprite:FlxSprite)
	{
		FlxTween.cancelTweensOf(sprite);
		FlxTween.tween(sprite, {alpha: 0}, 0.25);
	}

	public inline function moveShitIn(index:Int, sprite:FlxSprite)
	{
		FlxTween.tween(sprite, {y: sprite.y + 16}, 0.25);
	}

	public function forEachReflect(strs:Array<String>, func:String, index:Int, wipe:Bool):Void
	{
		var funct = Reflect.field(this, func);
		for (x in strs)
		{
			var spr = Reflect.field(this, x);
			if (spr == null)
			{
				trace(x + " IS NULL!");
				continue;
			}
			if (wipe)
			{
				spr.loadGraphic(Paths.image(x), false, 0, 0, true);
			}
			Reflect.callMethod(this, funct, [index, spr]);
		}
	}
}
