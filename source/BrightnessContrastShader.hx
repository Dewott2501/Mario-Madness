package;

import flixel.system.FlxAssets.FlxShader;

class BrightnessContrastShader extends FlxShader
{
	@:glFragmentSource('
        #pragma header

        uniform float brightness;
        uniform float contrast;
        void main() {
            vec2 uv = openfl_TextureCoordv.xy;
            
            gl_FragColor = flixel_texture2D(bitmap, uv);
            gl_FragColor.rgb = ((gl_FragColor.rgb - 0.5) * max(contrast, 0.)) + 0.5;
            gl_FragColor.rgb *= max(brightness, 0.);
        }
    ')
	public function new()
	{
		super();
		brightness.value = [1.0];
		contrast.value = [1.0];
	}
}
