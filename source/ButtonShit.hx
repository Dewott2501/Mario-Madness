package;

import cpp.UInt8;
import cpp.abi.Abi;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.io.Bytes;
import haxe.io.BytesData;
import openfl.display.BitmapData;
import openfl.utils.IAssetCache;

typedef Pathing = {
	left:FlxPoint,
	up:FlxPoint,
	right:FlxPoint,
	down:FlxPoint
};

typedef ButtonCombo = {
	button:Button,
	pathing:Pathing
};

typedef ButtonGrid = Map<Int, ButtonCombo>;

typedef CursorGroup = {
	topleft:PaletteSprite,
	topright:PaletteSprite,
	bottomright:PaletteSprite,
	bottomleft:PaletteSprite
};

enum ButtonState {
	Normal;
	Held;
	Instant;
}

// wow ngl, this code kinda sucks ass, ill prob have to redo a lot
// though itll be in new classes so i dont have to change a bunch of existing code

class ButtonGroup extends FlxGroup {
	// format for path:
	// byte 1: x and y position to go to when going left and up
	// byte 2: x and y position to go to when going right and down
	// byte 3: what button this grid space corresponds to
	public var grid:ButtonGrid;
	public var position:FlxPoint;
	public var cursorGroup:CursorGroup;
	public var tweens:Array<FlxTween>;
	public var movable:Bool;
	public var cursors:Bool;

	public override function new(MaxSize:Int = 0, StartPos:FlxPoint, Cursor:PaletteSprite, Pathing:String, Buttons:Array<Button>, GridSize:FlxPoint) {
		super(MaxSize);
		if (Pathing != null && Buttons != null && GridSize != null) {
			parseGrid(Pathing, Buttons, GridSize);
		}
		cursorGroup = {
			topleft: null,
			topright: null,
			bottomright: null,
			bottomleft: null
		};
		tweens = [];
		position = StartPos;
		cursors = false;
		if (Cursor != null) {
			setUpCursor(Cursor);
			cursors = true;
		}
		movable = true;
	}

	public function parseGrid(Pathing:String, Buttons:Array<Button>, GridSize:FlxPoint):Void {
		for (button in Buttons) {
			add(button);
		}
		grid = new ButtonGrid();
		var data:BytesData = Bytes.ofHex(Pathing).getData();
		for (y in 0...Std.int(GridSize.y)) {
			for (x in 0...Std.int(GridSize.x)) {
				var currData:BytesData = data.splice(0, 3);
				if (currData[2] != 0xFF) {
					var combo:ButtonCombo = {button: null, pathing: null};
					combo.button = Buttons[currData[2]];
					var pathing:Pathing = {
						left: null,
						up: null,
						right: null,
						down: null
					};
					for (i in 0...2) {
						var temp:UInt8 = currData[i];
						for (j in 0...2) {
							var temp2 = temp & 0x0F;
							var val:FlxPoint = null;
							if (temp2 != 0x0F) {
								val = new FlxPoint();
								val.y = temp2 & 0x3;
								temp2 >>= 2;
								val.x = temp2 & 0x3;
							}
							switch (i * 2 + j) {
								case 0:
									pathing.up = val;
								case 1:
									pathing.left = val;
								case 2:
									pathing.down = val;
								case 3:
									pathing.right = val;
							}
							temp >>= 4;
						}
					}
					combo.pathing = pathing;
					grid[x << 8 | y] = combo;
				}
			}
		}
	}

