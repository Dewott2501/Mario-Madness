package;

import flixel.effects.particles.FlxParticle;
import flixel.util.helpers.FlxRange;

class LavaParticle extends FlxParticle
{
	public var starting:Float;

	public function new()
	{
		super();
		loadGraphic(Paths.image('modstuff/lavaparticle'));
		alphaRange = new FlxRange(0.0, 1.0);
		colorRange = new FlxRange(0xffffffff, 0xffffffff);
		starting = alpha;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		alpha = starting * (1 - percent);
	}
}
