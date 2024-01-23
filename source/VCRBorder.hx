package;

import flixel.system.FlxAssets.FlxShader;

class VCRBorder extends FlxShader
{ // https://www.shadertoy.com/view/Ms23DR and https://www.shadertoy.com/view/MsXGD4
	@glFragmentSource('
        #pragma header

        vec2 curve(vec2 uv) {
            uv = (uv - 0.5) * 2.0;
	        uv *= 1.1;	
	        uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
	        uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
	        uv  = (uv / 2.0) + 0.5;
	        uv =  uv *0.92 + 0.04;
	        return uv;
        }

        float vignette(vec2 uv) {
            uv = (uv - 0.5) * 0.98;
            return clamp(pow(cos(uv.x * 3.1415), 2.5) * pow(cos(uv.y * 3.1415), 2.5) * 100.0, 0.0, 1.0);
        }

        void main() {
            vec2 uv = openfl_TextureCoordv;
            uv = curve(uv);
            vec3 color = flixel_texture2D(bitmap, uv).rgb;
            float alpha = flixel_texture2D(bitmap, uv).a;
            if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
                color = vec3(0.0, 0.0, 0.0);
            }
            gl_FragColor = vec4(color * vignette(uv), alpha);
        }
    ')
	public function new()
	{
		super();
	}
}