	public function setUpCursor(sprite:PaletteSprite):Void {
		var temp2 = grid[Std.int(position.x) << 8 | Std.int(position.y)].button;
		var offset = new FlxPoint(Std.int(sprite.width / 2), Std.int(sprite.height / 2));
		sprite.antialiasing = false;
		sprite.x = temp2.x - offset.x + temp2.cursorOffsets[0] + 2;
		sprite.y = temp2.y - offset.y + temp2.cursorOffsets[1] + 3;
		add(sprite);
		cursorGroup.topleft = sprite;
		var temp:PaletteSprite;
		var temp3:PaletteSprite;
		var temp4:PaletteSprite;
		temp = new PaletteSprite();
		temp.loadGraphicFromSprite(sprite);
		temp.cameras = sprite.cameras;
		temp.antialiasing = false;
		temp.angle = 90;
		temp.x = temp2.width + temp2.x - offset.x + temp2.cursorOffsets[2] - 4;
		temp.y = temp2.y - offset.y + temp2.cursorOffsets[3] + 3;
		add(temp);
		cursorGroup.topright = temp;
		temp3 = new PaletteSprite();
		temp3.loadGraphicFromSprite(sprite);
		temp3.cameras = sprite.cameras;
		temp3.antialiasing = false;
		temp3.angle = 180;
		temp3.x = temp2.width + temp2.x - offset.x + temp2.cursorOffsets[4] - 4;
		temp3.y = temp2.height + temp2.y - offset.y + temp2.cursorOffsets[5] - 4;
		add(temp3);
		cursorGroup.bottomright = temp3;
		temp4 = new PaletteSprite();
		temp4.loadGraphicFromSprite(sprite);
		temp4.cameras = sprite.cameras;
		temp4.antialiasing = false;
		temp4.angle = 270;
		temp4.x = temp2.x - offset.x + temp2.cursorOffsets[6] + 2;
		temp4.y = temp2.height + temp2.y - offset.y + temp2.cursorOffsets[7] - 4;
		add(temp4);
		cursorGroup.bottomleft = temp4;
	}

	public function move(direction:Int):Void {
		if (!movable) {
			return;
		}
		var current:Pathing = grid[Std.int(position.x) << 8 | Std.int(position.y)].pathing;
		var moveTo:FlxPoint = null;
		switch direction {
			case 0:
				moveTo = current.left;
			case 1:
				moveTo = current.up;
			case 2:
				moveTo = current.right;
			case 3:
				moveTo = current.down;
		}
		if (moveTo == null) {
			return;
		}
		for (tween in tweens) {
			tween.cancel();
			tween.destroy();
		}
		tweens.resize(0);
		position = moveTo;
		var temp:Button = grid[Std.int(position.x) << 8 | Std.int(position.y)].button;
		var offset = new FlxPoint(Std.int(cursorGroup.topleft.width / 2), Std.int(cursorGroup.topleft.height / 2));
		if (cursors) {
			tweens.push(FlxTween.tween(cursorGroup.topleft,
				{x: temp.x - offset.x + temp.cursorOffsets[0] + 2, y: temp.y - offset.y + temp.cursorOffsets[1] + 3}, 0.33, {ease: FlxEase.cubeOut}));
			tweens.push(FlxTween.tween(cursorGroup.topright,
				{x: temp.width + temp.x - offset.x + temp.cursorOffsets[2] - 4, y: temp.y - offset.y + temp.cursorOffsets[3] + 3}, 0.33,
				{ease: FlxEase.cubeOut}));
			tweens.push(FlxTween.tween(cursorGroup.bottomright, {x: temp.width + temp.x - offset.x + temp.cursorOffsets[4] - 4,
				y: temp.height
				+ temp.y
				- offset.y
				+ temp.cursorOffsets[5]
				- 4}, 0.33, {ease: FlxEase.cubeOut}));
			tweens.push(FlxTween.tween(cursorGroup.bottomleft,
				{x: temp.x - offset.x + temp.cursorOffsets[6] + 2, y: temp.height + temp.y - offset.y + temp.cursorOffsets[7] - 4}, 0.33,
				{ease: FlxEase.cubeOut}));
		}
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}
}

class Button extends FlxSprite {
	public var normal:FlxSprite;
	public var pressed:FlxSprite;
	public var mouseAway:FlxSprite;
	public var onClick:Button->Void;
	public var pressable:Bool;
	public var state:ButtonState;
	public var cursorOffsets:Array<Int>;

	override public function new(X:Null<Float> = 0, Y:Null<Float> = 0, normal:FlxGraphicAsset, pressed:Null<FlxGraphicAsset>, mouseAway:Null<FlxGraphicAsset>,
			instant:Bool = false, pressable:Bool = true) {
		this.pressable = pressable;
		super(X, Y);
		cursorOffsets = [0, 0, 0, 0, 0, 0, 0, 0];
		state = ButtonState.Instant;
		if (!instant) {
			state = ButtonState.Normal;
		}
		if (mouseAway != null) {
			this.mouseAway = new FlxSprite(0, 0).loadGraphic(mouseAway, false, 0, 0, true);
		}
		if (pressed != null) {
			this.pressed = new FlxSprite(0, 0).loadGraphic(pressed, false, 0, 0, true);
		}
		this.normal = new FlxSprite(0, 0).loadGraphic(normal, false, 0, 0, true);
		pixels = this.normal.pixels;
	}

