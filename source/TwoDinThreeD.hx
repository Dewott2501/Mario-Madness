package;

import flixel.system.FlxAssets.FlxShader;

class TwoDinThreeD extends FlxShader
{
	@glFragmentSource('
        #pragma header

        uniform float blur;
        uniform float gradMax;
        uniform float tiltDeg;
        uniform float xOff;
        uniform float yOff;

        const vec2 offsets[9] = vec2[9](vec2(0.0, 0.0), vec2(-1.0, -1.0), vec2(0.0, -1.0), vec2(1.0, -1.0),
        vec2(1.0, 0.0), vec2(1.0, 1.0), vec2(0.0, 1.0), vec2(-1.0, 1.0), vec2(-1.0, 0.0));

        void main() {
            float slope = tan(radians(tiltDeg));
            vec2 uv = openfl_TextureCoordv;
            vec4 avgCol = vec4(0.0, 0.0, 0.0, 0.0);
            vec2 step = vec2(1.0, 1.0)/(openfl_TextureSize.xy);
            for (int i = 0; i < 9; i++) {
                avgCol += flixel_texture2D(bitmap, uv + step * offsets[i]);
            }
            avgCol /= 9.0;
            vec4 finalCol = mix(flixel_texture2D(bitmap, uv), avgCol, blur);
            gl_FragColor = vec4(mix(finalCol.rgb, vec3(0.0, 0.0, 0.0), //fuck you fuck you fuck you
                (uv.y - yOff / openfl_TextureSize.y) * 4.0 + 0.15), flixel_texture2D(bitmap, uv).a); // fuck this gradient
        }
    ')
	public function new(blur:Float, gradMax:Float, tiltDeg:Float)
	{
		super();
		this.blur.value = [blur];
		this.gradMax.value = [gradMax];
		this.tiltDeg.value = [tiltDeg];
	}

	public function setXandY(x:Float, y:Float)
	{
		xOff.value = [x];
		yOff.value = [y];
	}
}
