package openfl.display;

import flixel.FlxG;
import lime.graphics.Image;
import lime.graphics.cairo.CairoImageSurface;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

/**
 * An optimized version of `openfl.display.BitmapData`, clearing
 * the stored bitmap on reguluar ram since FNF does not need it.
 * 
 * @see https://github.com/FNF-CNE-Devs/CodenameEngine/blob/main/source/funkin/backend/system/OptimizedBitmapData.hx
 * @author YoshiCrafter29
 */
class OptimizedBitmapData extends BitmapData {
	@SuppressWarnings("checkstyle:Dynamic")
	@:noCompletion private override function __fromImage(image:#if lime Image #else Dynamic #end):Void
	{
		#if lime
		if (image != null && image.buffer != null)
		{
			this.image = image;

			width = image.width;
			height = image.height;
			rect = new Rectangle(0, 0, image.width, image.height);

			__textureWidth = width;
			__textureHeight = height;

			#if sys
			image.format = BGRA32;
			image.premultiplied = true;
			#end

			__isValid = true;
			readable = true;

			lock();
			getTexture(FlxG.stage.context3D);
			getSurface();

			readable = true;
			this.image = null;

			// @:privateAccess
			// if (FlxG.bitmap.__doNotDelete)
			// 	MemoryUtil.clearMinor();
		}
		#end
	}

	@SuppressWarnings("checkstyle:Dynamic")
	@:dox(hide) public override function getSurface():#if lime CairoImageSurface #else Dynamic #end
	{
		#if lime
		if (__surface == null)
		{
			__surface = CairoImageSurface.fromImage(image);
		}

		return __surface;
		#else
		return null;
		#end
	}

	public static function fromImage(image:Image, transparent:Bool = true):OptimizedBitmapData {
		if (image == null || image.buffer == null) return null;

		var bitmapData = new OptimizedBitmapData(0, 0, transparent, 0);
		bitmapData.__fromImage(image);
		return bitmapData;
	}
}