	override public function update(elapsed:Float):Void {
		if (pressable) {
			switch (state) {
				case ButtonState.Instant:
					if (checkForPress()) {
						onClick(this);
					}
					if (pressed != null) {
						if (FlxG.mouse.pressed && overlapsPoint(FlxG.mouse.getPositionInCameraView(cameras[0]), false, cameras[0])) {
							pixels = pressed.pixels;
						}
						else {
							pixels = normal.pixels;
						}
					}
				case ButtonState.Normal:
					if (checkForPress()) {
						pixels = pressed.pixels;
						state = ButtonState.Held;
					}
				case ButtonState.Held:
					var overlaps:Bool = overlapsPoint(FlxG.mouse.getPositionInCameraView(cameras[0]), false, cameras[0]);
					if (overlaps) {
						pixels = pressed.pixels;
					}
					else {
						pixels = mouseAway.pixels;
					}
					if (FlxG.mouse.justReleased) {
						pixels = normal.pixels;
						state = ButtonState.Normal;
						if (overlaps) {
							onClick(this);
						}
					}
			}
		}
		super.update(elapsed);
	}

	public function checkForPress():Bool {
		if (FlxG.mouse.justPressed) {
			if (overlapsPoint(FlxG.mouse.getPositionInCameraView(cameras[0]), false, cameras[0])) {
				return true;
			}
		}
		return false;
	}
}

//* DONE!: make a better cursor class and a button class that works with it
class ButtonExt extends Button {
	public var left:ButtonExt;
	public var right:ButtonExt;
	public var up:ButtonExt;
	public var down:ButtonExt;

	public var onSelected:CursorExt->Void;
}

class CursorExt extends FlxSprite {
	public var currButton:ButtonExt;

	override public function update(elapsed:Float) {
		if (FlxG.keys.justPressed.LEFT) {
			if (currButton.left != null) {
				currButton = currButton.left;
				if (currButton.onSelected != null) {
					currButton.onSelected(this);
				}
			}
		}
		else if (FlxG.keys.justPressed.RIGHT) {
			if (currButton.right != null) {
				currButton = currButton.right;
				if (currButton.onSelected != null) {
					currButton.onSelected(this);
				}
			}
		}
		else if (FlxG.keys.justPressed.UP) {
			if (currButton.up != null) {
				currButton = currButton.up;
				if (currButton.onSelected != null) {
					currButton.onSelected(this);
				}
			}
		}
		else if (FlxG.keys.justPressed.DOWN) {
			if (currButton.down != null) {
				currButton = currButton.down;
				if (currButton.onSelected != null) {
					currButton.onSelected(this);
				}
			}
		}
		super.update(elapsed);
	}
}

// TODO: make keyboard just fucking do it jesus fuck lazy ass
// TODO: make text length unhardcoded
// TODO: i do actually have to add backspace space shift and caps
// this doesnt extend ButtonGroup or NewButtonGroup because no fuck off
class Keyboard extends FlxGroup {
	// universal vars
	public var isActive:Bool;
	public var font:String;
	public var fontSize:Int;
	public var fontColor:FlxColor;

	// keyboard vars
	public var buttons:FlxTypedGroup<Button>;
	public var normalText:FlxTypedGroup<FlxText>;
	public var shiftText:FlxTypedGroup<FlxText>;
	public var capsText:FlxTypedGroup<FlxText>;
	public var normal:Bool;
	public var shift:Bool;
	public var caps:Bool;

	// text display vars
	public var displayCursor:FlxSprite;
	public var displayCursorPos:Int;
	public var displayGroup:FlxTypedGroup<FlxSprite>;
	public var displayText:FlxTypedGroup<FlxText>;
	public var textOffset:FlxPoint;
	public var typed:String;

