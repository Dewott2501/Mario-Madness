package;

import flixel.system.FlxAssets.FlxShader;

class AngelShader extends FlxShader
{

	@:isVar
	public var strength(get, set):Float = 0;

	function get_strength()
	{
		return (stronk.value[0]);
	}
	function set_strength(v:Float)
	{
		stronk.value = [v, v];
		return v;
	}

	@:isVar
	public var pixelSize(get, set):Float = 1;

	function get_pixelSize()
	{
		return (pixel.value[0] + pixel.value[1])/2;
	}
	function set_pixelSize(v:Float)
	{
		pixel.value = [v, v];
		return v;
	}


	@:glFragmentSource('
    #pragma header

	uniform float stronk;
	uniform float iTime;
	uniform vec2 pixel;

	const bool allowWiggle = true;


	vec2 uvp(vec2 uv) {
		return clamp(uv, 0.0, 1.0);
	}

	float outCirc(float t) {
    	return sqrt(-t * t + 2.0 * t);
	}

	float rand(vec2 co) {
		return fract(sin(dot(co.xy,vec2(12.9898,78.233))) * 43758.5453);
	}

	void main() {
		vec3 col;
		float amp;
		
		amp = stronk;

		for (int i = 0; i < 3; i++) {

			vec2 size = openfl_TextureSize.xy / pixel;
			vec2 uv = floor(openfl_TextureCoordv.xy * size) / size;
			
			if (allowWiggle) {
				//uv += vec2(sin(iTime + float(i) + amp), cos(iTime + float(i) + (amp*0.5))) * (amp*0.5) * 0.2;
				uv += vec2(sin(float(i) * amp), cos(float(i) * amp)) * amp * 0.05;
			}

			vec3 texOrig = texture2D(bitmap, uvp(uv)).rgb;
			
			uv.x += (rand(vec2(uv.y + float(i), iTime)) * 2.0 - 1.0) * amp * 0.8 * (texOrig[i] + 0.2);
			uv.y += (rand(vec2(uv.x, iTime + float(i))) * 2.0 - 1.0) * amp * 0.1 * (texOrig[i] + 0.2);
			
			vec3 tex = texture2D(bitmap, uvp(uv)).rgb;

			tex += abs(tex[i] - texOrig[i]);
			
			tex *= rand(uv) * amp + 1.0;

			if (i != 0) {
				//tex = fract(tex);
			}

			
			
			
			col[i] = tex[i];
		}


    
		gl_FragColor = vec4(col,flixel_texture2D(bitmap,openfl_TextureCoordv).a);
	}

	
	
	')


	public function new()
	{
		super();
        this.iTime.value = [0.0];
		strength = 0;
		pixelSize = 1;

	}

    public function update(elapsed:Float) {
        this.iTime.value[0] += elapsed;
    }
}