package;

import flixel.system.FlxAssets.FlxShader;

class CRTShader extends FlxShader // Shout out to battery box for helping me port this -lunar
{
	@:glFragmentSource('
    #pragma header

    // https://www.shadertoy.com/view/4scSR8

	//
	// PUBLIC DOMAIN CRT STYLED SCAN-LINE SHADER
	//
	//	 by Timothy Lottes
	//
	// This is more along the style of a really good CGA arcade monitor.
	// With RGB inputs instead of NTSC.
	// The shadow mask example has the mask rotated 90 degrees for less chromatic aberration.
	//
	// Left it unoptimized to show the theory behind the algorithm.
	//
	// It is an example what I personally would want as a display option for pixel art games.
	// Please take and use, change, or whatever.
	//

	// Emulated input resolution.

    // Fix resolution to set amount.
    // Note: 256x224 is the most common resolution of the SNES, and that of Super Mario World.
    uniform vec2 res;

	// Hardness of scanline.
	//	-8.0 = soft
	// -16.0 = medium
	uniform float sHardScan;

	// Hardness of pixels in scanline.
	// -2.0 = soft
	// -4.0 = hard
	uniform float kHardPix;

	// Display warp.
	// 0.0 = none
	// 1.0 / 8.0 = extreme
	uniform vec2 kWarp;

	// Amount of shadow mask.
	uniform float kMaskDark;
	uniform float kMaskLight;

	//------------------------------------------------------------------------

	// sRGB to Linear.
	// Assuing using sRGB typed textures this should not be needed.
	float toLinear1(float c) {
		return (c <= 0.04045) ?
			(c / 12.92) :
			pow((c + 0.055) / 1.055, 2.4);
	}
	vec3 toLinear(vec3 c) {
		return vec3(toLinear1(c.r), toLinear1(c.g), toLinear1(c.b));
	}

	// Linear to sRGB.
	// Assuing using sRGB typed textures this should not be needed.
	float toSrgb1(float c) {
		return(c < 0.0031308 ?
			(c * 12.92) :
			(1.055 * pow(c, 0.41666) - 0.055));
	}
	vec3 toSrgb(vec3 c) {
		return vec3(toSrgb1(c.r), toSrgb1(c.g), toSrgb1(c.b));
	}

	// Nearest emulated sample given floating point position and texel offset.
	// Also zeros off screen.
	vec4 fetch(vec2 pos, vec2 off)
	{
		pos = floor(pos * res + off) / res;
		if (max(abs(pos.x - 0.5), abs(pos.y - 0.5)) > 0.5)
			return vec4(vec3(0.0), 0.0);
	  	
		vec4 sampledColor = vec4(flixel_texture2D(bitmap, pos.xy));
		
		sampledColor = vec4(
			(sampledColor.rgb * sampledColor.a) +
				( (1.0 - sampledColor.a)),
			1.0
		);
		
		return vec4(
			toLinear(sampledColor.rgb),
			sampledColor.a
		);
	}

	// Distance in emulated pixels to nearest texel.
	vec2 dist(vec2 pos) {
		pos = pos * res;
		return -((pos - floor(pos)) - vec2(0.5));
	}

	// 1D Gaussian.
	float gaus(float pos, float scale) {
		return exp2(scale * pos * pos);
	}

	// 3-tap Gaussian filter along horz line.
	vec3 horz3(vec2 pos, float off)
	{
		vec3 b = fetch(pos, vec2(-1.0, off)).rgb;
		vec3 c = fetch(pos, vec2( 0.0, off)).rgb;
		vec3 d = fetch(pos, vec2(+1.0, off)).rgb;
		float dst = dist(pos).x;
		// Convert distance to weight.
		float scale = kHardPix;
		float wb = gaus(dst - 1.0, scale);
		float wc = gaus(dst + 0.0, scale);
		float wd = gaus(dst + 1.0, scale);
		// Return filtered sample.
		return (b * wb + c * wc + d * wd) / (wb + wc + wd);
	}

	// 5-tap Gaussian filter along horz line.
	vec3 horz5(vec2 pos, float off)
	{
		vec3 a = fetch(pos, vec2(-2.0, off)).rgb;
		vec3 b = fetch(pos, vec2(-1.0, off)).rgb;
		vec3 c = fetch(pos, vec2( 0.0, off)).rgb;
		vec3 d = fetch(pos, vec2(+1.0, off)).rgb;
		vec3 e = fetch(pos, vec2(+2.0, off)).rgb;
		float dst = dist(pos).x;
		// Convert distance to weight.
		float scale = kHardPix;
		float wa = gaus(dst - 2.0, scale);
		float wb = gaus(dst - 1.0, scale);
		float wc = gaus(dst + 0.0, scale);
		float wd = gaus(dst + 1.0, scale);
		float we = gaus(dst + 2.0, scale);
		// Return filtered sample.
		return (a * wa + b * wb + c * wc + d * wd + e * we) / (wa + wb + wc + wd + we);
	}

	// Return scanline weight.
	float scan(vec2 pos, float off) {
		float dst = dist(pos).y;
		return gaus(dst + off, sHardScan);
	}

	// Allow nearest three lines to effect pixel.
	vec3 tri(vec2 pos)
	{
		vec3 a = horz3(pos, -1.0);
		vec3 b = horz5(pos,  0.0);
		vec3 c = horz3(pos, +1.0);
		float wa = scan(pos, -1.0);
		float wb = scan(pos,  0.0);
		float wc = scan(pos, +1.0);
		return a * wa + b * wb + c * wc;}

	// Distortion of scanlines, and end of screen alpha.
	vec2 warp(vec2 pos)
	{
		pos = pos * 2.0 - 1.0;
		pos *= vec2(
			1.0 + (pos.y * pos.y) * kWarp.x,
			1.0 + (pos.x * pos.x) * kWarp.y
		);
		return pos * 0.5 + 0.5;
	}

	// Shadow mask.
	vec3 mask(vec2 pos)
	{
		pos.x += pos.y * 3.0;
		vec3 mask = vec3(kMaskDark, kMaskDark, kMaskDark);
		pos.x = fract(pos.x / 6.0);
		if (pos.x < 0.333)
			mask.r = kMaskLight;
		else if (pos.x < 0.666)
			mask.g = kMaskLight;
		else
			mask.b = kMaskLight;
		return mask;
	}

	// Draw dividing bars.
	float bar(float pos, float bar) {
		pos -= bar;
		return (pos * pos < 4.0) ? 0.0 : 1.0;
	}

	float rand(vec2 co) {
		return fract(sin(dot(co.xy , vec2(12.9898, 78.233))) * 43758.5453);
	}

	// Entry.
	void main()
	{
		vec2 pos = openfl_TextureCoordv.xy;
		vec4 unmodifiedColor = fetch(pos, vec2(0,0));
		
		gl_FragColor.rgb = tri(pos) * mask(openfl_TextureCoordv.xy * openfl_TextureSize.xy);
		gl_FragColor = vec4(toSrgb(gl_FragColor.rgb), 1.0);
	}
    ')
	public function new()
	{
		super();

		res.value = [256.0 / 0.5, 224.0 / 0.5];
		sHardScan.value = [-8.0];
		kHardPix.value = [-2.0];
		kWarp.value = [0.0 / 32.0, 100 / 24.0]; // THE WARP ON THE EDGES OF SCREEN
		kMaskDark.value = [0.5];
		kMaskLight.value = [1.5];
	}
}