	// hehe i dont need to specify width or height wooo hardcoding
	// unfortunately, i still need to specify a shit ton
	public function new(cam:FlxCamera, x:Int, y:Int, font:String, fontSize:Int, fontColor:FlxColor, charset:String, charsetCaps:String, charsetShift:String,
			offset:Bool, unpressed:FlxGraphicAsset, pressed:FlxGraphicAsset, mouseAway:FlxGraphicAsset, instant:Bool, cursor:FlxSprite,
			backing:FlxGraphicAsset, cursor2:FlxGraphicAsset, x2:Int, y2:Int, offsetX:Int, offsetY:Int, repeatDelay:Float, repeatPeriod:Float) {
		super();
		camera = cam;

		// things that affect both
		this.font = font;
		this.fontSize = fontSize;
		this.fontColor = fontColor;

		// keyboard setup
		// TODO: add code you dumbass
		buttons = new FlxTypedGroup<Button>();
		add(buttons);

		normalText = new FlxTypedGroup<FlxText>();
		add(normalText);
		normal = true;

		shiftText = new FlxTypedGroup<FlxText>();
		add(shiftText);
		shift = false;

		capsText = new FlxTypedGroup<FlxText>();
		add(capsText);
		caps = false;

		// text display vars
		textOffset = new FlxPoint(offsetX, offsetY);
		typed = "";

		if (!offset) {
			for (i in 0...charset.length) {
				var temp:Button = new Button(0, 0, unpressed, pressed, mouseAway, instant, true);
				temp.antialiasing = false;
				temp.cameras = [cam];
				temp.x = x + (temp.width + 1) * (i % 11);
				temp.y = y + (temp.height + 1) * Math.floor(i / 11);
				temp.onClick = function(b:Button) {
					addCharacter(charset.charAt(i));
				};
				buttons.add(temp);

				var temp2:FlxText = new FlxText(0, 0, 0, charset.charAt(i));
				temp2.antialiasing = false;
				temp2.setFormat(font, fontSize, fontColor);
				centerTextOnRect(temp2, new FlxRect(temp.x, temp.y, temp.width, temp.height));
				normalText.add(temp2);
			}
		}
		else {
			trace("fuck you thats what");
		}

		// text display setup
		// backing setup
		displayGroup = new FlxTypedGroup<FlxSprite>();
		add(displayGroup);

		for (i in 0...10) {
			var temp:FlxSprite = new FlxSprite(0, y2).loadGraphic(backing);
			temp.antialiasing = false;
			temp.x = x2 + i * temp.width;
			displayGroup.add(temp);
		}

		// cursor that shows on the text display
		displayCursor = new FlxSprite(x2, y2).loadGraphic(cursor2);
		displayCursor.antialiasing = false;
		add(displayCursor);
		displayCursorPos = 0;

		// this group holds the text and needs to go over the cursor
		displayText = new FlxTypedGroup<FlxText>();
		add(displayText);
	}

	public function addCharacter(char:String):Void {
		var ref:FlxSprite = displayGroup.members[displayCursorPos];

		var temp:FlxText = new FlxText(0, 0, 0, char);
		temp.antialiasing = false;
		temp.setFormat(font, fontSize, fontColor);
		centerTextOnRect(temp, new FlxRect(ref.x, ref.y, ref.width, ref.height));

		if (displayText.length == 10) {
			removeCharacter();
			displayText.add(temp);
		}
		else if (displayText.length == 9) {
			displayText.add(temp);
		}
		else {
			displayText.add(temp);
			displayCursorPos++;
			displayCursor.x += displayCursor.width;
		}

		typed = typed + char;
		trace(typed);
	}

	public function removeCharacter():Void {
		if (displayCursorPos == 0) {
			return;
		}
		displayText.remove(displayText.members[displayText.length - 1], true).destroy();
		if (displayText.length != 9) {
			displayCursorPos--;
			displayCursor.x -= displayCursor.width;
		}
		typed = typed.substr(0, typed.length - 1);
		trace(typed);
	}

	private function centerTextOnRect(text:FlxText, rect:FlxRect):Void {
		text.x = rect.left + (rect.width - text.width) / 2 + textOffset.x;
		text.y = rect.top + (rect.height - text.height) / 2 + textOffset.y;
	}
}
