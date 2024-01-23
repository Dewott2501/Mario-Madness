package;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import ButtonShit.Keyboard;
import flixel.FlxCamera;

class KeyboardTestingState extends MusicBeatState {
    public var mainCam:FlxCamera;
    public var keyboard:Keyboard;

    override function create() {
        mainCam = new FlxCamera(0, -600, 256, 384, 2);
        FlxG.cameras.add(mainCam);

        var temp:FlxSprite = new FlxSprite(0, 0).makeGraphic(12, 12);
        temp.antialiasing = false;

        var temp2:FlxSprite = new FlxSprite(0, 0).makeGraphic(12, 12, FlxColor.ORANGE);

        trace("ayy");
        //"àáâäèéêë"
        trace("à á â ä è é ê ë");
        keyboard = new Keyboard(mainCam, 25, 210, Paths.font("BIOSNormal.ttf"), 16, FlxColor.RED, "", "", "", false, temp.pixels, temp2.pixels, null, true, null, temp.pixels, temp2.pixels, 50, 50, 0, -1, 0.0, 0.0);
        //keyboard = new Keyboard(25, 210, Paths.font("BIOSNormal.ttf"), 16, FlxColor.RED, "", "", "", false, temp.pixels, temp2.pixels, null, true, null, temp.pixels, temp2.pixels, 50, 50, 0, -1, 0.0, 0.0);
        add(keyboard);
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);
        var key:Int = FlxG.keys.firstJustPressed();
        if (key != FlxKey.NONE) {
            if (key == FlxKey.BACKSPACE) {
                keyboard.removeCharacter();
            }/* else {
                keyboard.addCharacter(FlxKey.toStringMap[key]);
            }*/
        }
    }
}