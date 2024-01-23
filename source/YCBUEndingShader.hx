package;

import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxShader;
import haxe.Timer;

class YCBUEndingShader extends FlxShader
{
	@:glFragmentSource('
        #pragma header
        #define LINES1 16.0
        #define LINES2 32.0
        #define LINES3 6.0
        #define MAX_LINES 20.0

        const uint k = 1103515245U;

        uniform float seed;

        uniform float intensity;

        //prng func, from https://stackoverflow.com/a/52207531
        vec3 hash(uvec3 x) {
            x = ((x>>8U)^x.yzx)*k;
            x = ((x>>8U)^x.yzx)*k;
            x = ((x>>8U)^x.yzx)*k;
            
            return vec3(x)*(1.0/float(0xffffffffU));
        }

        float offset(vec2 co) {
            if (intensity < 0.6) {
                return 0.0;
            }
            return sin(co.y * (intensity - 0.6) * (intensity - 0.6));
        }

        float random(in vec2 st) {
            return fract(sin(dot(st.xy,
            vec2(12.9898,78.233)))*
            43758.5453123);
        }

        float glitch(vec2 uv, float lines, float r) {
            float y = floor(uv.y*lines)/lines;
               return random(vec2(r, y))*(0.5+(intensity * MAX_LINES)*0.01);
        }

        void main()
        {
            vec2 uv = openfl_TextureCoordv;
            vec2 fragCoord = openfl_TextureSize * uv;
            uv = vec2(uv.x + offset(vec2(fragCoord.x, sin(mod(fragCoord.y, 200.0) / 15.84))), uv.y);
            float gl1 = glitch(uv, LINES1, floor(seed*2.0));
            float gl2 = glitch(uv, LINES2, floor(seed*5.0));
            float gl3 = glitch(uv, LINES3, floor(seed));
            float d1 = round(gl1) * (gl1);
            float d2 = round(gl2) * (gl2);
            float d3 = round(gl3) * (0.75 - gl3);
            
            uv.x += d1;
            uv.x -= d2;
            uv.x += d3;
            
            float r = flixel_texture2D(bitmap, uv+(d1-d2+d3)/6.0).r;
            float g = flixel_texture2D(bitmap, uv).g;
            float b = flixel_texture2D(bitmap, uv-(d1-d2+d3)/6.0).b;
            gl_FragColor = vec4(r, g, b, 1);
            if (intensity > 0.5) {
                gl_FragColor = mix(gl_FragColor, vec4(hash(uvec3(fragCoord.xy, seed * 100.0)), 1), (intensity - 0.5) / 0.5);
                float finalCol = gl_FragColor.r*0.59 + gl_FragColor.g*0.3 + gl_FragColor.b*0.11;
                gl_FragColor = mix(gl_FragColor, vec4(finalCol, finalCol, finalCol, 1), (intensity - 0.5) / 0.5);
            }
        }
    ')
	public function new()
	{
		super();
		seed.value = [Timer.stamp()];
		intensity.value = [0.0];
	}

	public function update(amount:Float, elapsed:Float)
	{
		seed.value[0] += elapsed;
		intensity.value[0] = FlxMath.bound(intensity.value[0] + amount, 0, 1);
	}
}
