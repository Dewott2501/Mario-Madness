package;

import editors.EditorPlayState;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

// based off of YSMenu by Yasu (http://home.usay.jp)
class YSState extends MusicBeatState
{
	public final dirs:Array<Dynamic> = [
		[],
		["Games", ["Mario Party DS (E).nds"]],
		[
			"TTMenu", ["skin", ["ass shit here"]], ["extinfo.dat"], ["infolib.dat"], ["language.ini"], ["OPTIONS.SYS"], ["reset.mse"], ["savlib.dat"],
			["SOFTRST.SYS"], ["system.ank"], ["system.fon"], ["system.l2u"], ["system.u2l"], ["ttdldi.dat"], ["TTMENU.SYS"], ["ttpatch.dat"], ["ttreset.dat"],
			["ttsystem.ini"], ["USRCHEAT.DAT"], ["YSMenu.ini"], ["YSMenu1.bmp"], ["YSMenu2.bmp"]],
		["TTMENU.DAT"],
		["TTMenu.nds"],
		["YSMenu.nds"]
	];
	public final sizes:Array<Dynamic> = [
		[],
		["", ["32MB"]],
		[
			"", ["", ["???"]], ["145KB"], ["614KB"], ["729B"], ["96B"], ["52KB"], ["440B"], ["4B"], ["256B"], ["590KB"], ["131KB"], ["131KB"], ["65KB"],
			["4GB"],
			["126KB"], ["70KB"], ["56B"], ["8GB"], ["17KB"], ["147KB"], ["147KB"]],
		["332KB"],
		["406KB"],
		["406KB"]
	];

	public var currDir:Array<Dynamic>;
	public var pastDirs:Array<Dynamic>;

	public var currSizes:Array<Dynamic>;
	public var pastSizes:Array<Dynamic>;

	public var selectNum:Int = 0;
	public var offset:Int = 0;

	public var mainCam:FlxCamera;
	public var textGroup:FlxTypedGroup<FlxText>;
	public var topBar:FlxSprite;
	public var currPath:FlxText;
	public var selection:FlxSprite;
	public var blocker:FlxSprite;

	override function create()
	{
		FlxG.sound.music.stop();
		FlxG.sound.soundTrayEnabled = false;

		bgColor = 0xFFBBBBBB;

		mainCam = new FlxCamera(0, -600, 256, 384, 2);
		FlxG.cameras.add(mainCam);

		selection = new FlxSprite(0, 12).makeGraphic(256, 10, 0xFF0000FF);
		selection.cameras = [mainCam];
		add(selection);

		textGroup = new FlxTypedGroup<FlxText>();
		add(textGroup);

		currDir = dirs;
		pastDirs = [];

		currSizes = sizes;
		pastSizes = [];

		createText();

		topBar = new FlxSprite(0, 0).makeGraphic(256, 12, 0xFF000000);
		topBar.cameras = [mainCam];
		for (i in 0...256)
		{
			topBar.pixels.setPixel32(i, 11, 0xFFEEEEEE);
		}
		add(topBar);

		currPath = new FlxText(-2, -4, 0, "/");
		currPath.setFormat(Paths.font("BIOSNormal.ttf"), 16, FlxColor.WHITE, FlxTextAlign.LEFT);
		currPath.cameras = [mainCam];
		currPath.antialiasing = false;
		add(currPath);

		blocker = new FlxSprite(0, 192).makeGraphic(256, 192, 0xFFBBBBBB);
		blocker.cameras = [mainCam];
		add(blocker);

		super.create();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		textGroup.members[selectNum * 2].color = 0xFF000000;
		textGroup.members[selectNum * 2 + 1].color = 0xFF000000;

		if (FlxG.keys.justPressed.BACKSLASH)
		{
			FlxG.switchState(new KeyboardTestingState());
		}

		if (controls.UI_UP_P)
		{
			selectNum--;
			if (currDir.length > 18 && selectNum < 8 - offset && offset < 0)
			{
				offset++;
				textGroup.forEachExists(function(t:FlxText)
				{
					t.y += 10;
				});
			}
		}
		else if (controls.UI_DOWN_P)
		{
			selectNum++;
			if (currDir.length > 18 && selectNum > 9 - offset && 19 - offset < currDir.length)
			{
				offset--;
				textGroup.forEachExists(function(t:FlxText)
				{
					t.y -= 10;
				});
			}
		}
		else if (controls.ACCEPT && currDir[selectNum + 1].length > 1)
		{
			pastDirs.push(currDir);
			pastSizes.push(currSizes);
			currDir = currDir[selectNum + 1];
			currSizes = currSizes[selectNum + 1];
			currPath.text += currDir[0] + "/";
			createText();
			selectNum = 0;
		}
		else if (controls.ACCEPT && currDir[selectNum + 1][0] == "Mario Party DS (E).nds")
		{
			// TODO: add anims and other shit
			FlxG.switchState(new PartyState());
		}
		else if (controls.BACK)
		{
			currDir = pastDirs.pop();
			currSizes = pastSizes.pop();
			var split:Array<String> = currPath.text.split("/");
			split.pop();
			split.pop();
			currPath.text = split.join("/") + "/";
			createText();
			selectNum = 0;
		}
		if (selectNum < 0)
		{
			selectNum = currDir.length - 2;
			if (currDir.length > 18)
			{
				offset = 18 - currDir.length;
				textGroup.forEachExists(function(t:FlxText)
				{
					t.y += 10 * offset;
				});
			}
		}
		else if (selectNum >= currDir.length - 1)
		{
			selectNum = 0;
			textGroup.forEachExists(function(t:FlxText)
			{
				t.y -= 10 * offset;
			});
			offset = 0;
		}
		selection.y = (selectNum + offset) * 10 + 12;

		textGroup.members[selectNum * 2].color = 0xFFFF0000;
		textGroup.members[selectNum * 2 + 1].color = 0xFFFF0000;
	}

	public function createText():Void
	{
		textGroup.forEachExists(function(t:FlxText)
		{
			t.destroy();
		});
		textGroup.clear();
		for (i in 0...currDir.length - 1)
		{
			var temp:FlxText = new FlxText(-2, 10 * i + 6, 0, currDir[i + 1][0]);
			temp.setFormat(Paths.font("pixelate-7.ttf"), 16, 0xFF000000, FlxTextAlign.LEFT);
			temp.cameras = [mainCam];
			temp.antialiasing = false;
			textGroup.add(temp);

			var temp2:FlxText = new FlxText(0, 10 * i + 6, 257, currSizes[i + 1][0]);
			temp2.setFormat(Paths.font("pixelate-7.ttf"), 16, 0xFF000000, FlxTextAlign.RIGHT);
			temp2.cameras = [mainCam];
			temp2.antialiasing = false;
			textGroup.add(temp2);
		}
	}
}
