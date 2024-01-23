package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;

class PaletteSprite extends FlxSprite
{
	public var copy:FlxSprite;

	public override function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false,
			?Key:String):FlxSprite
	{
		copy = new FlxSprite(0, 0).loadGraphic(Graphic, Animated, Width, Height, true, Key);
		copy.antialiasing = false;
		copy.visible = false;
		return super.loadGraphic(Graphic, Animated, Width, Height, true, Key);
	}

	public function setPalette(palette:FlxSprite, index:Int)
	{
		for (x in 0...frameWidth)
		{
			for (y in 0...frameHeight)
			{
				pixels.setPixel32(x, y, (copy.pixels.getPixel32(x, y) >> 24 << 24) | (palette.pixels.getPixel(copy.pixels.getPixel(x, y), index)));
			}
		}
	}
}

class PaletteText extends FlxText
{
	public inline function setPalette(palette:FlxSprite, index:Int)
	{
		color = palette.pixels.getPixel32(0, index);
	}
}
