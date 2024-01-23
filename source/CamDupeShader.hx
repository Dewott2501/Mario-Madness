package;

import flixel.system.FlxAssets.FlxShader;

class CamDupeShader extends FlxShader
{
    // ty nebula for the little bit of help with the mirroring
    @:isVar
    public var mult(get, set):Float = 0;
    @:isVar 
    public var mirror(get, set):Bool = false;

    function get_mult()
    {
        return multi.value[0];
    }
    function set_mult(value:Float)
    {
        multi.value = [value, value];
        return value;
    }
    function get_mirror()
    {
        return mirrorS.value[0];
    }
    function set_mirror(value:Bool)
    {
        mirrorS.value = [value];
        return value;
    }

    @:glFragmentSource('
    #pragma header

uniform float multi;
uniform bool mirrorS;

void main()
{
        vec2 uv = openfl_TextureCoordv*openfl_TextureSize/openfl_TextureSize.xy;
            uv.x *= multi;
            uv.y *= multi;
        uv = fract(uv);
        if(mirrorS)
            uv.x = (0.0-uv.x)+1.0;
        vec3 duplicate = vec3(mod(floor(uv.x) + floor(uv.y),1.0));
        vec3 color1 = vec3(flixel_texture2D(bitmap,uv));
        vec3 color;
        color = color1 * (1.0 - duplicate);

        gl_FragColor = vec4(color,flixel_texture2D(bitmap, uv).a);
}
    ')

    public function new()
        {
            super();
            mult = 1;
        }
}