package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import openfl.filters.ShaderFilter;

class YCBUShaderTester extends MusicBeatState
{
	public var cam:FlxCamera;
	public var cam2:FlxCamera;
	public var testImage:FlxSprite;
	public var text:FlxText;
	public var shader:OldTVShader;

	override function create()
	{
		shader = new OldTVShader();
		var border:VCRBorder = new VCRBorder();
		var vcr:VCRMario85 = new VCRMario85();

		cam = new FlxCamera(0, 0, 1280, 720);
		cam.setFilters([new ShaderFilter(vcr), new ShaderFilter(shader), new ShaderFilter(border)]);
		FlxG.cameras.add(cam);

		cam2 = new FlxCamera(0, 0, 1280, 720);
		cam2.bgColor.alpha = 0;
		cam2.setFilters([new ShaderFilter(vcr), new ShaderFilter(shader), new ShaderFilter(border)]);
		FlxG.cameras.add(cam2);

		testImage = new FlxSprite(0, 0).loadGraphic(Paths.image('testimage'));
		testImage.cameras = [cam];
		//add(testImage);

		text = new FlxText(50, 50, "0.00", 20);
		text.cameras = [cam2];
		//add(text);

		super.create();
	}

	override function update(elapsed:Float)
	{
		shader.update(elapsed);

		super.update(elapsed);
	}
}
