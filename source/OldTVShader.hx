package;

import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxShader;
import haxe.Timer;

class OldTVShader extends FlxShader
{
	@:glFragmentSource('
        #pragma header
        #define id vec2(0.,1.)
        #define k 1103515245U
        #define PI 3.141592653
        #define TAU PI * 2.

        uniform float iTime;

        //prng func, from https://stackoverflow.com/a/52207531
        vec3 hash(uvec3 x) {
            x = ((x>>8U)^x.yzx)*k;
            x = ((x>>8U)^x.yzx)*k;
            x = ((x>>8U)^x.yzx)*k;         
            return vec3(x)*(1.0/float(0xffffffffU));
        }

        void main() {
            bool flag = false;
            bool flag2 = false;

            vec2 uv = openfl_TextureCoordv;
            
            //picture offset
            float time = 2.0;
            float timeMod = 2.5;
            float repeatTime = 1.25;
            float lineSize = 50.0;
            float offsetMul = 0.01;
            float updateRate2 = 50.0;
            float uvyMul = 100.0;
            
            float realSize = lineSize / openfl_TextureSize.y / 2.0;
            float position = mod(iTime, timeMod) / time;
            float position2 = 99.;
            if (iTime > repeatTime) {
                position2 = mod(iTime - repeatTime, timeMod) / time;
            }
            if (!(uv.y - position > realSize || uv.y - position < -realSize)) {
                uv.x -= hash(uvec3(0., uv.y * uvyMul, iTime * updateRate2)).x * offsetMul;
                flag = true;
            } else if (position2 != 99.) {
                if (!(uv.y - position2 > realSize || uv.y - position2 < -realSize)) {
                    uv.x -= hash(uvec3(0., uv.y * uvyMul, iTime * updateRate2)).x * offsetMul;
                    flag = true;
                }
            }
            
            vec4 col = flixel_texture2D(bitmap, uv);
            
            //blur, from https://www.shadertoy.com/view/Xltfzj
            float directions = 16.0;
            float quality = 3.0;
            float size = 4.0;

            vec2 radius = size / openfl_TextureSize;
            for(float d = 0.0; d < TAU; d += TAU / directions) {
                for(float i= 1.0 / quality; i <= 1.0; i += 1.0 / quality) {
                    col += flixel_texture2D(bitmap, uv + vec2(cos(d), sin(d)) * radius * i);	
                }
            }
            col /= quality * directions - 14.0;
            
            //for the black on the left
            if (uv.x < 0.) {
                col = id.xxxy;
                flag = false;
                flag2 = true;
            }
            
            //randomized black shit and sploches
            float updateRate4 = 100.0;
            float uvyMul3 = 100.0;
            float cutoff2 = 0.92;
            float valMul2 = 0.007;
            
            float val2 = hash(uvec3(uv.y * uvyMul3, 0., iTime * updateRate4)).x;
            if (val2 > cutoff2) {
                float adjVal2 = (val2 - cutoff2) * valMul2 * (1. / (1. - cutoff2));
                if (uv.x < adjVal2) {
                    col = id.xxxy;
                    flag2 = true;
                } else {
                    flag = true;
                }
            }

            //static
            if (!flag2) {
                float updateRate = 100.0;
                float mixPercent = 0.05; 
                col = mix(col, vec4(hash(uvec3(uv * openfl_TextureSize, iTime * updateRate)).rrr, 1.), mixPercent);
            }
            
            //white sploches
            float updateRate3 = 75.0;
            float uvyMul2 = 400.0;
            float uvxMul = 20.0;
            float cutoff = 0.95;
            float valMul = 0.7;
            float falloffMul = 0.7;
            
            if (flag) {
                float val = hash(uvec3(uv.x * uvxMul, uv.y * uvyMul2, iTime * updateRate3)).x;
                if (val > cutoff) {
                    float offset = hash(uvec3(uv.y * uvyMul2, uv.x * uvxMul, iTime * updateRate3)).x;
                    float adjVal = (val - cutoff) * valMul * (1. / (1. - cutoff));
                    adjVal -= abs((uv.x * uvxMul - (floor(uv.x * uvxMul) + offset)) * falloffMul);
                    adjVal = clamp(adjVal, 0., 1.);
                    col = vec4(mix(col.rgb, id.yyy, adjVal), col.a);
                }
            }
            
            gl_FragColor = col;
        }
    ')
	public function new()
	{
		super();
		iTime.value = [Timer.stamp()];
	}

	public function update(elapsed:Float)
	{
		iTime.value[0] += elapsed;
	}
}
