package vlc;

import flixel.FlxSprite;
import flixel.FlxG;
import openfl.system.Capabilities;
#if (cpp && !mobile)
import cpp.NativeArray;
import cpp.UInt8;
import haxe.ValueException;
import haxe.io.Bytes;
import lime.app.Application;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.geom.Rectangle;
import vlc.LibVLC;

class DSBitmap extends VlcBitmap {
    public var renderSprite:FlxSprite;

    public override function new() {
        super();
        renderSprite = new FlxSprite(0, 0).makeGraphic(Std.int(width), Std.int(height), 0x00FFFFFF);
    }

    override function onAddedToStage(e:Event):Void {
        super.onAddedToStage(e);
        visible = false;
    }

    override function render() {
        try {
            super.render();

            if (bitmapData != null && renderSprite.pixels != null) {
                renderSprite.pixels = bitmapData;
            }

        } catch (e) {
            trace(e.message);
        }
    }
}
#end