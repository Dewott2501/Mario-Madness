package;

import flixel.system.FlxAssets.FlxShader;

class SilhouetteShader extends FlxShader
{
	@:glFragmentSource('
        #pragma header

        uniform vec3 col;
        uniform float amount;

        void main() {
            vec4 orig = flixel_texture2D(bitmap, openfl_TextureCoordv);
            gl_FragColor = vec4(mix(orig.rgb, mix(vec3(0.0, 0.0, 0.0), col, orig.a), amount), orig.a);
        }
    ')
	public function new(r:Int, g:Int, b:Int)
	{
		super();
		col.value = [r / 255, g / 255, b / 255];
		amount.value = [0.0];
	}

	public function update(amount1:Float)
	{
		amount.value[0] += amount1;
		while (amount.value[0] > 1)
		{
			amount.value[0] -= 1;
		}
	}
}
