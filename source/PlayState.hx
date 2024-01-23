package;

import FunkinLua;
import LavaParticle;
import Section.SwagSection;
import Song.SwagSong;
import StageData;
import TitleScreenShaders.TVStatic;
import WiggleEffect.WiggleEffectType;
import editors.CharacterEditorState;
import editors.ChartingState;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxShakeEffect;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import haxe.Timer;
import hxcodec.VideoHandler;
import hxcodec.VideoSprite;
import lime.app.Application;
import lime.utils.Assets;
import modchart.*;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets as OpenFlAssets;
import sys.FileSystem;
import sys.io.File;

using StringTools;
using flixel.util.FlxSpriteUtil;


#if desktop
import Discord.DiscordClient;
#end

class PlayState extends MusicBeatState
{
	public var modManager:ModManager;

	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['F', 0.2], // From 0% to 19%
		['E', 0.4], // From 20% to 39%
		['D', 0.5], // From 40% to 49%
		['C', 0.6], // From 50% to 59%
		['B', 0.69], // From 60% to 68%
		['A', 0.7], // 69%
		['A+', 0.8], // From 70% to 79%
		['S', 0.9], // From 80% to 89%
		['S+', 1], // From 90% to 99%
		['SS+', 1] // The value on this one isn't used actually, since Perfect is always "1"
	];

	#if (haxe >= "4.0.0")
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	#else
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, Dynamic>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	#end

	// event variables
	private var isCameraOnForcedPos:Bool = false;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;
	public static var BF_CAM_X:Float = 770;
	public static var BF_CAM_Y:Float = 100;
	public static var DAD_CAM_X:Float = 100;
	public static var DAD_CAM_Y:Float = 100;
	public static var GF_CAM_X:Float = 400;
	public static var GF_CAM_Y:Float = 130;
	public static var BF_ZOOM:Float = 0.5;
	public static var DAD_ZOOM:Float = 0.5;
	public static var GF_ZOOM:Float = 0.5;
	public static var BF_CAM_EXTEND:Float = 15;
	public static var DAD_CAM_EXTEND:Float = 15;
	public static var GF_CAM_EXTEND:Float = 15;

	public static var GFSINGDAD:Bool = false;
	public static var GFSINGBF:Bool = false;
	public static var ZOOMCHARS:Bool = true;
	public static var FOLLOWCHARS:Bool = true;

	public var songSpeed(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;

	var tvEffect:Bool = false;
	var noCount:Bool = false;
	var noHUD:Bool = false;
	var flipchar:Bool = false;

	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var isWarp:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = ['Its a me', 'Starman Slaughter'];
	public static var storyDifficulty:Int = 1;

	public var vocals:FlxSound;
	public var instALT:FlxSound;
	var vocalvol:Float = 1;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	public static var maxLuaFPS = 60;
	var fpsElapsed:Array<Float> = [0,0,0];
	var numCalls:Array<Float> = [0,0,0];

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<Dynamic> = [];

	private var strumLine:FlxSprite;

	// Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private var carro:FlxTween;

	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;
	private static var resetSpriteCache:Bool = false;

	public var camTweenY:Float;

	// public var camTweenX:Float;
	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public static var camDisplaceX:Float = 0;
	public static var camDisplaceY:Float = 0;

	public var camZooming:Bool = false;

	private var curSong:String = "";
	var isDodging:Bool = false;
	var canDodge:Bool = false;
	var quitarvida:Bool = false;
	var jodaflota:Bool = false;
	var goodlol:Bool = false;
	var coins:Int = 0;
	var canFade:Bool = false;

	var totalBeat:Int = 0;
	var totalShake:Int = 0;
	var timeBeat:Float = 1;
	var gameZ:Float = 0.015;
	var hudZ:Float  = 0.03;
	var gameShake:Float = 0.003;
	var hudShake:Float  = 0.003;
	var shakeTime:Bool = false;

	var startwindow:Bool = false;
	var startresize:Bool = false; // USING RESIZE ALL THE TIME WOULD BE DANGEROUS

	// ORIGINAL WINDOW SIZE AND POSITION
	var ogwinsizeX:Int;
	var ogwinsizeY:Int;

	public static var ogwinX:Int;
	public static var ogwinY:Int;

	// WINDOW MOVE VAR
	var winx:Int;
	var winy:Int;

	// i dont remember why im using this but ok
	var changex:Int;
	var changey:Int;

	// WINDOW SIZE CHANGE VAR
	var resizex:Int = 1280;
	var resizey:Int = 720;

	// MONITOR RESOLUTION
	var fsX:Int = 1920;
	var fsY:Int = 1080;

	var cantfade:Bool = false;
	var cantchange:Bool = false;

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var healthFake:Float = 1;
	public var healthDrain:Float = 0;
	var timerDrain:Float = 0;
	public var combo:Int = 0;

	private var floatshit:Float = 0;

	private var healthBarBG:AttachedSprite;
	private var customHB:AttachedSprite;
	private var customHBweegee:AttachedSprite;

	public var healthBar:FlxBar;

	var songPercent:Float = 0;
	var minustime:Float;

	private var timeBarBG:AttachedSprite;

	public var timeBar:FlxBar;

	public var drenando:Bool = false;

	private var generatedMusic:Bool = false;

	public var endingSong:Bool = false;

	public var specialGameOver:Bool = false;

	private var startingSong:Bool = false;
	private var updateTime:Bool = false;

	public static var practiceMode:Bool = false;
	public static var usedPractice:Bool = false;
	public static var changedDifficulty:Bool = false;
	public static var cpuControlled:Bool = false;

	var botplaySine:Float = 0;
	var luigiLogo:FlxSprite;
	var titleText:FlxText;
	var autorText:FlxText;
	var line1:FlxSprite;
	var line2:FlxSprite;

	var cutVid:VideoSprite;

	var midsongVid:VideoSprite;

	public static var autor:String = '';

	var legacycheck:String = '';
	var newName:String = '';

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camEst:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;
	var iconGF:FlxSprite;

	var promoBG:BGSprite;
	var promoBGSad:BGSprite;
	var promoDesk:BGSprite;
	var bgLuigi:BGSprite;
	var bgPeach:BGSprite;
	var darkFloor:BGSprite;
	var stanlines:BGSprite;
	var tvTransition:BGSprite;
	var stantext:Float = 1;
	var cameraTilt:Int = 0;

	// execlassic shit
	var fireL:BGSprite;
	var fireR:BGSprite;
	var fireOverlay:BGSprite;

	// forest bg
	var casa:Int = 300;
	var faropapu:FlxSprite;
	var lospapus:FlxSprite;
	var atrasarboleda:FlxSprite;
	var aas:FlxSprite;
	var sopapo:FlxSprite;
	var casa0:FlxSprite;
	var casa1:FlxSprite;
	var casa2:BGSprite;
	var s3:FlxSprite;
	var s2:FlxSprite;
	var fresco:BGSprite;
	var	trueno:BGSprite;
	var	seaweed1:BGSprite;
	var	seaweed2:BGSprite;
	var	seaweed3:BGSprite;
	var	glitch0:BGSprite;
	var	glitch1:BGSprite;
	var	glitch2:BGSprite;
	var	glitch3:BGSprite;
	var cososuelo:BGSprite;
	var leaf0:BGSprite;
	var leaf1:BGSprite;
	var leaf2:BGSprite;
	var bola0:BGSprite;
	var bola1:BGSprite;

	// demise bg
	var floordemise:BGSprite;
	var dembg:FlxBackdrop;
	var demLevel:FlxBackdrop;
	var demGround:FlxBackdrop;
	var demFore1:BGSprite;
	var demFore2:BGSprite;
	var demFore3:BGSprite;
	var demFore4:BGSprite;
	var demcut1:BGSprite;
	var demcut2:BGSprite;
	var demcut3:BGSprite;
	var demcut4:BGSprite;
	var gordobondiola:BGSprite;

	var underfloordemise:BGSprite;
	var underroofdemise:BGSprite;
	var underdemGround1:FlxBackdrop;
	var underdemGround2:FlxBackdrop;
	var underborderdemise:BGSprite;
	var underdembg:FlxBackdrop;
	var underdemLevel:FlxBackdrop;
	var underdemFore1:BGSprite;
	var underdemFore2:BGSprite;
	var demisetran:BGSprite;
	var whenyourered:FlxSprite;
	var demColor:FlxSprite;
	var demFlash:Bool = false;

	var whiteThingie:FlxSprite;
	var fogred:FlxSprite;

	public var changenose:Int = 0;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var ghostMisses:Int = 0;
	public var scoreTxt:FlxText;
	public var ratingTxt:FlxText;
	public var subTitle:FlxText;
	public var stream:Int = 0;
	public var ifuckingdelete:Int = 0;

	public static var virtualmode:Bool = false; // im only using this for the fps var

	var timeTxt:FlxText;
	var worldText:FlxText;
	var scoreTxtTween:FlxTween;
	var ihyLava:FlxSprite;
	var lavaTween:FlxTween;
	var startbf:FlxSprite;
	var mxLaugh:FlxSprite;
	var imgwarb:FlxSprite;
	var imgwar:FlxSprite;
	var estaland:FlxSprite;
	var tvMarco:FlxSprite;
	var estatica:FlxSprite;
	var liveScreen:FlxSprite;
	var blackBarThingie:FlxSprite;
	var bbar1:FlxSprite;
	var bbar2:FlxSprite;
	var screencolor:FlxSprite;

	var bgfeo:BGSprite;
	var aguaExe:BGSprite;
	var sueloExe:BGSprite;
	var landbg:FlxTypedGroup<BGSprite>;
	var bricksland:BGSprite;
	var brickslandEXE:BGSprite;

	var gfwasTaken:BGSprite;

	var eyelessboo:BGSprite;
	var eyelessboo2:BGSprite;
	var eyelessboo3:BGSprite;
	var bgsign:BGSprite;
	var degrad:BGSprite;
	var blueMario:BGSprite;
	var blueMario2:BGSprite;
	var capenose:BGSprite;
	var blackOGNThingie:FlxSprite;
	var susto:FlxSprite;
	var shaderOGN:Float = 0;
	var fire1:BGSprite;
	var fire2:BGSprite;
	var fire3:BGSprite;
	var fire4:BGSprite;
	var introbg:BGSprite;
	var introM:BGSprite;
	var introL:BGSprite;
	var introLText:BGSprite;
	var luigiCut:BGSprite;

	var wahooText:BGSprite;
	var shadowbg:BGSprite;
	var gfFall:BGSprite;
	var killMX:BGSprite;
	var lightmx:BGSprite;
	var creepyCloud:BGSprite;
	var creppyleaf:BGSprite;
	var turnevil:BGSprite;
	var mxLaughNEW:BGSprite;
	var enemyX:Float = 0;
	var enemyY:Float = 0;

	public static var getspeed:Float = 0;

	var epicbgthings:FlxTypedGroup<BGSprite>;

	var bfext:BGSprite;
	var bftors:BGSprite;
	var bfextmiss:BGSprite;
	var bftorsmiss:BGSprite;
	var bgwario:BGSprite;
	var bfFall:BGSprite;
	var warioDead:Bool = false;
	var fogbad:FlxSprite;

	var blackHUD2:FlxSprite;
	var caja:FlxSprite;
	var redS:FlxSprite;

	var bfcolgao:FlxSprite;
	var lluvia:BGSprite;
	var gota:BGSprite;

	var xboxigualGOD:BGSprite;

	var bgstars:BGSprite;
	var building:BGSprite;
	var platformlol:BGSprite;
	var titleNES:FlxSprite;
	var ringcount:FlxText;
	var ring:Int = 0;
	var extrazero:String;
	var nodamage:Bool = false;
	var pixelLights:BGSprite;
	
	var bg:BGSprite;
	var floor:BGSprite;
	var mesa:BGSprite;
	var letsago:BGSprite;

	var elfin:BGSprite;
	var nametag:BGSprite;
	var bgred:BGSprite;
	var bordervid:BGSprite;
	var miyamoto:BGSprite;
	var camBG:BGSprite;
	var livechat:FlxText;

	var starmanPOW:BGSprite;
	var starmanGF:BGSprite;
	var peachCuts:BGSprite;
	var platform2:BGSprite;

	public static var ytUI:BGSprite;
	public static var ytbutton:BGSprite;
	
	var chatcolor1:FlxTextFormat = new FlxTextFormat(FlxColor.RED, false, false, 0xFF000000);
	var chatcolor2:FlxTextFormat = new FlxTextFormat(0xFF4888F0, false, false, 0xFF000000);
	var chatcolor3:FlxTextFormat = new FlxTextFormat(0xFF76E657, false, false, 0xFF000000);
	var chatcolor4:FlxTextFormat = new FlxTextFormat(0xFFE4F55F, false, false, 0xFF000000);
	var chatcolor5:FlxTextFormat = new FlxTextFormat(0xFFF04891, false, false, 0xFF000000);

	var byecirc:FlxSprite;
	var badHUDMario:BGSprite;
	var badGrad1:FlxSprite;
	var badGrad2:FlxSprite;
	var badPoisonVG:FlxSprite;
	var badRipple:RippleShader;

	var startbutton:BGSprite;
	var flintbg:BGSprite;
	var flintwater:BGSprite;
	var thegang:BGSprite;
	var hamster:BGSprite;
	var blockzoom:Bool;
	var noteAR:Array<Float> = [];
	public static var gdRunners:FlxTypedGroup<GrandDadRunners>;

	var lightWall:BGSprite;
	var gflol:BGSprite;
	var gfwalk:BGSprite;
	var gfspeak:BGSprite;
	var bfwalk:BGSprite;
	var mrwalk:BGSprite;
	var lgwalk:BGSprite;

	var yourhead:BGSprite;
	var virtuabg:FlxSprite;
	var effect:SMWPixelBlurShader;

	var clashmario:FlxTypedGroup<BGSprite>;
	var vwall:BGSprite;
	var crazyFloor:BGSprite;
	var turtle:BGSprite;
	var turtle2:BGSprite;

	var duckbg:FlxSprite;
	var ducktree:BGSprite;
	var duckleafs:BGSprite;
	var duckfloor:BGSprite;
	var ducksign:BGSprite;
	var bowbg:BGSprite;
	var bowbg2:BGSprite;
	var bowlava:BGSprite;
	var bowplat:BGSprite;
	var bowsign:BGSprite;
	var cutbg:BGSprite;
	var cutskyline:BGSprite;
	var cutstatic:BGSprite;
	var beatText:FlxText;
	var otherBeatText:FlxText;
	var ycbuLightningL:BGSprite;
	var ycbuLightningR:BGSprite;
	var ycbuHeadL:FlxBackdrop;
	var ycbuHeadR:FlxBackdrop;
	var ycbuCrosshair:FlxSprite;
	var ycbuGyromite:BGSprite;
	var ycbuLakitu:BGSprite;
	var fellakoopa:BGSprite;
	var felladuck:BGSprite;
	var fireBar:BGSprite;
	var clownCar:BGSprite;
	var val:Float = 0;
	var endingnes:Bool = false;
	var nomiss:Bool = false;
	var blackinfrontobowser:FlxSprite;
	var ycbuWhite:FlxSprite;

	var ycbuIconPos1 = new FlxPoint(0, 0);
	var ycbuIconPos2 = new FlxPoint(-85, 50);
	var ycbuIconPos3 = new FlxPoint(-85, -50);

	var funnylayer0:BGSprite;
	var linefount:BGSprite;
	var foreground1:BGSprite;
	var foreground2:BGSprite;
	var aguaEstrella:BGSprite;
	var lifemetter:BGSprite;
	var eel:BGSprite;
	var luigilife:Int = 8;
	var candrain:Bool = true;

	var marioattack:BGSprite;
	var powervitte:FlxSprite;
	var powerWarning:FlxSprite;

	var frontTrees:BGSprite;
	var explosionBOM:BGSprite;
	var secretWarning:BGSprite;
	var warning:BGSprite;
	var buttonxml:BGSprite;
	var bulletTimer:Float = -1;
	var bulletCounter:Int = 0;
	var bulletSub:Note;

	var castle0:BGSprite;
	var powerTrail:FlxTrail;

	var meatworldGroup:FlxTypedGroup<BGSprite>;
	var meatForeGroup:FlxTypedGroup<BGSprite>;
	var meatfog:BGSprite;
	var streetGroup:FlxTypedGroup<BGSprite>;
	var streetFore:BGSprite;
	var castleFloor:BGSprite;
	var castleCeiling:BGSprite;
	var gunShotPico:BGSprite;
	var gunAmmo:BGSprite;
	var ammo:Int = 3;
	var hallTLL1:FlxBackdrop;
	var hallTLL2:FlxBackdrop;
	var hallTLL3:FlxBackdrop;
	var fgTLL:FlxBackdrop;
	var poison:Float = 0;
	var overFuckYou:Bool = false;

	var warningPopup:BGSprite;
	var redStat:BGSprite;
	var flood:BGSprite;
	var luigilaugh:BGSprite;
	var fondaso2:BGSprite;
	var atra2:BGSprite;
	var fondaso:BGSprite;
	var atra:BGSprite;
	var adel:BGSprite;
	var adel2:BGSprite;
	var thefog:BGSprite;
	var redTV:BGSprite;
	var redTVStat:BGSprite;
	var redTVImg:BGSprite;

	var flooding:Bool = false;


	var backing:FlxSprite;
	var lifebar:BGSprite;
	var bgH1:FlxBackdrop;
	var djStart:BGSprite;
	var djDone:BGSprite;
	var bfspot:BGSprite;
	var drawspot:BGSprite;
	var canvas:FlxSprite;
	var thetext:FlxText;
	var thetextC:FlxText;
	var writeText:FlxText;
	var dsTimer:Float = 0;
	public var lastPosition = new FlxPoint(9999, 9999);

	// all stars

	var act1Stat:BGSprite;
	var act1Sky:BGSprite;
	var act1Skyline:BGSprite;
	var act1Buildings:BGSprite;
	var act1Floor:BGSprite;
	var act1FG:BGSprite;
	var act1Gradient:BGSprite;
	var act1Fog:BGSprite;
	var act1Intro:BGSprite;

	var act1BGGroup:FlxTypedGroup<BGSprite>;
	
	var iconLG:FlxSprite;
	var iconW4:FlxSprite;
	var iconY0:FlxSprite;
	var iconA4:FlxSprite;
	var iconA42:FlxSprite;

	var act2Stat:BGSprite;
	var act2WhiteFlash:FlxSprite;
	var act2Sky:FlxBackdrop;
	var act2PipesFar:BGSprite;
	var act2Gradient:BGSprite;
	var act2PipesMiddle:BGSprite;
	var act2PipesClose:BGSprite;
	var act2LPipe:BGSprite;
	var act2WPipe:BGSprite;
	var act2YPipe:BGSprite;
	var act2BFPipe:BGSprite;
	var act2Fog:BGSprite;

	var act2IntroGF:BGSprite;
	var act2IntroEyes:BGSprite;

	var act2BGGroup:FlxTypedGroup<BGSprite>;

	var act3Stat:BGSprite;
	var act3Hills:BGSprite;
	var act3UltraArm:BGSprite;
	var act3UltraBody:BGSprite;
	var act3UltraHead1:BGSprite;
	var act3UltraHead2:BGSprite;
	var act3UltraPupils:BGSprite;
	var act3BFPipe:BGSprite;
	var act3Spotlight:BGSprite;
	var act3Fog:BGSprite;

	var act3BGGroup:FlxTypedGroup<BGSprite>;

	var act4Stat:BGSprite;
	var act4Ripple:BGSprite;

	var act4BGGroup:FlxTypedGroup<BGSprite>;

	var act4Floaters:FlxTypedGroup<BGSprite>;
	var act4SpawnNum:Int = 1;
	
	var act4Pipe1:BGSprite;
	var act4Pipe2:BGSprite;
	var act4Memory1:BGSprite;
	var act4Memory2:BGSprite;

	var act4BG2Group:FlxTypedGroup<BGSprite>;

	var act4Spotlight:BGSprite;
	var act4Lightning:BGSprite;
	var act4DeadBF:BGSprite;
	var act4GameOver:BGSprite;

	var act4Intro:BGSprite;

	var hasDownScroll:Bool = ClientPrefs.downScroll;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	public static var pixelPerfect:Bool = false;

	public var inCutscene:Bool = false;

	var songLength:Float = 0;
	var timebarthing:Float;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	var discName:String = "itsame";
	#end

	private var luaArray:Array<FunkinLua> = [];

	// Achievement shit
	var keysPressed:Array<Bool> = [false, false, false, false];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;

	public var introSoundsSuffix:String = '';

	public var vcr:VCRMario85;
	public var staticShader:TVStatic;

	public var lavaEmitter:FlxTypedEmitter<LavaParticle>;
	public var bubbleEmitter:FlxTypedEmitter<BubbleParticle>;

	public var nesTweens:Array<FlxTween> = [];
	public var nesTimers:Array<FlxTimer> = [];

	var alreadychange:Bool = false;
	var alreadychange2:Bool = true;
	var oldTV:Bool;
	public var oldFX:OldTVShader;
	public var contrastFX:BrightnessContrastShader;
	var beatend:YCBUEndingShader;
	var angel:AngelShader;

	var dupe:CamDupeShader;
	var dupeTimer:Int = 0;
	var dupeMax:Int = 4;
	var inc:Bool = true;

	var shit:Float = 0;

	var altAnims:String = '';
	var altdad:Bool = false;

	var luigidies:VideoSprite;

	public static var songIsModcharted:Bool = false;

	override public function create()
	{
		instance = this;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		winx = Lib.application.window.x;
		winy = Lib.application.window.y;
		changex = winx;
		changey = winy;

		practiceMode = false;
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camEst = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camEst.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camEst);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		//if(curStage == 'piracy' && !hasDownScroll) FlxCamera.defaultCameras = [camEst];
		CustomFadeTransition.nextCamera = camOther;
		// FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = '' + CoolUtil.difficultyStuff[storyDifficulty][0];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode";
		}
		else if(isWarp){
			detailsText = "Overworld";
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		PauseSubState.muymalo = 1;
		var songName:String = Paths.formatToSongPath(SONG.song);
		curStage = PlayState.SONG.stage;

		if (curStage == 'somari')
		{
			if (ClientPrefs.middleScroll)
			{
				ifuckingdelete = 1;
			}
		}

		if (curStage == 'piracy')
		{
			Lib.application.window.resizable = false;
			if(ogwinX == 0){
				ogwinX = Lib.application.window.x;
				ogwinY = Lib.application.window.y;
			}
			var win = Lib.application.window; // just to make this following line shorter
			win.move(win.x + Std.int((win.width - 512) / 2), win.y + Std.int((win.height - 768) / 2));
			win.resize(512, 768);
			Lib.current.x = 0;
			Lib.current.y = 0;
			Lib.current.scaleX = 2.665;
			Lib.current.scaleY = 2.665;

			var camarasTODAS:Array<FlxCamera> = [camHUD, camEst, camOther];

			for (camera in camarasTODAS)
			{
				camera.x = 0;
				FlxG.camera.x = 0;

				camera.y = -600;
				FlxG.camera.y = -600;
			}
		}

		if (curStage == 'somari')
		{
			Lib.application.window.fullscreen = false;
			Lib.application.window.resizable = false;

			if (Lib.application.window.maximized == false)
			{
				if (Lib.application.window.width == 1280 && Lib.application.window.height == 720)
				{
					Lib.application.window.move(winx + 240, winy + 60);
				}
			}
			else
			{
				Lib.application.window.maximized = false;
				Lib.application.window.move(560, 240);
			}
			Lib.application.window.resize(800, 600);

			stream = 1;
			Lib.application.window.resizable = false;

			Lib.current.x = 0;
			Lib.current.y = 0;
			Lib.current.scaleX = 1.8;
			Lib.current.scaleY = 1.8;
			var camarasTODAS:Array<FlxCamera> = [camGame, camHUD, camEst, camOther];

			for (camera in camarasTODAS)
			{
				camera.x = -300;
				FlxG.camera.x = -300;

				camera.y = -210;
				FlxG.camera.y = -210;
			}

			if (hasDownScroll)
			{
				camera.y = -260;
				FlxG.camera.y = -260;
			}
		}

		var stageData:StageFile = StageData.getStageFile(curStage);
		if (stageData == null)
		{ // Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				defaultExtend: 15,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100]
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		pixelPerfect = (curStage == 'somari' || curStage == 'piracy');
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];
		if (stageData.boyfriend.length > 2) {
			BF_CAM_X = stageData.boyfriend[2];
			BF_CAM_Y = stageData.boyfriend[3];
		}
		if (stageData.girlfriend.length > 2) {
			GF_CAM_X = stageData.girlfriend[2];
			GF_CAM_Y = stageData.girlfriend[3];
		}
		if (stageData.opponent.length > 2) {
			DAD_CAM_X = stageData.opponent[2];
			DAD_CAM_Y = stageData.opponent[3];
		}
		if (stageData.boyfriend.length > 4) {
			BF_ZOOM = stageData.boyfriend[4];
		}
		else
			BF_ZOOM = stageData.defaultZoom;
		if (stageData.opponent.length > 4) {
			DAD_ZOOM = stageData.opponent[4];
		}
		else
			DAD_ZOOM = stageData.defaultZoom;
		if (stageData.girlfriend.length > 4) {
			GF_ZOOM = stageData.girlfriend[4];
		}
		else
			GF_ZOOM = stageData.defaultZoom;
		if (stageData.boyfriend.length > 5) {
			BF_CAM_EXTEND = stageData.boyfriend[5];
		}
		else
			BF_CAM_EXTEND = stageData.defaultExtend;
		if (stageData.opponent.length > 5) {
			DAD_CAM_EXTEND = stageData.opponent[5];
		}
		else
			DAD_CAM_EXTEND = stageData.defaultExtend;
		if (stageData.girlfriend.length > 5) {
			GF_CAM_EXTEND = stageData.girlfriend[5];
		}
		else
			GF_CAM_EXTEND = stageData.defaultExtend;

		ZOOMCHARS = true;
		FOLLOWCHARS = true;

		camDisplaceX = 0;
		camDisplaceY = 0;

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);
		switch (curStage)
		{
			case 'stage': // Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);

				if (!ClientPrefs.lowQuality)
				{
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}

			case 'execlassic': // Mario.exe Classic
				GameOverSubstate.characterName = 'bfexe';
				GameOverSubstate.loopSoundName = 'gameOver';
				GameOverSubstate.endSoundName = 'gameOverEnd';

				if (PlayState.SONG.song != 'Its a me Old')
				{
					GameOverSubstate.characterName = 'bfexenewdeath';
					addCharacterToList('bfexenewdeath', 0);
					if (!ClientPrefs.lowQuality){
						effect = new SMWPixelBlurShader();
					}
					addCharacterToList('mariohorrorpissed', 1);
					var bg:BGSprite = new BGSprite('mario/EXE1/Castillo fondo de hasta atras', -1000, -850, 0.45, 0.45);
					bg.antialiasing = ClientPrefs.globalAntialiasing;
					add(bg);

					fireL = new BGSprite('mario/EXE1/starman/Starman_BG_Fire_Assets', -1400, -800 + 1300, 0.4, 0.4, ['fire anim effects'], true);
					fireL.antialiasing = ClientPrefs.globalAntialiasing;
					fireL.alpha = 0.00001;
					add(fireL);

					fireR = new BGSprite('mario/EXE1/starman/Starman_BG_Fire_Assets', 700, -800 + 1300, 0.4, 0.4, ['fire anim effects'], true);
					fireR.animation.addByIndices('delay', 'fire anim effects', [8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7], "", 24, true);
					fireR.antialiasing = ClientPrefs.globalAntialiasing;
					fireR.alpha = 0.00001;
					fireR.flipX = true;
					add(fireR);
					fireR.animation.play('delay');

					var castillo:BGSprite = new BGSprite('mario/EXE1/Suelo y brillo atmosferico', -1000, -850, 1, 1);
					castillo.antialiasing = ClientPrefs.globalAntialiasing;
					add(castillo);

					var suelo:BGSprite = new BGSprite('mario/EXE1/Arboles y sombra', -1000, -850, 1, 1);
					suelo.antialiasing = ClientPrefs.globalAntialiasing;
					add(suelo);

					fireOverlay = new BGSprite('mario/EXE1/smoke', 0, 0, 1, 1);
					fireOverlay.antialiasing = ClientPrefs.globalAntialiasing;
					fireOverlay.cameras = [camEst];
					fireOverlay.alpha = 0;
					fireOverlay.screenCenter();
					add(fireOverlay);

					var fogblack:BGSprite = new BGSprite('mario/EXE1/dark', -1000, -850, 1, 1);
					fogblack.antialiasing = ClientPrefs.globalAntialiasing;
					fogblack.cameras = [camEst];
					fogblack.alpha = 0.8;
					fogblack.screenCenter();
					add(fogblack);
					
					blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
					blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
					blackBarThingie.scrollFactor.set(0, 0);
					blackBarThingie.alpha = 0;
					blackBarThingie.cameras = [camEst];
					add(blackBarThingie);

					DAD_CAM_X = 470;
					DAD_CAM_Y = 350;
					DAD_ZOOM = 0.5;
					DAD_CAM_EXTEND = 20;
					BF_CAM_X = 1020;
					BF_CAM_Y = 500;
					BF_ZOOM = 0.5;	
					BF_CAM_EXTEND = 20;
				}
				else{
					DAD_CAM_X = 420;
					DAD_CAM_Y = 450;
					DAD_ZOOM = 0.9;
					DAD_CAM_EXTEND = 30;
					BF_CAM_X = 720;
					BF_CAM_Y = 450;
					BF_ZOOM = 0.9;	
					BF_CAM_EXTEND = 30;

				var bg:BGSprite = new BGSprite('mario/EXE1/old/Brick3', -100, -100, 0.45, 0.45);
				bg.setGraphicSize(Std.int(bg.width * 1.3));
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				add(bg);

				var castillo:BGSprite = new BGSprite('mario/EXE1/old/Brick4', -100, -100, 0.55, 0.55);
				castillo.antialiasing = ClientPrefs.globalAntialiasing;
				castillo.setGraphicSize(Std.int(castillo.width * 1.3));
				add(castillo);

				var suelo:BGSprite = new BGSprite('mario/EXE1/old/BricksBG1', -300, -100, 1, 1);
				suelo.antialiasing = ClientPrefs.globalAntialiasing;
				suelo.setGraphicSize(Std.int(suelo.width * 1.4));
				add(suelo);

				var plantas:BGSprite = new BGSprite('mario/EXE1/old/Brick5', -60, 190, 1, 1);
				plantas.setGraphicSize(Std.int(plantas.width * 1.3));
				plantas.antialiasing = ClientPrefs.globalAntialiasing;
				add(plantas);

				var bloques:BGSprite = new BGSprite('mario/EXE1/old/BricksBG2', -100, -100, 0.95, 0.95);
				bloques.setGraphicSize(Std.int(bloques.width * 1.3));
				bloques.antialiasing = ClientPrefs.globalAntialiasing;
				add(bloques);
				}

			case 'exesequel': // Mario.exe Classic
				//(gfGroup.alpha = 0.00001;

				GameOverSubstate.characterName = 'bfexenewdeath';

				addCharacterToList('mariohorror-melt', 1);
				addCharacterToList('bfexenewdeath', 0);
				addCharacterToList('peach-exe', 1);
				addCharacterToList('yoshi-exe', 2);

				var sky:BGSprite = new BGSprite('mario/EXE1/starman/SS_sky', -1100, -600, 0.1, 0.1);
				sky.antialiasing = ClientPrefs.globalAntialiasing;
				add(sky);

				var castillo:BGSprite = new BGSprite('mario/EXE1/starman/SS_castle', -1125, -600, 0.2, 0.2);
				castillo.antialiasing = ClientPrefs.globalAntialiasing;
				add(castillo);

				var fireL:BGSprite = new BGSprite('mario/EXE1/starman/Starman_BG_Fire_Assets', -1400, -850, 0.4, 0.4, ['fire anim effects'], true);
				fireL.antialiasing = ClientPrefs.globalAntialiasing;
				add(fireL);

				var fireR:BGSprite = new BGSprite('mario/EXE1/starman/Starman_BG_Fire_Assets', 700, -850, 0.4, 0.4, ['fire anim effects'], true);
				fireR.animation.addByIndices('delay', 'fire anim effects', [8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7], "", 24, true);
				fireR.antialiasing = ClientPrefs.globalAntialiasing;
				fireR.flipX = true;
				add(fireR);
				fireR.animation.play('delay');

				var platform0:BGSprite = new BGSprite('mario/EXE1/starman/SS_farplatforms', -950, -600, 0.55, 0.55);
				platform0.antialiasing = ClientPrefs.globalAntialiasing;
				add(platform0);

				starmanPOW = new BGSprite('mario/EXE1/starman/SS_POWblock', 835, 610, 0.55, 0.55);
				starmanPOW.antialiasing = ClientPrefs.globalAntialiasing;
				add(starmanPOW);

				var platform1:BGSprite = new BGSprite('mario/EXE1/starman/SS_midplatforms', -850, -600, 0.65, 0.65);
				platform1.antialiasing = ClientPrefs.globalAntialiasing;
				add(platform1);

				var floor:BGSprite = new BGSprite('mario/EXE1/starman/SS_floor', -750, -600, 1, 1);
				floor.antialiasing = ClientPrefs.globalAntialiasing;
				add(floor);

				starmanGF = new BGSprite('characters/SS_GF_scared_Assets', 1900, 425, 1, 1, ["GF Dancing Beat"], false);
				starmanGF.animation.addByIndices('danceRight', 'GF Dancing Beat', [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14], "", 24, false);
				starmanGF.animation.addByIndices('danceLeft', 'GF Dancing Beat', [15,16,17,18,19,20,21,22,23,24,25,28,29], "", 24, false);
				starmanGF.animation.addByPrefix('sad', "gf sad", 24, false);
				starmanGF.antialiasing = ClientPrefs.globalAntialiasing;
				add(starmanGF);

				peachCuts = new BGSprite('characters/Peach_EXE_Cuts_New', -160, -100, 1, 1, ["PeachFalling"], true);
				peachCuts.animation.addByPrefix('floats', "PeachFalling1", 24, true);
				peachCuts.animation.addByPrefix('fall', "PeachFalling2", 24, false);
				peachCuts.animation.addByPrefix('dies', "PeachDIES", 24, false);
				peachCuts.antialiasing = ClientPrefs.globalAntialiasing;
				peachCuts.alpha = 0.000001;
				add(peachCuts);

				//john dick icon
				iconGF = new FlxSprite().loadGraphic(Paths.image('icons/icon-LG'));
				iconGF.width = iconGF.width / 2;
				iconGF.loadGraphic(Paths.image('icons/icon-johndick'), true, Math.floor(iconGF.width), Math.floor(iconGF.height));
				iconGF.animation.add("win", [0], 10, true);
				iconGF.animation.add("lose", [1], 10, true);
				iconGF.cameras = [camHUD];
				iconGF.antialiasing = ClientPrefs.globalAntialiasing;

				blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
				blackBarThingie.scrollFactor.set(0, 0);
				blackBarThingie.visible = false;
				add(blackBarThingie);
				//var platform2:BGSprite = new BGSprite('mario/EXE1/starman/SS_foreground', -750, -600, 1, 1);
				//platform2.antialiasing = ClientPrefs.globalAntialiasing;
				//add(platform2);

			case 'landstage': // GB

				noCount = true;

				if (PlayState.SONG.song == 'Golden Land Old')
				{
					GameOverSubstate.loopSoundName = 'gameOver';
					GameOverSubstate.endSoundName = 'gameOverEnd';
					GameOverSubstate.characterName = 'bfgb';
					DAD_CAM_X = 420;
					DAD_CAM_Y = 450;
					BF_CAM_X = 720;
					BF_CAM_Y = 450;

					gfGroup.visible = false;
					// FONDO NORMAL
					var bgland:BGSprite = new BGSprite('mario/EXE2/old/Nubes', 400, 300, 0.5, 0.5); // nubes
					bgland.setGraphicSize(Std.int(bgland.width * 3));
					bgland.antialiasing = false;
					add(bgland);

					var agualand:BGSprite = new BGSprite('mario/EXE2/old/Nubes2', 400, 700, 0.7, 0.7); // agua
					agualand.setGraphicSize(Std.int(agualand.width * 3));
					agualand.antialiasing = false;
					add(agualand);

					var sueloland:BGSprite = new BGSprite('mario/EXE2/old/Nubes3', 400, 800, 1, 1); // suelo
					sueloland.setGraphicSize(Std.int(sueloland.width * 3));
					sueloland.antialiasing = false;
					add(sueloland);

					// FONDO DIABLO

					bgfeo = new BGSprite('mario/EXE2/old/Mario_Phase2_Background_Assets_Static', 200, 300, 0.6, 0.6, ['Estatica papu instancia '], true);
					bgfeo.setGraphicSize(Std.int(bgfeo.width * 2.5));
					bgfeo.antialiasing = false;
					bgfeo.alpha = 0;
					add(bgfeo);

					aguaExe = new BGSprite('mario/EXE2/old/weaspuki2', 400, 700, 0.7, 0.7); // agua
					aguaExe.setGraphicSize(Std.int(aguaExe.width * 3));
					aguaExe.antialiasing = false;
					aguaExe.alpha = 0;
					add(aguaExe);

					gfwasTaken = new BGSprite('mario/EXE2/old/Mario_Phase2_GF_Assets_v1', 600, 1000, 0.9, 0.9, ['GF Dancing Beat'], true); // WTF GF ES UN PROP
					gfwasTaken.setGraphicSize(Std.int(gfwasTaken.width * 2.8));
					gfwasTaken.antialiasing = false;
					gfwasTaken.alpha = 0;
					add(gfwasTaken);

					sueloExe = new BGSprite('mario/EXE2/old/weaspuki1', 400, 800, 1, 1); // suelo
					sueloExe.setGraphicSize(Std.int(sueloExe.width * 3));
					sueloExe.antialiasing = false;
					sueloExe.alpha = 0;
					add(sueloExe);

					bricksland = new BGSprite('mario/EXE2/old/Nubes4', 600, 200, 0.9, 0.9); // bloques
					bricksland.setGraphicSize(Std.int(bricksland.width * 3));
					bricksland.antialiasing = false;
					add(bricksland);

					defaultCamZoom = 1;
				}
				else
				{
					GameOverSubstate.loopSoundName = 'GBgameover';
					staticShader = new TVStatic();
					var border:VCRBorder = new VCRBorder();
					camGame.setFilters([new ShaderFilter(staticShader), new ShaderFilter(border)]);
					staticShader.strengthMulti.value = [0.5];
					staticShader.imtoolazytonamethis.value = [.3];
					
					var bglandEXE:BGSprite = new BGSprite('mario/EXE2/bad/4', -500, -200, 0.3, 0.3); // nubes
					bglandEXE.setGraphicSize(Std.int(bglandEXE.width * 6));
					bglandEXE.updateHitbox();
					bglandEXE.antialiasing = false;
					add(bglandEXE);

					bgfeo = new BGSprite('mario/EXE2/old/Mario_Phase2_Background_Assets_Static', 200, 300, 0.1, 0.1, ['Estatica papu instancia '], true);
					bgfeo.setGraphicSize(Std.int(bgfeo.width * 2.5));
					bgfeo.antialiasing = false;
					bgfeo.alpha = 0.5;
					add(bgfeo);

					var bgwaterEXE:BGSprite = new BGSprite('mario/EXE2/bad/3', -500, -200, 0.4, 0.4); // agua
					bgwaterEXE.setGraphicSize(Std.int(bgwaterEXE.width * 6));
					bgwaterEXE.updateHitbox();
					bgwaterEXE.antialiasing = false;
					add(bgwaterEXE);

					add(gfGroup);

					var floorEXE:BGSprite = new BGSprite('mario/EXE2/bad/2', -500, -200, 1, 1); // suelo
					floorEXE.setGraphicSize(Std.int(floorEXE.width * 6));
					floorEXE.updateHitbox();
					floorEXE.antialiasing = false;
					add(floorEXE);

					brickslandEXE = new BGSprite('mario/EXE2/bad/1', -500, -400, 1.2, 1.2); // bloques
					brickslandEXE.setGraphicSize(Std.int(brickslandEXE.width * 6));
					brickslandEXE.updateHitbox();
					brickslandEXE.visible = false;
					brickslandEXE.antialiasing = false;

					landbg = new FlxTypedGroup<BGSprite>();

					var bgland:BGSprite = new BGSprite('mario/EXE2/normal/4', -500, -200, 0.3, 0.3); // nubes
					bgland.setGraphicSize(Std.int(bgland.width * 6));
					bgland.updateHitbox();
					bgland.antialiasing = false;
					landbg.add(bgland);

					var bgwater:BGSprite = new BGSprite('mario/EXE2/normal/3', -500, -200, 0.4, 0.4); // agua
					bgwater.setGraphicSize(Std.int(bgwater.width * 6));
					bgwater.updateHitbox();
					bgwater.antialiasing = false;
					landbg.add(bgwater);

					var floor:BGSprite = new BGSprite('mario/EXE2/normal/2', -500, -200, 1, 1); // suelo
					floor.setGraphicSize(Std.int(floor.width * 6));
					floor.updateHitbox();
					floor.antialiasing = false;
					landbg.add(floor);

					bricksland = new BGSprite('mario/EXE2/normal/1', -500, -400, 1.2, 1.2); // bloques
					bricksland.setGraphicSize(Std.int(bricksland.width * 6));
					bricksland.updateHitbox();
					bricksland.antialiasing = false;

					add(landbg);

					defaultCamZoom = 0.8;
				}

				blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
				blackBarThingie.alpha = 0;
				add(blackBarThingie);

			case 'exeport': // MX Mario 85'

				GameOverSubstate.characterName = 'bf_PDdeath';
				addCharacterToList('bf_PDdeath', 0);
				noCount = true;
				noHUD = true;
				tvEffect = true;

				if (PlayState.SONG.song == 'Powerdown Old')
				{
					GameOverSubstate.characterName = 'bfvhs';
					GameOverSubstate.loopSoundName = 'gameOver';
					GameOverSubstate.endSoundName = 'gameOverEnd';
					DAD_CAM_X = 380;
					DAD_CAM_Y = 350;
					BF_CAM_X = 1120;
					BF_CAM_Y = 550;	
					var bg:BGSprite = new BGSprite('mario/MX/old/MXBC1', -160, -200);
					bg.setGraphicSize(Std.int(bg.width * 1.6));
					bg.antialiasing = ClientPrefs.globalAntialiasing;
					add(bg);

					epicbgthings = new FlxTypedGroup<BGSprite>();

					var creepyCloud:BGSprite = new BGSprite('mario/MX/old/MX_Background_Assets_Cloud', 400, -233, 0.9, 0.9, ['Cloud instancia 1'], true);
					creepyCloud.antialiasing = ClientPrefs.globalAntialiasing;
					epicbgthings.add(creepyCloud);

					var creppyleaf:BGSprite = new BGSprite('mario/MX/old/MX_Background_Assets_Mountain2', 694, 219, ['Mountain instancia 1'], true);
					creppyleaf.antialiasing = ClientPrefs.globalAntialiasing;
					epicbgthings.add(creppyleaf);

					var finishline:BGSprite = new BGSprite('mario/MX/old/MXBC2', 0, -200);
					finishline.antialiasing = ClientPrefs.globalAntialiasing;
					finishline.setGraphicSize(Std.int(finishline.width * 1.4));
					epicbgthings.add(finishline);

					var luigiempa:BGSprite = new BGSprite('mario/MX/old/MX_Background_Assets_Luigi', 1583, 170);
					luigiempa.antialiasing = ClientPrefs.globalAntialiasing;
					epicbgthings.add(luigiempa);

					add(epicbgthings);

					wahooText = new BGSprite('mario/MX/waho', 483, -220);
					wahooText.antialiasing = ClientPrefs.globalAntialiasing;
					wahooText.alpha = 0;
				}
				else
				{
					addCharacterToList('mxV2', 1);
					addCharacterToList('bfsad', 0);
					addCharacterToList('gfnew', 2);
					gfGroup.x = 650;
					var bg:BGSprite = new BGSprite('mario/MX/MXBG1_2', -1250, -1100);
					// bg.setGraphicSize(Std.int(bg.width * 1.6));
					bg.antialiasing = ClientPrefs.globalAntialiasing;
					add(bg);

					lightmx = new BGSprite('mario/MX/MXBG1_3', -1250, -1100);
					lightmx.antialiasing = ClientPrefs.globalAntialiasing;

					epicbgthings = new FlxTypedGroup<BGSprite>(); // ignore the tags mx pc mario port pc port 85 bg

					var fullbg:BGSprite = new BGSprite('mario/MX/1', -1920, -1680);
					fullbg.antialiasing = ClientPrefs.globalAntialiasing;
					epicbgthings.add(fullbg);

					creppyleaf = new BGSprite('mario/MX/MX_BG_Assets_2', 294, -319, 0.8, 0.8, ['BushIdle'], true);
					creppyleaf.animation.addByPrefix('idle', 'BushIdle', 24, true);
					creppyleaf.animation.addByPrefix('blink', 'BushBlink', 24, false);
					creppyleaf.antialiasing = ClientPrefs.globalAntialiasing;
					epicbgthings.add(creppyleaf);

					creepyCloud = new BGSprite('mario/MX/MX_BG_Assets_2', -400, -1233, 0.6, 0.6, ['Cloud'], false);
					creepyCloud.animation.addByPrefix('idle', 'Cloud', 24, false);
					creepyCloud.antialiasing = ClientPrefs.globalAntialiasing;
					epicbgthings.add(creepyCloud);


					var bgfloor:BGSprite = new BGSprite('mario/MX/2', -1920, -1680);
					bgfloor.antialiasing = ClientPrefs.globalAntialiasing;
					epicbgthings.add(bgfloor);

					shadowbg = new BGSprite('mario/MX/3', -1920, -1680);
					shadowbg.antialiasing = ClientPrefs.globalAntialiasing;


					var luigiempa:BGSprite = new BGSprite('mario/MX/MX_BG_Assets_1', 1763, -170, ['LucasHead'], true);
					luigiempa.antialiasing = ClientPrefs.globalAntialiasing;
					epicbgthings.add(luigiempa);

					var luigibody:BGSprite = new BGSprite('mario/MX/MX_BG_Assets_1', 1383, 360, ['Lucasody'], true);
					luigibody.antialiasing = ClientPrefs.globalAntialiasing;
					epicbgthings.add(luigibody);

					var dedtoad:BGSprite = new BGSprite('mario/MX/MX_BG_Assets_1', 183, 370, ['ToadBody'], true);
					dedtoad.antialiasing = ClientPrefs.globalAntialiasing;
					epicbgthings.add(dedtoad);

					epicbgthings.visible = false;
					add(epicbgthings);

					wahooText = new BGSprite('mario/MX/waho', 483, -220);
					wahooText.antialiasing = ClientPrefs.globalAntialiasing;
					wahooText.alpha = 0;

					killMX = new BGSprite('mario/MX/MX_v2_Assets_wahoo', -1500, -1150, ['MXWahoo'], false);
					killMX.antialiasing = ClientPrefs.globalAntialiasing;
					killMX.alpha = 0.000001;
					killMX.animation.addByPrefix('yupi', "MXWahoo", 32, false);

					gfFall = new BGSprite('mario/MX/MX_v2_Assets_gfdiesepico', -1600, -700, ['GFDies'], false);
					gfFall.antialiasing = ClientPrefs.globalAntialiasing;
					gfFall.alpha = 0.000001;
					gfFall.animation.addByPrefix('fallgirls', "GFDies0", 32, false);

					gfwasTaken = new BGSprite('mario/MX/MX_v2_Assets_gfdiesepico', -1600, 200, ['GFDies2'], false);
					gfwasTaken.antialiasing = ClientPrefs.globalAntialiasing;
					gfwasTaken.alpha = 0.000001;
					gfwasTaken.animation.addByPrefix('fallgu', "GFDies2", 32, false);
					gfwasTaken.animation.addByPrefix('idle', "GFDieLoop", 32, true);

					//funnylayer0 powerdown
					funnylayer0 = new BGSprite('mario/MX/MM_Boyfriend_Assets_jump', 1120, 185, ['JUMP'], false);
					funnylayer0.animation.addByPrefix('jump', "JUMP0", 30, false);
					funnylayer0.animation.addByPrefix('jumpend', "JUMPLAND0", 24, false);
					funnylayer0.antialiasing = ClientPrefs.globalAntialiasing;
					funnylayer0.visible = false;
					add(funnylayer0);

					var vid:VideoSprite = new VideoSprite();
					vid.playVideo(Paths.video('powerdownscene'));
					vid.cameras = [camHUD];
					vid.visible = false;
					add(vid);
					vid.finishCallback = function()
						{
							vid.destroy();
						}

					midsongVid = new VideoSprite();
					midsongVid.cameras = [camHUD];
					midsongVid.visible = false;
					add(midsongVid);
				}

			case 'hatebg': // Luigi I hate You

				noCount = true;
				noHUD = true;

				var cosomario:String = '';

				if (PlayState.SONG.song == 'Oh God No')
				{
					flipchar = true;
					gfGroup.alpha = 0.000001;

					cosomario = 'M';

					BF_CAM_X = 220;
					BF_CAM_Y = 350;

					DAD_CAM_X = 620;
					DAD_CAM_Y = 290;

					boyfriendGroup.x = 0;
					dadGroup.x = 770;
					
				}

				if(PlayState.SONG.song == 'I Hate You Old'){
					GameOverSubstate.loopSoundName = 'gameOver';
					GameOverSubstate.endSoundName = 'gameOverEnd';

					var bg:BGSprite = new BGSprite('mario/IHY/old/Luigi_IHY_Background_Assets_ete_sech', -360, 100, 0.6, 0.6);
					// bg.setGraphicSize(Std.int(bg.width * 1.4));
					bg.antialiasing = ClientPrefs.globalAntialiasing;
					add(bg);

					var candlewall:BGSprite = new BGSprite('mario/IHY/Luigi_IHY_Background_Assets_Candle', 994, 39, 0.6, 0.6, ['fuegoaaaaaaaaa'], true);
					candlewall.setGraphicSize(Std.int(candlewall.width * 1));
					candlewall.antialiasing = ClientPrefs.globalAntialiasing;
					add(candlewall);
	
					var candlewall2:BGSprite = new BGSprite('mario/IHY/Luigi_IHY_Background_Assets_Candle', -194, 39, 0.6, 0.6, ['fuegoaaaaaaaaa'], true);
					candlewall2.setGraphicSize(Std.int(candlewall2.width * 1));
					candlewall2.antialiasing = ClientPrefs.globalAntialiasing;
					add(candlewall2);
				}else{
					GameOverSubstate.characterName = 'bfihydeath';
					var bg:BGSprite = new BGSprite('mario/IHY/Ladrillos y ventanas', -960, -700, 0.6, 0.6);
					// bg.setGraphicSize(Std.int(bg.width * 1.4));
					bg.antialiasing = ClientPrefs.globalAntialiasing;
					add(bg);
				}

				bgsign = new BGSprite('mario/IHY/Luigi_IHY_Background_Assets_ete_sech_v2', 1160, 300, 0.6, 0.6);
				bgsign.setGraphicSize(Std.int(bgsign.width * 0.8));
				bgsign.alpha = 0;
				bgsign.antialiasing = ClientPrefs.globalAntialiasing;
				add(bgsign);

				if (PlayState.SONG.song == 'Oh God No'){
				fire1  = new BGSprite('mario/IHY/OGN_Fireball', FlxG.random.float(-900, 230), -1200, 1.5, 1.5, ['flame'], true);
				fire1.antialiasing = ClientPrefs.globalAntialiasing;
				fire1.animation.addByPrefix('idle', 'flame', 21, true);
				fire1.animation.play('idle');

				fire2  = new BGSprite('mario/IHY/OGN_Fireball', FlxG.random.float(230, 1360), -1200, 1.5, 1.5, ['flame'], true);
				fire2.antialiasing = ClientPrefs.globalAntialiasing;
				fire2.animation.addByPrefix('idle', 'flame', 26, true);
				fire2.animation.play('idle');

				fire3  = new BGSprite('mario/IHY/OGN_Fireball', FlxG.random.float(-900, 230), -1200, 0.6, 0.6, ['flame'], true);
				fire3.antialiasing = ClientPrefs.globalAntialiasing;
				fire3.setGraphicSize(Std.int(fire3.width * 0.5));
				fire3.animation.addByPrefix('idle', 'flame', 24, true);
				fire3.animation.play('idle');
				add(fire3);

				fire4  = new BGSprite('mario/IHY/OGN_Fireball', FlxG.random.float(230, 1360), -1200, 0.5, 0.5, ['flame'], true);
				fire4.antialiasing = ClientPrefs.globalAntialiasing;
				fire4.setGraphicSize(Std.int(fire4.width * 0.5));
				fire4.animation.addByPrefix('idle', 'flame', 25, true);
				fire4.animation.play('idle');
				add(fire4);


				}

				degrad = new BGSprite('mario/IHY/asset_deg', 260, 280);
				degrad.screenCenter();
				degrad.cameras = [camEst];
				degrad.setGraphicSize(Std.int(degrad.width * 4));
				degrad.antialiasing = ClientPrefs.globalAntialiasing;
				add(degrad);

				if(PlayState.SONG.song == 'I Hate You Old'){

					GameOverSubstate.loopSoundName = 'gameOver';
					GameOverSubstate.endSoundName = 'gameOverEnd';

					DAD_CAM_X = 220;
					DAD_CAM_Y = 450;
					BF_CAM_X = 920;
					BF_CAM_Y = 550;		
					ZOOMCHARS = true;

					// este es el boo al lado de luigi
					eyelessboo = new BGSprite('mario/IHY/old/Luigi_IHY_Background_Assets_Boo', -200, 233, 0.8, 0.8, ['Boo'], true);
					eyelessboo.flipX = true;
					eyelessboo.alpha = 0;
					eyelessboo.antialiasing = ClientPrefs.globalAntialiasing;
					add(eyelessboo);

					// este es el boo de la derecha abajo
					eyelessboo2 = new BGSprite('mario/IHY/old/Luigi_IHY_Background_Assets_Boo', 1200, 133, 0.8, 0.8, ['Boo'], true);
					eyelessboo2.alpha = 0;
					eyelessboo2.antialiasing = ClientPrefs.globalAntialiasing;
					add(eyelessboo2);

					// este es el boo de la derecha arriba
					eyelessboo3 = new BGSprite('mario/IHY/old/Luigi_IHY_Background_Assets_Boo', 1150, 333, 0.8, 0.8, ['Boo'], true);
					eyelessboo3.alpha = 0;
					eyelessboo3.antialiasing = ClientPrefs.globalAntialiasing;
					add(eyelessboo3);

					var puenteHate:BGSprite = new BGSprite('mario/IHY/old/Luigi_IHY_Background_Assets_Floor', -860, -80);
					puenteHate.antialiasing = ClientPrefs.globalAntialiasing;
					add(puenteHate);

					blueMario = new BGSprite('mario/IHY/old/Luigi_IHY_Background_Assets_DrownedMario', -260, 448, ['DrownedMarioIdle'], false);
					blueMario.animation.addByPrefix('hey', 'DrownedMarioGrab', 24, false);
					blueMario.animation.addByPrefix('dance', 'DrownedMarioIdle', 24, false);
					blueMario.antialiasing = ClientPrefs.globalAntialiasing;
					blueMario.visible = false;
					add(blueMario);

					blueMario2 = new BGSprite('mario/IHY/old/Luigi_IHY_Background_Assets_DrownedMario', 1060, 448, ['DrownedMarioIdle'], false);
					blueMario2.animation.addByPrefix('hey', 'DrownedMarioGrab', 24, false);
					blueMario2.animation.addByPrefix('dance', 'DrownedMarioIdle', 24, false);
					blueMario2.antialiasing = ClientPrefs.globalAntialiasing;
					blueMario2.visible = false;
					add(blueMario2);
				}else{
					addCharacterToList('bfihydeath', 2);
					// este es el boo al lado de luigi
					eyelessboo = new BGSprite('mario/IHY/Luigi_HY_BG_Assetss', -500, 233, 0.8, 0.8, ['GhostIdle'], true);
					eyelessboo.flipX = true;
					eyelessboo.alpha = 0;
					eyelessboo.antialiasing = ClientPrefs.globalAntialiasing;
					add(eyelessboo);
					
					// este es el boo de la derecha abajo
					eyelessboo2 = new BGSprite('mario/IHY/Luigi_HY_BG_Assetss', 1500, 33, 0.8, 0.8, ['GhostIdle'], true);
					eyelessboo2.alpha = 0;
					eyelessboo2.antialiasing = ClientPrefs.globalAntialiasing;
					add(eyelessboo2);
					
					// este es el boo de la derecha arriba
					eyelessboo3 = new BGSprite('mario/IHY/Luigi_HY_BG_Assetss', 1450, 333, 0.8, 0.8, ['GhostIdle'], true);
					eyelessboo3.alpha = 0;
					eyelessboo3.antialiasing = ClientPrefs.globalAntialiasing;
					add(eyelessboo3);

					if (PlayState.SONG.song == 'Oh God No'){
						var puenteHate:BGSprite = new BGSprite('mario/IHY/PuenteCompleto', -1360, -680);
						puenteHate.antialiasing = ClientPrefs.globalAntialiasing;
						add(puenteHate);
					}else{
						var puenteHate:BGSprite = new BGSprite('mario/IHY/Puente Roto', -1360, -680);
						puenteHate.antialiasing = ClientPrefs.globalAntialiasing;
						add(puenteHate);
					}

					blueMario = new BGSprite('mario/IHY/Luigi_HY_BG_Assetss', 100, 352, ['MarioIntro'], false);
					blueMario.animation.addByPrefix('hey', 'MarioIntro', 24, false);
					blueMario.animation.addByPrefix('dance', 'MarioIdle', 24, false);
					blueMario.antialiasing = ClientPrefs.globalAntialiasing;
					blueMario.visible = false;
					add(blueMario);
	
					blueMario2 = new BGSprite('mario/IHY/Luigi_HY_BG_Assetss', 1360, 352, ['MarioIntro'], false);
					blueMario2.animation.addByPrefix('hey', 'MarioIntro', 24, false);
					blueMario2.animation.addByPrefix('dance', 'MarioIdle', 24, false);
					blueMario2.antialiasing = ClientPrefs.globalAntialiasing;
					blueMario2.visible = false;
					add(blueMario2);
				}

				blackOGNThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackOGNThingie.setGraphicSize(Std.int(blackOGNThingie.width * 10));
				blackOGNThingie.alpha = 0;
				add(blackOGNThingie);

				susto = new BGSprite('mario/IHY/image', 0, 0);
				susto.antialiasing = ClientPrefs.globalAntialiasing;
				susto.alpha = 0.00000001;
				susto.cameras = [camHUD];
				susto.screenCenter();


				estatica = new FlxSprite();
				if (ClientPrefs.lowQuality)
				{
					estatica.frames = Paths.getSparrowAtlas('modstuff/static');
					estatica.setGraphicSize(Std.int(estatica.width * 10));
				}
				else
				{
					estatica.frames = Paths.getSparrowAtlas('modstuff/Mario_static');
				}
				estatica.animation.addByPrefix('idle', "static play", 20);
				estatica.animation.play('idle');
				estatica.antialiasing = false;
				estatica.cameras = [camHUD];
				estatica.alpha = 0.00000001;
				estatica.updateHitbox();
				estatica.screenCenter();

			case 'warioworld':
				GameOverSubstate.endSoundName = 'bowlaugh';
				GameOverSubstate.deathSoundName = 'gameoverwario';
				warioDead = false;

				if(PlayState.SONG.song != 'Apparition Old' && PlayState.SONG.song != 'Forbidden Star'){
				tvEffect = true;
				oldTV = true;
				}

				bgwario = new BGSprite('mario/Wario/wea_mala_ctm', 180, 100, ['fondo instancia 1'], true);
				bgwario.setGraphicSize(Std.int(bgwario.width * 2.4));
				bgwario.antialiasing = ClientPrefs.globalAntialiasing;
				add(bgwario);

				if(PlayState.SONG.song != 'Apparition Old' && PlayState.SONG.song != 'Forbidden Star'){
					
					GameOverSubstate.deathSoundName = 'Wario/APPdeath';
					GameOverSubstate.loopSoundName = 'Wario/APPgameover';
					GameOverSubstate.endSoundName = 'Wario/APPconfirm';
					specialGameOver = true;

					bftors = new BGSprite('characters/apparitionbf/BFRUNNING_backlegs', 490, 780, ['back0'], true);
					bftors.animation.addByPrefix('idle', 'back0', 48, true);
					bftors.antialiasing = ClientPrefs.globalAntialiasing;

					bfext = new BGSprite('characters/apparitionbf/BFRUNNING_frontlegs', 440, 730, ['frontlegs'], true);
					bfext.animation.addByPrefix('idle', 'front0', 48, true);
					bfext.antialiasing = ClientPrefs.globalAntialiasing;

					bftorsmiss = new BGSprite('characters/apparitionbf/BFRUNNING_backlegs', 490, 780, ['back fail'], true);
					bftorsmiss.animation.addByPrefix('idle', 'back fail', 48, true);
					bftorsmiss.antialiasing = ClientPrefs.globalAntialiasing;
					bftorsmiss.visible = false;

					bfextmiss = new BGSprite('characters/apparitionbf/BFRUNNING_frontlegs', 440, 730, ['front fail'], true);
					bfextmiss.animation.addByPrefix('idle', 'front fail', 48, true);
					bfextmiss.antialiasing = ClientPrefs.globalAntialiasing;
					bfextmiss.visible = false;

					bftorsmiss.animation.play('idle');
					bfextmiss.animation.play('idle');

					bfFall = new BGSprite('mario/Wario/Apparition_Game_Over', boyfriendGroup.x - 70, boyfriendGroup.y + 150, ['bf fall anim'], false);
					bfFall.animation.addByPrefix('fall', "bf fall anim", 24, true);
					bfFall.scale.set(0.9, 0.9);
					bfFall.alpha = 0.00001;
					add(bfFall);
				}
				else
				{
					BF_CAM_EXTEND = 0;
					bftors = new BGSprite('mario/Wario/BoyFriend_Wario_Assets_v3_Body1', 460, 705, ['BF Body Idle 1'], true);
					bftors.animation.addByPrefix('idle', 'BF Body Idle 1', 48, true);
					bftors.antialiasing = ClientPrefs.globalAntialiasing;

					bfext = new BGSprite('mario/Wario/BoyFriend_Wario_Assets_v3_Body2', 410, 655, ['BF Body Idle 2'], true);
					bfext.animation.addByPrefix('idle', 'BF Body Idle 2', 48, true);
					bfext.antialiasing = ClientPrefs.globalAntialiasing;
				}

				bftors.animation.play('idle');
				bfext.animation.play('idle');

				blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
				blackBarThingie.alpha = 0;
				blackBarThingie.cameras = [camOther];
				add(blackBarThingie);
				
			case 'promoshow':
				flipchar = true;
				oldTV = true;
				tvEffect = true;

				promoBGSad = new BGSprite('mario/promo/promobg', 0, 19, ['bg depression'], true);
				promoBGSad.antialiasing = ClientPrefs.globalAntialiasing;
				add(promoBGSad);
				promoBGSad.visible = false;

				promoBG = new BGSprite('mario/promo/promobg', 0, 19, ['bg normal'], true);
				promoBG.antialiasing = ClientPrefs.globalAntialiasing;
				add(promoBG);

				promoDesk = new BGSprite('mario/promo/promodesk', 740, 552, ['Promario desk static'], true);
				promoDesk.animation.addByPrefix('stat', 'Promario desk static', 24, true);
				promoDesk.animation.addByPrefix('luigi', 'Promario desk luigi', 24, true);
				promoDesk.animation.addByPrefix('flash', 'Promario desk flash', 24, false);
				promoDesk.antialiasing = ClientPrefs.globalAntialiasing;

				darkFloor = new BGSprite('mario/promo/wood floor', 600, 800);
				darkFloor.antialiasing = ClientPrefs.globalAntialiasing;
				add(darkFloor);
				darkFloor.visible = false;

				bgLuigi = new BGSprite('mario/promo/promo_luigi', 200, 275, ['luigi idle right'], false);
				bgLuigi.animation.addByPrefix('idle', 'luigi idle right', 24, false);
				bgLuigi.animation.addByPrefix('idle-alt', 'luigi idle left', 24, false);
				bgLuigi.antialiasing = ClientPrefs.globalAntialiasing;
				add(bgLuigi);
				bgLuigi.alpha = 0;

				bgPeach = new BGSprite('mario/promo/promo_peach', 1225, 225, ['peach idle right'], false);
				bgPeach.animation.addByPrefix('idle', 'peach idle right', 24, false);
				bgPeach.animation.addByPrefix('idle-alt', 'peach idle left', 24, false);
				bgPeach.antialiasing = ClientPrefs.globalAntialiasing;
				add(bgPeach);
				bgPeach.alpha = 0;

				stanlines = new BGSprite('mario/promo/stanley_lines', 550, 500, ['lines'], false);
				stanlines.animation.addByIndices('line1', 'lines', [0], "", 24, true);
				stanlines.animation.addByIndices('line2', 'lines', [1], "", 24, true);
				stanlines.animation.addByIndices('line3', 'lines', [2], "", 24, true);
				stanlines.animation.addByIndices('line4', 'lines', [3], "", 24, true);
				stanlines.animation.addByIndices('line5', 'lines', [4], "", 24, true);
				stanlines.animation.addByIndices('line6', 'lines', [5], "", 24, true);
				stanlines.animation.addByIndices('line7', 'lines', [6], "", 24, true);
				stanlines.animation.addByIndices('line8', 'lines', [7], "", 24, true);
				stanlines.antialiasing = ClientPrefs.globalAntialiasing;

				blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
				blackBarThingie.alpha = 0;
				blackBarThingie.cameras = [camEst];
				add(blackBarThingie);

				tvTransition = new BGSprite('mario/promo/tv_trans', 0, 0, ['transition'], false);
				tvTransition.animation.addByPrefix('dothething', 'transition', 24, false);
				tvTransition.antialiasing = ClientPrefs.globalAntialiasing;
				tvTransition.cameras = [camEst];
				tvTransition.visible = false;
				add(tvTransition);

				addCharacterToList('stanley', 1);

			case 'racing':
				GameOverSubstate.deathSoundName = 'racelose';
				noCount = true;
				noHUD = true;

				addCharacterToList('racet1', 1);
				addCharacterToList('racet2', 1);
				addCharacterToList('racet3', 1);

				var bg:BGSprite = new BGSprite('mario/Races/Race_Mario_BG2', -100, -50, 0.5, 0.5);
				// bg.setGraphicSize(Std.int(bg.width * 1.45));
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				add(bg);

				var bgColina:BGSprite = new BGSprite('mario/Races/Race_Mario_BG3', -400, -150, 0.9, 0.9);
				// bg.setGraphicSize(Std.int(bg.width * 1.45));
				bgColina.antialiasing = ClientPrefs.globalAntialiasing;
				add(bgColina);

				var bgPista:BGSprite = new BGSprite('mario/Races/Race_Mario_BG1', -160, -120, ['Ground'], true);
				bgPista.setGraphicSize(Std.int(bgPista.width * 1.3));
				bgPista.antialiasing = ClientPrefs.globalAntialiasing;
				add(bgPista);

				xboxigualGOD = new BGSprite('mario/Races/KRAAAATOOOOOS', 2460, -90);
				xboxigualGOD.setGraphicSize(Std.int(xboxigualGOD.width * 1.05));
				xboxigualGOD.antialiasing = ClientPrefs.globalAntialiasing;

				var fernan:BGSprite = new BGSprite('mario/Races/fernan', 50, 20);
				fernan.cameras = [camEst];
				fernan.setGraphicSize(Std.int(fernan.width * 0.9));
				fernan.antialiasing = ClientPrefs.globalAntialiasing;
				if(FlxG.random.bool(0.05)) 
					add(fernan);

			case 'betamansion':
				noCount = true;

				if (PlayState.SONG.song != 'Alone Old')
				{
					noHUD = true;
					specialGameOver = true;
					var bg:BGSprite = new BGSprite('mario/LuigiBeta/Skybox', -1200, -850, 0.2, 0.2);
					bg.antialiasing = ClientPrefs.globalAntialiasing;
					add(bg);

					var scarymansion:BGSprite = new BGSprite('mario/LuigiBeta/BackBG', -1200, -850, 0.8, 0.8);
					scarymansion.antialiasing = ClientPrefs.globalAntialiasing;
					add(scarymansion);

					add(gfGroup);

					var betafire1:BGSprite = new BGSprite('mario/LuigiBeta/Alone_Fire', -320, -630, ['fire'], true);
					//betafire.setGraphicSize(Std.int(lluvia.width * 1.7));
					betafire1.antialiasing = ClientPrefs.globalAntialiasing;
					add(betafire1);

					var betafire2:BGSprite = new BGSprite('mario/LuigiBeta/Alone_Fire', 1270, -630, ['fire'], true);
					//betafire.setGraphicSize(Std.int(lluvia.width * 1.7));
					betafire2.antialiasing = ClientPrefs.globalAntialiasing;
					betafire2.flipX = true;
					add(betafire2);

					var scaryfloor:BGSprite = new BGSprite('mario/LuigiBeta/FrontBG', -1200, -850);
					scaryfloor.antialiasing = ClientPrefs.globalAntialiasing;
					add(scaryfloor);

					starmanGF = new BGSprite('characters/Beta_Luigi_GF_Assets', 570, 100, 1, 1, ["GFIdle"], false);
					starmanGF.animation.addByIndices('danceRight', 'GFIdle', [15,16,17,18,19,20,21,22,23,24,25,26,27,28,29], "", 24, false);
					starmanGF.animation.addByIndices('danceLeft', 'GFIdle', [30,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14], "", 24, false);
					starmanGF.animation.addByPrefix('sad', "GFMiss", 24, false);
					starmanGF.antialiasing = ClientPrefs.globalAntialiasing;
					add(starmanGF);

					lluvia = new BGSprite('mario/LuigiBeta/old/Beta_Luigi_Rain_V1', -170, 50, ['RainLuigi'], true);
					lluvia.setGraphicSize(Std.int(lluvia.width * 1.7));
					lluvia.alpha = 0;
					lluvia.antialiasing = ClientPrefs.globalAntialiasing;
					lluvia.cameras = [camEst];
					add(lluvia);
					
					//alone mario
					iconGF = new FlxSprite().loadGraphic(Paths.image('icons/icon-LG'));
					iconGF.width = iconGF.width / 2;
					iconGF.loadGraphic(Paths.image('icons/icon-alonemario'), true, Math.floor(iconGF.width), Math.floor(iconGF.height));
					iconGF.animation.add("win", [0], 10, true);
					iconGF.animation.add("lose", [1], 10, true);
					iconGF.cameras = [camHUD];
					iconGF.alpha = 0;
					iconGF.antialiasing = ClientPrefs.globalAntialiasing;

					blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
					blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
					blackBarThingie.cameras = [camEst];
					blackBarThingie.scrollFactor.set(0, 0);
					add(blackBarThingie);
				}
				else
				{
					DAD_CAM_X = 420;
					DAD_CAM_Y = 450;
					BF_CAM_X = 720;
					BF_CAM_Y = 450;

					GameOverSubstate.loopSoundName = 'gameOver';
					GameOverSubstate.endSoundName = 'gameOverEnd';

					var bg:BGSprite = new BGSprite('mario/LuigiBeta/old/Beta_Luigi_BG_Assets_2', -400, -50, 0.5, 0.5);
					// bg.setGraphicSize(Std.int(bg.width * 1.45));
					bg.antialiasing = ClientPrefs.globalAntialiasing;
					add(bg);

					var scarymansion:BGSprite = new BGSprite('mario/LuigiBeta/old/Beta_Luigi_BG_Assets_1', -350, -170);
					scarymansion.setGraphicSize(Std.int(scarymansion.width * 1.1));
					scarymansion.antialiasing = ClientPrefs.globalAntialiasing;
					add(scarymansion);

					var scaryLights:BGSprite = new BGSprite('mario/LuigiBeta/old/Beta_Luigi_BG_Assets_3', 320, 50);
					scaryLights.setGraphicSize(Std.int(scaryLights.width * 1.1));
					scaryLights.antialiasing = ClientPrefs.globalAntialiasing;
					add(scaryLights);

					lluvia = new BGSprite('mario/LuigiBeta/old/Beta_Luigi_Rain_V1', -170, 50, ['RainLuigi'], true);
					lluvia.setGraphicSize(Std.int(lluvia.width * 1.7));
					lluvia.alpha = 0.5;
					lluvia.visible = false;
					lluvia.antialiasing = ClientPrefs.globalAntialiasing;
				}

			case 'superbad':
				// GameOverSubstate.characterName = 'bfbaddeath';

				camHUD.visible = false;

				var lumpy:BGSprite = new BGSprite('mario/BadMario/lumpy', -570, -265, 1, 1);
				lumpy.setGraphicSize(Std.int(lumpy.width * 0.65));
				lumpy.antialiasing = ClientPrefs.globalAntialiasing;
				add(lumpy);

				var ohMyGodImHumpingMy:BGSprite = new BGSprite('mario/BadMario/couch', -700, -350, 1, 1);
				ohMyGodImHumpingMy.antialiasing = ClientPrefs.globalAntialiasing;
				add(ohMyGodImHumpingMy);

				badGrad1 = new FlxSprite(0, 0).loadGraphic(Paths.image('mario/BadMario/sideBar'));
				badGrad1.antialiasing = ClientPrefs.globalAntialiasing;
				badGrad1.cameras = [camOther];
				badGrad1.visible = false;
				add(badGrad1);

				badGrad2 = new FlxSprite(600, 0).loadGraphic(Paths.image('mario/BadMario/sideBar'));
				badGrad2.antialiasing = ClientPrefs.globalAntialiasing;
				badGrad2.cameras = [camOther];
				badGrad2.visible = false;
				badGrad2.flipX = true;
				add(badGrad2);

				badPoisonVG = new FlxSprite(0, 0).loadGraphic(Paths.image('mario/BadMario/poisonVG'));
				badPoisonVG.scale.set(1.4, 1.4);
				badPoisonVG.screenCenter();
				badPoisonVG.antialiasing = ClientPrefs.globalAntialiasing;
				badPoisonVG.cameras = [camOther];
				badPoisonVG.alpha = 0;

				badHUDMario = new BGSprite('mario/BadMario/HUD_Mario', 0, 0, 1, 1, ['mario spin jump'], true);
				badHUDMario.animation.addByPrefix('walk', 'mario walk', 12, true);
				badHUDMario.animation.addByPrefix('spin', 'mario spin jump', 18, true);
				badHUDMario.animation.addByPrefix('jump', 'jump', 12, true);
				badHUDMario.animation.addByPrefix('fall', 'fall', 12, true);
				badHUDMario.antialiasing = false;
				badHUDMario.scale.set(5, 5);
				badHUDMario.cameras = [camHUD];

				blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));

				// im sorry little one...
				// camGame.setSize(FlxG.width * 2, FlxG.height * 2);
				// camGame.setPosition(-1 * (FlxG.width / 2), -1 * (FlxG.width / 4));

			case 'somari':
				noCount = true;
				specialGameOver = true;

				Main.fpsVar.visible = false;

				var bg = new BGSprite('mario/Somari/somari_stag1', 256, 222, 0, 0);
				bg.scale.set(4, 4);
				bg.antialiasing = false;
				bg.updateHitbox();

				building = new BGSprite('mario/Somari/buildings_papu', 256, 222, 0, 0, ['buildings papu color'], true);
				building.animation.addByPrefix('idle', 'buildings papu color', 1, true);
				building.animation.play('idle');
				building.scale.set(4, 4);
				building.antialiasing = false;
				building.updateHitbox();

				bgstars = new BGSprite('mario/Somari/bgstars', 256, 222, 0, 0, ['bgstars flash'], true);
				bgstars.animation.addByPrefix('idle', 'bgstars flash', 5, true);
				bgstars.animation.play('idle');
				bgstars.scale.set(4, 4);
				bgstars.antialiasing = false;
				bgstars.updateHitbox();
				// bgstars.velocity.set(-40, 0);

				add(bgstars);
				add(building);
				add(bg);

				eventTweens.push(FlxTween.tween(bgstars, {x: bgstars.x - 1388}, 30, {type: LOOPING}));

				platformlol = new BGSprite('mario/Somari/platform', 922.5, 593, 1, 1);
				platformlol.scale.set(4, 4);
				platformlol.updateHitbox();
				platformlol.antialiasing = false;
				add(platformlol);

				titleNES = new FlxSprite();
				titleNES.loadGraphic(Paths.image('pixelUI/title'));
				titleNES.width = titleNES.width / 4;
				titleNES.loadGraphic(Paths.image('pixelUI/title'), true, Math.floor(titleNES.width), Math.floor(titleNES.height));
				titleNES.scale.set(2, 2);
				titleNES.antialiasing = false;
				titleNES.visible = false;
				titleNES.cameras = [camHUD];
				titleNES.updateHitbox();
				titleNES.screenCenter();
				titleNES.x += 25;
				titleNES.animation.add("show", [3, 2, 1, 0], 12, false);
				titleNES.animation.add("hide", [0, 1, 2, 3], 12, false);
				add(titleNES);

				ringcount = new FlxText(-115, 670, FlxG.width, '00', 24);
				ringcount.setFormat(Paths.font("mariones.ttf"), 40, FlxColor.WHITE, RIGHT);
				ringcount.antialiasing = false;
				ringcount.cameras = [camHUD];
				add(ringcount);
				if (hasDownScroll) ringcount.y = -20;

				var	ringicon:BGSprite = new BGSprite('mario/Somari/image', 1020, ringcount.y, 1, 1);
				ringicon.scale.set(8, 8);
				ringicon.updateHitbox();
				ringicon.antialiasing = false;
				ringicon.cameras = [camHUD];
				//ringicon.screenCenter();
				add(ringicon);

				if (hasDownScroll)
					{
						ringcount.y = -20;
						ringicon.y = -20;
					}
				
				pixelLights = new BGSprite('mario/Somari/spot', 370.5, 321, 1, 1, ['spot 3']);
				pixelLights.animation.addByPrefix('double', 'spot 3', 1, true);
				pixelLights.animation.addByPrefix('full', 'spot 0', 1, true);
				pixelLights.animation.addByPrefix('left', 'spot 1', 1, true);
				pixelLights.animation.addByPrefix('right', 'spot 2', 1, true);
				pixelLights.animation.play('double');
				pixelLights.scale.set(4, 4);
				pixelLights.updateHitbox();
				pixelLights.antialiasing = false;
				pixelLights.visible = false;

			case 'directstream':
				noHUD = true;
				noCount = true;
				BF_CAM_EXTEND = 0;

				DirectChat.reset();

				var bggrey:BGSprite = new BGSprite('mario/Real/direct bg grey', 0, -50);
				bggrey.antialiasing = ClientPrefs.globalAntialiasing;
				add(bggrey);

				bgred = new BGSprite('mario/Real/direct bg red', 0, -50);
				bgred.antialiasing = ClientPrefs.globalAntialiasing;
				add(bgred);

				miyamoto = new BGSprite('mario/Real/miyamoto',  345, 236, ['miyamoto still'], true);
				miyamoto.animation.addByPrefix('idle', 'miyamoto still', 24, false);
				miyamoto.animation.addByPrefix('talk', 'miyamoto talking', 24, true);
				miyamoto.animation.addByPrefix('hand', 'miyamoto hand motion', 24, false);
				miyamoto.antialiasing = ClientPrefs.globalAntialiasing;
				add(miyamoto);

				livechat = new FlxText(860, 30, 818, '', 24);
				livechat.setFormat(Paths.font("pixel.otf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

				livechat.addFormat(chatcolor1);
				livechat.addFormat(chatcolor2);
				livechat.addFormat(chatcolor3);
				livechat.addFormat(chatcolor4);
				livechat.addFormat(chatcolor5);

				livechat.cameras = [camEst];
				add(livechat);

				ytUI = new BGSprite('mario/Real/ytui', 0, 0, 0, 0);
				ytUI.antialiasing = ClientPrefs.globalAntialiasing;
				ytUI.alpha = 0;
				ytUI.setGraphicSize(Std.int(ytUI.width * 1.52));
				ytUI.updateHitbox();
				ytUI.screenCenter();
				add(ytUI);

				ytbutton = new BGSprite('mario/Real/button', 0, 0, 0, 0, ['button play'], true);
				ytbutton.antialiasing = ClientPrefs.globalAntialiasing;
				ytbutton.alpha = 0;
				ytbutton.animation.addByPrefix('play', 'button play', 1, false);
				ytbutton.animation.addByPrefix('pause', 'button pause', 1, false);
				ytbutton.setGraphicSize(Std.int(ytbutton.width * 1.52));
				ytbutton.updateHitbox();
				ytbutton.screenCenter();
				ytbutton.scale.set(0.8, 0.8);

				add(dadGroup);

				camBG = new BGSprite('mario/Real/facecam bg', 1345, 636, ['facecam bg down'], true);
				camBG.animation.addByPrefix('up', 'facecam bg up', 1, false);
				camBG.animation.addByPrefix('down', 'facecam bg down', 1, false);
				camBG.animation.addByPrefix('left', 'facecam bg left', 1, false);
				camBG.animation.addByPrefix('right', 'facecam bg right', 1, false);
				camBG.antialiasing = ClientPrefs.globalAntialiasing;
				add(camBG);

				if (hasDownScroll)
				{
					boyfriendGroup.y = -255;
					gfGroup.y = -176;
					camBG.y = 50;
					livechat.y = 320;
				}

				bordervid = new BGSprite('mario/Real/facecam border', 1340, 50);
				bordervid.antialiasing = ClientPrefs.globalAntialiasing;
				bordervid.flipY = !hasDownScroll;

				blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
				blackBarThingie.cameras = [camEst];
				blackBarThingie.scrollFactor.set(0, 0);
				add(blackBarThingie);

				nametag = new BGSprite('mario/Real/nametag', -510, 790);
				nametag.alpha = 0;
				nametag.antialiasing = ClientPrefs.globalAntialiasing;

				elfin = new BGSprite('mario/Real/chris', 0, 0);
				elfin.cameras = [camEst];
				elfin.alpha = 0;
				elfin.antialiasing = ClientPrefs.globalAntialiasing;
			// add(elfin);

			case 'bootleg':
				GameOverSubstate.deathSoundName = 'gran_gag_sounddesign';
				GameOverSubstate.characterName = 'bfGDDIES';
				GameOverSubstate.loopSoundName = 'GD/ghost_' + FlxG.random.int(1, 24);
				noCount = true;
				noHUD = true;
				FOLLOWCHARS = false;

				addCharacterToList('bfGDDIES', 0);

				var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF155FD9);
				bg.setGraphicSize(Std.int(bg.width * 10));
				bg.scrollFactor.set(0, 0);
				add(bg);

				startbutton = new BGSprite('mario/dad7/start', 400, 1250, 1, 1);
				startbutton.antialiasing = false;
				startbutton.setGraphicSize(Std.int(startbutton.width * 4));
				add(startbutton);

				flintbg = new BGSprite('mario/dad7/flint', 900, 250, 1, 1);
				flintbg.antialiasing = false;
				flintbg.visible = false;
				flintbg.setGraphicSize(Std.int(flintbg.width * 12));
				add(flintbg);

				flintwater = new BGSprite('mario/dad7/Water', 50, 1650, 1.4, 1, ['Water idle'], true);
				flintwater.antialiasing = false;
				flintwater.visible = false;
				flintwater.setGraphicSize(Std.int(flintwater.width * 12));
				add(flintwater);

				gdRunners = new FlxTypedGroup<GrandDadRunners>();
				gdRunners.visible = false;
				add(gdRunners);

				var gdRunnerRandom:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7];
				gdRunnerRandom = FlxG.random.shuffleArray(gdRunnerRandom, 10);
				gdRunnerRandom.insert(gdRunnerRandom.length, 8);
				gdRunnerRandom.insert(gdRunnerRandom.length, 9);
				gdRunnerRandom.insert(gdRunnerRandom.length, 10);

				for(i in 0...gdRunnerRandom.length){
					var gdRunner:GrandDadRunners = new GrandDadRunners(gfGroup.x - 100, gfGroup.y - 280, i, gdRunnerRandom[i]);
					gdRunner.ID = i;
					gdRunners.add(gdRunner);
				}

				thegang = new BGSprite('mario/dad7/Grand_Dad_Girlfriend_Assets_gang', gfGroup.x - 70, gfGroup.y + 110, 1, 1, ['funnygangIdle'], true);
				thegang.animation.addByPrefix('idle', 'funnygangIdle', 24, false);
				thegang.antialiasing = ClientPrefs.globalAntialiasing;
				thegang.visible = false;
				add(thegang);

				hamster = new BGSprite('mario/dad7/Hamster', 50, -1400, 1, 1);
				hamster.antialiasing = ClientPrefs.globalAntialiasing;
				hamster.setGraphicSize(Std.int(hamster.width * 0.8));

				var title7:BGSprite = new BGSprite('mario/dad7/gdtitle', -200, -1400, 1, 1);
				title7.antialiasing = ClientPrefs.globalAntialiasing;
				title7.setGraphicSize(Std.int(title7.width * 0.8));
				add(title7);

				add(hamster);

			case 'luigiout':
				GameOverSubstate.characterName = 'bf-ldo';

				noCount = true;
				noHUD = true;
				flipchar = true;

				ZOOMCHARS = false;

				var sky:BGSprite = new BGSprite('mario/cityout/skyL', -200, -1000, 0.7, 0.8);
				add(sky);

				var citybg:BGSprite = new BGSprite('mario/cityout/buildings far', 400, -200, 0.7, 0.8);
				add(citybg);

				var cityplus:BGSprite = new BGSprite('mario/cityout/road plus building', 600, 100, 0.8, 1);
				add(cityplus);

				var lightsky:BGSprite = new BGSprite('mario/cityout/corner sky overlay', 800, -500, 0.8, 0.8);
				add(lightsky);

				var wall:BGSprite = new BGSprite('mario/cityout/buildingSide', -950, -450, 1, 1);
				add(wall);

				gflol = new BGSprite('mario/cityout/GF_LDO', -400, 300, ['ldo gf dance'], false);
				gflol.animation.addByIndices('danceleft', "ldo gf dance", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				gflol.animation.addByIndices('danceright', "ldo gf dance", [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				gflol.animation.addByIndices('danceLeft-alt', "ldo gf dance annoyed", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				gflol.animation.addByIndices('danceRight-alt', "ldo gf dance annoyed", [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				gflol.animation.addByPrefix('why', "ldo gf why", 24, false);
				gflol.antialiasing = ClientPrefs.globalAntialiasing;
				gflol.alpha = 0.000001;
				add(gflol);

				gfwalk = new BGSprite('mario/cityout/they-walkin', -390, 280, ['ldo gf end dialogue'], false);
				gfwalk.animation.addByPrefix('why', "ldo gf end dialogue", 21, false);

				gfspeak = new BGSprite('mario/cityout/stereo_still_image', -390, 640);
				gfspeak.alpha = 0.000001;

				bfwalk = new BGSprite('mario/cityout/they-walkin', -13, 325, ['ldo bf end dialogue'], false);
				bfwalk.animation.addByPrefix('why', "ldo bf end dialogue", 21, false);
				bfwalk.scale.set(1.1, 1.1);

				mrwalk = new BGSprite('mario/cityout/they-walkin', 355, 248, ['ldo mario end dialogue'], false);
				mrwalk.animation.addByPrefix('why', "ldo mario end dialogue", 21, false);

				lgwalk = new BGSprite('mario/cityout/they-walkin', 796.5, 150, ['ldo luigi end dialogue'], false);
				lgwalk.animation.addByPrefix('why', "ldo luigi end dialogue", 21, false);

				gfwalk.alpha = 0.000001;
				bfwalk.alpha = 0.000001;
				mrwalk.alpha = 0.000001;
				lgwalk.alpha = 0.000001;
				add(gfspeak);
				add(lgwalk);
				add(mrwalk);
				add(bfwalk);
				add(gfwalk);

				lightWall = new BGSprite('mario/cityout/Overlay All', -800, -550, 1.2, 1.2);

			case 'virtual':

				noCount = true;
				virtualmode = true;
				GameOverSubstate.hasVA = true;
				GameOverSubstate.vaCount = 5;

				addCharacterToList('vDialog2', 1);
				addCharacterToList('vGF2', 1);

				Lib.application.window.fullscreen = true;
				fsX = Lib.application.window.width;
				fsY = Lib.application.window.height;
				Lib.application.window.fullscreen = false;
				Lib.application.window.maximized = false;
				Lib.application.window.resizable = false;

				ogwinsizeX = Lib.application.window.width;
				ogwinsizeY = Lib.application.window.height;

				ogwinX = Lib.application.window.x;
				ogwinY = Lib.application.window.y;

				PauseSubState.restsizeX = Lib.application.window.width;
				PauseSubState.restsizeY = Lib.application.window.height;
				PauseSubState.restX = Lib.application.window.x;
				PauseSubState.restY = Lib.application.window.y;

				effect = new SMWPixelBlurShader();
				dupe = new CamDupeShader();
				dupe.mult = 1;
				angel = new AngelShader();
				camGame.setFilters([new ShaderFilter(effect.shader), new ShaderFilter(dupe), new ShaderFilter(angel)]);
				camHUD.setFilters([new ShaderFilter(angel)]);
				// trace(winx + ' and ' + winy);

				var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				bg.setGraphicSize(Std.int(bg.width * 10));
				bg.scrollFactor.set(0, 0);
				add(bg);

				yourhead = new BGSprite('mario/virtual/headbg', -400, -200, 1, 1);
				yourhead.setGraphicSize(Std.int(yourhead.width * 2));
				yourhead.antialiasing = ClientPrefs.globalAntialiasing;
				yourhead.alpha = 0.2;
				yourhead.visible = false;
				yourhead.scrollFactor.set();
				add(yourhead);

				virtuabg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF571900);
				virtuabg.setGraphicSize(Std.int(virtuabg.width * 10));
				virtuabg.scrollFactor.set(0, 0);
				virtuabg.alpha = 0;
				add(virtuabg);

				blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
				//blackBarThingie.alpha = 0;
				blackBarThingie.scrollFactor.set(0, 0);
				blackBarThingie.cameras = [camOther];
				add(blackBarThingie);

				vwall = new BGSprite('mario/virtual/Wall Bg', -1200, -750, 0.6, 0.6);
				vwall.antialiasing = ClientPrefs.globalAntialiasing;

				clashmario = new FlxTypedGroup<BGSprite>();

				var backFloor:BGSprite = new BGSprite('mario/virtual/Back Platform', -1200, -750, 0.75, 0.75);
				backFloor.antialiasing = ClientPrefs.globalAntialiasing;

				turtle = new BGSprite('mario/virtual/v_koopa_thorny', 800, 200, 0.75, 0.75, ['Koopa Idle Glitch'], false);
				turtle.antialiasing = ClientPrefs.globalAntialiasing;
				turtle.animation.addByPrefix('glitch', "glitch in", 24, false);
				turtle.animation.addByPrefix('idle', "Koopa Idle Glitch", 24, false);
				turtle.scale.set(0.8, 0.8);
				turtle.flipX = true;
				turtle.visible = false;

				turtle2 = new BGSprite('mario/virtual/v_koopa_thorny', 200, 200, 0.75, 0.75, ['Koopa Idle Glitch'], false);
				turtle2.antialiasing = ClientPrefs.globalAntialiasing;
				turtle2.animation.addByPrefix('glitch', "glitch in", 24, false);
				turtle2.animation.addByPrefix('idle', "Koopa Idle Glitch", 24, false);
				turtle2.scale.set(0.8, 0.8);
				turtle2.visible = false;

				gfwasTaken = new BGSprite('characters/Mr_Virtual_Girlfriend_Assets_jaj', 900, 0, 0.75, 0.75, ['GF Dies lol'], false);
				gfwasTaken.animation.addByPrefix('dies', "GF Dies lol", 24, false);
				gfwasTaken.antialiasing = ClientPrefs.globalAntialiasing;
				gfwasTaken.visible = false;

				var backPipes:BGSprite = new BGSprite('mario/virtual/Back Pipes', -1200, -750, 0.75, 0.75);
				backPipes.antialiasing = ClientPrefs.globalAntialiasing;

				var frontFloor:BGSprite = new BGSprite('mario/virtual/Main Platform', -1200, -750, 1, 1);
				frontFloor.antialiasing = ClientPrefs.globalAntialiasing;

				var frontPipes:BGSprite = new BGSprite('mario/virtual/Front Pipes', -1200, -750, 1, 1);
				frontPipes.antialiasing = ClientPrefs.globalAntialiasing;

				var cornerPipes:BGSprite = new BGSprite('mario/virtual/Corner top Left Pipes', -1400, -600, 0.75, 0.75);
				cornerPipes.antialiasing = ClientPrefs.globalAntialiasing;

				var cornerPipes:BGSprite = new BGSprite('mario/virtual/Corner top Left Pipes', -1400, -600, 0.75, 0.75);
				cornerPipes.antialiasing = ClientPrefs.globalAntialiasing;

				add(vwall);
				clashmario.add(backPipes);
				clashmario.add(backFloor);
				clashmario.add(turtle);
				clashmario.add(turtle2);
				clashmario.add(frontPipes);
				clashmario.add(frontFloor);
				clashmario.add(cornerPipes);

				add(gfwasTaken);
				add(clashmario);

				crazyFloor = new BGSprite('mario/virtual/Platform', -1200, -170, 1, 1);
				crazyFloor.antialiasing = ClientPrefs.globalAntialiasing;
				crazyFloor.visible = false;
				add(crazyFloor);

			case 'nesbeat':
				GameOverSubstate.endSoundName = 'gameOverEndUB';
				GameOverSubstate.loopSoundName = 'gameOverUB';
				noCount = true;
				noHUD = true;
				tvEffect = true;

				addCharacterToList('hunter', 1);
				addCharacterToList('koopa', 1);
				addCharacterToList('mrSYSwb', 1);

				var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bars'));
				bg.scale.set(3, 3);
				bg.screenCenter();
				bg.scrollFactor.set(0, 0);
				add(bg);

				duckbg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
				duckbg.setGraphicSize(Std.int(duckbg.width * 10));
				duckbg.alpha = 0;
				duckbg.color = 0xFF5595DA;
				add(duckbg);

				ducktree = new BGSprite('mario/beatus/tree', -600, -100, 0.6, 0.6);
				ducktree.scale.set(6.5, 6.5);
				ducktree.updateHitbox();
				ducktree.antialiasing = false;
				ducktree.visible = false;
				add(ducktree);

				duckleafs = new BGSprite('mario/beatus/arbust', 1600, 400, 0.8, 0.8);
				duckleafs.scale.set(6.5, 6.5);
				duckleafs.updateHitbox();
				duckleafs.antialiasing = false;
				duckleafs.visible = false;
				add(duckleafs);

				duckfloor = new BGSprite('mario/beatus/grass', 0, 550, 1, 1);
				duckfloor.scale.set(6.5, 6.5);
				duckfloor.updateHitbox();
				duckfloor.antialiasing = false;
				duckfloor.screenCenter(X);
				duckfloor.alpha = 0;
				add(duckfloor);

				bowbg = new BGSprite('mario/beatus/castle', -700, -200, 0.4, 0.4);
				bowbg.scale.set(5, 5);
				bowbg.updateHitbox();
				bowbg.antialiasing = false;
				bowbg.visible = false;
				add(bowbg);

				bowbg2 = new BGSprite('mario/beatus/castle2', -700, -200, 0.4, 0.4);
				bowbg2.scale.set(5, 5);
				bowbg2.updateHitbox();
				bowbg2.antialiasing = false;
				bowbg2.visible = false;
				add(bowbg2);

				bowplat = new BGSprite('mario/beatus/platnes', 800, 300, 0.5, 0.5);
				bowplat.scale.set(5, 5);
				bowplat.updateHitbox();
				bowplat.visible = false;
				bowplat.antialiasing = false;
				add(bowplat);

				bowlava = new BGSprite('mario/beatus/neslava', -300, 900, 0.85, 0.85, ['lava hot ow ow its too hot aaa'], false);
				bowlava.scale.set(5, 5);
				bowlava.updateHitbox();
				bowlava.animation.addByPrefix('idle', "lava hot ow ow its too hot aaa", 5, true);
				bowlava.animation.play('idle');
				bowlava.visible = false;
				bowlava.antialiasing = false;
				add(bowlava);

				blackinfrontobowser = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackinfrontobowser.setGraphicSize(Std.int(blackinfrontobowser.width * 10));
				blackinfrontobowser.alpha = 1;
				add(blackinfrontobowser);

				cutbg = new BGSprite('mario/beatus/staticbg', 800, 300, 0.2, 0.2, ['staticbg duck'], true);
				cutbg.scale.set(2.61, 2.61);
				cutbg.updateHitbox();
				cutbg.animation.addByPrefix('duck', "staticbg duck", 15, true);
				cutbg.animation.addByPrefix('bowser', "staticbg castle", 15, true);
				cutbg.visible = false;
				cutbg.screenCenter(XY);
				cutbg.antialiasing = ClientPrefs.globalAntialiasing;
				add(cutbg);

				cutskyline = new BGSprite('mario/beatus/staticbg', 800, 300, 0.2, 0.2, ['staticbg duck'], true);
				cutskyline.scale.set(2.61, 2.61);
				cutskyline.updateHitbox();
				cutskyline.animation.addByPrefix('duck', "staticbg duck", 15, true);
				cutskyline.animation.addByPrefix('bowser', "staticbg castle", 15, true);
				cutskyline.visible = false;
				cutskyline.screenCenter(XY);
				cutskyline.antialiasing = ClientPrefs.globalAntialiasing;
				add(cutskyline);

				cutstatic = new BGSprite('mario/beatus/static', 800, 300, 0.2, 0.2, ['static idle'], true);
				cutstatic.scale.set(1.3, 1.3);
				cutstatic.updateHitbox();
				cutstatic.visible = false;
				cutstatic.screenCenter(XY);
				cutstatic.antialiasing = ClientPrefs.globalAntialiasing;
				add(cutstatic);

				screencolor = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
				screencolor.setGraphicSize(Std.int(screencolor.width * 10));
				screencolor.alpha = 0;
				screencolor.scrollFactor.set(0, 0);
				add(screencolor);

				blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
				blackBarThingie.alpha = 0;
				blackBarThingie.scrollFactor.set(0, 0);
				add(blackBarThingie);

				beatText = new FlxText(-230, 150, 1818, '', 24);
				beatText.setFormat(Paths.font("mariones.ttf"), 130, FlxColor.WHITE, CENTER);
				beatText.scrollFactor.set(0, 0);
				beatText.scale.set(1, 1.5);
				beatText.updateHitbox();
				beatText.screenCenter();
				add(beatText);

				ycbuLightningL = new BGSprite('mario/beatus/ycbu_lightning', 0, 0, 1, 1, ['lightning'], true);
				ycbuLightningL.animation.addByPrefix('idle', "lightning", 15, true);
				ycbuLightningL.animation.play('idle', true);
				ycbuLightningL.screenCenter(XY);
				ycbuLightningL.x -= 440;
				ycbuLightningL.antialiasing = ClientPrefs.globalAntialiasing;
				ycbuLightningL.visible = false;
				ycbuLightningL.cameras = [camEst];
				add(ycbuLightningL);

				ycbuLightningR = new BGSprite('mario/beatus/ycbu_lightning', 0, 0, 1, 1, ['lightning'], true);
				ycbuLightningR.animation.addByPrefix('idle', "lightning", 15, true);
				ycbuLightningR.flipY = true;
				ycbuLightningR.animation.play('idle', true);
				ycbuLightningR.screenCenter(XY);
				ycbuLightningR.x += 455;
				ycbuLightningR.antialiasing = ClientPrefs.globalAntialiasing;
				ycbuLightningR.visible = false;
				ycbuLightningR.cameras = [camEst];
				add(ycbuLightningR);

				ycbuHeadL = new FlxBackdrop(Y);
				ycbuHeadL.frames = Paths.getSparrowAtlas('mario/beatus/YouCannotBeatUS_Fellas_Assets');
				ycbuHeadL.animation.addByPrefix('LOL', "Rotat e", 24, true);
				ycbuHeadL.animation.addByPrefix('gyromite', "Bird Up", 24, false);
				ycbuHeadL.animation.addByPrefix('lakitu', "Lakitu", 24, false);
				ycbuHeadL.animation.play('LOL', true);
				ycbuHeadL.updateHitbox();
				ycbuHeadL.scale.set(0.6, 0.6);
				ycbuHeadL.screenCenter(X);
				ycbuHeadL.x -= 450;
				ycbuHeadL.flipX = true;
				ycbuHeadL.antialiasing = ClientPrefs.globalAntialiasing;
				ycbuHeadL.velocity.set(0, 600);
				ycbuHeadL.visible = false;
				ycbuHeadL.cameras = [camEst];
				add(ycbuHeadL);

				ycbuHeadR = new FlxBackdrop(Y);
				ycbuHeadR.frames = Paths.getSparrowAtlas('mario/beatus/YouCannotBeatUS_Fellas_Assets');
				ycbuHeadR.animation.addByPrefix('LOL', "Rotat e", 24, true);
				ycbuHeadR.animation.addByPrefix('gyromite', "Bird Up", 24, false);
				ycbuHeadR.animation.addByPrefix('lakitu', "Lakitu", 24, false);
				ycbuHeadR.animation.play('LOL', true);
				ycbuHeadR.updateHitbox();
				ycbuHeadR.scale.set(0.6, 0.6);
				ycbuHeadR.screenCenter(X);
				ycbuHeadR.x += 445;
				ycbuHeadR.antialiasing = ClientPrefs.globalAntialiasing;
				ycbuHeadR.velocity.set(0, -600);
				ycbuHeadR.visible = false;
				ycbuHeadR.cameras = [camEst];
				add(ycbuHeadR);

				ycbuCrosshair = new FlxSprite().loadGraphic(Paths.image('mario/beatus/duckCrosshair'));
				ycbuCrosshair.scale.set(28, 28);
				ycbuCrosshair.screenCenter(XY);
				ycbuCrosshair.cameras = [camEst];
				ycbuCrosshair.visible = false;
				add(ycbuCrosshair);

				estatica = new FlxSprite();
				if (ClientPrefs.lowQuality)
				{
					estatica.frames = Paths.getSparrowAtlas('modstuff/static');
					estatica.setGraphicSize(Std.int(estatica.width * 10));
				}
				else
				{
					estatica.frames = Paths.getSparrowAtlas('modstuff/Mario_static');
				}
				estatica.animation.addByPrefix('idle', "static play", 15);
				estatica.animation.play('idle');
				estatica.antialiasing = false;
				estatica.cameras = [camEst];
				estatica.alpha = 0.05;
				estatica.updateHitbox();
				estatica.screenCenter();
				add(estatica);

				ycbuWhite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
				ycbuWhite.setGraphicSize(Std.int(ycbuWhite.width * 10));
				ycbuWhite.alpha = 0;

				otherBeatText = new FlxText(-230, 150, 1818, '', 24);
				otherBeatText.setFormat(Paths.font("mariones.ttf"), 130, FlxColor.BLACK, CENTER);
				otherBeatText.scrollFactor.set(0, 0);
				otherBeatText.scale.set(1, 1.5);
				otherBeatText.updateHitbox();
				otherBeatText.screenCenter();
				// 21.5

				ycbuGyromite = new BGSprite('mario/beatus/YouCannotBeatUS_Fellas_Assets', 800, 1000, 1.1, 1.1, ['Bird Up'], false);
				ycbuGyromite.animation.addByPrefix('idle', "Bird Up", 24, false);
				ycbuGyromite.animation.play('idle', true);
				ycbuGyromite.antialiasing = ClientPrefs.globalAntialiasing;

				ycbuLakitu = new BGSprite('mario/beatus/YouCannotBeatUS_Fellas_Assets', 0, 1000, 1.1, 1.1, ['Lakitu'], false);
				ycbuLakitu.animation.addByPrefix('idle', "Lakitu", 24, false);
				ycbuLakitu.animation.play('idle', true);
				ycbuLakitu.antialiasing = ClientPrefs.globalAntialiasing;

				ycbuGyromite.visible = false;
				ycbuLakitu.visible = false;
				add(ycbuGyromite);
				add(ycbuLakitu);

				clownCar = new BGSprite('mario/beatus/Clown_Car', 0, 0, 1, 1, ['clown car anim'], true);
				clownCar.scale.set(55, 55);
				clownCar.antialiasing = false;
				clownCar.visible = false;
				add(clownCar);

				//funnylayer0 ycbu bowser
				funnylayer0 = new BGSprite('characters/YouCannotBeatUS_Bowser_Asset', 600, 100, 1, 1, ['Left']);
				funnylayer0.animation.addByPrefix('idle', 'Idle', 24, false);
				funnylayer0.animation.addByPrefix('singUP', 'Up', 24, false);
				funnylayer0.animation.addByPrefix('singDOWN', 'Down', 24, false);
				funnylayer0.animation.addByPrefix('singLEFT', 'Left', 24, false);
				funnylayer0.animation.addByPrefix('singRIGHT', 'Right', 24, false);
				funnylayer0.antialiasing = ClientPrefs.globalAntialiasing;
				funnylayer0.animation.play('idle');

				starmanGF = new BGSprite('characters/YouCannotBeatUS_GF_Assets', 400, 250, 1, 1, ["GF Dancing Beat"], false);
				starmanGF.animation.addByIndices('danceRight', 'GF Dancing Beat', [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14], "", 24, false);
				starmanGF.animation.addByIndices('danceLeft', 'GF Dancing Beat', [15,16,17,18,19,20,21,22,23,24,25,28,29], "", 24, false);
				starmanGF.animation.addByPrefix('hey', 'GF Cheer', 24, false);
				starmanGF.antialiasing = ClientPrefs.globalAntialiasing;
				add(starmanGF);

				//ycbu mrsys icon finale
				iconLG = new FlxSprite().loadGraphic(Paths.image('icons/icon-sys'));
				iconLG.width = iconLG.width / 2;
				iconLG.loadGraphic(Paths.image('icons/icon-sys'), true, Math.floor(iconLG.width), Math.floor(iconLG.height));
				iconLG.animation.add("win", [0], 10, true);
				iconLG.animation.add("lose", [1], 10, true);
				iconLG.cameras = [camHUD];
				iconLG.visible = false;
				iconLG.antialiasing = ClientPrefs.globalAntialiasing;
				
				//ycbu bowser icon finale
				iconW4 = new FlxSprite().loadGraphic(Paths.image('icons/icon-hunt'));
				iconW4.width = iconW4.width / 2;
				iconW4.loadGraphic(Paths.image('icons/icon-hunt'), true, Math.floor(iconW4.width), Math.floor(iconW4.height));
				iconW4.animation.add("win", [0], 10, true);
				iconW4.animation.add("lose", [1], 10, true);
				iconW4.cameras = [camHUD];
				iconW4.antialiasing = ClientPrefs.globalAntialiasing;
				iconW4.visible = false;

				//ycbu duck hunt icon finale
				iconY0 = new FlxSprite().loadGraphic(Paths.image('icons/icon-bowser'));
				iconY0.width = iconY0.width / 2;
				iconY0.loadGraphic(Paths.image('icons/icon-bowser'), true, Math.floor(iconY0.width), Math.floor(iconY0.height));
				iconY0.animation.add("win", [0], 10, true);
				iconY0.animation.add("lose", [1], 10, true);
				iconY0.cameras = [camHUD];
				iconY0.antialiasing = ClientPrefs.globalAntialiasing;
				iconY0.visible = false;

				ycbuIconPos1 = new FlxPoint(0, 0);
				ycbuIconPos2 = new FlxPoint(-85, 50);
				ycbuIconPos3 = new FlxPoint(-85, -50);

				lofiTweensToBeCreepyTo(bg);
				nesTimers.push(new FlxTimer().start(21.5, function(timer:FlxTimer)
				{
					lofiTweensToBeCreepyTo(bg);
				}, 0));

			case 'forest':
				noCount = true;
				noHUD = true;

				addCharacterToList('peachtalk1', 1);
				addCharacterToList('peachtheG', 1);

				faropapu = new FlxSprite(-1200, -500, Paths.image('mario/Coronation/firstpart/FondoFondo'));
				faropapu.antialiasing = true;
				faropapu.scrollFactor.set(0.5, 0.5);
				faropapu.updateHitbox();
				add(faropapu);

				whiteThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				whiteThingie.setGraphicSize(Std.int(whiteThingie.width * 10));
				whiteThingie.alpha = 0;
				add(whiteThingie);

				trueno = new BGSprite('mario/Coronation/thirdpart/Coronation_Peach_misc_Assets', 180, -600, 0.7, 0.7, ['AAARayo'], false);
				trueno.animation.addByPrefix('rayo', 'AAARayo', 24, false);
				trueno.antialiasing = ClientPrefs.globalAntialiasing;
				trueno.visible = false;
				add(trueno);

				seaweed1 = new BGSprite('mario/Coronation/thirdpart/Coronation_Peach_misc_Assets', 520, -50, 1, 1, ['Leave0'], true);
				seaweed1.antialiasing = ClientPrefs.globalAntialiasing;
				seaweed1.visible = false;
				seaweed1.color = 0xFFB8837F;
				seaweed1.scale.set(1.2, 1.2);
				seaweed1.updateHitbox();
				add(seaweed1);

				seaweed2 = new BGSprite('mario/Coronation/thirdpart/Coronation_Peach_misc_Assets', 1420, -150, 1, 1, ['Leave0'], true);
				seaweed2.antialiasing = ClientPrefs.globalAntialiasing;
				seaweed2.visible = false;
				seaweed2.color = 0xFFB8837F;
				seaweed2.scale.set(1.2, 1.2);
				seaweed2.updateHitbox();
				add(seaweed2);

				lospapus = new FlxSprite(-1200, -500, Paths.image('mario/Coronation/firstpart/Arboles'));
				lospapus.antialiasing = true;
				lospapus.scrollFactor.set(1, 1);
				lospapus.updateHitbox();
				add(lospapus);

				atrasarboleda = new FlxSprite(-1200, -500, Paths.image('mario/Coronation/firstpart/AtrasArboles'));
				atrasarboleda.antialiasing = true;
				atrasarboleda.scrollFactor.set(1, 1);
				atrasarboleda.updateHitbox();
				add(atrasarboleda);

				aas = new FlxSprite(-1200, -500, Paths.image('mario/Coronation/firstpart/asdas'));
				aas.antialiasing = true;
				aas.scrollFactor.set(1, 1);
				aas.updateHitbox();
				add(aas);

				seaweed3 = new BGSprite('mario/Coronation/thirdpart/Coronation_Peach_misc_Assets', 820, 350, 1, 1, ['Leave0'], true);
				seaweed3.antialiasing = ClientPrefs.globalAntialiasing;
				seaweed3.visible = false;
				seaweed3.color = 0xFFB8837F;
				seaweed3.scale.set(1.2, 1.2);
				seaweed3.updateHitbox();
				add(seaweed3);

				sopapo = new FlxSprite(-1200, -500, Paths.image('mario/Coronation/firstpart/Stage'));
				sopapo.antialiasing = true;
				sopapo.scrollFactor.set(1, 1);
				sopapo.updateHitbox();
				add(sopapo);

				casa0 = new FlxSprite(-1200, casa + -2800, Paths.image('mario/Coronation/secondpart/BGforBG'));
				casa0.antialiasing = true;
				casa0.scrollFactor.set(0.5, 0.5);
				casa0.updateHitbox();
				casa0.visible = false;
				add(casa0);

				casa1 = new FlxSprite(-1200, casa + -4800, Paths.image('mario/Coronation/secondpart/TreeHouse'));
				casa1.antialiasing = true;
				casa1.scrollFactor.set(1, 1);
				casa1.updateHitbox();
				add(casa1);

				casa2 = new BGSprite('mario/Coronation/secondpart/CoroDay_DeadMario', 400, casa + -3600, 1, 1, ['DeadMario'], true);
				casa2.antialiasing = ClientPrefs.globalAntialiasing;
				casa2.animation.addByPrefix('idle', "DeadMario", 24, false);
				add(casa2);

				var nerve0:BGSprite = new BGSprite('mario/Coronation/secondpart/thenerve', -400, casa + -2500, 1, 1);
				nerve0.antialiasing = ClientPrefs.globalAntialiasing;
				add(nerve0);

				var nerve1:BGSprite = new BGSprite('mario/Coronation/secondpart/thenerve', 400, casa + -2500, 1, 1);
				nerve1.antialiasing = ClientPrefs.globalAntialiasing;
				add(nerve1);

				var nerve2:BGSprite = new BGSprite('mario/Coronation/secondpart/thenerve', 800, casa + -2500, 1, 1);
				nerve2.antialiasing = ClientPrefs.globalAntialiasing;
				add(nerve2);

				var nerve3:BGSprite = new BGSprite('mario/Coronation/secondpart/thenerve', 2400, casa + -2500, 1, 1);
				nerve3.antialiasing = ClientPrefs.globalAntialiasing;
				add(nerve3);

				var nerve4:BGSprite = new BGSprite('mario/Coronation/secondpart/thenerve', 0, casa + -2500, 1, 1);
				nerve0.antialiasing = ClientPrefs.globalAntialiasing;
				add(nerve0);

				var nerve5:BGSprite = new BGSprite('mario/Coronation/secondpart/thenerve', 600, casa + -2500, 1, 1);
				nerve1.antialiasing = ClientPrefs.globalAntialiasing;
				add(nerve1);

				eventTweens.push(FlxTween.tween(nerve0, {y: -5000}, 4.5, {type: LOOPING, loopDelay: 0.2}));
				eventTweens.push(FlxTween.tween(nerve1, {y: -5000}, 4, {type: LOOPING, loopDelay: 0.3}));
				eventTweens.push(FlxTween.tween(nerve2, {y: -5000}, 3, {type: LOOPING, loopDelay: 0.6}));
				eventTweens.push(FlxTween.tween(nerve3, {y: -5000}, 3, {type: LOOPING, loopDelay: 0.5}));
				eventTweens.push(FlxTween.tween(nerve4, {y: -5000}, 4, {type: LOOPING, loopDelay: 0.4}));
				eventTweens.push(FlxTween.tween(nerve5, {y: -5000}, 3, {type: LOOPING, loopDelay: 0.2}));

				eventTweens.push(FlxTween.tween(nerve0, {x: -450}, 0.4, {type: PINGPONG}));
				eventTweens.push(FlxTween.tween(nerve1, {x: 350}, 0.2, {type: PINGPONG}));
				eventTweens.push(FlxTween.tween(nerve2, {x: 850}, 0.3, {type: PINGPONG}));
				eventTweens.push(FlxTween.tween(nerve3, {x: 250}, 3.5, {type: PINGPONG}));
				eventTweens.push(FlxTween.tween(nerve4, {x: 50}, 0.3, {type: PINGPONG}));
				eventTweens.push(FlxTween.tween(nerve5, {x: 750}, 0.45, {type: PINGPONG}));

				s3 = new FlxSprite(-1200, casa + -4500, Paths.image('mario/Coronation/secondpart/TransitionTop'));
				s3.scrollFactor.set(1.3, 1.3);
				s3.updateHitbox();
				add(s3);

				s2 = new FlxSprite(-1200, casa + -2500, Paths.image('mario/Coronation/secondpart/TransitionBottom'));
				s2.scrollFactor.set(1.3, 1.3);
				s2.updateHitbox();
				add(s2);

				//glitches

				glitch0 = new BGSprite('mario/Coronation/thirdpart/Coronation_Peach_misc_Assets', 400, 200, 1.3, 1.3, ['glitch2'], true);
				glitch0.antialiasing = ClientPrefs.globalAntialiasing;
				glitch0.visible = false;
				glitch0.color = 0xFFB8837F;
				glitch0.scale.set(2, 2);
				glitch0.updateHitbox();

				glitch1 = new BGSprite('mario/Coronation/thirdpart/Coronation_Peach_misc_Assets', 1500, 400, 1, 1, ['glitch2'], false);
				glitch1.animation.addByPrefix('idle', 'glitch2', 16, true);
				glitch1.animation.play('idle');
				glitch1.antialiasing = ClientPrefs.globalAntialiasing;
				glitch1.visible = false;
				glitch1.color = 0xFFB8837F;
				glitch1.scale.set(4, 3);
				glitch1.updateHitbox();

				glitch2 = new BGSprite('mario/Coronation/thirdpart/Coronation_Peach_misc_Assets', -500, 600, 1.1, 1.1, ['glitchcausa'], false);
				glitch2.animation.addByPrefix('idle', 'glitchcausa', 20, true);
				glitch2.animation.play('idle');
				glitch2.antialiasing = ClientPrefs.globalAntialiasing;
				glitch2.visible = false;
				glitch2.color = 0xFFB8837F;
				glitch2.scale.set(2, 6);
				glitch2.updateHitbox();

				glitch3 = new BGSprite('mario/Coronation/thirdpart/Coronation_Peach_misc_Assets', -200, 1200, 1.2, 1.2, ['glitchcausa'], false);
				glitch3.animation.addByPrefix('idle', 'glitchcausa', 15, true);
				glitch3.animation.play('idle');
				glitch3.antialiasing = ClientPrefs.globalAntialiasing;
				glitch3.visible = false;
				glitch3.color = 0xFFB8837F;
				glitch3.scale.set(5, 3);
				glitch3.updateHitbox();

				cososuelo = new BGSprite('mario/Coronation/thirdpart/Coronation_Peach_misc_Assets', 1700, 400, 1, 1, ['har'], true);
				cososuelo.antialiasing = ClientPrefs.globalAntialiasing;
				cososuelo.visible = false;
				cososuelo.color = 0xFFB8837F;
				cososuelo.scale.set(2.5, 2.5);
				cososuelo.updateHitbox();

				//-700, 1500
				//-400 1000

				leaf0 = new BGSprite('mario/Coronation/thirdpart/Coronation_Peach_misc_Assets', 0, -700, 1.3, 1, ['Leavehar'], true);
				leaf0.antialiasing = ClientPrefs.globalAntialiasing;
				leaf0.visible = false;
				leaf0.scale.set(1.5, 1.5);
				leaf0.updateHitbox();

				leaf1 = new BGSprite('mario/Coronation/thirdpart/Coronation_Peach_misc_Assets', -400, -700, 1.3, 1, ['Leavehar'], true);
				leaf1.antialiasing = ClientPrefs.globalAntialiasing;
				leaf1.visible = false;
				leaf1.scale.set(1.5, 1.5);
				leaf1.updateHitbox();

				leaf2 = new BGSprite('mario/Coronation/thirdpart/Coronation_Peach_misc_Assets', 600, -700, 1.3, 1, ['Leavehar'], true);
				leaf2.antialiasing = ClientPrefs.globalAntialiasing;
				leaf2.visible = false;
				leaf2.scale.set(1.5, 1.5);
				leaf2.updateHitbox();

				eventTweens.push(FlxTween.tween(leaf0, {y: 1500, x: leaf0.x + 500}, 1.3, {type: LOOPING, loopDelay: 0.3}));
				eventTweens.push(FlxTween.tween(leaf1, {y: 1500, x: leaf1.x + 500}, 1, {type: LOOPING}));
				eventTweens.push(FlxTween.tween(leaf2, {y: 1500, x: leaf2.x + 500}, 1, {type: LOOPING, loopDelay: 0.6}));

				bola0 = new BGSprite('mario/Coronation/thirdpart/Coronation_Peach_misc_Assets', 1000, -700, 1.3, 1.3, ['bobol'], true);
				bola0.antialiasing = ClientPrefs.globalAntialiasing;
				bola0.visible = false;
				bola0.scale.set(1.5, 1.5);
				bola0.updateHitbox();

				bola1 = new BGSprite('mario/Coronation/thirdpart/Coronation_Peach_misc_Assets', 300, -700, 1.3, 1.3, ['bobol'], true);
				bola1.antialiasing = ClientPrefs.globalAntialiasing;
				bola1.visible = false;
				bola1.scale.set(1.5, 1.5);
				bola1.updateHitbox();


				eventTweens.push(FlxTween.tween(bola0, {x: 1100}, 0.5, {ease: FlxEase.quadInOut, type: PINGPONG}));
				eventTweens.push(FlxTween.tween(bola1, {x: 400}, 0.5, {ease: FlxEase.quadInOut, type: PINGPONG}));
				eventTweens.push(FlxTween.tween(bola0, {y: 1500}, 4, {type: LOOPING, loopDelay: 1}));
				eventTweens.push(FlxTween.tween(bola1, {y: 1500}, 4, {type: LOOPING, loopDelay: 0.6}));
				

				//seaweed.color = 0xFF595959;
				//seaweed2.color = 0xFF595959;
				//seaweed3.color = 0xFF595959;

				lluvia = new BGSprite('mario/LuigiBeta/old/Beta_Luigi_Rain_V1', -170, 50, ['RainLuigi'], true);
				lluvia.setGraphicSize(Std.int(lluvia.width * 1.7));
				lluvia.alpha = 0.6;
				lluvia.visible = false;
				lluvia.antialiasing = ClientPrefs.globalAntialiasing;
				lluvia.cameras = [camEst];
				add(lluvia);

				fogred = new FlxSprite().loadGraphic(Paths.image('modstuff/232'));
				fogred.antialiasing = ClientPrefs.globalAntialiasing;
				fogred.cameras = [camEst];
				fogred.alpha = 0;
				fogred.screenCenter();
				add(fogred);

				capenose = new BGSprite('characters/MM_IHY_Boyfriend_AssetsFINAL', 1130, 710, ['Capejajacomoelcharter'], false);
				capenose.animation.addByPrefix('idle', 'Capejajacomoelcharter', 24, true);
				capenose.animation.addByPrefix('miss', 'CapeFail', 24, false);
				capenose.antialiasing = ClientPrefs.globalAntialiasing;
				capenose.color = 0xFF93ADB5;
				add(capenose);

				fresco = new BGSprite('characters/Coronation_Peach_Dialogue2', 180, -740, ['Peach'], false);
				fresco.animation.addByPrefix('llevar', 'Peach', 24, false);
				fresco.antialiasing = ClientPrefs.globalAntialiasing;
				fresco.color = 0xFF93ADB5;
				fresco.alpha = 0.00001;

			case 'demiseport':
				noCount = true;
				flipchar = true;
				tvEffect = true;
				gfGroup.visible = false;
				health = 2;
				
				GameOverSubstate.characterName = 'bf_demisedeath';

				addCharacterToList('mx_demiseUG', 1);
				addCharacterToList('bf_demiseUG', 0);
				addCharacterToList('bf_demisedeath', 0);

				demColor = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
				demColor.setGraphicSize(Std.int(demColor.width * 10));
				demColor.scrollFactor.set(0, 0);
				demColor.color = FlxColor.BLACK;
				add(demColor);

				dembg = new FlxBackdrop(Paths.image('mario/MX/demise/1/Demise_BG_BG2'), X);
				dembg.scrollFactor.set(0.3, 0.3);
				dembg.velocity.set(100, 0);
				dembg.y -= 500;
				add(dembg);

				demLevel = new FlxBackdrop(Paths.image('mario/MX/demise/1/Demise_BG_BGCaca'), X);
				demLevel.scrollFactor.set(0.5, 0.5);
				demLevel.velocity.set(250, 0);
				demLevel.y -= 300;
				add(demLevel);

				floordemise = new BGSprite('mario/MX/demise/1/Demise_BG_suelo', -800, 300, ['Floor'], false);
				floordemise.animation.addByPrefix('idle', 'Floor', 60, true);
				floordemise.antialiasing = ClientPrefs.globalAntialiasing;
				floordemise.animation.play('idle');
				add(floordemise);

				demGround = new FlxBackdrop(Paths.image('mario/MX/demise/1/Demise_BG_BG1'), X, 800);
				demGround.scrollFactor.set(0.9, 0.9);
				demGround.velocity.set(3200, 0);
				demGround.y -= 70;
				add(demGround);








				underdembg = new FlxBackdrop(Paths.image('mario/MX/demise/2/Demise_BG2_Mountains.png'), X);
				underdembg.scrollFactor.set(0.3, 0.3);
				underdembg.velocity.set(100, 0);
				underdembg.y -= 500;
				add(underdembg);

				underdemLevel = new FlxBackdrop(Paths.image('mario/MX/demise/2/Demise_BG2_BGLower.png'), X);
				underdemLevel.scrollFactor.set(0.5, 0.5);
				underdemLevel.velocity.set(250, 0);
				underdemLevel.y -= 1400;
				add(underdemLevel);

				underdemGround1 = new FlxBackdrop(Paths.image('mario/MX/demise/2/Demise_BG2_BG1'), X, 6000);
				underdemGround1.scrollFactor.set(0.9, 0.9);
				underdemGround1.velocity.set(3200, 0);
				underdemGround1.y -= 800;
				add(underdemGround1);

				underdemGround2 = new FlxBackdrop(Paths.image('mario/MX/demise/2/Demise_BG2_BG2'), X, 4000);
				underdemGround2.scrollFactor.set(0.9, 0.9);
				underdemGround2.velocity.set(3200, 0);
				underdemGround2.y -= 800;
				add(underdemGround2);

				underfloordemise = new BGSprite('mario/MX/demise/2/Demise_BG2_suelo', -800, 300, ['Floor'], false);
				underfloordemise.animation.addByPrefix('idle', 'Floor', 60, true);
				underfloordemise.antialiasing = ClientPrefs.globalAntialiasing;
				underfloordemise.animation.play('idle');
				add(underfloordemise);

				underroofdemise = new BGSprite('mario/MX/demise/2/Demise_BG2_techo', -800, -1050, ['Celling'], false);
				underroofdemise.animation.addByPrefix('idle', 'Celling', 60, true);
				underroofdemise.antialiasing = ClientPrefs.globalAntialiasing;
				underroofdemise.animation.play('idle');
				add(underroofdemise);
 
				whenyourered = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFD10000);
				whenyourered.setGraphicSize(Std.int(whenyourered.width * 10));
				whenyourered.alpha = 0;
				add(whenyourered);

				demcut1 = new BGSprite('mario/MX/demise/cutscene/DemiseBF_Cutscene3', -1100, -250, ['Bodies'], false);
				demcut1.animation.addByPrefix('idle', 'Bodies', 21, false);
				demcut1.antialiasing = ClientPrefs.globalAntialiasing;
				//demcut1.animation.play('idle');
				add(demcut1);

				demcut2 = new BGSprite('mario/MX/demise/cutscene/DemiseBF_Cutscene2', demcut1.x + 650, demcut1.y, ['Bodies'], false);
				demcut2.animation.addByPrefix('idle', 'Bodies', 21, false);
				demcut2.antialiasing = ClientPrefs.globalAntialiasing;
				add(demcut2);

				demcut3 = new BGSprite('mario/MX/demise/cutscene/DemiseBF_Cutscene1', demcut1.x + 1100, demcut1.y + 370, ['BFheadcutscene'], true);
				demcut3.animation.addByPrefix('idle', 'BFheadcutscene', 21, false);
				demcut3.antialiasing = ClientPrefs.globalAntialiasing;
				add(demcut3);

				demcut4 = new BGSprite('mario/MX/demise/cutscene/DemiseBF_Cutscene4', demcut1.x + 270, demcut1.y + 30, ['GFHeadcutscene'], false);
				demcut4.animation.addByPrefix('idle', 'GFHeadcutscene', 21, false);
				demcut4.antialiasing = ClientPrefs.globalAntialiasing;
				add(demcut4);

				demcut1.alpha = 0.000001;
				demcut2.alpha = 0.000001;
				demcut3.alpha = 0.000001;
				demcut4.alpha = 0.000001;

				gordobondiola = new BGSprite('mario/MX/demise/cutscene/MXJump', 2200, -2900);
				gordobondiola.antialiasing = ClientPrefs.globalAntialiasing;
				add(gordobondiola);
				


				//underborderdemise = new BGSprite('mario/MX/demise/2/Demise_skyline_RockBorder', -800, -1050);
				//underborderdemise.antialiasing = ClientPrefs.globalAntialiasing;
				//add(underborderdemise);
				//underborderdemise.visible = false;

				
				underdembg.visible = false;
				underdemLevel.visible = false;
				underdemGround1.visible = false;
				underdemGround2.visible = false;
				underfloordemise.visible = false;
				underroofdemise.visible = false;

				demFore1 = new BGSprite('mario/MX/demise/1/Demise_BG_Foreground1', -3800, 300);
				demFore1.scrollFactor.set(1.3, 1.3);
				demFore2 = new BGSprite('mario/MX/demise/1/Demise_BG_Foreground2', -3800, 300);
				demFore2.scrollFactor.set(1.3, 1.3);
				demFore3 = new BGSprite('mario/MX/demise/1/Demise_BG_Foreground3', -1800, -1200);
				demFore3.scrollFactor.set(1.3, 1.3);
				demFore4 = new BGSprite('mario/MX/demise/1/Demise_BG_Foreground4', -3800, 300);
				demFore4.scrollFactor.set(1.3, 1.3);

				underdemFore1 = new BGSprite('mario/MX/demise/2/Demise_BG2_Foreground1', -3800, 300);
				underdemFore1.scrollFactor.set(1.3, 1.3);
				underdemFore2 = new BGSprite('mario/MX/demise/2/Demise_BG2_Foreground2', -3800, 300);
				underdemFore2.scrollFactor.set(1.3, 1.3);

				demisetran = new BGSprite('mario/MX/demise/1/transition', -1600, 0);
				demisetran.cameras = [camEst];
				demisetran.scale.set(3, 1);
				add(demisetran);

				startFore(1);

			case 'realbg':
				noCount = true;
				noHUD = true;
				specialGameOver = true;

				//bubbleEmitter = new FlxTypedEmitter<BubbleParticle>(200, 2250);
				//bubbleEmitter.particleClass = BubbleParticle;
				//bubbleEmitter.launchMode = FlxEmitterMode.SQUARE;
				//bubbleEmitter.width = FlxG.width;
				//bubbleEmitter.velocity.set(0, -500);
				//bubbleEmitter.alpha.set(1, 0);
				//add(bubbleEmitter);
				//bubbleEmitter.start(false, 1.2);

				var skybox:BGSprite = new BGSprite('mario/lisfalse/Skybox', -400, -150, 1.1, 1.1);
				add(skybox);

				var water:BGSprite = new BGSprite('mario/lisfalse/Water', -400, -150, 1, 1);
				add(water);

				eel = new BGSprite('mario/lisfalse/Shaded_Mario_64_Eel', -8500, 900, 0.8, 0.8);
				add(eel);

				var encima:BGSprite = new BGSprite('mario/lisfalse/Encima', -400, -150, 1, 1);
				add(encima);

				aguaEstrella = new BGSprite('mario/lisfalse/AguaEstrella', -400, -150, 1, 1);

				foreground2 = new BGSprite('mario/lisfalse/Foreground2', -400, -150, 1, 1);
				foreground1 = new BGSprite('mario/lisfalse/Foreground',  -400, -150, 1, 1);




				var fogblack:FlxSprite = new FlxSprite().loadGraphic(Paths.image('modstuff/126'));
				fogblack.antialiasing = ClientPrefs.globalAntialiasing;
				fogblack.cameras = [camEst];
				fogblack.alpha = 1;
				fogblack.screenCenter();
				add(fogblack);

				lifemetter = new BGSprite('mario/lisfalse/health', 25, 40, ['health 0'], false);
				lifemetter.animation.addByPrefix('life0', 'health 0', 24, true);
				lifemetter.animation.addByPrefix('life1', 'health 1', 24, true);
				lifemetter.animation.addByPrefix('life2', 'health 2', 24, true);
				lifemetter.animation.addByPrefix('life3', 'health 3', 24, true);
				lifemetter.animation.addByPrefix('life4', 'health 4', 24, true);
				lifemetter.animation.addByPrefix('life5', 'health 5', 24, true);
				lifemetter.animation.addByPrefix('life6', 'health 6', 24, true);
				lifemetter.animation.addByPrefix('life7', 'health 7', 24, true);
				lifemetter.animation.addByPrefix('life8', 'health 8', 24, true);
				lifemetter.cameras = [camHUD];
				lifemetter.alpha = 0;
				lifemetter.setGraphicSize(Std.int(lifemetter.width * 2.2));
				lifemetter.updateHitbox();
				lifemetter.screenCenter(X);
				add(lifemetter);

				FlxG.watch.addQuick('life', luigilife);

			case 'secretbg':
				noCount = true;
				noHUD = true;
				GameOverSubstate.deathSoundName = 'goodbye_old_friend_sh_mario';
				GameOverSubstate.characterName = 'bfsecretgameover';
				addCharacterToList('bfsecretgameover', 0);

				var floorField:BGSprite = new BGSprite('mario/secret/WallAndFloor', -1300, -600, 1, 1);
				floorField.setGraphicSize(Std.int(floorField.width * 0.85));

				var backTrees:BGSprite = new BGSprite('mario/secret/BackTrees', -1300, -600, 0.8, 0.8);
				backTrees.setGraphicSize(Std.int(backTrees.width * 0.85));

				var skyBox:BGSprite = new BGSprite('mario/secret/SkyBox', -1300, -600, 0.4, 0.4);
				skyBox.setGraphicSize(Std.int(skyBox.width * 0.85));

				add(skyBox);
				add(backTrees);
				add(floorField);

				addCharacterToList('secretmario', 1);

				explosionBOM = new BGSprite('mario/secret/SECRETEXPLOSION', 250, -290, 1, 1, ['1'], false);
				explosionBOM.animation.addByPrefix('BOOM', '1', 35, false);
				explosionBOM.alpha = 0;
				explosionBOM.setGraphicSize(Std.int(explosionBOM.width * 1.5));
				explosionBOM.updateHitbox();

				secretWarning = new BGSprite('mario/secret/BulletBill_Warning', 0, 0, 1, 1, ['warning'], true);
				secretWarning.animation.addByPrefix('loop', 'warning', 24, true);
				secretWarning.animation.addByPrefix('bye', 'blow away', 24, false);
				secretWarning.animation.play('loop');
				secretWarning.cameras = [camHUD];
				secretWarning.screenCenter();
				secretWarning.x += 200;
				secretWarning.visible = false;

				frontTrees = new BGSprite('mario/secret/BushesForeground', -1300, -700, 1.4, 1.4);

			case 'turmoilsweep':
				GameOverSubstate.characterName = 'bf-goomba';
				// GameOverSubstate.loopSoundName = '';
				GameOverSubstate.deathSoundName = 'turmoil_death1';
				gfGroup.visible = false;
				noCount = true;
				noHUD = true;

				var fartree:BGSprite = new BGSprite('mario/Turmoil/ThirdBGTrees', -1300, -750, 0.5, 0.5);
				add(fartree);

				var backtree:BGSprite = new BGSprite('mario/Turmoil/SecondBGTrees', -1300, -750, 0.8, 0.8);
				add(backtree);

				var floor:BGSprite = new BGSprite('mario/Turmoil/MainFloorAndTrees', -1300, -750, 1, 1);
				add(floor);

				var lashojas:BGSprite = new BGSprite('mario/Turmoil/TreeLeaves', -1300, -350, 1.9, 1.9);
				add(lashojas);

				var ramasnose:BGSprite = new BGSprite('mario/Turmoil/TreesForeground', -1300, -350, 1.4, 1.4);
				add(ramasnose);

				warning = new BGSprite('mario/Turmoil/Turmoil_HARHARHARHAR', -1300, -350, 1.4, 1.4);
				warning.cameras = [camEst];
				warning.alpha = 0;
				warning.screenCenter();
				add(warning);

				buttonxml = new BGSprite('mario/Turmoil/button', 30, 550, 1, 1, ['button no press'], false);
				buttonxml.animation.addByPrefix('nopress', 'button no press', 12, false);
				buttonxml.animation.addByPrefix('press', 'button press', 12, false);
				buttonxml.cameras = [camEst];
				// buttonxml.alpha = 0;
				buttonxml.scale.set(0.25, 0.25);
				buttonxml.updateHitbox();

				var fogblack:FlxSprite = new FlxSprite().loadGraphic(Paths.image('modstuff/126'));
				fogblack.antialiasing = ClientPrefs.globalAntialiasing;
				fogblack.cameras = [camEst];
				fogblack.alpha = 1;
				fogblack.screenCenter();
				add(fogblack);

				add(buttonxml);

			case 'castlestar':
				GameOverSubstate.deathSoundName = 'POWERSTARDEATH';
				GameOverSubstate.loopSoundName = 'POWERSTARDEATH_LOOP_60BPM';
				GameOverSubstate.endSoundName = 'POWERSTARDEATH_RETRY';
				GameOverSubstate.characterName = 'bfPowerdeath';
				GameOverSubstate.hasVA = true;
				GameOverSubstate.vaCount = 4;

				noCount = true;
				noHUD = true;
				gfGroup.visible = false;

				addCharacterToList('devilmariotalk', 1);
				addCharacterToList('bfPowerdeath', 1);
				var thex:Float = -900;
				var they:Float = -930;

				var bg:BGSprite = new BGSprite('mario/star/Cielo', thex, they, 0.1, 0.1);
				//bg.scale.set(1.15, 1.15);
				add(bg);

				var castle2:BGSprite = new BGSprite('mario/star/castillos traseros', thex - 200, they, 0.1, 0.1);
				//castle4.scale.set(1.15, 1.15);
				add(castle2);

				var castle2:BGSprite = new BGSprite('mario/star/castillos medio', thex - 200, they, 0.25, 0.25);
				//castle4.scale.set(1.15, 1.15);
				add(castle2);

				var castle1:BGSprite = new BGSprite('mario/star/castillos delanteros', thex - 200, they, 0.4, 0.4);
				//castle3.scale.set(1.15, 1.15);
				add(castle1);

				var floor:BGSprite = new BGSprite('mario/star/pUENTE', thex, they, 1, 1);
				//floor.scale.set(1.15, 1.15);
				add(floor);

				var charStar0:BGSprite = new BGSprite('mario/star/Powerstar_Mario_BG_Assets', -850, 650, 1, 1, ['Luigi'], true);
				add(charStar0);

				var charStar1:BGSprite = new BGSprite('mario/star/Powerstar_Mario_BG_Assets', 1600, 600, 1, 1, ['Peach'], true);
				add(charStar1);

				marioattack = new BGSprite('mario/star/Powerstar_Mario_v2_AssetsFINAL1', 1600, 600, 1, 1, ['AttackPrev'], false);
				marioattack.animation.addByPrefix('prevAttack', 'AttackPrev', 16, false);
				marioattack.animation.addByPrefix('Attack', 'AttackFinal', 24, false);
				add(marioattack);

				var blackthing = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackthing.setGraphicSize(Std.int(blackthing.width * 10));
				blackthing.cameras = [camEst];
				add(blackthing);

				eventTweens.push(FlxTween.tween(blackthing, {alpha: 0}, 2, {startDelay: 1}));

				powervitte = new FlxSprite().loadGraphic(Paths.image('modstuff/126'));
				powervitte.antialiasing = ClientPrefs.globalAntialiasing;
				powervitte.cameras = [camEst];
				powervitte.alpha = 0.000001;
				powervitte.screenCenter();
				add(powervitte);

				powerWarning = new FlxSprite().loadGraphic(Paths.image('mario/star/warning'));
				powerWarning.antialiasing = ClientPrefs.globalAntialiasing;
				powerWarning.cameras = [camEst];
				powerWarning.screenCenter();
				powerWarning.visible = false;
				add(powerWarning);

			case 'meatworld':
				gfGroup.alpha = 0.00000001;

				GameOverSubstate.deathSoundName = 'TOOPOOP_LUIGI';
				GameOverSubstate.characterName = 'picodeath';
				GameOverSubstate.loopSoundName = 'overdueGameover';
				addCharacterToList('picodeath', 0);
				addCharacterToList('picodiag', 0);
				addCharacterToList('pico_run', 0);

				castleFloor = new BGSprite('mario/TooLateBG/feet/Overdue_Final_BG_floorfixed', -1500, 650, 1, 1, ['Floor']);
				castleFloor.animation.addByPrefix('idle', "Floor", 24, false);
				castleFloor.animation.addByPrefix('loop', "Floor", 24, true);
				castleFloor.animation.play('idle');
				castleFloor.alpha = 0;
				add(castleFloor);

				castleCeiling = new BGSprite('mario/TooLateBG/feet/Overdue_Final_BG_topfixed', -1500, -1100, 1, 1, ['Top']);
				castleCeiling.animation.addByPrefix('idle', "Top", 24, false);
				castleCeiling.animation.addByPrefix('loop', "Top", 24, true);
				castleCeiling.animation.play('idle');
				castleCeiling.alpha = 0;
				add(castleCeiling);

				streetGroup = new FlxTypedGroup<BGSprite>();

				var street1 = new BGSprite('mario/TooLateBG/street/BackTrees', -1400, -550, 0.95, 0.95);
				streetGroup.add(street1);

				var street2 = new BGSprite('mario/TooLateBG/street/Front Trees', -1400, -550, 1.05, 1.05);
				streetGroup.add(street2);

				var street3 = new BGSprite('mario/TooLateBG/street/Road', -1400, -550, 1, 1);
				streetGroup.add(street3);

				var street4 = new BGSprite('mario/TooLateBG/street/car', -1400, -550, 1, 1);
				streetGroup.add(street4);

				add(streetGroup);

				streetFore = new BGSprite('mario/TooLateBG/street/Foreground Trees', -1600, -550, 1.2, 1);

				meatworldGroup = new FlxTypedGroup<BGSprite>();

				var meat1 = new BGSprite('mario/TooLateBG/meat/TL_Meat_Sky', -2350, -1350, 0.2, 0.2);
				meat1.ID = 0;
				meat1.scale.set(4, 4);
				meat1.setPosition(meat1.x + (meat1.width / 4), meat1.y + (meat1.height / 4));
				meatworldGroup.add(meat1);

				var meat2 = new BGSprite('mario/TooLateBG/meat/TL_Meat_FarBG', -2350, -1350, 0.4, 0.4);
				meat2.ID = 0;
				meat2.scale.set(2, 2);
				meat2.setPosition(meat2.x + (meat2.width / 2), meat2.y + (meat2.height / 2));
				meatworldGroup.add(meat2);

				var meat3 = new BGSprite('mario/TooLateBG/meat/TL_Meat_MedBG', -2350, -1350, 0.6, 0.6);
				meat3.ID = 0;
				meat3.scale.set(2, 2);
				meat3.setPosition(meat3.x + (meat3.width / 2), meat3.y + (meat3.height / 2));
				meatworldGroup.add(meat3);

				var meat4 = new BGSprite('mario/TooLateBG/meat/TL_Meat_BG', -2350, -1350, 0.8, 0.8);
				meat4.ID = 0;
				meat4.scale.set(2, 2);
				meat4.setPosition(meat4.x + (meat4.width / 2), meat4.y + (meat4.height / 2));
				meatworldGroup.add(meat4);

				var meat5 = new BGSprite('mario/TooLateBG/meat/TL_Meat_Ground', -2350, -1350, 1, 1);
				meat5.ID = 0;
				meat5.scale.set(2, 2);
				meat5.setPosition(meat5.x + (meat5.width / 2), meat5.y + (meat5.height / 2));
				meatworldGroup.add(meat5);

				var meat6 = new BGSprite('mario/TooLateBG/meat/TL_Meat_Pupil', 530, -100, 1, 1);
				meat6.ID = 1;
				meatworldGroup.add(meat6);

				add(meatworldGroup);
				meatworldGroup.visible = false;

				meatForeGroup = new FlxTypedGroup<BGSprite>();

				var meat1 = new BGSprite('mario/TooLateBG/meat/TL_Meat_FG_string', -2350 + 3660, -1350 + 395, 1.15, 1.15);
				meat1.ID = 0;
				meat1.scale.set(2, 2);
				meat1.setPosition(meat1.x + (meat1.width / 2), meat1.y + (meat1.height / 2));
				meatForeGroup.add(meat1);

				var meat2 = new BGSprite('mario/TooLateBG/meat/TL_Meat_FG_bottomteeth', -2350 + 1245, -1350 + 1969 + 750, 1.15, 1.15);
				meat2.ID = 1;
				meat2.scale.set(2, 2);
				meat2.setPosition(meat2.x + (meat2.width / 2), meat2.y + (meat2.height / 2));
				meatForeGroup.add(meat2);

				var meat3 = new BGSprite('mario/TooLateBG/meat/TL_Meat_FG_topteeth', -2350 + 879, -1350, 1.15, 1.15);
				meat3.ID = 0;
				meatForeGroup.add(meat3);

				var meat4 = new BGSprite('mario/TooLateBG/meat/TL_Meat_FG_topteeth2', -2350 + 921, -1350 + 411 - 1300, 1.15, 1.15);
				meat4.ID = 2;
				meatForeGroup.add(meat4);

				var meat5 = new BGSprite('mario/TooLateBG/meat/TL_Meat_CloseFG', -2280, -1350 - 50, 1.35, 1.35);
				meat5.ID = 0;
				meat5.scale.set(2, 2);
				meat5.setPosition(meat5.x + (meat5.width / 2), meat5.y + (meat5.height / 2));
				meatForeGroup.add(meat5);

				meatworldGroup.forEach(function(meat:BGSprite)
					{
						meat.alpha = 0;
					});

				meatForeGroup.forEach(function(meat:BGSprite)
					{
						meat.alpha = 0;
					});

				meatForeGroup.visible = false;

				gunShotPico = new BGSprite('characters/Too_Late_Pico_ass_sets_v2', boyfriendGroup.x - 290, boyfriendGroup.y + 195, 1, 1, ['PicoShoot']);
				gunShotPico.animation.addByPrefix('Shoot', 'PicoShoot', 40, false);
				gunShotPico.alpha = 0.0001;
				add(gunShotPico);

				var fogblack:FlxSprite = new FlxSprite().loadGraphic(Paths.image('modstuff/126'));
				fogblack.antialiasing = ClientPrefs.globalAntialiasing;
				fogblack.cameras = [camEst];
				fogblack.alpha = 1;
				fogblack.screenCenter();
				add(fogblack);

				meatfog = new BGSprite('mario/TooLateBG/meat/TL_Meat_Fog', 0, 0, 0, 0);
				meatfog.antialiasing = ClientPrefs.globalAntialiasing;
				meatfog.cameras = [camEst];
				meatfog.alpha = 0;
				meatfog.screenCenter();
				add(meatfog);

				hallTLL1 = new FlxBackdrop(X, -1170);
				hallTLL1.frames = Paths.getSparrowAtlas('Too_Late_Luigi_Hallway');
				hallTLL1.animation.addByPrefix('idle', "tll idle",   24, false);
				hallTLL1.animation.addByPrefix('singUP', "tll up", 	 24, false);
				hallTLL1.animation.addByPrefix('singDOWN', "tll down",   24, false);
				hallTLL1.animation.addByPrefix('singLEFT', "tll left",   24, false);
				hallTLL1.animation.addByPrefix('singRIGHT', "tll right", 24, false);
				hallTLL1.animation.play('idle', true);
				hallTLL1.updateHitbox();
				hallTLL1.antialiasing = true;
				hallTLL1.velocity.set(-2800, 0);
				hallTLL1.alpha = 0.000001;


				hallTLL2 = new FlxBackdrop(X, -1170);
				hallTLL2.frames = Paths.getSparrowAtlas('Too_Late_Luigi_Hallway');
				hallTLL2.animation.addByPrefix('idle', "tll idle",   24, false);
				hallTLL2.scale.set(0.8, 0.8);
				hallTLL2.updateHitbox();
				hallTLL2.antialiasing = true;
				hallTLL2.velocity.set(-2240, 0);
				// hallTLL2.brightness = 0.8;
				hallTLL2.alpha = 0.000001;
				hallTLL2.color = 0xFF979797;

				hallTLL3 = new FlxBackdrop(X, -1170);
				hallTLL3.frames = Paths.getSparrowAtlas('Too_Late_Luigi_Hallway');
				hallTLL3.animation.addByPrefix('idle', "tll idle",   24, false);
				hallTLL3.scale.set(0.6, 0.6);
				hallTLL3.updateHitbox();
				hallTLL3.antialiasing = true;
				hallTLL3.velocity.set(-1680, 0);
				// hallTLL3.brightness = 0.6;
				hallTLL3.alpha = 0.000001;
				hallTLL3.color = 0xFF696969;
				add(hallTLL3);
				add(hallTLL2);
				add(hallTLL1);

				fgTLL = new FlxBackdrop(Paths.image('mario/TooLateBG/feet/FG_Too_Late_Luigi'), X, 1545);
				fgTLL.updateHitbox();
				fgTLL.antialiasing = true;
				fgTLL.velocity.set(-3920, 0);

				fgTLL.alpha = 0.000001;

				blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
				blackBarThingie.scrollFactor.set(0, 0);
				blackBarThingie.cameras = [camEst];
				blackBarThingie.alpha = 0.000001;
				add(blackBarThingie);

				gunAmmo = new BGSprite('mario/TooLateBG/street/Bullet Ammo', 50, 850, 1, 1, ['Bullet Ammo 3']);
				gunAmmo.animation.addByPrefix('Bullet 3', 'Bullet Ammo 3', 5, false);
				gunAmmo.animation.addByPrefix('Bullet 2', 'Bullet Ammo 2', 5, false);
				gunAmmo.animation.addByPrefix('Bullet 1', 'Bullet Ammo 1', 5, false);
				gunAmmo.animation.addByPrefix('Bullet 0', 'Bullet Ammo 0', 5, false);
				gunAmmo.antialiasing = ClientPrefs.globalAntialiasing;
				gunAmmo.cameras = [camEst];
				gunAmmo.scale.set(0.65, 0.65);
				gunAmmo.updateHitbox();
				gunAmmo.alpha = 0.8;
				add(gunAmmo);

				if (PlayState.SONG.song == 'Overdue Old'){
					gunAmmo.alpha = 0.2;
					gunAmmo.y = 450;
				}

				iconGF = new FlxSprite().loadGraphic(Paths.image('icons/icon-LG'));
				iconGF.width = iconGF.width / 2;
				iconGF.loadGraphic(Paths.image('icons/icon-latemario'), true, Math.floor(iconGF.width), Math.floor(iconGF.height));
				iconGF.animation.add("win", [0], 10, true);
				iconGF.animation.add("lose", [1], 10, true);
				iconGF.cameras = [camHUD];
				iconGF.alpha = 0;
				iconGF.antialiasing = ClientPrefs.globalAntialiasing;
				iconGF.flipX = true;

			case 'endstage':
				gfGroup.visible = false;
				noCount = true;
				noHUD = true;
				tvEffect = true;
				oldTV = true;

				addCharacterToList('costumedark', 1);

				bg = new BGSprite('mario/costume/PedacitoDeGris', -1200, -770, 0.5, 1);
				add(bg);

				floor= new BGSprite('mario/costume/Floor and Courtains', -1200, -770, 1, 1);
				add(floor);

				mesa = new BGSprite('mario/costume/mesa mesa mesa que mas aplauda', -1200, -770, 1, 1);
				add(mesa);

				letsago = new BGSprite('mario/costume/Costume_Letsago', 0, 0, 1, 1, ['Lets A Go']);
				letsago.animation.addByPrefix('go', 'Lets A Go', 24, false);
				letsago.cameras = [camEst];
				letsago.alpha = 0;
				add(letsago);

				castle0 = new BGSprite('mario/costume/Foreground', -1400, -300, 1.4, 1.4);

				//funnylayer0 the end
				funnylayer0 = new BGSprite('mario/costume/Lamp', -1200, -770, 1, 1);

				blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
				blackBarThingie.alpha = 1;

				elfin = new BGSprite('mario/costume/end', 0, 0);
				elfin.setGraphicSize(1280);
				elfin.updateHitbox();
				elfin.screenCenter();
				elfin.antialiasing = ClientPrefs.globalAntialiasing;
				// elfin.cameras = [camGame];
				elfin.alpha = 0;

				linefount = new BGSprite('mario/costume/endtext', 0, 0, 1, 1);
				linefount.screenCenter();
				linefount.antialiasing = ClientPrefs.globalAntialiasing;
				linefount.cameras = [camEst];
				linefount.visible = false;
				

			case 'allfinal':
				GameOverSubstate.characterName = 'bfASdeath';
				GameOverSubstate.hasVA = true;
				GameOverSubstate.vaCount = 12;
				noCount = true;

				addCharacterToList('omega', 1);
				addCharacterToList('w4r', 2);
				addCharacterToList('lg2', 1);
				addCharacterToList('bf_behind', 0);
				addCharacterToList('bfASsad', 0);
				addCharacterToList('gx', 1);
				addCharacterToList('bf_ultrafinale', 0);
				addCharacterToList('bf_ultrafinale2', 0);
				addCharacterToList('mario_ultra2', 1);
				addCharacterToList('bf_ultrafinale3', 0);
				addCharacterToList('mario_ultra3', 1);
				addCharacterToList('bfASdeath', 0);
				addCharacterToList('gfASdeath', 0);

				BF_CAM_EXTEND = 30;

				//act 1 stage

				act1BGGroup = new FlxTypedGroup<BGSprite>();
				add(act1BGGroup);

				act1Stat = new BGSprite('mario/allfinal/act1/act1_stat', -900, -860, 0.4, 0.4, ['act1_static']);
				act1Stat.animation.addByPrefix('idle', 'act1_static', 24, true);
				act1Stat.animation.play('idle');
				act1Stat.scale.set(4, 4);
				act1BGGroup.add(act1Stat);

				act1Sky = new BGSprite('mario/allfinal/act1/act1_sky', -1850, -660, 0.6, 0.6);
				act1BGGroup.add(act1Sky);

				act1Skyline = new BGSprite('mario/allfinal/act1/act1_skyline', -2100, -660, 0.8, 0.8);
				act1BGGroup.add(act1Skyline);

				act1Buildings = new BGSprite('mario/allfinal/act1/act1_bgbuildings', -2100, -660, 0.8, 0.8);
				act1BGGroup.add(act1Buildings);

				act1Floor = new BGSprite('mario/allfinal/act1/act1_floor', -2300, -660, 1, 1);
				act1BGGroup.add(act1Floor);

				act1Fog = new BGSprite('mario/allfinal/act1/act1', 0, 0, 1, 1);
				act1Fog.cameras = [camOther];
				act1Fog.visible = false;
				act1BGGroup.add(act1Fog);

				act1FG = new BGSprite('mario/allfinal/act1/act1_fg', -2530, -850, 1.7, 1.7);
			
				act1Gradient = new BGSprite('mario/allfinal/act1/act1_gradient', -2300, -910, 1, 1);

				//act 2 stage

				act2BGGroup = new FlxTypedGroup<BGSprite>();

				act2Stat = new BGSprite('mario/allfinal/act2/act2_static', -70, -360, 0.2, 0.2, ['act2Stat']);
				act2Stat.animation.addByPrefix('idle', 'act2stat', 24, true);
				act2Stat.animation.play('idle');
				act2Stat.scale.set(1.75, 1.75);
				add(act2Stat);

				act2WhiteFlash = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
				act2WhiteFlash.setGraphicSize(Std.int(act2Stat.width * 10));
				act2WhiteFlash.alpha = 0;
				add(act2WhiteFlash);

				act2Sky = new FlxBackdrop(Paths.image('mario/allfinal/act2/act2_scroll1'), X);
				act2Sky.scrollFactor.set(0.3, 0.3);
				act2Sky.velocity.set(100, 0);
				act2Sky.y = -300;
				act2Sky.x = -500;
				act2Sky.visible = false;
				add(act2Sky);

				add(act2BGGroup);

				act2PipesFar = new BGSprite('mario/allfinal/act2/act2_pipes_far', -500, -270, 0.6, 0.6);
				act2BGGroup.add(act2PipesFar);

				act2Gradient = new BGSprite('mario/allfinal/act2/act2_abyss_gradient', -500, -425, 0.6, 0.6);
				act2BGGroup.add(act2Gradient);

				act2PipesMiddle = new BGSprite('mario/allfinal/act2/act2_pipes_middle', -500, -300, 0.7, 0.7);
				act2BGGroup.add(act2PipesMiddle);

				act2PipesClose = new BGSprite('mario/allfinal/act2/act2_pipes_close', -500, -320, 0.8, 0.8);
				act2BGGroup.add(act2PipesClose);
				//LG Pipe
				act2LPipe = new BGSprite('mario/allfinal/act2/act2_pipes_lgbf', -600, -360 + 800, 0.9, 0.9);
				act2BGGroup.add(act2LPipe);
				//w4r pipe
				act2WPipe = new BGSprite('mario/allfinal/act2/act2_pipes_waryosh', -740, -260 + 800, 0.95, 0.95);
				act2BGGroup.add(act2WPipe);
				//y0sh pipe
				act2YPipe = new BGSprite('mario/allfinal/act2/act2_pipes_waryosh', -460, -260 + 800, 0.95, 0.95);
				act2YPipe.flipX = true;
				act2BGGroup.add(act2YPipe);

				//funnylayer0 y0sh
				funnylayer0 = new BGSprite('characters/yoshi', 850, 1000, 0.9, 0.9, ['yoshi left']);
				funnylayer0.animation.addByPrefix('idle', 'yoshi idle', 24, false);
				funnylayer0.animation.addByPrefix('singUP', 'YOSHI UP', 24, false);
				funnylayer0.animation.addByPrefix('singDOWN', 'yoshi down', 24, false);
				funnylayer0.animation.addByPrefix('singLEFT', 'yoshi left', 24, false);
				funnylayer0.animation.addByPrefix('singRIGHT', 'yoshi right', 24, false);
				funnylayer0.antialiasing = ClientPrefs.globalAntialiasing;
				add(funnylayer0);

				//bf pipe
				act2BFPipe = new BGSprite('mario/allfinal/act2/act2_pipes_lgbf', -630, -80, 1, 1);
				act2BFPipe.scale.set(1.2, 1.2);
				add(act2BFPipe);

				act2Fog = new BGSprite('mario/allfinal/act2/act2', 0, 0, 1, 1);
				act2Fog.cameras = [camOther];
				act2BGGroup.add(act2Fog);

				act2IntroGF = new BGSprite('mario/allfinal/act1/Act_2_Intro', 0, 330, 0.2, 0.2, ['act2Stat']);
				act2IntroGF.animation.addByPrefix('idle', 'Anim1', 24, true);
				act2IntroGF.cameras = [camOther];
				act2IntroGF.scale.set(2, 2);
				act2IntroGF.visible = false;
				act2IntroGF.screenCenter(X);
				act2IntroGF.x -= 40;
				act2IntroGF.alpha = 0;
				act2IntroGF.angle = -10;

				act2IntroEyes = new BGSprite('mario/allfinal/act1/Act_2_Intro', 0, 320, 0.2, 0.2, ['act2Stat']);
				act2IntroEyes.animation.addByPrefix('idle', 'EyesBG', 24, false);
				act2IntroEyes.cameras = [camOther];
				act2IntroEyes.scale.set(0.8, 0.8);
				act2IntroEyes.screenCenter(X);
				act2IntroEyes.x -= 270;
				act2IntroEyes.origin.set(act2IntroEyes.width / 2, act2IntroEyes.height / 2);
				act2IntroEyes.visible = false;

				act2BGGroup.visible = false;
				act2BFPipe.visible = false;
				act2Stat.visible = false;
				funnylayer0.visible = false;
				
				// act 3 stage

				act3BGGroup = new FlxTypedGroup<BGSprite>();
				add(act3BGGroup);

				act3Stat = new BGSprite('mario/allfinal/act3/Act3_Static', -730 - 275, -720 + 440, 0.2, 0.2, ['act3Stat']);
				act3Stat.animation.addByPrefix('idle', 'act3stat', 24, true);
				act3Stat.animation.play('idle');
				act3Stat.scale.set(1.3, 1.3);
				act3BGGroup.add(act3Stat);

				act3Hills = new BGSprite('mario/allfinal/act3/Act3_Hills', -730 - 275 + 300, 450, 0.4, 0.4, ['hills']);
				act3Hills.animation.addByPrefix('idle', 'hills', 24, true);
				act3Hills.animation.play('idle');
				act3Hills.scale.set(1.3, 1.3);
				act3BGGroup.add(act3Hills);
				
				act3UltraArm = new BGSprite('mario/allfinal/act3/Act3_Ultra_Arm', -900 - 275, -1215 + 440, 0.8, 0.8);
				act3UltraArm.origin.set(880, 1540);
				act3BGGroup.add(act3UltraArm);

				act3UltraBody = new BGSprite('mario/allfinal/act3/Act3_Ultra_M', -1185, -650 + 600, 0.8, 0.8, ['torso idle 1']);
				act3UltraBody.animation.addByPrefix('idle', 'torso idle 1', 24, false);
				act3UltraBody.animation.addByPrefix('change', 'torso change pose', 24, false);
				act3UltraBody.animation.addByPrefix('idle-alt', 'torso idle 2', 24, false);
				act3UltraBody.scale.set(1.4, 1.4);
				act3BGGroup.add(act3UltraBody);

				act3UltraHead1 = new BGSprite('mario/allfinal/act3/Act3_Ultra_M_Head', -200 - 275, -650 + 440, 0.8, 0.8, ['ultra m static head']);
				act3UltraHead1.animation.addByPrefix('idle', 'ultra m static head', 24, true);
				act3UltraHead1.animation.addByPrefix('sing', 'ultra m lyrics 1', 24, false);
				act3UltraHead1.animation.play('idle');
				act3UltraHead1.scale.set(1.1, 1.1);
				act3BGGroup.add(act3UltraHead1);

				act3UltraHead2 = new BGSprite('mario/allfinal/act3/Act3_Ultra_M_Head2', -200 - 300, -650 + 325, 0.8, 0.8, ['ultra m lyrics 1']);
				act3UltraHead2.animation.addByPrefix('sing', 'ultra m lyrics 2', 24, false);
				act3UltraHead2.animation.addByPrefix('laugh', 'ultra m head laugh', 24, false);
				act3BGGroup.add(act3UltraHead2);

				act3UltraPupils = new BGSprite('mario/allfinal/act3/Act3_Ultra_Pupils', -175, -300 + 405, 0.8, 0.8, ['ultra pupils']);
				act3UltraPupils.animation.addByPrefix('idle', 'ultra pupils', 24, true);
				act3UltraPupils.animation.play('idle');
				act3BGGroup.add(act3UltraPupils);

				act3BFPipe = new BGSprite('mario/allfinal/act3/Act3_bfpipe', 390 - 275, 165 + 440, 1, 1);
				act3BGGroup.add(act3BFPipe);

				act3Spotlight = new BGSprite('mario/allfinal/act3/act3Spotlight', -1550, -300, 1, 1);
				act3Spotlight.scale.set(1.3, 1);
				act3Spotlight.visible = false;

				act3Fog = new BGSprite('mario/allfinal/act3/act3', 0, 0, 1, 1);
				act3Fog.alpha = 0.7;
				act3Fog.cameras = [camOther];
				act3BGGroup.add(act3Fog);

				act3BGGroup.visible = false;

				//act 4 stage

				act4BGGroup = new FlxTypedGroup<BGSprite>();
				add(act4BGGroup);

				act4Stat = new BGSprite('mario/allfinal/act4/gray static', -75, -300, 0.3, 0.3, ['static']);
				act4Stat.animation.addByPrefix('idle', 'static', 24, true);
				act4Stat.animation.play('idle');
				act4BGGroup.add(act4Stat);

				act4Ripple = new BGSprite('mario/allfinal/act4/bg ripple', -180, 25, 0.5, 0.5, ['bg ripple']);
				act4Ripple.animation.addByPrefix('idle', 'bg ripple', 24, true);
				act4Ripple.animation.play('idle');
				act4BGGroup.add(act4Ripple);

				act4BGGroup.visible = false;

				act4Floaters = new FlxTypedGroup<BGSprite>();
				add(act4Floaters);

				act4Pipe1 = new BGSprite('mario/allfinal/act4/bf pipe final', 890, 620, 1, 1);
				act4Pipe1.visible = false;
				add(act4Pipe1);

				act4BG2Group = new FlxTypedGroup<BGSprite>();
				add(act4BG2Group);

				act4Pipe2 = new BGSprite('characters/Act_4_secondperspective', 685, 580, 1, 1, ['pipe']);
				act4Pipe2.animation.addByPrefix('idle', 'pipe', 24, true);
				act4Pipe2.animation.play('idle');
				act4BG2Group.add(act4Pipe2);

				act4Memory1 = new BGSprite('mario/allfinal/act4/memory', -70, 100 + 150, 1.1, 1.1);
				act4Memory1.animation.play('idle');
				act4Memory1.scale.set(1.2,1.2);
				act4Memory1.alpha = 0;
				act4BG2Group.add(act4Memory1);

				act4Memory2 = new BGSprite('mario/allfinal/act4/she got infected with the exe', 1250, 100 - 150, 1.1, 1.1);
				act4Memory2.animation.play('idle');
				act4Memory2.scale.set(1.2,1.2);
				act4Memory2.alpha = 0;
				act4BG2Group.add(act4Memory2);

				act4BG2Group.visible = false;

				act4Lightning = new BGSprite('mario/allfinal/act4/Act_4_FINALE_Lightingmcqueen', 550, 40, 1, 1, ['line']);
				act4Lightning.animation.addByPrefix('idle', 'line', 24, true);
				act4Lightning.animation.play('idle');
				act4Lightning.visible = false;

				act4DeadBF = new BGSprite('mario/allfinal/act4/Act_4_FINALE_DEATH', 340, -85, 1, 1, ['Death']);
				act4DeadBF.animation.addByPrefix('die', 'Death', 24, false);
				act4DeadBF.alpha = 0.00001;
				add(act4DeadBF);

				act4GameOver = new BGSprite('mario/allfinal/act4/Act_4_FINALE_Gameover', 0, 0, 1, 1);
				act4GameOver.cameras = [camEst];
				act4GameOver.screenCenter();

				act4Spotlight = new BGSprite('mario/allfinal/act4/spotlight', 400, 30, 1, 1);
				act4Spotlight.scale.set(2, 2);
				act4Spotlight.alpha = 0.25;
				act4Spotlight.visible = false;

				iconLG = new FlxSprite().loadGraphic(Paths.image('icons/icon-LG'));
				iconLG.width = iconLG.width / 2;
				iconLG.loadGraphic(Paths.image('icons/icon-LG'), true, Math.floor(iconLG.width), Math.floor(iconLG.height));
				iconLG.animation.add("win", [0], 10, true);
				iconLG.animation.add("lose", [1], 10, true);
				iconLG.cameras = [camHUD];
				// iconLG.visible = false;
				iconLG.antialiasing = ClientPrefs.globalAntialiasing;

				iconW4 = new FlxSprite().loadGraphic(Paths.image('icons/icon-W4R'));
				iconW4.width = iconW4.width / 2;
				iconW4.loadGraphic(Paths.image('icons/icon-W4R'), true, Math.floor(iconW4.width), Math.floor(iconW4.height));
				iconW4.animation.add("win", [0], 10, true);
				iconW4.animation.add("lose", [1], 10, true);
				iconW4.cameras = [camHUD];
				iconW4.antialiasing = ClientPrefs.globalAntialiasing;
				// iconW4.visible = false;

				iconY0 = new FlxSprite().loadGraphic(Paths.image('icons/icon-Y0SH'));
				iconY0.width = iconY0.width / 2;
				iconY0.loadGraphic(Paths.image('icons/icon-Y0SH'), true, Math.floor(iconY0.width), Math.floor(iconY0.height));
				iconY0.animation.add("win", [0], 10, true);
				iconY0.animation.add("lose", [1], 10, true);
				iconY0.cameras = [camHUD];
				iconY0.antialiasing = ClientPrefs.globalAntialiasing;
				// iconY0.visible = false;

				iconA4 = new BGSprite('mario/allfinal/act4/iconAct4', 0, 0, 1, 1, ['BEEGY0SH']);
				iconA4.animation.addByPrefix('beta2', 'beta2', 1, false);
				iconA4.animation.addByPrefix('costume', 'costume', 1, false);
				iconA4.animation.addByPrefix('devil', 'devil', 1, false);
				iconA4.animation.addByPrefix('gb', 'gb', 1, false);
				iconA4.animation.addByPrefix('hally', 'hally', 1, false);
				iconA4.animation.addByPrefix('luigiH2', 'luigiH2', 1, false);
				iconA4.animation.addByPrefix('mrl', 'mrl', 1, false);
				iconA4.animation.addByPrefix('2MX', '2MX', 1, false);
				iconA4.animation.addByPrefix('omega', 'omega', 1, false);
				iconA4.animation.addByPrefix('cdpeach', 'cdpeach', 1, false);
				iconA4.animation.addByPrefix('peachex', 'peachex', 1, false);
				iconA4.animation.addByPrefix('secret', 'secret', 1, false);
				iconA4.animation.addByPrefix('stanley', 'stanley', 1, false);
				iconA4.animation.addByPrefix('sys', 'sys', 1, false);
				iconA4.animation.addByPrefix('turmoil', 'turmoil', 1, false);
				iconA4.animation.addByPrefix('v', 'v', 1, false);
				iconA4.animation.addByPrefix('wario', 'wario', 1, false);
				iconA4.animation.addByPrefix('wdwluigi', 'wdwluigi', 1, false);
				iconA4.animation.addByPrefix('BEEGY0SH', 'BEEGY0SH', 1, false);
				iconA4.cameras = [camHUD];
				iconA4.antialiasing = ClientPrefs.globalAntialiasing;

				iconA42 = new BGSprite('mario/allfinal/act4/iconAct4', 0, 0, 1, 1, ['yoshiex']);
				iconA42.cameras = [camHUD];
				iconA42.antialiasing = ClientPrefs.globalAntialiasing;

				blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
				blackBarThingie.alpha = 1;
				blackBarThingie.cameras = [camEst];
				add(blackBarThingie);

				act1Intro = new BGSprite('mario/allfinal/act1/All_Stars_Intro', 0, 0, 0, 0, ['intro anim']);
				act1Intro.animation.addByPrefix('idle', 'intro anim', 24, false);
				act1Intro.cameras = [camEst];
				act1Intro.alpha = 0;
				act1Intro.screenCenter(X);
				add(act1Intro);

				act4Intro = new BGSprite('mario/allfinal/act4/Act_4_Voiceline', 0, 0, 1, 1, ['thingy']);
				act4Intro.animation.addByPrefix('anim', 'thingy', 24, false);
				act4Intro.cameras = [camEst];
				act4Intro.alpha = 0.00001;

				camHUD.visible = false;
				
				add(act2IntroGF);
				add(act2IntroEyes);

			case 'wetworld':
				noCount = true;
				noHUD = true;
				gfGroup.visible = false;
				tvEffect = true;
				oldTV = true;

				// contrastFX = new BrightnessContrastShader();

				// camGame.setFilters([new ShaderFilter(contrastFX)]);

				// contrastFX.brightness.value = [0.5];
				// contrastFX.contrast.value = [20.0];

				addCharacterToList('luigi_fountain3d', 1);
				addCharacterToList('bf-back3d', 0);

				fondaso = new BGSprite('mario/abandoned/fondo', -800, -600, 1, 1);
				fondaso.antialiasing = ClientPrefs.globalAntialiasing;
				fondaso.setGraphicSize(Std.int(fondaso.width * 1.5));
				fondaso.visible = false;
				fondaso.updateHitbox();
				
				atra = new BGSprite('mario/abandoned/atras', -800, -600, 1, 1);
				atra.antialiasing = ClientPrefs.globalAntialiasing;
				atra.setGraphicSize(Std.int(atra.width * 1.5));
				atra.visible = false;
				atra.updateHitbox();

				adel = new BGSprite('mario/abandoned/adelante', -800, -600, 1, 1);
				adel.antialiasing = ClientPrefs.globalAntialiasing;
				adel.setGraphicSize(Std.int(adel.width * 1.5));
				adel.visible = false;
				adel.updateHitbox();

				fondaso2 = new BGSprite('mario/abandoned/Wall and buildings', -800, -620, 1, 1);
				fondaso2.antialiasing = ClientPrefs.globalAntialiasing;
				fondaso2.setGraphicSize(Std.int(fondaso2.width * 0.75));
				fondaso2.updateHitbox();

				atra2 = new BGSprite('mario/abandoned/Middle', -800, -620, 1, 1);
				atra2.antialiasing = ClientPrefs.globalAntialiasing;
				atra2.setGraphicSize(Std.int(atra2.width * 0.75));
				atra2.updateHitbox();

				adel2 = new BGSprite('mario/abandoned/Front BG', -800, -620, 1, 1);
				adel2.antialiasing = ClientPrefs.globalAntialiasing;
				adel2.setGraphicSize(Std.int(adel2.width * 0.75));
				adel2.updateHitbox();

				add(fondaso2);
				add(atra2);
				add(fondaso);
				add(atra);

				thefog = new BGSprite('mario/abandoned/fog', 0, 0, 1, 1);
				thefog.antialiasing = ClientPrefs.globalAntialiasing;
				thefog.cameras = [camEst];
				thefog.alpha = 0;
				thefog.screenCenter();
				add(thefog);

				flood = new BGSprite('mario/abandoned/Flood_Assets', 0, 720, 1, 1, ['water overlay'], true);
				flood.cameras = [camEst];
				flood.antialiasing = ClientPrefs.globalAntialiasing;
				flood.alpha = 0.7;
				add(flood);

				blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
				blackBarThingie.alpha = 1;
				blackBarThingie.cameras = [camEst];
				add(blackBarThingie);

				redTVStat = new BGSprite('mario/abandoned/Abandoned_Intro_Assets2', 0, 0, 1, 1, ['StaticFinal'], true);
				redTVStat.cameras = [camEst];
				redTVStat.screenCenter();
				redTVStat.antialiasing = ClientPrefs.globalAntialiasing;
				redTVStat.alpha = 0;
				redTVStat.animation.addByIndices('justStat', 'StaticFinal', [1,3,5,7,9,11,13,15,17,19], "", 24, true);
				add(redTVStat);

				redTVImg = new BGSprite('mario/abandoned/Abandoned_Intro_Assets2', 0, 0, 1, 1, ['StaticFinal'], true);
				redTVImg.cameras = [camEst];
				redTVImg.screenCenter();
				redTVImg.antialiasing = ClientPrefs.globalAntialiasing;
				redTVImg.alpha = 0;
				redTVImg.animation.addByIndices('justImg', 'StaticFinal', [0, 0], "", 12, true);

				redTV = new BGSprite('mario/abandoned/Abandoned_Intro_Assets2', 0, 0, 1, 1, ['TV'], true);
				redTV.cameras = [camEst];
				redTV.screenCenter();
				redTV.antialiasing = ClientPrefs.globalAntialiasing;
				redTV.alpha = 0;
				redTV.x -= 210;
				redTV.y -= 135;
				add(redTV);

				luigilaugh = new BGSprite('mario/abandoned/Fountain_Luigi_2D_Laugh', 0, 0, 1, 1, ['laugh'], false);
				luigilaugh.animation.addByPrefix('laugh', 'laugh', 24, false);
				luigilaugh.cameras = [camEst];
				luigilaugh.screenCenter();
				luigilaugh.y += 50;
				luigilaugh.antialiasing = ClientPrefs.globalAntialiasing;
				luigilaugh.alpha = 0.00001;
				add(luigilaugh);

				redStat = new BGSprite('mario/abandoned/redstatic', 0, 0, 1, 1, ['red static'], true);
				redStat.cameras = [camEst];
				redStat.antialiasing = ClientPrefs.globalAntialiasing;
				redStat.alpha = 0;
				add(redStat);

				warningPopup = new BGSprite('mario/abandoned/popup', 0, 0, 1, 1);
				warningPopup.scale.x = 0.7;
				warningPopup.scale.y = 0.7;
				warningPopup.antialiasing = ClientPrefs.globalAntialiasing;
				warningPopup.cameras = [camHUD];
				warningPopup.alpha = 0;
				warningPopup.screenCenter();

				var vid:VideoSprite = new VideoSprite();
				vid.playVideo(Paths.video('luigifuckingdies'));
				vid.cameras = [camOther];
				vid.visible = false;
				add(vid);
				vid.finishCallback = function()
					{
						vid.destroy();
					}

			case 'piracy':
				//hasDownScroll = true;
				noCount = true;
				BF_CAM_EXTEND = 0;
				CoolUtil.precacheSound('lightOn');
				gfGroup.visible = false;
				boyfriendGroup.scrollFactor.set(0.1, 0.1);

				Main.fpsVar.visible = false;

				var scrollcoords:Float = 0;
				if(!hasDownScroll){
					camHUD.y = -480;
					boyfriendGroup.y = 280;
					dadGroup.y = 470;
					scrollcoords = 362;
					}

				var bgH0:BGSprite = new BGSprite('mario/piracy/HallyBG2', 0, -2.5 + scrollcoords, 0, 0);
				bgH0.scale.set(1.3, 1.3);
				bgH0.updateHitbox();
				bgH0.antialiasing = false;
				add(bgH0);

				add(dadGroup);

				bgH1 = new FlxBackdrop(Paths.image('mario/piracy/HallyBG4'), Y);
				bgH1.x = 240;
				bgH1.scale.set(1.3, 1.3);
				bgH1.updateHitbox();
				bgH1.scrollFactor.set(0, 0);
				bgH1.velocity.set(0, 40);
				bgH1.antialiasing = false;
				add(bgH1);

				var bgH3:BGSprite = new BGSprite('mario/piracy/HallyBG3', 240, -2.5 + scrollcoords, 0, 0);
				bgH3.scale.set(1.3, 1.3);
				bgH3.updateHitbox();
				bgH3.antialiasing = false;
				bgH3.alpha = 0.8;
				add(bgH3);

				var bgH4:BGSprite = new BGSprite('mario/piracy/HallyBG1', 0, -2.5 + scrollcoords, 0, 0);
				bgH4.scale.set(1.3, 1.3);
				bgH4.updateHitbox();
				bgH4.antialiasing = false;
				add(bgH4);

				var bgbottom:FlxBackdrop = new FlxBackdrop(Paths.image('mario/piracy/bgbottom'), X);
				bgbottom.scrollFactor.set(0, 0);
				bgbottom.velocity.set(40, 0);
				bgbottom.setGraphicSize(Std.int(bgbottom.width * 2.5));
				bgbottom.updateHitbox();
				bgbottom.x = 600;
				bgbottom.y = hasDownScroll ? 360 : -120;
				bgbottom.antialiasing = false;
				bgbottom.cameras = [camEst];
				add(bgbottom);

				lifebar = new BGSprite('mario/piracy/bar', -263, 400, 0, 0);
				lifebar.setGraphicSize(Std.int(lifebar.width * 2.71));
				lifebar.updateHitbox();
				lifebar.antialiasing = false;
				lifebar.visible = false;
				lifebar.cameras = [camHUD];
				add(lifebar);

				backing = new BGSprite('mario/piracy/paper', 7, hasDownScroll ? 1200 : -690, 1, 1);
				//backing = new FlxSprite(30, 400).makeGraphic(416, 250, 0xFFFFFFFF, true);
				backing.setGraphicSize(Std.int(backing.width * 1.9));
				backing.updateHitbox();
				backing.antialiasing = false;
				backing.cameras = [camEst];
				add(backing);
		
				thetext = new FlxText(backing.x + 30, backing.y + 69, 416, "sorry", 95);
				thetext.setFormat(Paths.font("arial-rounded-mt-bold.ttf"), 95, 0xBA888888, FlxTextAlign.CENTER);
				thetext.cameras = [camEst];
				add(thetext);
				thetext.y = backing.y + 125 - thetext.pixels.rect.height / 2;

				thetextC = new FlxText(backing.x + 30, backing.y + 69, 416, "criminal", 95);
				thetextC.setFormat(Paths.font("arial-rounded-mt-bold.ttf"), 95, 0xFFE58F8F, FlxTextAlign.CENTER);
				thetextC.visible = false;
				thetextC.cameras = [camEst];
				add(thetextC);
		
				canvas = new FlxSprite(backing.x, backing.y).makeGraphic(Std.int(backing.width), Std.int(backing.height), 0x00000000, true);
				canvas.cameras = [camEst];
				canvas.updateHitbox();
				canvas.visible = false;
				add(canvas);

				writeText = new FlxText(30, 500, 416, "00", 16);
				writeText.cameras = [camEst];
				writeText.color = FlxColor.BLACK;
				writeText.setFormat(Paths.font("BIOSNormal.ttf"), 28, FlxColor.BLACK, CENTER);
				writeText.visible = false;
				writeText.y = backing.y - 680;
				add(writeText);

				djStart = new BGSprite('mario/piracy/start', 510, hasDownScroll? 150 : 510, 0, 0);
				djStart.setGraphicSize(Std.int(djStart.width * 2));
				djStart.updateHitbox();
				djStart.antialiasing = false;

				djDone = new BGSprite('mario/piracy/Finish', 160, hasDownScroll? 150 : 510, 0, 0);
				djDone.setGraphicSize(Std.int(djDone.width * 2));
				djDone.updateHitbox();
				djDone.antialiasing = false;
				//djDone.alpha = 0;
				// add(djStart);

				bfspot = new BGSprite('mario/piracy/bfspotlight', 0, -2.5 + scrollcoords, 0, 0);
				//bgspot.setGraphicSize(Std.int(bgspot.width * 2));
				bfspot.updateHitbox();
				bfspot.antialiasing = true;
				bfspot.alpha = 0;

				drawspot = new BGSprite('mario/piracy/spotlight', -83, -100, 0, 0);
				//drawspot.setGraphicSize(Std.int(drawspot.width * 1.2));
				drawspot.updateHitbox();
				drawspot.antialiasing = true;
				drawspot.cameras = [camOther];
				drawspot.alpha = 0;
				add(drawspot);
		
				FlxG.mouse.load(TitleState.mouse.pixels, 0.8);
				FlxG.mouse.visible = true;
		}

		if (isPixelStage)
		{
			introSoundsSuffix = '-pixel';
		}

		if (curStage == 'bootleg' || curStage == 'warioworld')
			PauseSubState.pausemusic = 'breakfast1';
		else
			PauseSubState.pausemusic = 'breakfast' + FlxG.random.int(1,3);

		// trace('set pause music to ' + PauseSubState.pausemusic);

		if (curStage != 'realbg' || curStage != 'landstage' || (PlayState.SONG.song != 'Alone Old' && curStage != 'betamansion'))
		{
			add(gfGroup); // GIRLFRIEND LAYER
		}

		// Shitty layering but whatev it works LOL
		if (curStage == 'promoshow')
			add(promoDesk);

		if (curStage == 'racing')
			add(xboxigualGOD);

		if (curStage != 'directstream' && curStage != 'turmoilsweep' && curStage != 'piracy')
		{
			add(dadGroup); // OPPONENT LAYER / DAD LAYER
		}

		if(curStage == 'wetworld'){
			add(adel);
			add(adel2);
		}
		if (curStage == 'warioworld')
		{
			add(bftors);
			add(bftorsmiss);
		}

		if (curStage == 'realbg')
		{
			add(aguaEstrella);
		}

		if(curStage == 'hatebg'){
			if (PlayState.SONG.song != 'I Hate You Old' && PlayState.SONG.song != 'Oh God No')
				{
					capenose = new BGSprite('characters/MM_IHY_Boyfriend_AssetsFINAL', 1130, 520, ['Capejajacomoelcharter'], false);
					capenose.animation.addByPrefix('idle', 'Capejajacomoelcharter', 24, true);
					capenose.animation.addByPrefix('miss', 'CapeFail', 24, false);
					capenose.antialiasing = ClientPrefs.globalAntialiasing;
					add(capenose);
				}
		}

		add(boyfriendGroup); // BOYFRIEND LAYER

		switch (curStage)
		{
			
			case 'execlassic':
				var bloques:BGSprite = new BGSprite('mario/EXE1/CLadrillosPapus', -1000, -850, 1, 1);
				bloques.antialiasing = ClientPrefs.globalAntialiasing;
				add(bloques);

			case 'exesequel':
				platform2 = new BGSprite('mario/EXE1/starman/SS_foreground', -1100, -600, 1.3, 1.3);
				platform2.antialiasing = ClientPrefs.globalAntialiasing;
				add(platform2);

			case 'hatebg':
				if (PlayState.SONG.song == 'Oh God No'){
				add(fire2);
				add(fire1);
				}
			case 'forest':
				add(fresco);
				add(glitch0);
				add(glitch1);
				add(glitch2);
				add(glitch3);
				add(cososuelo);
				add(leaf0);
				add(leaf1);
				add(leaf2);
				add(bola0);
				add(bola1);

			case 'landstage':
				add(bricksland);
				add(brickslandEXE);

			case 'turmoilsweep':
				add(dadGroup);

			case 'nesbeat':
				add(ducksign);
				add(bowsign);
				add(ycbuWhite);
				add(otherBeatText);

			case 'secretbg':
				add(frontTrees);
				add(explosionBOM);

			case 'piracy':
				add(bfspot);
				blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
				blackBarThingie.scrollFactor.set(0, 0);
				blackBarThingie.alpha = 0;
				add(blackBarThingie);

			case 'castlestar':
				var fore:BGSprite = new BGSprite('mario/star/LADRILLOS', -1000, -930, 1, 1);
				fore.scale.set(1.2, 1.2);
				fore.scrollFactor.set(1.5, 1.5);
				add(fore);

			case 'endstage':
				add(castle0);
				add(funnylayer0);
				add(blackBarThingie);
				add(linefount);
				add(elfin);

			case 'directstream':
				add(ytbutton);
				add(bordervid);
				add(nametag);

			case 'luigiout':
				add(lightWall);

			case 'betamansion':
				add(lluvia);

			case 'warioworld':
				add(bfext);
				add(bfextmiss);

			case 'realbg':
				add(foreground2);
				add(foreground1);

			case 'exeport':
				if (PlayState.SONG.song == 'Powerdown Old')
				{
					add(wahooText);
				}
				else
				{
					add(lightmx);
					add(killMX);
					add(gfFall);
					add(gfwasTaken);
					add(shadowbg);
				}

			case 'demiseport':
				add(demFore1);
				add(demFore2);
				add(demFore3);
				add(demFore4);

				add(underdemFore1);
				add(underdemFore2);

			case 'meatworld':
				add(streetFore);
				add(meatForeGroup);
				add(fgTLL);
			
			case 'somari':
				add(pixelLights);

		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if (FileSystem.exists(Paths.modFolders(luaFile)))
		{
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		}
		else
		{
			luaFile = Paths.getPreloadPath(luaFile);
			if (FileSystem.exists(luaFile))
			{
				doPush = true;
			}
		}

		if (doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		var gfVersion:String = SONG.player3;
		if (gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				default:
					gfVersion = 'gf';
			}
			SONG.player3 = gfVersion; // Fix for the Chart Editor
		}

		gf = new Character(0, 0, gfVersion);
		startCharacterPos(gf);
		gf.scrollFactor.set(0.95, 0.95);
		gfGroup.add(gf);
		startCharacterLua(gf.curCharacter);

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		var camPos:FlxPoint = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		camPos.x += gf.cameraPosition[0];
		camPos.y += gf.cameraPosition[1];

		if (dad.curCharacter.startsWith('gf'))
		{
			dad.setPosition(GF_X, GF_Y);
			gf.visible = false;
		}

		// type: PINGPONG, loopDelay: 1

		/*	if(dad.curCharacter.startsWith('mariano')) {
			carro = FlxTween.tween(dad, {x: 400}, 2, {startDelay: 1, ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(dad, {x: 100}, 2, {startDelay: 1, ease: FlxEase.quadInOut, type: PINGPONG, loopDelay: 1});
				}});
		}*/

		// if (curStage == 'superbad')
		// {
		// 	dad.shader = new TwoDinThreeD(0.7, 0.5, 0);
		// 	dad.superBad = true;
		// }

		if (curStage == 'virtual')
		{
			gf.visible = false;
		}

		if (curStage == 'luigiout')
		{
			boyfriendGroup.alpha = 0.000001;
		}

		if (curStage == 'warioworld')
		{
			gf.visible = false;
			// opponentStrums.visible = false;
			dad.alpha = 0;
			dad.scale.x = 0.1;
			dad.scale.y = 0.1;
		}

		if (curStage == 'nesbeat')
		{
			dad.alpha = 0;
			boyfriend.alpha = 0.000001;
			starmanGF.alpha = 0.000001;
			gf.alpha = 0.000001;
		}

		if(curStage == 'wetworld'){
			//dadGroup.scrollFactor.set(0.7, 0.7);
		}

		if(curStage == 'exeport'){
			boyfriendGroup.color.saturation = 0;
		}

		if(curStage == 'allfinal'){
			add(act1FG);
			add(act1Gradient);
			add(act3Spotlight);
			// add(act4Spotlight);
		}

		if (PlayState.SONG.song == 'Oh God No')
		{
			boyfriend.shader = new SilhouetteShader(255, 0, 59);
			dad.shader = new SilhouetteShader(20, 180, 0);
		}

		//var colorSwap:ColorSwap;
		//colorSwap = new ColorSwap();
		//colorSwap.hue = (145 / 255) ;
		//colorSwap.saturation = 0;
		//colorSwap.brightness = 0;
		//boyfriend.shader = colorSwap.shader;

		if (curStage == 'hatebg')
		{
			// blueMario.dance(true);
			// blueMario2.dance(true);
			extraTween.push(FlxTween.tween(degrad, {alpha: 0.6}, 0.5, {ease: FlxEase.quadInOut, type: PINGPONG}));
		}

		if (dad.curCharacter == "wario")
		{
			var upDad:Float = 20000;
			// var justone:Bool = false;
			if (upDad == 20000)
			{
				upDad = dad.y;
			}
			eventTweens.push(FlxTween.tween(dad, {y: upDad - 20}, 1, {ease: FlxEase.quadInOut, type: PINGPONG}));
		}

		if(boyfriend.curCharacter == "bf_demise"){
			eventTweens.push(FlxTween.tween(boyfriendGroup, {x: boyfriendGroup.x + 200}, 2, {ease: FlxEase.quadInOut, type: PINGPONG}));
		}

		if(dad.curCharacter == "mx_demise"){
			eventTweens.push(FlxTween.tween(dadGroup, {x: dadGroup.x - 200}, 2, {startDelay: 1, ease: FlxEase.quadInOut, type: PINGPONG}));
		}

		if (boyfriend.curCharacter == "bfrun")
		{
			var upBf:Float = 20000;
			// var justone:Bool = false;
			if (upBf == 20000)
			{
				upBf = boyfriend.y;
			}
			// eventTweens.push(FlxTween.tween(boyfriend, {y: upBf + 10}, 0.5, {ease: FlxEase.quadInOut}));
		}

		if (boyfriend.curCharacter == "racebf")
		{
			var upBf:Float = 20000;
			// var justone:Bool = false;
			if (upBf == 20000)
			{
				upBf = boyfriend.x;
			}
			eventTweens.push(FlxTween.tween(boyfriend, {x: upBf + 50}, 1.2, {ease: FlxEase.quadInOut, type: PINGPONG}));
		}

		if (gf.curCharacter == "gfrace")
		{
			var upGf:Float = 20000;
			// var justone:Bool = false;
			if (upGf == 20000)
			{
				upGf = gf.x;
			}
			eventTweens.push(FlxTween.tween(gf, {x: upGf + 100}, 2, {ease: FlxEase.quadInOut, type: PINGPONG}));
		}

		if (curStage == 'landstage')
		{
			estaland = new FlxSprite();
			estaland.frames = Paths.getSparrowAtlas('modstuff/Mario_Phase2_Background_Assets_Overlay');
			estaland.animation.addByPrefix('idle', "aeiuo instancia 1", 12);
			estaland.animation.play('idle');
			estaland.antialiasing = false;
			estaland.setGraphicSize(Std.int(estaland.width * 2));
			estaland.alpha = 0.2;
			estaland.visible = false;
			estaland.cameras = [camEst];
			estaland.updateHitbox();
			estaland.screenCenter(XY);
			add(estaland);
		}

		if (curStage == 'luigiout' || curStage == 'realbg' || curStage == 'turmoilsweep' || curStage == 'secretbg')
		{
			blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
			blackBarThingie.alpha = 1;
			blackBarThingie.cameras = [camEst];
			add(blackBarThingie);
		}

		Conductor.songPosition = -5000;

		if (curStage == 'exeport')
		{
			blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
			blackBarThingie.alpha = 0;
			blackBarThingie.cameras = [camEst];
			add(blackBarThingie);

			screencolor = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
			screencolor.setGraphicSize(Std.int(screencolor.width * 10));
			screencolor.alpha = 0;
			screencolor.cameras = [camEst];
			add(screencolor);

			turnevil = new BGSprite('mario/MX/MX_Transformation_Assets', -500, -1000, ['MX Transformation'], true);
			turnevil.antialiasing = ClientPrefs.globalAntialiasing;
			turnevil.setGraphicSize(Std.int(turnevil.width * 0.5));
			turnevil.alpha = 0.00001;
			turnevil.animation.addByPrefix('laugh', "MX Transformation", 24, false);
			turnevil.cameras = [camEst];
			add(turnevil);

			mxLaughNEW = new BGSprite('mario/MX/MX_Dialogue_Asseta', -1150, 200, ['Innocence'], false);
			mxLaughNEW.animation.addByPrefix('freddyfazbear', "Innocence", 32, false);
			mxLaughNEW.antialiasing = ClientPrefs.globalAntialiasing;
			mxLaughNEW.alpha = 0.000001;
			mxLaughNEW.cameras = [camEst];
			mxLaughNEW.updateHitbox();
			mxLaughNEW.screenCenter();
			add(mxLaughNEW);

			mxLaugh = new FlxSprite(-15, 716);
			mxLaugh.frames = Paths.getSparrowAtlas('modstuff/MX_Assets_Laugh_v1');
			mxLaugh.animation.addByPrefix('idle', "MXLaugh", 18);
			mxLaugh.animation.play('idle');
			// mxLaugh.setGraphicSize(Std.int(mxLaugh.width * 0.6));
			mxLaugh.alpha = 0;
			mxLaugh.antialiasing = ClientPrefs.globalAntialiasing;
			mxLaugh.cameras = [camEst];
			mxLaugh.updateHitbox();
			mxLaugh.screenCenter();
			add(mxLaugh);

			imgwarb = new FlxSprite().loadGraphic(Paths.image('modstuff/cuidao0'));
			imgwarb.setGraphicSize(Std.int(imgwarb.width * 8));
			imgwarb.antialiasing = false;
			imgwarb.cameras = [camEst];
			imgwarb.visible = false;
			imgwarb.updateHitbox();
			imgwarb.screenCenter(Y);

			if (ClientPrefs.middleScroll)
			{
				imgwarb.x = 200;
			}
			else
			{
				imgwarb.screenCenter(X);
			}

			add(imgwarb);

			imgwar = new FlxSprite().loadGraphic(Paths.image('modstuff/cuidao'));
			imgwar.setGraphicSize(Std.int(imgwar.width * 8));
			imgwar.antialiasing = false;
			imgwar.cameras = [camEst];
			imgwar.visible = false;
			imgwar.updateHitbox();
			imgwar.screenCenter(Y);

			if (ClientPrefs.middleScroll)
			{
				imgwar.x = 200;
			}
			else
			{
				imgwar.screenCenter(X);
			}

			add(imgwar);

			liveScreen = new FlxSprite().loadGraphic(Paths.image('modstuff/mxscreen'));
			liveScreen.setGraphicSize(Std.int(liveScreen.width * 3));
			liveScreen.antialiasing = false;
			liveScreen.cameras = [camEst];
			liveScreen.updateHitbox();
			liveScreen.screenCenter();
			add(liveScreen);

			if (ClientPrefs.filtro85)
			{
				estatica = new FlxSprite();
				if (ClientPrefs.lowQuality)
				{
					estatica.frames = Paths.getSparrowAtlas('modstuff/static');
					estatica.setGraphicSize(Std.int(estatica.width * 10));
				}
				else
				{
					estatica.frames = Paths.getSparrowAtlas('modstuff/Mario_static');
				}
				estatica.animation.addByPrefix('idle', "static play", 15);
				estatica.animation.play('idle');
				estatica.antialiasing = false;
				estatica.cameras = [camEst];
				estatica.alpha = 0.05;
				estatica.updateHitbox();
				estatica.screenCenter();
				add(estatica);
			}

			// tvMarco = new FlxSprite().loadGraphic(Paths.image('modstuff/tvscreen'));
			// tvMarco.setGraphicSize(Std.int(tvMarco.width * 10));
			// tvMarco.antialiasing = false;
			// tvMarco.cameras = [camEst];
			// tvMarco.updateHitbox();
			// add(tvMarco);
		}

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		// if (hasDownScroll)
			// strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var gbcolor:Int = 0xFFF42626;

		var nameXD:String = 'healthBarNEW';

		if (curStage == 'landstage')
		{
			nameXD = 'GBhealthBarNEW';
			gbcolor = 0xFFADADAD;
		}

		if(cpuControlled && curStage != 'virtual' && curStage != 'landstage'){
			gbcolor = 0xFF25cd49;
		}

		if (curStage == 'hatebg' || curStage == 'forest')
		{
			timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 44, 400, "", 32);
			timeTxt.setFormat(Paths.font("mario2.ttf"), 22, 0xFFF4DA8F, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			if (hasDownScroll){
				timeTxt.y = FlxG.height - 45;
			}

			worldText = new FlxText(STRUM_X + (FlxG.width / 2) - 248, timeTxt.y - 24, 400, "TIME", 32);
			worldText.setFormat(Paths.font("mario2.ttf"), 22, 0xFFF4DA8F, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			worldText.cameras = [camHUD];
			worldText.borderSize = 2;
			worldText.visible = !ClientPrefs.hideTime;
			add(worldText);
		}
		else if (curStage == 'endstage' || (curStage == 'warioworld' && (PlayState.SONG.song != 'Apparition Old' && PlayState.SONG.song != 'Forbidden Star')))
		{
			timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 20, 400, "", 32);
			timeTxt.setFormat(Paths.font("vcr.ttf"), 70, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		else
		{
			timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 20, 400, "", 32);
			timeTxt.setFormat(Paths.font("mario2.ttf"), 22, gbcolor, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = !ClientPrefs.hideTime;
		if (hasDownScroll){
			timeTxt.y = FlxG.height - 45;
		}

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = !ClientPrefs.hideTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, gbcolor);
		timeBar.numDivisions = 800; // How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = !ClientPrefs.hideTime;

		if(PlayState.SONG.song == 'Unbeatable' && isWarp && !ClientPrefs.storySave[8]){
			timeBarBG.visible = false;
			timeBar.visible = false;
			timeTxt.visible = false;
		}

		timeBarBG.sprTracker = timeBar;

		if (curStage == 'racing')
		{
			caja = new FlxSprite(0, 0);
			caja.frames = Paths.getSparrowAtlas('modstuff/cajamk');
			caja.animation.addByPrefix('idle', "cajamk nada", 15);
			caja.animation.addByPrefix('random', "cajamk random", 15);
			caja.animation.addByPrefix('shell', "cajamk shell", 15);
			caja.animation.addByPrefix('bomb', "cajamk bomb", 15);
			caja.animation.addByPrefix('ghost', "cajamk ghost", 15);
			caja.animation.addByPrefix('1up', "cajamk 1up", 15);
			caja.antialiasing = ClientPrefs.globalAntialiasing;
			caja.cameras = [camHUD];
			caja.updateHitbox();

			if (!hasDownScroll)
				caja.y = -200;
			else
			{
				caja.y = 760;
			}

			if (!ClientPrefs.middleScroll)
			{
				caja.screenCenter(X);
			}
			else
			{
				caja.x = 1000;
			}

			add(caja);
		}

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		if (curStage == 'somari')
		{
			scoreTxt = new FlxText(152, 670, FlxG.width, "", 60);
			scoreTxt.setFormat(Paths.font("mariones.ttf"), 40, FlxColor.WHITE, LEFT);
			scoreTxt.scrollFactor.set();
			scoreTxt.antialiasing = false;
			scoreTxt.cameras = [camHUD];

			if (hasDownScroll) scoreTxt.y = -20;

			add(scoreTxt);
		}

		if (curStage == 'endstage' || (curStage == 'warioworld' && (PlayState.SONG.song != 'Apparition Old' && PlayState.SONG.song != 'Forbidden Star')))
		{
			scoreTxt = new FlxText(-100, 565, FlxG.width, "", 100);
			scoreTxt.setFormat(Paths.font("vcr.ttf"), 70, FlxColor.WHITE, RIGHT);
			scoreTxt.cameras = [camHUD];
			add(scoreTxt);

			ratingTxt = new FlxText(150, 365, FlxG.width, "", 100);
			ratingTxt.setFormat(Paths.font("vcr.ttf"), 70, FlxColor.WHITE, LEFT);
			ratingTxt.cameras = [camHUD];
			ratingTxt.screenCenter(X);
			ratingTxt.x += 50;
			add(ratingTxt);
		}

		generateSong(SONG.song);
		modManager = new ModManager(this);

		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if (FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
		}
		for (event in eventPushedMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if (FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (curStage == 'forest')
		{
			enemyY = dad.y;
			enemyX = dad.x;

			blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
			blackBarThingie.alpha = 1;
			blackBarThingie.cameras = [camEst];
			add(blackBarThingie);

			startbf = new FlxSprite().loadGraphic(Paths.image('modstuff/hatestart'));
			startbf.setGraphicSize(Std.int(startbf.width * 3));
			startbf.antialiasing = false;
			startbf.cameras = [camEst];
			startbf.alpha = 0;
			startbf.updateHitbox();
			startbf.screenCenter();
			add(startbf);
		}

		if (curStage == 'hatebg')
		{
			blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
			blackBarThingie.alpha = 1;
			blackBarThingie.cameras = [camEst];

			var cosomario:String = '';

			if (PlayState.SONG.song == 'Oh God No')
				cosomario = 'M';

			startbf = new FlxSprite().loadGraphic(Paths.image('modstuff/hatestart' + cosomario));
			startbf.setGraphicSize(Std.int(startbf.width * 3));
			startbf.antialiasing = false;
			startbf.cameras = [camEst];
			startbf.alpha = 0;
			startbf.updateHitbox();
			startbf.screenCenter();

			if (ClientPrefs.lowQuality)
			{
				ihyLava = new FlxSprite(-18, 716);
				ihyLava.frames = Paths.getSparrowAtlas('modstuff/lava');
				ihyLava.animation.addByPrefix('idle', "lava brota", 4);
				ihyLava.setGraphicSize(Std.int(ihyLava.width * 8));
				ihyLava.antialiasing = false;
				ihyLava.cameras = [camHUD];
				ihyLava.updateHitbox();
				add(ihyLava);
			}
			else
			{
				ihyLava = new FlxSprite(-18, 750);
				ihyLava.frames = Paths.getSparrowAtlas('modstuff/Luigi_IHY_Background_Assets_Lava');
				ihyLava.animation.addByPrefix('idle', "Lava", 12);
				ihyLava.setGraphicSize(Std.int(ihyLava.width * 1.3));
				ihyLava.antialiasing = ClientPrefs.globalAntialiasing;
				add(ihyLava);
			}

			ihyLava.animation.play('idle');
			ihyLava.cameras = [camHUD];
			ihyLava.updateHitbox();

			lavaEmitter = new FlxTypedEmitter<LavaParticle>(0, ihyLava.y);
			lavaEmitter.particleClass = LavaParticle;
			lavaEmitter.launchMode = FlxEmitterMode.SQUARE;
			lavaEmitter.width = FlxG.width;
			lavaEmitter.velocity.set(0, -150, 0, -300, 0, -10, 0, -50);
			lavaEmitter.alpha.set(1, 0);
			add(lavaEmitter);
			lavaEmitter.cameras = [camEst];

			if (hasDownScroll)
			{
				if (ClientPrefs.lowQuality)
				{
					ihyLava.y = -716;
				}
				else
				{
					ihyLava.y = -440;
				}
				ihyLava.flipY = true;
				lavaEmitter.velocity.set(0, 150, 0, 300, 0, 10, 0, 50);
				lavaEmitter.y = 0;
			}

			if (PlayState.SONG.song == 'Oh God No'){
	
				introbg  = new BGSprite('mario/IHY/cutscene/ihy_intro_bg', 0, 180, ['ihy intro bg stage no way'], true);
				introbg.antialiasing = false;
				introbg.screenCenter();
				introbg.y = 180;
				introbg.animation.addByPrefix('idle', 'ihy intro bg stage no way', 5, true);
				introbg.animation.play('idle');
				introbg.cameras = [camEst];
				introbg.setGraphicSize(Std.int(introbg.width * 4));
				add(introbg);
	
				introM  = new BGSprite('mario/IHY/cutscene/mario_intro_ihy', 0, 475, ['mario intro ihy walk'], true);
				introM.antialiasing = false;
				introM.animation.addByPrefix('walk', 'mario intro ihy walk', 12, true);
				introM.animation.addByIndices('stand', 'mario intro ihy walk', [2], "", 12, false);
				introM.animation.addByPrefix('look', 'mario intro ihy looking up', 12, false);
				introM.animation.addByPrefix('huh', 'mario intro ihy huh', 12, false);
				introM.animation.addByPrefix('shock', 'mario intro ihy shocked', 12, false);
				introM.animation.addByPrefix('scared', 'mario intro ihy scared', 12, false);
				introM.animation.addByPrefix('idle', 'mario intro ihy transition', 12, false);
				introM.animation.play('walk');
				introM.cameras = [camEst];
				introM.setGraphicSize(Std.int(introM.width * 4));
				add(introM);
	
				introL  = new BGSprite('mario/IHY/cutscene/ihy_luigi_intro', 1200, 470, ['ihy luigi intro walk'], true);
				introL.antialiasing = false;
				introL.animation.addByPrefix('walk', 'ihy luigi intro walk', 12, true);
				introL.animation.addByPrefix('stand', 'ihy luigi intro stand', 12, false);
				introL.animation.addByPrefix('worked', 'ihy luigi intro worked', 12, false);
				introL.animation.addByPrefix('alone', 'ihy luigi intro alone', 12, false);
				introL.animation.addByPrefix('transition', 'ihy luigi intro transition', 12, false);
				introL.animation.play('walk');
				introL.cameras = [camEst];
				introL.setGraphicSize(Std.int(introL.width * 4));
				add(introL);

				introLText = new BGSprite('mario/IHY/cutscene/ihy_intro_text', 600, 400, ['you'], true);
				introLText.antialiasing = false;
				introLText.animation.addByPrefix('0', 'ihy intro text you', 12, true);
				introLText.animation.addByPrefix('1', 'ihy intro text thought', 12, false);
				introLText.animation.addByPrefix('2', 'ihy intro text koopa', 12, false);
				introLText.animation.addByPrefix('3', 'ihy intro text worked', 12, false);
				introLText.animation.addByPrefix('4', 'ihy intro text alone', 12, false);
				introLText.animation.play('4');
				introLText.cameras = [camEst];
				introLText.setGraphicSize(Std.int(introLText.width * 4));
				introLText.visible = false;
				add(introLText);

				bbar1 = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				bbar1.cameras = [camEst];
				bbar1.x = 1152;
				add(bbar1);

				bbar2 = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				bbar2.cameras = [camEst];
				bbar2.x = -1152;
				add(bbar2);

				add(blackBarThingie);

				luigiCut = new BGSprite('mario/IHY/cutscene/OGN_Cutscene', 300, 0, ['LuigiAnim'], false);
				luigiCut.animation.addByPrefix('anim', 'LuigiAnim', 24, false);
				luigiCut.animation.addByPrefix('end', 'blood', 5, false);
				luigiCut.cameras = [camEst];
				luigiCut.alpha = 0.0000001;
				add(luigiCut);

				add(startbf);
				}else{
					add(blackBarThingie);
					add(startbf);
				}

			lavaEmitter.start(false);
		}
		if (curStage == 'betamansion')
		{
			var fogblack:FlxSprite = new FlxSprite().loadGraphic(Paths.image('modstuff/126'));
			fogblack.antialiasing = ClientPrefs.globalAntialiasing;
			fogblack.cameras = [camEst];
			fogblack.alpha = 0.8;
			fogblack.screenCenter();
			add(fogblack);

			bfcolgao = new FlxSprite(700, -100);
			bfcolgao.frames = Paths.getSparrowAtlas('modstuff/Beta_BF_Hang');
			bfcolgao.animation.addByPrefix('idle', "BFHang", 24);
			bfcolgao.antialiasing = ClientPrefs.globalAntialiasing;
			bfcolgao.cameras = [camEst];
			bfcolgao.alpha = 0;
			add(bfcolgao);
		}

		if (curStage != 'hatebg' && curStage != 'forest')
		{
			add(timeBarBG);
			add(timeBar);
		}
		add(timeTxt);

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		healthBarBG.visible = false;
		add(healthBarBG);
		if (hasDownScroll)
			healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		if(curStage == 'piracy'){
			healthBar = new FlxBar(lifebar.x, lifebar.y, RIGHT_TO_LEFT, Std.int(lifebar.width), Std.int(lifebar.height), this, 'health', -3.55, 2);
		}
		healthBar.scrollFactor.set();
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		customHB = new AttachedSprite(nameXD);
		customHB.screenCenter(X);
		customHB.y = healthBarBG.y - 5;
		customHB.scrollFactor.set();
		add(customHB);

		customHBweegee = new AttachedSprite(nameXD + 'luigi');
		customHBweegee.screenCenter(X);
		customHBweegee.y = healthBarBG.y - 5;
		customHBweegee.scrollFactor.set();
		customHBweegee.visible = false;
		add(customHBweegee);


		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.visible = true;

		if (curStage == 'luigiout')
		{
			add(iconP2);
			add(iconP1);
		}
		else
		{
			add(iconP1);
			add(iconP2);
		}
		reloadHealthBarColors();

		subTitle = new FlxText(0, 560.8, FlxG.width, "", 20);
		if (curStage != 'exeport')
		{
			subTitle.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		else
		{
			subTitle.setFormat(Paths.font("mariones.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		subTitle.scrollFactor.set();
		subTitle.borderSize = 1.25;
		subTitle.cameras = [camOther];
		subTitle.visible = !ClientPrefs.hideHud;
		add(subTitle);

		if(curStage == 'nesbeat'){
		fireBar = new BGSprite('mario/beatus/firebar', 80, 750, 1.1, 1.1, ['firebar loop'], false);
		fireBar.setGraphicSize(Std.int(fireBar.width * 6));
		fireBar.updateHitbox();
		fireBar.antialiasing = false;
		fireBar.visible = false;
		fireBar.animation.addByPrefix('loop', "firebar loop", 10, false);
		fireBar.animation.play('loop');
		fireBar.cameras = [camHUD];
		
		add(fireBar);
		}

		var plus:String = '';
		if(curStage == 'virtual') plus = 'V';
		if(curStage == 'landstage') plus = 'GB';
		if(curStage == 'endstage') plus = 'End';
		if(curStage == 'somari') plus = 'S';

		luigiLogo = new FlxSprite(400, timeBarBG.y + 55);
		luigiLogo.loadGraphic(Paths.image('modstuff/luigi/luigi' + plus));
		luigiLogo.scrollFactor.set();
		luigiLogo.scale.set(0.3, 0.3);
		luigiLogo.updateHitbox();
		luigiLogo.screenCenter(X);
		// luigiLogo.x += 10;
		luigiLogo.y = timeBarBG.y + ((!hasDownScroll ? 40 : -90));
		luigiLogo.visible = cpuControlled;
		add(luigiLogo);
		if (curStage == 'virtual' || curStage == 'landstage' || curStage == 'somari'){
			luigiLogo.antialiasing = false;
			var thesize:Float = 4;
			if(curStage == 'virtual'){
				thesize = 3.5;
				luigiLogo.y = strumLine.y;
			} 
			if(curStage == 'somari'){
				thesize = 6;
				luigiLogo.x += 28;
				luigiLogo.y -= 1;
			}
			luigiLogo.scale.set(thesize, thesize);
			luigiLogo.updateHitbox();
			luigiLogo.x -= 40;
		}

		switch (PlayState.SONG.song)
		{
			// Story Songs
			case 'Its a me':
				autor = 'TheWAHbox\n ft. Sandi and Comodo_';

			case 'Starman Slaughter':
				autor = 'Sandi ft. RedTV53\n FriedFrick and theWAHbox';

			case 'Golden Land':
				autor = 'FriedFrick';

			case 'All-Stars':
				autor = 'Kenny L';

			// Warp Zone Songs
			case 'Oh God No':
				autor = 'Kenny L';
			case 'I Hate You':
				autor = 'Kenny L';
			case 'Powerdown':
				autor = 'Kenny L ft. TaeSkull';
			case 'Demise':
				autor = 'Kenny L';
			case 'Alone':
				autor = 'RedTV53';
			case 'Apparition':
				autor = 'FriedFrick';

			// Extra songs
			case 'Racetraitors':
				autor = 'Kenny L';
			case 'Dark Forest':
				autor = 'Kenny L';
			case 'Bad Day':
				autor = 'RedTV53';
			case 'So Cool':
				autor = 'FriedFrick ft. TheWAHBox';
			case 'Nourishing Blood':
				autor = 'Kenny L';
			case 'Unbeatable':
				autor = 'RedTV53\n ft. theWAHbox and scrumbo_';
			case 'Paranoia':
				autor = 'Sandi ft. Kenny L';
			case 'Day Out':
				autor = 'TheWAHBox';
			case 'Thalassophobia':
				autor = 'Hazy ft. TaeSkull';
			case 'Promotion':
				autor = 'Sandi';
			case 'Dictator':
				autor = 'Kenny L';
			case 'Last Course':
				autor = 'FriedFrick ft. Sandi';
			case 'No Hope':
				autor = 'FriedFrick';
			case 'The End':
				autor = 'Kenny L';
			case 'MARIO SING AND GAME RYTHM 9':
				autor = 'TaeSkull';
			case 'Overdue':
				autor = 'FriedFrick ft. Sandi';
			case 'Abandoned':
				autor = 'TheWAHBox ft. FriedFrick';
			case 'No Party':
				autor = 'Kenny L';

			// Old Songs
			case 'Forbidden Star':
				autor = 'KINGF0X';
			case 'Its a me Old':
				autor = 'KINGF0X';
			case 'Golden Land Old':
				autor = 'Kenny L';
			case 'I Hate You Old':
				autor = 'Kenny L';
			case 'Apparition Old':
				autor = 'Kenny L';
			case 'Alone Old':
				autor = 'KINGF0X';
			case 'Powerdown Old':
				autor = 'Kenny L';
			case 'Racetraitors Old':
				autor = 'Kenny L';
			case 'Overdue Old':
				autor = 'Hazy';
			case 'No Party Old':
				autor = 'Joey Perleoni ft. RedTV53';
			case 'All-Stars Old':
				autor = 'Kenny L';
			case 'Demise Old':
				autor = 'Kenny L';
			case 'Dictator Old':
				autor = 'Kenny L';
			
		}

		if (SONG.song.endsWith('Old'))
		{
			if (SONG.song == 'Demise Old'){
				newName = 'Time Out (Demise Original)';
			}else{
			legacycheck = ' (Legacy)';
			newName = SONG.song.replace(' Old', '');
			}
			Lib.application.window.title = "Friday Night Funkin': Mario's Madness | " + newName + legacycheck + ' | ' + autor;
		}
		else
		{
			newName = SONG.song;
			if(PlayState.SONG.song == 'All-Stars'){
				newName = 'All-Stars (Act 1)';
			}
			Lib.application.window.title = "Friday Night Funkin': Mario's Madness | " + newName + ' | ' + autor;
		}
		if(isWarp){
			var warpText:String = "?";
			var alphabet:Array<String> = ["a", "b", "c", "d", "e", "f", "g", 
										  "h", "i", "j", "k", "l", "m", "n", 
										  "o", "p", "q", "r", "s", "t", "u", 
										  "v", "w", "x", "y", "z", "-", "0", 
										  "1", "2", "3", "4", "5", "6", "7", 
										  "8", "9", "."]; //three birds with one stone, i got all your keyca-

			var secretName:String = newName.toLowerCase();
			var secretAutor:String = autor.toLowerCase();

			for(i in 0...alphabet.length){
				secretName = secretName.replace(alphabet[i], '?');
				secretAutor = secretAutor.replace(alphabet[i], '?');
			}
			Lib.application.window.title = "Friday Night Funkin': Mario's Madness | " + secretName + ' | ' + secretAutor;
		}

		titleText = new FlxText(400, 304.5, 0, newName, 42);
		titleText.setFormat(Paths.font("mariones.ttf"), 42, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, gbcolor);
		titleText.borderSize = 3;
		titleText.screenCenter(X);
		titleText.alpha = 0;
		add(titleText);

		var format = new FlxTextFormat(0x000000, false, false, gbcolor);
		format.leading = -5;
		autorText = new FlxText(400, titleText.y + 70, 0, autor, 35);
		autorText.setFormat(Paths.font("mariones.ttf"), 35, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, gbcolor);
		autorText.borderSize += 2;
		autorText.screenCenter(X);
		autorText.alpha = 0;
		add(autorText);

		autorText.addFormat(format);

		var checkwidth:Float = autorText.width;

		if (titleText.width >= autorText.width)
		{
			checkwidth = titleText.width;
		}

		line2 = new FlxSprite(566, titleText.y + 57).makeGraphic(Std.int(checkwidth), 5, FlxColor.BLACK);
		line2.cameras = [camEst];
		line2.screenCenter(X);
		line2.alpha = 0;

		line1 = new FlxSprite(line2.x - 5, line2.y - 2).makeGraphic(Std.int(checkwidth + 10), 8, gbcolor);
		line1.cameras = [camEst];
		line1.alpha = 0;
		add(line1);
		add(line2);

		if (curStage == 'somari')
		{
			timeTxt.visible = false;
			timeBarBG.visible = false;
			timeBar.visible = false;
			iconP2.visible = false;
			iconP1.visible = false;
			customHB.visible = false;
			healthBar.visible = false;
		}
		else if (curStage == 'endstage' || (curStage == 'warioworld' && (PlayState.SONG.song != 'Apparition Old' && PlayState.SONG.song != 'Forbidden Star')))
		{
			timeBarBG.visible = false;
			timeBar.visible = false;
			iconP2.visible = false;
			iconP1.visible = false;
			customHB.visible = false;
			healthBar.visible = false;
		}
		else
		{
			scoreTxt = new FlxText(100, healthBarBG.y + 36, FlxG.width, "", 20);
			scoreTxt.setFormat(Paths.font("mario2.ttf"), 15, gbcolor, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreTxt.scrollFactor.set();
			scoreTxt.borderSize = 1.25;
			scoreTxt.visible = !ClientPrefs.hideHud;
			scoreTxt.screenCenter(X);
			scoreTxt.cameras = [camHUD];
			
			if(curStage == 'piracy') scoreTxt.setFormat(Paths.font("BIOSNormal.ttf"), 48, FlxColor.BLACK, LEFT);
			add(scoreTxt);
		}

		if (curStage == 'piracy'){
			timeTxt.visible = false;
			timeBarBG.visible = false;
			timeBar.visible = false;
			iconP2.visible = false;
			iconP1.visible = false;
			customHB.visible = false;
			//lifebar.visible = false;
			healthBar.setPosition(-55, 411);
			scoreTxt.setPosition(-262, 360);

			if(!hasDownScroll){
				healthBar.y = 131;
				scoreTxt.y = 150;
			}
		}

		if (curStage == 'warioworld')
		{
			fogbad = new FlxSprite();
			fogbad.frames = Paths.getSparrowAtlas('modstuff/Wario_Apparition_Overlay_v1');
			fogbad.animation.addByPrefix('idle', "WarioOverlay", 24);
			fogbad.antialiasing = ClientPrefs.globalAntialiasing;
			fogbad.cameras = [camEst];
			fogbad.alpha = 0;
			fogbad.animation.play('idle');
			fogbad.screenCenter();
			add(fogbad);
		}

		if(curStage == 'hatebg' && SONG.song == 'Oh God No'){
			add(susto);
			add(estatica);
		}

		if (curStage == 'racing')
		{
			redS = new FlxSprite(-200, 535);
			redS.frames = Paths.getSparrowAtlas('modstuff/shellmk');
			redS.animation.addByPrefix('idle', "idle", 15);
			redS.animation.addByPrefix('hit', "hit", 15, false);
			redS.animation.play('idle');
			redS.antialiasing = ClientPrefs.globalAntialiasing;
			redS.visible = !ClientPrefs.hideHud;
			redS.cameras = [camHUD];

			if (hasDownScroll)
			{
				redS.y = -10;
			}

			redS.updateHitbox();
			add(redS);
		}

		if (curStage == 'superbad')
		{
			GameOverSubstate.characterName = 'bfbaddeath';
			addCharacterToList('bfbaddeath', 0);
			remove(dadGroup);
			insert(members.indexOf(boyfriendGroup) + 1, blackBarThingie);
			insert(members.indexOf(blackBarThingie) + 1, dadGroup);

			FOLLOWCHARS = false;
			ZOOMCHARS = false;
			dadGroup.x = -50;
			dadGroup.y = 400;
			camGame.zoom = 1.6;
			//idk what the fuck is going on in this song with the cam zoom at the start its pissing me off
			//if it twerks it twerks :overdue:

			// triggerEventNote('Camera Follow Pos', '280', '400');

			
			byecirc = new FlxSprite();
			byecirc.frames = Paths.getSparrowAtlas('modstuff/bye');
			byecirc.animation.addByPrefix('p1', "goodbye", 15, false);
			byecirc.animation.addByPrefix('p2', "bye bye", 15, false);
			byecirc.animation.addByPrefix('p3', "hello", 24, false);
			byecirc.antialiasing = ClientPrefs.globalAntialiasing;
			byecirc.screenCenter();
			byecirc.cameras = [camEst];
			byecirc.alpha = 0.0000001;
			byecirc.y -= 2;
			byecirc.x -= 2;
			add(byecirc);
			add(badPoisonVG);

			if(!ClientPrefs.lowQuality){
				badRipple = new RippleShader();
				camGame.setFilters([new ShaderFilter(badRipple)]);
				camHUD.setFilters([new ShaderFilter(badRipple)]);
				camEst.setFilters([new ShaderFilter(badRipple)]);
			}
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		customHB.cameras = [camHUD];
		customHBweegee.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		luigiLogo.cameras = [camHUD];
		titleText.cameras = [camEst];
		autorText.cameras = [camEst];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];

		if (noHUD)
		{
			camHUD.alpha = 0;
		}
		if (flipchar)
		{
			healthBar.flipX = true;
			healthBarBG.flipX = true;
			iconP1.flipX = true;
			iconP2.flipX = true;
		}
		if(curStage == 'demiseport'){
			iconP2.flipX = true;
			healthBar.flipX = false;
			healthBarBG.flipX = false;
		}
		if (tvEffect)
		{
			if (ClientPrefs.filtro85)
			{
				var border:VCRBorder = new VCRBorder();

				camGame.setFilters([new ShaderFilter(border)]);
				camEst.setFilters([new ShaderFilter(border)]);
				camHUD.setFilters([new ShaderFilter(border)]);

				vcr = new VCRMario85();

				camGame.setFilters([new ShaderFilter(vcr), new ShaderFilter(border),]);
				camEst.setFilters([new ShaderFilter(vcr), new ShaderFilter(border),]);
				camHUD.setFilters([new ShaderFilter(vcr), new ShaderFilter(border),]);

				if(curStage == 'nesbeat'){
					beatend = new YCBUEndingShader();
					angel = new AngelShader();
					camGame.setFilters([new ShaderFilter(vcr), new ShaderFilter(border), new ShaderFilter(beatend), new ShaderFilter(angel)]);
					camEst.setFilters([new ShaderFilter(vcr), new ShaderFilter(border), new ShaderFilter(angel)]);
				}

				if (oldTV)
				{
					if (ClientPrefs.filtro85)
					{
						oldFX = new OldTVShader();

						camGame.setFilters([new ShaderFilter(vcr), new ShaderFilter(oldFX), new ShaderFilter(border)]);
						camEst.setFilters([new ShaderFilter(vcr), new ShaderFilter(oldFX), new ShaderFilter(border)]);
						camHUD.setFilters([new ShaderFilter(vcr), new ShaderFilter(oldFX), new ShaderFilter(border)]);

						contrastFX = new BrightnessContrastShader();

						camGame.setFilters([new ShaderFilter(contrastFX), new ShaderFilter(vcr), new ShaderFilter(oldFX), new ShaderFilter(border)]);
					}
				}
			}
			else if(curStage == 'wetworld'){
				contrastFX = new BrightnessContrastShader();

				camGame.setFilters([new ShaderFilter(contrastFX)]);
			}
		}

		if (oldTV && !tvEffect)
		{
			if (ClientPrefs.filtro85)
			{
				oldFX = new OldTVShader();

				camGame.setFilters([new ShaderFilter(oldFX)]);
				camEst.setFilters([new ShaderFilter(oldFX)]);
				camHUD.setFilters([new ShaderFilter(oldFX)]);
				FlxG.camera.setFilters([new ShaderFilter(oldFX)]);
			}
		}

		if (curStage == 'somari')
		{
			var blackHUD1 = new FlxSprite().makeGraphic(400, 200, FlxColor.BLACK);
			blackHUD1.setGraphicSize(Std.int(blackHUD1.width * 10));
			blackHUD1.cameras = [camEst];
			blackHUD1.y = -879;
			if (hasDownScroll)
				blackHUD1.y = -969;
			add(blackHUD1);

			blackHUD2 = new FlxSprite().makeGraphic(400, 1473, FlxColor.BLACK);
			blackHUD2.setGraphicSize(Std.int(blackHUD2.width * 10));
			blackHUD2.y = 7197;
			if (hasDownScroll)
				blackHUD2.y = 7197;
			blackHUD2.cameras = [camEst];
			add(blackHUD2);
		}

		if (curStage == 'warioworld' && (PlayState.SONG.song != 'Apparition Old' && PlayState.SONG.song != 'Forbidden Star'))
		{
			// scoreTxt.x += 200;
			// iconP1.x += 200;
			// iconP2.x += 200;
			// healthBar.x += 200;
			var months:Array<String> = [
				"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
			];
			var now:Date = Date.now();
			var t:String = months[now.getMonth()] + " " + now.getDate() + " 1996";
			var text:FlxText = new FlxText(65, 625, FlxG.width, t, 70);
			text.setFormat(Paths.font("vcr.ttf"), 70, 0xaaffffff, LEFT, FlxTextBorderStyle.OUTLINE, 0xaa000000);
			text.scrollFactor.set();
			text.cameras = [camHUD];
			add(text);
		}
		else if (curStage == 'endstage')
		{
			var text:FlxText = new FlxText(65, 625, FlxG.width, 'SEP.02 97', 70);
			text.setFormat(Paths.font("vcr.ttf"), 70, 0xaaffffff, LEFT, FlxTextBorderStyle.OUTLINE, 0xaa000000);
			text.scrollFactor.set();
			text.cameras = [camHUD];
			add(text);
		}

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		updateTime = true;

		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'data/songData/' + Paths.formatToSongPath(SONG.song) + '/script.lua';
		if (FileSystem.exists(Paths.modFolders(luaFile)))
		{
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		}
		else
		{
			luaFile = Paths.getPreloadPath(luaFile);
			if (FileSystem.exists(luaFile))
			{
				doPush = true;
			}
		}

		if (doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		var daSong:String = Paths.formatToSongPath(curSong);
		trace(isStoryMode);
		trace(seenCutscene);
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				case 'its-a-me':
					startVideo('Itsame_cutscene');

				case 'starman-slaughter' | 'starman slaughter':
					startVideo('ss_cutscene');

				case 'golden-land':
					startVideo('cutscene2');

				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else if(isWarp && !seenCutscene){
			seenCutscene = true;
			switch(daSong){
			case 'overdue':
				startVideo('overdue_cutscn');				
			case 'demise':
				startVideo('demise_cutscene');
			case 'i-hate-you':
				startVideo('ihy_cutscene');
			case 'promotion':
				startVideo('promocut');
			case 'abandoned':
				startVideo('abandoncut');
			default:
				startCountdown();
				seenCutscene = false;
			}
		}
		else
		{	
			startCountdown();
		}

		switch(curStage){
			case 'wetworld':
				luigidies = new VideoSprite(300, 100);
				luigidies.cameras = [camOther];
				luigidies.visible = false;

				luigidies.alpha = 0;

				luigidies.blend = MULTIPLY;

				luigidies.scale.set(2, 2);
				add(luigidies);
			case 'realbg':
					enemyY = dad.y;
					snapCamFollowToPos(1020, 650);
					dad.color = 0xFF608B60;
					customHB.alpha = 0;
					iconP1.alpha = 0;
					iconP2.alpha = 0;
	
			case 'superbad':
					snapCamFollowToPos(280, 400);
	
			case 'directstream':
					snapCamFollowToPos(1011, 508.5);
	
			case 'bootleg':
					snapCamFollowToPos(850, -930);
					isCameraOnForcedPos = true;
			
			case 'promoshow':
				snapCamFollowToPos(804, 742);

			case 'forest':
					var colornew:Int = 0xFF93ADB5;
					dadGroup.color = colornew;
					gfGroup.color = colornew;
					boyfriendGroup.color = colornew;
			}
		RecalculateRating();

		// PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3');

		if (curStage == 'racing')
		{
			CoolUtil.precacheSound('shellhit');
		}
		if (curStage == 'exeport')
		{
			CoolUtil.precacheSound('warningmx');
		}
		if (curStage == 'turmoilsweep')
		{
			CoolUtil.precacheSound('TURMOIL-LENGUETAZO');
		}
		if (curStage == 'meatworld')
		{
			CoolUtil.precacheSound('FAILGUN');
		}
		if (curStage == 'somari')
		{
			CoolUtil.precacheSound('ringhit');
		}
		if(curStage == 'castlestar'){
			CoolUtil.precacheSound('psPre');
			CoolUtil.precacheSound('psAtt');
		}

		discName = PlayState.SONG.song.replace(' ', '');

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, newName + legacycheck, discName.toLowerCase(), iconP2.getCharacter().toLowerCase());
		#end

		callOnLuas('onCreatePost', []);

		super.create();
	}

	public function lofiTweensToBeCreepyTo(sprite:FlxSprite):Void
	{
		var tempx = sprite.x;
		// this tween chain is an abomination
		nesTweens.push(FlxTween.tween(sprite, {x: tempx + 420, angle: -35}, 4.0, {
			onComplete: function(tween:FlxTween)
			{
				nesTweens.push(FlxTween.tween(sprite, {angle: 20}, 2.0, {
					onComplete: function(tween:FlxTween)
					{
						nesTweens.push(FlxTween.tween(sprite, {x: tempx + 400, angle: 30}, 2.0, {
							onComplete: function(tween:FlxTween)
							{
								nesTweens.push(FlxTween.tween(sprite, {x: tempx + 420, angle: 0}, 2.0, {
									onComplete: function(tween:FlxTween)
									{
										nesTweens.push(FlxTween.tween(sprite, {x: tempx + 520, angle: -15}, 3.0, {
											onComplete: function(tween:FlxTween)
											{
												nesTweens.push(FlxTween.tween(sprite, {angle: 10}, 1.5, {
													onComplete: function(tween:FlxTween)
													{
														nesTweens.push(FlxTween.tween(sprite, {x: tempx - 50, angle: -40}, 5.5, {
															onComplete: function(tween:FlxTween)
															{
																nesTweens.push(FlxTween.tween(sprite, {x: tempx, angle: 0}, 1.5));
															}
														}));
													}
												}));
											}
										}));
									}
								}));
							}
						}));
					}
				}));
			}
		}));
	}

	public function transitionOGN(inOut:Bool, imgonnakillsomeone:Bool)
	{
		if (inOut)
		{
			shaderOGN += 0.05;
			cast(boyfriend.shader, SilhouetteShader).update(0.05);
			cast(dad.shader, SilhouetteShader).update(0.05);

			if (imgonnakillsomeone)
			{
				extraTimers.push(new FlxTimer().start(1.05, function(tmr:FlxTimer)
				{
					shaderOGN += 0.04999;
					cast(boyfriend.shader, SilhouetteShader).update(0.04999);
					cast(dad.shader, SilhouetteShader).update(0.04999);
				}));
			}

			if (shaderOGN < 0.95)
			{
				extraTimers.push(new FlxTimer().start(0.05, function(tmr:FlxTimer)
				{
					transitionOGN(true, false);
				}));
			}
		}
		else
		{
			shaderOGN -= 0.05;
			cast(boyfriend.shader, SilhouetteShader).update(-0.05);
			cast(dad.shader, SilhouetteShader).update(-0.05);

			if (imgonnakillsomeone)
			{
				extraTimers.push(new FlxTimer().start(1.05, function(tmr:FlxTimer)
				{
					shaderOGN -= 0.04999;
					cast(boyfriend.shader, SilhouetteShader).update(-0.04999);
					cast(dad.shader, SilhouetteShader).update(-0.04999);
				}));
			}

			if (shaderOGN > 0.05)
			{
				extraTimers.push(new FlxTimer().start(0.05, function(tmr:FlxTimer)
				{
					transitionOGN(false, false);
				}));
			}
		}
	}

	function bfJump(){

		boyfriend.visible = false;
		funnylayer0.visible = true;
		funnylayer0.animation.play('jump');
		FlxG.sound.play(Paths.sound('bfjump'));
		
		
		if(!cpuControlled){
		isDodging = true;
		canDodge = true;
		}
		eventTimers.push(new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			eventTweens.push(FlxTween.tween(funnylayer0, {y: funnylayer0.y - 250}, 0.3, {
				ease: FlxEase.expoOut,
				onComplete: function(twn:FlxTween)
				{
					eventTweens.push(FlxTween.tween(funnylayer0, {y: funnylayer0.y + 420}, 0.3, {
						ease: FlxEase.expoIn,
						onComplete: function(twn:FlxTween)
						{
							funnylayer0.x += 10;
							funnylayer0.y += 100;
							if(!cpuControlled) isDodging = false;
							funnylayer0.animation.play('jumpend');
						}
					}));
				}
			}));
		}));
		eventTimers.push(new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			boyfriend.visible = true;
			funnylayer0.visible = false;
			funnylayer0.y -= 270;
			funnylayer0.x -= 10;
		}));
		eventTimers.push(new FlxTimer().start(1.23, function(tmr:FlxTimer)
		{
			if(!cpuControlled) canDodge = false;
		}));
	}

	public function addTextToDebug(text:String)
	{
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText)
		{
			spr.y += 20;
		});
		luaDebugGroup.add(new DebugLuaText(text, luaDebugGroup));
		#end
	}

	public function reloadHealthBarColors()
	{
		if (Reflect.getProperty(iconP1, 'char') == gf.healthIcon && gf.curCharacter == 'luigi-ldo')
		{
			healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
				FlxColor.fromRGB(gf.healthColorArray[0], gf.healthColorArray[1], gf.healthColorArray[2]));
		}
		else if(curStage == 'piracy'){
			healthBar.createImageBar(Paths.image('modstuff/bar1'), Paths.image('modstuff/bar2'), FlxColor.WHITE, FlxColor.BLACK);
			healthBar.setGraphicSize(Std.int(healthBar.width * 2.71));
			healthBar.antialiasing = false;
		}
		else if(curStage == 'allfinal' && gf.curCharacter == 'lg2'){
			healthBar.createFilledBar(FlxColor.fromRGB(gf.healthColorArray[0], gf.healthColorArray[1], gf.healthColorArray[2]),
				FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		}
		else
		{
			healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
				FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		}

		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int)
	{
		switch (type)
		{
			case 0:
				if (!boyfriendMap.exists(newCharacter))
				{
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					newBoyfriend.alreadyLoaded = false;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if (!dadMap.exists(newCharacter))
				{
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					newDad.alreadyLoaded = false;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if (!gfMap.exists(newCharacter))
				{
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					newGf.alreadyLoaded = false;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		if (FileSystem.exists(Paths.modFolders(luaFile)))
		{
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		}
		else
		{
			luaFile = Paths.getPreloadPath(luaFile);
			if (FileSystem.exists(luaFile))
			{
				doPush = true;
			}
		}

		if (doPush)
		{
			for (lua in luaArray)
			{
				if (Reflect.getProperty(lua, 'scriptName') == luaFile)
					return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false)
	{
		if (gfCheck && char.curCharacter.startsWith('gf'))
		{ // IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String):Void
	{
			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			bg.cameras = [camOther];
			bg.scrollFactor.set(0, 0);
			add(bg);

			eventTimers.push(new FlxTimer().start(0.32, function(tmr:FlxTimer)
				{
					bg.destroy();
				}));

			inCutscene = true;
			cutVid = new VideoSprite();
			cutVid.scrollFactor.set(0, 0);
			cutVid.playVideo(Paths.video(name));
			cutVid.cameras = [camOther];
			add(cutVid);
			cancelFadeTween();
			CustomFadeTransition.nextCamera = null;

			if(SONG.song.toLowerCase() == 'demise'){
				cutVid.finishCallback = function()
				{
					remove(cutVid);
					camHUD.flash(FlxColor.RED, 2);
				}
				eventTimers.push(new FlxTimer().start(0.32, function(tmr:FlxTimer)
				{
					startCountdown();
				}));				
			}
			else{
				cutVid.finishCallback = function()
				{
					finishVideo();
				}
			}

			if(SONG.song.toLowerCase() == 'abandoned'){
				new FlxTimer().start(18.4, function(tmr:FlxTimer)
				{
					startCountdown();
				});
			}
	}

	public function finishVideo():Void{
		remove(cutVid);
		if(SONG.song.toLowerCase() != 'abandoned'){
			if (endingSong)
			{
				cancelFadeTween();
				CustomFadeTransition.nextCamera = camOther;
				if (FlxTransitionableState.skipNextTransIn)
				{
					CustomFadeTransition.nextCamera = null;
				}
				if(isWarp)
					MusicBeatState.switchState(new WarpState());
				else
					MusicBeatState.switchState(new MainMenuState());
			}
			else
			{
				startCountdown();
			}
		}else{
			Conductor.songPosition = -10000;
			startCountdown();
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countDownSprites:Array<FlxSprite> = [];

	public function startCountdown():Void
	{
		if (startedCountdown)
		{
			callOnLuas('onStartCountdown', []);
			return;
		}

		if (curStage == 'warioworld')
		{
			eventTweens.push(FlxTween.tween(boyfriend, {y: boyfriend.y + 10}, 0.15, {ease: FlxEase.quadInOut, type: PINGPONG}));
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if (ret != FunkinLua.Function_Stop)
		{
			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			modManager.receptors = [playerStrums.members, opponentStrums.members];
			callOnLuas('preModifierRegister', []);
			modManager.registerDefaultModifiers();
			callOnLuas('postModifierRegister', []);
			Modcharts.loadModchart(modManager, SONG.song);
			// modManager.setValue("tipsy", 1);

			if (curStage == 'exeport')
			{
				FlxG.sound.playMusic(Paths.music('staticloop'), 0.5, true);
				enemyY = dad.y;
				eventTimers.push(new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					startedCountdown = true;
				}));
				eventTimers.push(new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					eventTweens.push(FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.5));
					eventTweens.push(FlxTween.tween(liveScreen, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut}));
					eventTweens.push(FlxTween.tween(camHUD, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut}));
				}));
			}
			else if (curStage == 'bootleg')
			{
				var blackthing = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackthing.setGraphicSize(Std.int(blackthing.width * 10));
				blackthing.alpha = 1;
				blackthing.cameras = [camOther];
				add(blackthing);
				eventTweens.push(FlxTween.tween(blackthing, {alpha: 0}, 0.5, {startDelay: 1.4, ease: FlxEase.quadInOut}));
				eventTweens.push(FlxTween.tween(camGame, {zoom: 0.6}, (2 * (1 / (Conductor.bpm / 60))), {startDelay: 1.8, ease: FlxEase.expoOut}));

				FlxG.sound.play(Paths.sound('gdstart'), 0.6);
				startedCountdown = true;
			}
			else if (curStage == 'somari')
			{
				var countmix:FlxSprite = new FlxSprite().loadGraphic(Paths.image('pixelUI/countdown'));
				countmix.width = countmix.width / 4;
				countmix.height = countmix.height / 2;
				countmix.loadGraphic(Paths.image('pixelUI/countdown'), true, Math.floor(countmix.width), Math.floor(countmix.height));
				countmix.scale.set(6, 6);
				countmix.antialiasing = false;
				countmix.visible = false;
				countmix.cameras = [camHUD];
				countmix.updateHitbox();
				countmix.screenCenter();
				countmix.animation.add("3", [0, 4], 10, true);
				countmix.animation.add("2", [1, 5], 10, true);
				countmix.animation.add("1", [2, 6], 10, true);
				countmix.animation.add("go", [3, 7], 10, true);
				add(countmix);

				eventTimers.push(new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxG.sound.play(Paths.sound('mixcountdown'), 0.6);
					countmix.animation.play("3");
					countmix.visible = true;
				}));
				eventTimers.push(new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					startedCountdown = true;
					FlxG.sound.play(Paths.sound('mixcountdown'), 0.6);
					countmix.animation.play("2");
				}));
				eventTimers.push(new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					FlxG.sound.play(Paths.sound('mixcountdown'), 0.6);
					countmix.animation.play("1");
				}));
				eventTimers.push(new FlxTimer().start(4, function(tmr:FlxTimer)
				{
					FlxG.sound.play(Paths.sound('mixcountdownend'), 0.6);
					countmix.animation.play("go");
				}));
				eventTimers.push(new FlxTimer().start(5, function(tmr:FlxTimer)
				{
					remove(countmix);
					countmix.destroy();
				}));
			}
			else if (curStage == 'landstage')
			{
				startedCountdown = true;
				var blackthing = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackthing.setGraphicSize(Std.int(blackthing.width * 10));
				blackthing.alpha = 1;
				blackthing.cameras = [camOther];
				add(blackthing);

				FlxTween.tween(blackthing, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
			}
			else if(curStage == 'virtual'){
				camHUD.alpha = 0;
				CoolUtil.precacheSound('virtualintro');
				eventTimers.push(new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxG.sound.play(Paths.sound('virtualintro'));
				blackBarThingie.alpha = 0;
				camGame.zoom = 1;
				eventTweens.push(FlxTween.tween(camGame, {zoom: 0.5}, 1.3, {ease: FlxEase.expoOut}));
				startedCountdown = true;
				effect.setStrength(40, 40);
				FlxTween.num(40, 1, 0.7, function(v)
				{
					effect.setStrength(v, v);
				});
				}));
				}
			else if(curStage == 'hatebg' || curStage == 'forest'){
				if(PlayState.SONG.song == 'Oh God No'){
				eventTimers.push(new FlxTimer().start(2, function(tmr:FlxTimer)
					{
				eventTweens.push(FlxTween.tween(introM, {x: 400}, 1.5, {onComplete: function(twn:FlxTween)
					{
						introM.animation.play('stand');
						eventTimers.push(new FlxTimer().start(0.8, function(tmr:FlxTimer)
							{
								introM.animation.play('look');
								eventTweens.push(FlxTween.tween(introL, {x: 800}, 1.5, {onComplete: function(twn:FlxTween){
									introM.animation.play('huh');
									introL.animation.play('stand');
								}}));
							}));
					}}));
				}));

				eventTimers.push(new FlxTimer().start(4, function(tmr:FlxTimer)
					{
						startedCountdown = true;
					}));
				}else{
				startedCountdown = true;
				}
				eventTimers.push(new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						startbf.alpha = 1;
						FlxG.sound.play(Paths.sound('smw_coin'));
					}));
					eventTimers.push(new FlxTimer().start(1.8, function(tmr:FlxTimer)
					{
						startbf.alpha = 0;
						eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 0}, 1, {ease: FlxEase.quadOut}));
					}));
			}
			else if (curStage == 'execlassic')
			{
				startedCountdown = true;
				var blackthing = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackthing.setGraphicSize(Std.int(blackthing.width * 10));
				blackthing.alpha = 1;
				blackthing.cameras = [camHUD];
				add(blackthing);

				FlxTween.tween(blackthing, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
			}
			else
			{
				startedCountdown = true;
			}

			Conductor.songPosition = 0;
			if(SONG.song.toLowerCase() != 'demise')
				Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);

			var swagCounter:Int = 0;

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (!noCount){
					if (tmr.loopsLeft % gfSpeed == 0
						&& !gf.stunned
						&& gf.animation.curAnim.name != null
						&& !gf.animation.curAnim.name.startsWith("sing"))
					{
						gf.dance();
					}
					if (tmr.loopsLeft % 2 == 0)
					{
						if (boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing'))
						{
							boyfriend.dance();
						}
						if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
						{
							dad.dance();
						}
					}
					else if (dad.danceIdle
						&& dad.animation.curAnim != null
						&& !dad.stunned
						&& !dad.curCharacter.startsWith('gf')
						&& !dad.animation.curAnim.name.startsWith("sing"))
					{
						dad.dance();
					}
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if (isPixelStage)
				{
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				if (curStage == 'landstage' && PlayState.SONG.song != 'Golden Land Old')
				{
					// bgfeo.dance(true);
					minustime = -97.073;
				}

				if (PlayState.SONG.song == 'Demise')
				{
					// bgfeo.dance(true);
					minustime = -20.10;
				}

				if (curStage == 'nesbeat')
				{
					//minustime = -142.907;
				}

				if (!noCount)
				{
					switch (swagCounter)
					{
						case 0:
							FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
						case 1:
							var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
							ready.scrollFactor.set();
							ready.updateHitbox();
							ready.cameras = [camOther];

							if (PlayState.isPixelStage)
								ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

							ready.screenCenter();
							ready.antialiasing = antialias;
							add(ready);
							countDownSprites.push(ready);
							FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									countDownSprites.remove(ready);
									remove(ready);
									ready.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
						case 2:
							var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
							set.scrollFactor.set();

							if (PlayState.isPixelStage)
								set.setGraphicSize(Std.int(set.width * daPixelZoom));

							set.screenCenter();
							set.antialiasing = antialias;
							set.cameras = [camOther];
							add(set);
							countDownSprites.push(set);
							FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									countDownSprites.remove(set);
									remove(set);
									set.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
						case 3:
							var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
							go.scrollFactor.set();

							if (PlayState.isPixelStage)
								go.setGraphicSize(Std.int(go.width * daPixelZoom));

							go.updateHitbox();

							go.screenCenter();
							go.cameras = [camOther];
							go.antialiasing = antialias;
							add(go);
							countDownSprites.push(go);
							FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									countDownSprites.remove(go);
									remove(go);
									go.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
						case 4:
					}

					notes.forEachAlive(function(note:Note)
					{
						note.copyAlpha = false;
						note.alpha = 1 * note.multAlpha;
					});
					callOnLuas('onCountdownTick', [swagCounter]);

					if (generatedMusic)
					{
						notes.sort(FlxSort.byY, hasDownScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
					}

					swagCounter += 1;
					// generateSong('fresh');
				}
			}, 5);
		}
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = finishSong;
		instALT.play();
		vocals.play();

		if (paused)
		{
			// trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			instALT.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		// timebarthing = songLength + (minustime * 1000);

		if(curStage == 'piracy'){
			triggerEventNote('Show Song', '0', '');
		}
		else if (curStage == 'demiseport'){
			demcut1.visible = false;
			demcut2.visible = false;
			demcut3.visible = false;
			demcut4.visible = false;

			demcut1.alpha = 1;
			demcut2.alpha = 1;
			demcut3.alpha = 1;
			demcut4.alpha = 1;
		}
		
		if(curStage != 'betamansion'){
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, newName + legacycheck, discName.toLowerCase(), iconP2.getCharacter().toLowerCase(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	public function set_songSpeed(value:Float):Float
	{
		return SONG.speed;
	}

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		
		if (curStage == 'wetworld' || (curStage == 'meatworld' && PlayState.SONG.song != 'Overdue Old')){
			instALT = new FlxSound().loadEmbedded(Paths.sound(curStage + 'instALT'));

		}else{
			instALT = new FlxSound();
		}

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(instALT);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json('songData/' + songName + '/events');
		#if sys
		if (FileSystem.exists(Paths.modsJson('songData/' + songName + '/events')) || FileSystem.exists(file))
		{
		#else
		if (OpenFlAssets.exists(file))
		{
		#end
			var eventsData:Array<SwagSection> = Song.loadFromJson('events', songName).notes;
			for (section in eventsData)
			{
				for (songNotes in section.sectionNotes)
				{
					if (songNotes[1] < 0)
					{
						eventNotes.push([songNotes[0], songNotes[1], songNotes[2], songNotes[3], songNotes[4]]);
						eventPushed(songNotes);
					}
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				if (songNotes[1] > -1)
				{ // Real notes
					var daStrumTime:Float = songNotes[0];
					var daNoteData:Int = Std.int(songNotes[1] % 4);

					var gottaHitNote:Bool = section.mustHitSection;

					if (songNotes[1] > 3)
					{
						gottaHitNote = !section.mustHitSection;
					}
					var oldNote:Note;

					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;
					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.mustPress = gottaHitNote;
					swagNote.sustainLength = songNotes[2];
					swagNote.noteType = songNotes[3];
					if (!Std.isOfType(songNotes[3], String))
						swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; // Backward compatibility + compatibility with Week 7 charts
					swagNote.scrollFactor.set();
					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);
					var floorSus:Int = Math.floor(susLength);

					if (floorSus > 0)
					{
						for (susNote in 0...floorSus + 1)
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
							var sustainNote:Note = new Note(daStrumTime
								+ (Conductor.stepCrochet * susNote)
								+ (Conductor.stepCrochet / FlxMath.roundDecimal(SONG.speed, 2)), daNoteData,
								oldNote, true);
							sustainNote.mustPress = gottaHitNote;
							sustainNote.noteType = swagNote.noteType;
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);
							if (sustainNote.mustPress)
							{
								sustainNote.x += FlxG.width / 2; // general offset
							}
						}
					}
					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2; // general offset
					}
					else {}
					if (!noteTypeMap.exists(swagNote.noteType))
					{
						noteTypeMap.set(swagNote.noteType, true);
					}
				}
				else
				{ // Event Notes
					eventNotes.push([songNotes[0], songNotes[1], songNotes[2], songNotes[3], songNotes[4]]);
					eventPushed(songNotes);
				}
			}
			daBeats += 1;
		}
		// trace(unspawnNotes.length);
		// playerCounter += 1;
		unspawnNotes.sort(sortByShit);
		if (eventNotes.length > 1)
		{ // No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:Array<Dynamic>)
	{
		switch (event[2])
		{
			case 'Change Character':
				var charType:Int = 0;
				switch (event[3].toLowerCase())
				{
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(event[3]);
						if (Math.isNaN(charType)) charType = 0;
				}
			case 'Triggers Race Traitors':
				var charType:Int = 0;
				switch (event[3].toLowerCase())
				{
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(event[3]);
						if (Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event[4];
				addCharacterToList(newCharacter, charType);
		}

		if (!eventPushedMap.exists(event[2]))
		{
			eventPushedMap.set(event[2], true);
		}
	}

	function eventNoteEarlyTrigger(event:Array<Dynamic>):Float
	{
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event[2]]);
		if (returnedValue != 0)
		{
			return returnedValue;
		}

		switch (event[2])
		{
			case 'Kill Henchmen': // Better timing so that the kill sound matches the beat intended
				return 280; // Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		var earlyTime1:Float = eventNoteEarlyTrigger(Obj1);
		var earlyTime2:Float = eventNoteEarlyTrigger(Obj2);
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0] - earlyTime1, Obj2[0] - earlyTime2);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			if (!isStoryMode && curStage != 'somari')
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}

		if(!PlayState.isPixelStage){
			if(cpuControlled){
				for(note in playerStrums.members){
					note.updateNoteSkin('Luigi_NOTE_assets');
					note.playAnim('static');
				}
				for(note in opponentStrums.members){
					note.updateNoteSkin('Luigi_NOTE_assets');
					note.playAnim('static');
				}
		}
		else{
			for(note in playerStrums.members)
				note.updateNoteSkin('Mario_NOTE_assets');
			for(note in opponentStrums.members)
				note.updateNoteSkin('Mario_NOTE_assets');
		}
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				instALT.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length)
			{
				if (chars[i].colorTween != null)
				{
					chars[i].colorTween.active = false;
				}
			}

			for (tween in modchartTweens)
			{
				tween.active = false;
			}
			for (timer in modchartTimers)
			{
				timer.active = false;
			}

			if (eventTweens != null)
			{
				for (tween in eventTweens)
				{
					tween.active = false;
				}
			}
			if (lavaTween != null)
			{
				lavaTween.active = false;
			}
			if (extraTween != null)
			{
				for (tween in extraTween)
				{
					tween.active = false;
				}
			}
			if (windowTween != null)
			{
				for (tween in windowTween)
				{
					tween.active = false;
				}
			}
			if (eventTimers != null)
			{
				for (timer in eventTimers)
				{
					timer.active = false;
				}
			}
			if (extraTimers != null)
			{
				for (timer in extraTimers)
				{
					timer.active = false;
				}
			}
			if (funnyTimers != null)
				{
					for (timer in funnyTimers)
					{
						timer.active = false;
					}
				}

			if (nesTweens != null)
			{
				for (tween in nesTweens)
				{
					tween.active = false;
				}
			}
			if (nesTimers != null)
			{
				for (timer in nesTimers)
				{
					timer.active = false;
				}
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if(curStage != 'virtual' && curStage != 'landstage' && curStage != 'somari' && curStage != 'endstage' && curStage != 'piracy'){
				if(cpuControlled){
					for(note in playerStrums.members){
						note.updateNoteSkin('Luigi_NOTE_assets');
						note.playAnim('static');
					}
					for(note in opponentStrums.members){
						note.updateNoteSkin('Luigi_NOTE_assets');
						note.playAnim('static');
					}
				}
				else{
					for(note in playerStrums.members)
						note.updateNoteSkin('Mario_NOTE_assets');
					for(note in opponentStrums.members)
						note.updateNoteSkin('Mario_NOTE_assets');
				}
			}

			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length)
			{
				if (chars[i].colorTween != null)
				{
					chars[i].colorTween.active = true;
				}
			}

			for (tween in modchartTweens)
			{
				tween.active = true;
			}
			for (timer in modchartTimers)
			{
				timer.active = true;
			}
			if (eventTweens != null)
			{
				for (tween in eventTweens)
				{
					tween.active = true;
				}
			}
			if (lavaTween != null)
			{
				lavaTween.active = true;
			}
			if (extraTween != null)
			{
				for (tween in extraTween)
				{
					tween.active = true;
				}
			}
			if (windowTween != null)
			{
				for (tween in windowTween)
				{
					tween.active = true;
				}
			}
			if (eventTimers != null)
			{
				for (timer in eventTimers)
				{
					timer.active = true;
				}
			}
			if (extraTimers != null)
			{
				for (timer in extraTimers)
				{
					timer.active = true;
				}
			}
			if (nesTweens != null)
			{
				for (tween in nesTweens)
				{
					tween.active = true;
				}
			}
			if (nesTimers != null)
			{
				for (timer in nesTimers)
				{
					timer.active = true;
				}
			}

			if(luigidies != null) luigidies.bitmap.resume();
			if(midsongVid != null) midsongVid.bitmap.resume();
			if(cutVid != null && SONG.song.toLowerCase() == 'demise') cutVid.bitmap.resume();

			paused = false;
			callOnLuas('onResume', []);

			if(curStage != 'landstage' && curStage != 'virtual')
			if(cpuControlled){
				timeBar.createFilledBar(0xFF000000, 0xFF25cd49);
				timeBar.numDivisions = 800;
			}
			else{
				timeBar.createFilledBar(0xFF000000, 0xFFF42626);
				timeBar.numDivisions = 800;
			}
				
			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, newName
					+ legacycheck, discName.toLowerCase(), iconP2.getCharacter().toLowerCase(), true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, newName + legacycheck, discName.toLowerCase(), iconP2.getCharacter().toLowerCase());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, newName
					+ legacycheck, discName.toLowerCase(), iconP2.getCharacter().toLowerCase(), true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, newName + legacycheck, discName.toLowerCase(), iconP2.getCharacter().toLowerCase());
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, newName + legacycheck, discName.toLowerCase(), iconP2.getCharacter().toLowerCase());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if (finishTimer != null)
			return;

		vocals.pause();
		instALT.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		instALT.time = Conductor.songPosition;

		vocals.play();
		instALT.play();

	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
	}*/

		if(angel != null){
			if(curStage != 'virtual' && ClientPrefs.flashing)
				angel.strength = FlxMath.lerp(angel.strength, 0, CoolUtil.boundTo(elapsed * 4, 0, 1));
			else
				angel.strength = FlxMath.lerp(angel.strength, 0, CoolUtil.boundTo(elapsed * 8, 0, 1));

			angel.pixelSize = FlxMath.lerp(angel.pixelSize, 1, CoolUtil.boundTo(elapsed * 4, 0, 1));
			angel.data.iTime.value = [Conductor.songPosition / 1000];

		}
		if(cpuControlled && (curStage != 'virtual' && curStage != 'landstage' && curStage != 'somari' && curStage != 'endstage' && curStage != 'piracy')){
			notes.forEachAlive(function(note:Note){
				if(note.botplaySkin)
					note.reloadNote('', 'Luigi_NOTE_assets');
			});
		}
		if (tvEffect && ClientPrefs.filtro85)
		{
			vcr.update(elapsed);
		}

		if (oldTV && ClientPrefs.filtro85)
		{
			oldFX.update(elapsed);
		}

		if(curStage == 'piracy'){
			if(dsTimer <= 0){
				if(canvas.visible) writeGone();
			}else{
				writeText.text = '' + Math.round(dsTimer * 10) / 10;
				dsTimer -= elapsed;
			}
		}

		if (curStage == 'nesbeat' )
			{
				if(fireBar.animation.curAnim.finished){
						fireBar.animation.play('loop');
						if(fireBar.angle >= (90 * 3))
							fireBar.angle = 0;
						else
							fireBar.angle += 90;
				}
				if(fireBar.visible){
				var placeVals:Array<Dynamic> = [[270, 2, 7, 1.9], [0, 0, 2, 1.7], [0, 3, 4, 1.5], [0, 5, 7, 1], [90, 0, 3, 1.3]];

				for(i in 0... placeVals.length){
					if(fireBar.angle == placeVals[i][0] && fireBar.animation.frameIndex >= placeVals[i][1] && fireBar.animation.frameIndex <= placeVals[i][2]){
					if(health > placeVals[i][3]){
					health -= elapsed * 2;

					eventTweens.push(FlxTween.angle(iconP1, FlxG.random.float(-20, 20), 0, ((1 / (Conductor.bpm / 60))), {ease: FlxEase.backOut}));
					eventTweens.push(FlxTween.color(iconP1, (1 / (Conductor.bpm / 60)), 0xFF3B3B3B, FlxColor.WHITE, {ease: FlxEase.circOut}));
					}
					}
				}
				}

				if(ClientPrefs.filtro85 && endingnes){
					val += elapsed;
					val /= 4;
					beatend.update(val, elapsed);
				}
			}
		
			if(staticShader != null){
				staticShader.update(elapsed);
			}

		if(ClientPrefs.framerate <= maxLuaFPS){

			callOnLuas('onUpdate', [elapsed]);
		}
		else {
			numCalls[0]+=1;
			fpsElapsed[0]+=elapsed;
			if(numCalls[0] >= Std.int(ClientPrefs.framerate/maxLuaFPS)){
				//trace("New Update");
				callOnLuas('onUpdate', [fpsElapsed[0]]);
				fpsElapsed[0]=0;
				numCalls[0]=0;

			}
		}
		
		if (!inCutscene)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);

			if(generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null){
				var curSection = Std.int(curStep / 16);
				//trace(SONG.notes[Math.floor(curStep / 16)].mustHitSection);
				if (!endingSong){
					if (ZOOMCHARS)
					{
						if(SONG.notes[curSection].mustHitSection){
							if (GFSINGBF)
								defaultCamZoom = GF_ZOOM;
								else
								defaultCamZoom = BF_ZOOM;
						}
						else{
							if (GFSINGDAD)
								defaultCamZoom = GF_ZOOM;
							else
								defaultCamZoom = DAD_ZOOM;
						}
					}
					if (FOLLOWCHARS)
					{
						if(!SONG.notes[curSection].mustHitSection){
							if (GFSINGDAD){
								camFollow.x = GF_CAM_X;
								camFollow.y = GF_CAM_Y;
							}
							else{
								camFollow.x = DAD_CAM_X;
								camFollow.y = DAD_CAM_Y;
							}
						}
						else{
							if (GFSINGBF){
								camFollow.x = GF_CAM_X;
								camFollow.y = GF_CAM_Y;
							}
							else{
								camFollow.x = BF_CAM_X;
								camFollow.y = BF_CAM_Y;
							}
						}
					}
				}
			}

			if(FOLLOWCHARS)
				camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x + camDisplaceX, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y + camDisplaceY, lerpVal));
			
			if (!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle'))
			{
				boyfriendIdleTime += elapsed;
				if (boyfriendIdleTime >= 0.15)
				{ // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			}
			else
			{
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		if (curStage == 'superbad'){
			if(badGrad1.alpha >= (ClientPrefs.flashing ? 0.15 : 0.1))
				badGrad1.alpha -= 0.01;
			if(badGrad2.alpha >= (ClientPrefs.flashing ? 0.15 : 0.1))
				badGrad2.alpha -= 0.01;
			if(badPoisonVG.alpha >= 0){}
				badPoisonVG.alpha -= 0.0005;

			if (!ClientPrefs.lowQuality){
			if (badRipple != null){
				// trace(badRipple.iTime.value[0]);
				badRipple.iTime.value[0] += elapsed;
				badRipple.max_po.value[0] = badPoisonVG.alpha * 45;
			}
			}
		}

		if (curStage == 'wetworld')
			{
				if (flooding)
				{
					if (flood.y < 660){
						// health -= 0.9 / (flood.y + 100); //old damage equation, changed for more linear health drain
						health -= (((((flood.y + 90) / 750) - 1) * -1) / 160) * (60 * elapsed);
					}
					
					if(flood.y >= -90){
						flood.y -= 1.5 * (60 * elapsed);
						//trace(elapsed); PORFAVOR NATE STOP :hand_splayed: 
					}
				}
				else{

				}
				if (flood.y > 720)
					flood.y = 720;

				if (flood.y < 390){
					instALT.volume = ((((flood.y + 90) / 480) - 1) * -1);
					FlxG.sound.music.volume = ((flood.y + 90) / 480);
					vocals.volume = 0.5 + ((flood.y + 90) / 960);
					vocalvol = vocals.volume;
					
				}
				else{
					vocals.volume = vocalvol;
					instALT.volume = 0;
					vocalvol = 1;
					FlxG.sound.music.volume = 1;
				}
			}

		if (curStage == 'somari')
		{
			scoreTxt.text = formatMario(songScore, 6);
			if(ring < 10){
				extrazero = '0';
			}
			else{
				extrazero = '';
			}
			ringcount.text = extrazero + ring;
		}
		else if (curStage == 'endstage' || (curStage == 'warioworld' && PlayState.SONG.song != 'Apparition Old' && PlayState.SONG.song != 'Forbidden Star'))
		{
			var newhealth:Int = Std.int(health * 100);
			if (newhealth >= 200)
				newhealth = 200;

			scoreTxt.text = "H:" + newhealth + "\nS:" + songScore;

			if (curStage == 'warioworld' && (PlayState.SONG.song != 'Apparition Old' && PlayState.SONG.song != 'Forbidden Star')){
				bftors.visible = bfext.visible = !(bftorsmiss.visible = bfextmiss.visible = boyfriend.animation.curAnim.name.endsWith('miss'));
				if(warioDead){
					//apparition game over confirm/exit
					if(controls.ACCEPT){
						FlxG.sound.music.volume = 0;
						FlxG.sound.play(Paths.music(GameOverSubstate.endSoundName));
						new FlxTimer().start(2, function(gef:FlxTimer)
							{
								eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 2.5, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
									{
										if(deathCounter == 3 && (isStoryMode || isWarp)){
											MusicBeatState.switchState(new BotplayState());
										}else{
											CustomFadeTransition.nextCamera = camOther;
											MusicBeatState.resetState();
										}
									}}));
							});
					}
					if(controls.BACK){
						ClientPrefs.saveSettings();
						FlxG.sound.music.stop();
						deathCounter = 0;
						seenCutscene = false;
	
						if (PlayState.isWarp)
						{
							MusicBeatState.switchState(new WarpState());
						}
						else
						{
							MusicBeatState.switchState(new MainMenuState());
						}
					}
				}
			}
			
			if (ClientPrefs.flashing){
				if (dad.curCharacter == 'costumedark' && dad.animation.curAnim.name != 'wahoo'){
					if (dad.animation.curAnim.name == 'idle'){
						extraTween.push(FlxTween.tween(dad, {alpha: 1}, 1.5, {ease: FlxEase.cubeOut}));
					}
				}
			}
		}
		else
		{
			if (ratingString == '?')
			{
				scoreTxt.text = 'Score: ' + songScore + '      Misses: ' + songMisses + '      Rating: ' + ratingString;
			}
			else
			{
				scoreTxt.text = 'Score: ' + songScore + '      Misses: ' + songMisses + '      Rating: ' + ratingString + ' (' + Math.floor(ratingPercent * 100)
					+ '%)';
			}
		}
		if(curStage == 'piracy'){
			scoreTxt.text = scoreTxt.text.toUpperCase();
			scoreTxt.text = scoreTxt.text.replace("      ", "  ");
		}

		if (curStage == 'realbg')
		{
			lifemetter.animation.play('life' + luigilife, true);
			if (health > 1.7)
			{
				health = 1.7;
			}
		}

		if (cpuControlled)
		{
			botplaySine += 180 * elapsed;

			
			if(curStage != 'virtual' && curStage != 'landstage' && curStage != 'somari' && curStage != 'endstage' && curStage != 'piracy'){
			luigiLogo.angle = ((1 - Math.sin((Math.PI * botplaySine) / 180)) * 20) - 20;
			}else{
				if(curStage == 'virtual' || curStage == 'landstage'){
					if(1 - Math.sin((Math.PI * (botplaySine * 2)) / 180) < 1){
						luigiLogo.alpha = 0;
					}else{
						luigiLogo.alpha = 1;
					}
				}
			}
		}
		luigiLogo.visible = cpuControlled;
		if(curStage != 'virtual' && curStage != 'landstage' && curStage != 'somari' && curStage != 'endstage' && curStage != 'piracy' && curStage != 'warioworld'){
			if(cpuControlled){
				if(curStage != 'forest' && curStage != 'hatebg'){
					timeTxt.color = 0xFF25cd49;
				}
				scoreTxt.color = 0xFF25cd49;
				customHBweegee.visible = true;	
			}
			else{
				if(curStage != 'forest' && curStage != 'hatebg'){
					timeTxt.color = 0xFFF42626;	
				}
				scoreTxt.color = 0xFFF42626;
				customHBweegee.visible = false;
			}
		}

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', []);
			if (ret != FunkinLua.Function_Stop)
			{
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// // 1 / 1000 chance for Gitaroo Man easter egg
				// if (FlxG.random.bool(0.05) && curStage != 'somari' && curStage != 'piracy' && curStage != 'virtual')
				// {
				// 	// gitaroo man easter egg
				// 	cancelFadeTween();
				// 	CustomFadeTransition.nextCamera = camOther;
				// 	MusicBeatState.switchState(new GitarooPause());
				// }
				// else
				// {
					if (FlxG.sound.music != null)
					{
						FlxG.sound.music.pause();
						vocals.pause();
						instALT.pause();
						FlxG.sound.play(Paths.sound('pauseb'));
					}

					if(luigidies != null) luigidies.bitmap.pause();
					if(midsongVid != null) midsongVid.bitmap.pause();
					if(cutVid != null && SONG.song.toLowerCase() == 'demise') cutVid.bitmap.pause();

					PauseSubState.transCamera = camOther;
					openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				// }

				#if desktop
				DiscordClient.changePresence(detailsPausedText, newName + legacycheck, discName.toLowerCase(), iconP2.getCharacter().toLowerCase());
				#end
			}
		}
		else if(FlxG.keys.justPressed.ENTER && inCutscene && cutVid != null && SONG.song.toLowerCase() != 'demise'){
			finishVideo();
			cutVid.bitmap.stop();
		}

		if (healthDrain > 0)
		{
			timerDrain -= elapsed;
			health -= healthDrain * (60 * elapsed);

			if (timerDrain <= 0)
				healthDrain = 0;
		}

		if (curStage == 'hatebg'
			&& !boyfriend.animation.curAnim.name.endsWith('miss')
			&& PlayState.SONG.song != 'I Hate You Old'
			&& PlayState.SONG.song != 'Oh God No')
		{
			capenose.animation.play('idle');
		}

		if (curStage == 'forest' && !boyfriend.animation.curAnim.name.endsWith('miss'))
		{
			capenose.animation.play('idle');
		}

		if (startwindow)
		{
			Lib.application.window.move(winx, winy);
		}
		else if (startresize)
		{
			Lib.application.window.resize(resizex, resizey);
			Lib.application.window.move(winx, winy);
		}

		if (PlayState.SONG.song == 'Oh God No')
		{
			// cast(boyfriend.shader, SilhouetteShader).update(shaderOGN);
			// cast(dad.shader, SilhouetteShader).update(shaderOGN);
		}

		if (FlxG.keys.justPressed.SEVEN && !endingSong && !inCutscene && ClientPrefs.storySave[7])
		{
			persistentUpdate = false;
			paused = true;
			if (getspeed != 0)
			{
				SONG.speed = getspeed;
			}
			cancelFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		#if debug
		if (FlxG.keys.justPressed.SEVEN && !endingSong && !inCutscene)
		{
			persistentUpdate = false;
			paused = true;
			if (getspeed != 0)
			{
				SONG.speed = getspeed;
			}
			cancelFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}
		#end

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		// iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));
		// iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;
		var iconOffset2:Int = 86;

		if (!flipchar)
		{
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

			if (curStage == 'piracy')
				{
					iconP1.x = (healthBar.x + (lifebar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset - 20)) * 3;
					iconP2.x = (healthBar.x + (lifebar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - ((iconP2.width - iconOffset) - 50)) * 3;
				}
		}
		else
		{
			if(curStage != 'meatworld' && !songIsModcharted && !inCutscene && !ClientPrefs.middleScroll)
				modManager.setValue("opponentSwap", 1);
			
			if(curStage == 'demiseport' || overFuckYou){
				iconOffset = 35;
				if(curStage == 'demiseport'){
					iconP2.x = healthBar.x + healthBar.width - 40;
					iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
				}
				if(overFuckYou){
					iconOffset = 640;
					iconP2.x = healthBar.x - 100;
					iconP1.x = healthBar.x - (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP1.width - iconOffset);
				}
			}else{
				iconOffset = 610;
				iconP1.x = healthBar.x - (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP1.width - iconOffset);
				iconP2.x = healthBar.x - (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP1.width - (iconOffset + iconOffset2));

			}
		}

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		
		if (curStage != 'demiseport' || overFuckYou){
			if (healthBar.percent > 80){
				iconP2.animation.curAnim.curFrame = 1;
				iconP2.angle = 0;
			}
			else
				iconP2.animation.curAnim.curFrame = 0;
				if(overFuckYou){
					var shF:Int = Math.floor(10 - (healthBar.percent / 10));
					iconP2.angle = FlxG.random.int(shF, shF * -1);
				}
		}
		else{
			if (healthBar.percent > 80)
				iconP2.animation.curAnim.curFrame = 1;
			else
				iconP2.animation.curAnim.curFrame = 0;
		}
		

		if (FlxG.keys.justPressed.EIGHT && !endingSong && !inCutscene)
		{
			persistentUpdate = false;
			paused = true;
			cancelFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if(curStage == 'meatworld'){
			if(dad.animation.curAnim.name == 'idle'){
				hallTLL1.animation.play('idle', true);
			}
		}

		if (curStage == 'directstream' && boyfriend.animation.curAnim.name == 'idle')
		{
			camBG.animation.play('down');
		}

		if (curStage == 'exeport')
		{
			if (PlayState.SONG.song != 'Powerdown Old')
			{
				if (killMX.animation.curAnim.name == 'yupi' && killMX.animation.curAnim.curFrame == 16)
				{
					gfFall.alpha = 1;
					gfFall.animation.play('fallgirls');
				}

				if (gfFall.animation.curAnim.name == 'fallgirls' && gfFall.animation.curAnim.finished)
				{
					gfFall.alpha = 0;
					gfFall.animation.play('fallgirls');
					gfFall.animation.curAnim.paused = true;
					gfwasTaken.alpha = 1;
					gfwasTaken.animation.play('fallgu');
				}
			}
		}

		if(curStage == 'demiseport'){
			demcut2.x = demcut1.x + 650;
			demcut3.x = demcut1.x + 1100;
			demcut4.x = demcut1.x + 270;

			demcut2.y = demcut1.y;
			demcut3.y = demcut1.y + 370;
			demcut4.y = demcut1.y + 30;

			if(demcut1.animation.frameIndex == 17 && demcut1.alpha == 1 && demcut1.visible == true){
				eventTweens.push(FlxTween.tween(demcut1, {y: -600, x: -200}, 5, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
					{
						eventTweens.push(FlxTween.tween(demcut1, {x: -300}, 2.5, {ease: FlxEase.quadInOut, type: PINGPONG}));
						eventTweens.push(FlxTween.tween(demcut1, {y: -500}, 4, {ease: FlxEase.quadInOut, type: PINGPONG}));
					}}));
			}

			if(demcut1.animation.frameIndex == 232 && demcut1.alpha == 1 && demcut1.visible == true){
				demcut1.visible = false;
				demcut2.visible = false;
				demcut3.visible = false;
				demcut4.visible = false;
				gordobondiola.visible = false;

				boyfriend.alpha = 1;
				dad.alpha = 1;
			}
		}


		if(curStage == 'hatebg' && boyfriend.animation.curAnim.name == 'attack' && boyfriend.animation.curAnim.finished)
			{
				capenose.x = boyfriendGroup.x + 260;
				capenose.visible = true;
			}

		if (startingSong)
		{
			if (startedCountdown)
			{
				
				if (curStage == 'luigiout' || curStage == 'secretbg')
				{
					Conductor.songPosition = 0;
					eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 0}, 0.5, {startDelay: 1, ease: FlxEase.quadInOut}));
				}
				if (curStage == 'demiseport' || curStage == 'castlestar')
					{
						Conductor.songPosition = 0;
					}
				else if (curStage == 'wetworld')
					{
						camEst.zoom = 0.5;
						eventTweens.push(FlxTween.tween(camEst, {zoom: 1}, 12, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(redTV, {alpha: 1}, 10, {ease: FlxEase.quadInOut}));
						if (ClientPrefs.flashing){
							eventTweens.push(FlxTween.tween(redTVStat, {alpha: 1}, 10, {ease: FlxEase.quadInOut}));
						}else{
							redTVStat.animation.play("justStat");
							add(redTVImg);
							redTVImg.animation.play("justImg");
							eventTweens.push(FlxTween.tween(redTVImg, {alpha: 0.6}, 10, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(redTVStat, {alpha: 0.6}, 10, {ease: FlxEase.quadInOut}));
						}
						Conductor.songPosition = 0;
					}
				else if (curStage == 'turmoilsweep')
				{
					Conductor.songPosition = 0;
					eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 0}, 4, {startDelay: 1, ease: FlxEase.quadInOut}));
					eventTweens.push(FlxTween.tween(buttonxml, {alpha: 0}, 2, {startDelay: 3, ease: FlxEase.quadInOut}));
				}
				else if (curStage == 'betamansion' && PlayState.SONG.song != 'Alone Old')
				{
					Conductor.songPosition = 0;
					camGame.zoom = 1.3;
					eventTweens.push(FlxTween.tween(camGame, {zoom: 0.8}, 3.7, {ease: FlxEase.quadOut}));
					eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 0.5}, 3.5, {startDelay: 1, ease: FlxEase.quadInOut}));

					extraTween.push(FlxTween.tween(boyfriendGroup, {y: boyfriendGroup.y - 20}, 3, {ease: FlxEase.quadInOut, type: PINGPONG}));
					extraTween.push(FlxTween.tween(boyfriendGroup, {x: boyfriendGroup.x + 40}, 5, {ease: FlxEase.quadInOut, type: PINGPONG}));

					extraTween.push(FlxTween.tween(starmanGF, {y: gfGroup.y + 40}, 2, {startDelay: 0.2, ease: FlxEase.quadInOut, type: PINGPONG}));
					extraTween.push(FlxTween.tween(starmanGF, {x: gfGroup.x - 20}, 4, {startDelay: 0.2, ease: FlxEase.quadInOut, type: PINGPONG}));
					starmanGF.alpha = 0;
					boyfriendGroup.alpha = 0;
					health = 2;

					gfGroup.scale.set(0.2, 0.2);
					gfGroup.scrollFactor.set(0.8, 0.8);
					gfGroup.alpha = 0.000001;
					gfGroup.x = 310;
					gfGroup.y = -360;

					iconP1.alpha = 0;
					iconP2.alpha = 0;
					healthBar.alpha = 0;
					healthBarBG.alpha = 0;
					customHB.alpha = 0;
					customHBweegee.alpha = 0;
					scoreTxt.alpha = 0;
				}
				else if (curStage == 'directstream')
				{
					Conductor.songPosition = 0;
					eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 0}, 4, {startDelay: 1, ease: FlxEase.quadInOut}));
				}
				else if (curStage == 'endstage')
				{
					Conductor.songPosition = 0;
					elfin.visible = true;
					elfin.cameras = [camEst];
				}
				else
				{
					Conductor.songPosition += FlxG.elapsed * 1000;
				}
				if (Conductor.songPosition >= 0)
				{
					startSong();
				}
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if (updateTime)
				{
					var curTime:Float = FlxG.sound.music.time - ClientPrefs.noteOffset;

					if (curTime < 0)
						curTime = 0;
					songPercent = (curTime / (songLength + (minustime * 1000)));

					var secondsTotal:Int = Math.floor(((songLength - curTime) / 1000) + minustime);
					if (secondsTotal < 0)
						secondsTotal = 0;

					if (curStage == 'hatebg' || curStage == 'forest')
					{
						timeTxt.text = '' + secondsTotal;
					}
					else
					{
						var minutesRemaining:Int = Math.floor(secondsTotal / 60);
						var secondsRemaining:String = '' + secondsTotal % 60;
						if (secondsRemaining.length < 2)
							secondsRemaining = '0' + secondsRemaining; // Dunno how to make it display a zero first in Haxe lol
						timeTxt.text = minutesRemaining + ':' + secondsRemaining;
					}
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming && curStage != 'somari' && !blockzoom)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			if (curStage == 'directstream')
			{
				camEst.zoom = FlxMath.lerp(1, camEst.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			}
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		modManager.updateTimeline(curDecStep);
		modManager.update(elapsed);

		scoreTxt.alpha = 
		healthBar.alpha = 
		healthBarBG.alpha = 
		customHBweegee.alpha = 
		customHB.alpha;

		if(curStage == 'piracy' && canvas.visible == true){
		if (FlxG.mouse.pressed)
			{
				canvas.drawCircle(FlxG.mouse.screenX - canvas.x, FlxG.mouse.screenY - canvas.y, 5, 0xFF0000FF);
				if (lastPosition.x != 9999 && lastPosition.y != 9999 && FlxG.mouse.justMoved)
				{
					var tanSlope:Float = (-(FlxG.mouse.screenY - lastPosition.y)) / (FlxG.mouse.screenX - lastPosition.x);
					var secSlope:Float = -(1 / tanSlope);
					var angle:Float = Math.atan(secSlope);
					var circlePos:FlxPoint = new FlxPoint(5 * Math.cos(angle), 5 * Math.sin(angle));
					var vertices = new Array<FlxPoint>();
					vertices[0] = new FlxPoint(FlxG.mouse.screenX - canvas.x + circlePos.x, FlxG.mouse.screenY - canvas.y - circlePos.y);
					vertices[1] = new FlxPoint(lastPosition.x - canvas.x + circlePos.x, lastPosition.y - canvas.y - circlePos.y);
					vertices[2] = new FlxPoint(lastPosition.x - canvas.x - circlePos.x, lastPosition.y - canvas.y + circlePos.y);
					vertices[3] = new FlxPoint(FlxG.mouse.screenX - canvas.x - circlePos.x, FlxG.mouse.screenY - canvas.y + circlePos.y);
					if (!Math.isNaN(vertices[0].x)) {
						canvas.drawPolygon(vertices, 0xFF0000FF);
					}
				}
				lastPosition = new FlxPoint(FlxG.mouse.screenX, FlxG.mouse.screenY);
			}
			else if (FlxG.mouse.justReleased)
			{
				lastPosition = new FlxPoint(9999, 9999);
			}
		}

		if(curStage == 'meatworld'){
			gunShotPico.x = boyfriendGroup.x - 210;
			gunShotPico.y = boyfriendGroup.y + 180;
			iconGF.x = iconP1.x + 55;
			iconGF.y = iconP1.y - 40;
			iconGF.scale.set(iconP1.scale.x - 0.2, iconP1.scale.y - 0.2);

			if(health < 0.4){
				iconGF.animation.play('lose');
			}else{
				iconGF.animation.play('win');
			}
		}

		if(curStage == 'exesequel'){
			//john dick/yoshiexe controller
			iconGF.x = iconP2.x - 70;
			if (gf.curCharacter == 'yoshiexe')
				iconGF.scale.set(iconP1.scale.x - 0.2, iconP1.scale.y - 0.2);
			else
				iconGF.scale.set(iconP1.scale.x, iconP1.scale.y);

			if(health > 1.6){
				iconGF.animation.play('lose');
			}else{
				iconGF.animation.play('win');
			}
		}

		if(curStage == 'betamansion' && SONG.song != 'Alone Old'){
			//alone mario controller
			iconGF.x = iconP2.x -70;
			iconGF.scale.set(iconP1.scale.x - 0.2, iconP1.scale.y - 0.2);

			if(health > 1.6 || health < 0.4){
				iconGF.animation.play('lose');
			}else{
				iconGF.animation.play('win');
			}
		}

		if(dad.curCharacter == 'luigi_fountain' || dad.curCharacter == 'luigi_fountain3d'){
			DAD_CAM_Y = (dadGroup.y / 2) + ((dad.animation.curAnim.name == 'Hey') ? 200 : 125);
		}

		if(dad.curCharacter == 'peachtalk1' || dad.curCharacter == 'peachtalk2'){
			DAD_CAM_X = (dadGroup.x / 2) + 250;
			DAD_CAM_Y = (dadGroup.y / 2) + 250;
		}

		if (curStage == 'secretbg'){
			if (bulletTimer > 0){
				trace(bulletTimer);
				bulletTimer -= 1 * (60 / ClientPrefs.framerate);
				if (bulletTimer <= 0){
					bulletTimer = -1;
					eventTweens.push(FlxTween.tween(this, {health: health - 1}, 0.2, {ease: FlxEase.quadOut}));
					FlxG.sound.play(Paths.sound('SHbulletmiss'), 0.5);
					var whiteSquare:FlxSprite = new FlxSprite().makeGraphic(Std.int(iconP1.width / 2), Std.int(iconP1.height / 2), FlxColor.WHITE);
					whiteSquare.cameras = [camHUD];
					whiteSquare.setPosition(iconP1.x + 60, iconP1.y + 30);
					whiteSquare.visible = ClientPrefs.flashing;
					add(whiteSquare);

					eventTimers.push(new FlxTimer().start(0.05, function(tmr:FlxTimer)
						{
							whiteSquare.destroy();
							iconP1.color = 0x000000;
							whiteSquare.visible = true;
							eventTimers.push(new FlxTimer().start(0.05, function(tmr:FlxTimer)
								{
									iconP1.color = 0xFFFFFF;
								}));
						}));
				}
			}
		}

		if (curStage == 'allfinal'){
			iconLG.x = iconP2.x;
			iconW4.x = iconY0.x = iconP2.x - 75;
			iconLG.scale.set(iconP2.scale.x, iconP2.scale.y);
			iconW4.scale.set(iconP2.scale.x, iconP2.scale.y);
			iconY0.scale.set(iconP2.scale.x, iconP2.scale.y);

			iconA42.x = iconA4.x = iconP2.x - 50;
			iconA4.scale.set(iconP2.scale.x - 0.2, iconP2.scale.y - 0.2);
			iconA42.scale.set(iconP2.scale.x - 0.2, iconP2.scale.y - 0.2);
			if(iconA4.alpha > 0.1){
				iconA42.alpha = iconA4.alpha -= elapsed;
			}

			if(health < 1.6){
				
				iconLG.animation.play('win');
				iconW4.animation.play('win');
				iconY0.animation.play('win');
			}else{
				
				iconLG.animation.play('lose');
				iconW4.animation.play('lose');
				iconY0.animation.play('lose');
			}
		}

		if (curStage == 'nesbeat'){
			iconLG.setPosition(iconP2.x + ycbuIconPos1.x, iconP2.y + ycbuIconPos1.y);
			iconW4.setPosition(iconP2.x + ycbuIconPos2.x, iconP2.y + ycbuIconPos2.y);
			iconY0.setPosition(iconP2.x + ycbuIconPos3.x, iconP2.y + ycbuIconPos3.y);
			iconLG.scale.set(iconP2.scale.x, iconP2.scale.y);
			iconW4.scale.set(iconP2.scale.x, iconP2.scale.y);
			iconY0.scale.set(iconP2.scale.x, iconP2.scale.y);

			if(health < 1.6){
				
				iconLG.animation.play('win');
				iconW4.animation.play('win');
				iconY0.animation.play('win');
			}else{
				
				iconLG.animation.play('lose');
				iconW4.animation.play('lose');
				iconY0.animation.play('lose');
			}
		}

		if (boyfriend.curCharacter == "bfbetanew" && canFade){
			boyfriendGroup.alpha = health / 2;

			if(health > 1.8){
				boyfriendGroup.alpha = 0.9;
			}else if(health < 0.4){
				boyfriendGroup.alpha = 0.2;
			}
		}

		if (controls.DODGE && !inCutscene && !endingSong && !isDodging && !canDodge && !cpuControlled && !startingSong)
		{ // PONELE MÁS REQUISITOS LA CTM

			if (curStage == 'turmoilsweep' || curStage == 'castlestar')
			{
				boyfriend.playAnim('dodge', true);
				if(curStage == 'turmoilsweep') buttonxml.animation.play('press');
				isDodging = true;
				canDodge = true;
				boyfriend.specialAnim = true;
				eventTimers.push(new FlxTimer().start(0.4, function(tmr:FlxTimer)
				{
					isDodging = false;
					boyfriend.specialAnim = false;
				}));
				eventTimers.push(new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					canDodge = false;
				}));
			}

			if (curStage == 'exeport')
			{
				if (PlayState.SONG.song == 'Powerdown Old')
				{
					boyfriend.playAnim('dodge', true);
					isDodging = true;
					canDodge = true;
					boyfriend.specialAnim = true;
					eventTimers.push(new FlxTimer().start(0.4, function(tmr:FlxTimer)
					{
						isDodging = false;
						boyfriend.specialAnim = false;
					}));
					eventTimers.push(new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						canDodge = false;
					}));
				}
				else
				{
					if(boyfriend.curCharacter != "bfsad") bfJump();
				}
			}
		}

		var roundedSpeed:Float = FlxMath.roundDecimal(SONG.speed, 2);
		if (unspawnNotes[0] != null)
		{
			var time:Float = 1500;
			if (roundedSpeed < 1)
				time /= roundedSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		opponentStrums.forEachAlive(function(strum:StrumNote)
			{
				var pos = modManager.getPos(0, 0, 0, curDecBeat, strum.noteData, 1, strum, [], strum.vec3Cache);
				modManager.updateObject(curDecBeat, strum, pos, 1);
				strum.x = pos.x;
				strum.y = pos.y;
			});
	
			playerStrums.forEachAlive(function(strum:StrumNote)
			{
				var pos = modManager.getPos(0, 0, 0, curDecBeat, strum.noteData, 0, strum, [], strum.vec3Cache);
				modManager.updateObject(curDecBeat, strum, pos, 0);
				strum.x = pos.x;
				strum.y = pos.y;
			});

		if (generatedMusic)
		{
			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				if (!daNote.mustPress && ClientPrefs.middleScroll)
				{
					daNote.active = true;
					if(!songIsModcharted) daNote.visible = false;
				}
				else if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				// i am so fucking sorry for this if condition
				var strumX:Float = 0;
				var strumY:Float = 0;
				var strumAngle:Float = 0;
				var strumAlpha:Float = 0;
				if (daNote.mustPress)
				{
					strumX = playerStrums.members[daNote.noteData].x;
					strumY = playerStrums.members[daNote.noteData].y;
					strumAngle = playerStrums.members[daNote.noteData].angle;
					strumAlpha = playerStrums.members[daNote.noteData].alpha;
				}
				else
				{
					strumX = opponentStrums.members[daNote.noteData].x;
					strumY = opponentStrums.members[daNote.noteData].y;
					strumAngle = opponentStrums.members[daNote.noteData].angle;
					strumAlpha = opponentStrums.members[daNote.noteData].alpha;
				}

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;
				var pN:Int = daNote.mustPress ? 0 : 1;
				var pos = modManager.getPos(daNote.strumTime, modManager.getVisPos(Conductor.songPosition, daNote.strumTime, SONG.speed),
					daNote.strumTime - Conductor.songPosition, curBeat, daNote.noteData, pN, daNote, [], daNote.vec3Cache);

				modManager.updateObject(curBeat, daNote, pos, pN);
				pos.x += daNote.offsetX;
				pos.y += daNote.offsetY;
				daNote.x = pos.x;
				daNote.y = pos.y;
				if (daNote.isSustainNote)
				{
					var futureSongPos = Conductor.songPosition + 75;
					var diff = daNote.strumTime - futureSongPos;
					var vDiff = modManager.getVisPos(futureSongPos, daNote.strumTime, SONG.speed);

					var nextPos = modManager.getPos(daNote.strumTime, vDiff, diff, Conductor.getStep(futureSongPos) / 4, daNote.noteData, pN, daNote, [],
						daNote.vec3Cache);
					nextPos.x += daNote.offsetX;
					nextPos.y += daNote.offsetY;
					var diffX = (nextPos.x - pos.x);
					var diffY = (nextPos.y - pos.y);
					var rad = Math.atan2(diffY, diffX);
					var deg = rad * (180 / Math.PI);
					if (deg != 0)
						daNote.mAngle = (deg + 90);
					else
						daNote.mAngle = 0;
				}
				var center:Float = strumY + Note.swagWidth / 2;

				if (daNote.copyX)
				{
					daNote.x = strumX;
				}
				if (daNote.copyAngle)
				{
					daNote.angle = strumAngle;
				}
				if (daNote.copyAlpha)
				{
					daNote.alpha = strumAlpha;
				}
				if (daNote.copyY)
				{
					if (hasDownScroll)
					{
						daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
						if (daNote.isSustainNote)
						{
							// Jesus fuck this took me so much mother fucking time AAAAAAAAAA
							if (daNote.animation.curAnim.name.endsWith('end'))
							{
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * roundedSpeed + (46 * (roundedSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * roundedSpeed;
								if (PlayState.isPixelStage)
								{
									daNote.y += 8;
								}
								else
								{
									daNote.y -= 19;
								}
							}
							daNote.y += (Note.swagWidth / 2) - (60.5 * (roundedSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (roundedSpeed - 1);

							if (daNote.mustPress || !daNote.ignoreNote)
							{
								if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
									&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
								{
									var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
									swagRect.height = (center - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
						}
					}
					else
					{
						daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);

						if (daNote.mustPress || !daNote.ignoreNote)
						{
							if (daNote.isSustainNote
								&& daNote.y + daNote.offset.y * daNote.scale.y <= center
								&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					if (Paths.formatToSongPath(SONG.song) != 'tutorial')
						camZooming = true;

					if (daNote.noteType == 'Hey!' && dad.animOffsets.exists('hey'))
					{
						dad.playAnim('hey', true);
						dad.specialAnim = true;
						dad.heyTimer = 0.6;
					}
					else if (!daNote.noAnimation)
					{
						var altAnim:String = "";

						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim || daNote.noteType == 'Alt Animation')
							{
								altAnim = '-alt';
							}
							else if(altdad){
								altAnim = altAnims;
							}
						}

						var animToPlay:String = '';
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								animToPlay = 'singLEFT';
							case 1:
								animToPlay = 'singDOWN';
							case 2:
								animToPlay = 'singUP';
							case 3:
								animToPlay = 'singRIGHT';
						}
						if (curStage == 'superbad'){
							badGrad1.alpha = ((ClientPrefs.flashing ? 0.4 : 0.2));
							switch (Math.abs(daNote.noteData))
							{
								case 0:
									badGrad1.color = FlxColor.MAGENTA;
								case 1:
									badGrad1.color = FlxColor.CYAN;
								case 2:
									badGrad1.color = FlxColor.LIME;
								case 3:
									badGrad1.color = FlxColor.RED;
							}
						}
							
						if (daNote.noteType == 'GF Sing')
						{
							gf.playAnim(animToPlay + altAnim, true);
							gf.holdTimer = 0;
							GFSINGDAD = true;
							// if (gf.curCharacter == 'lg2' && curStage == 'allfinal')
							// 	{
							// 		DAD_CAM_X = 520;
							// 		DAD_CAM_Y = 350;
							// 		DAD_ZOOM = 0.7;
							// 	}
						}
						else if (daNote.noteType == 'Yoshi Note')
						{
							if (curStage == 'exesequel' || curStage == 'betamansion'){
								gf.playAnim(animToPlay + altAnim, true);
								gf.holdTimer = 0;
							}

							if (curStage == 'allfinal' || curStage == 'nesbeat'){
								if (curStage == 'allfinal'){
									DAD_CAM_X = 780;
									DAD_CAM_Y = 450;
									DAD_ZOOM = 0.7;
									switch (Math.abs(daNote.noteData))
									{
										case 0: // LEFT
											funnylayer0.offset.x = 59;
											funnylayer0.offset.y = -5;
										case 1: // DOWN
											funnylayer0.offset.x = 33;
											funnylayer0.offset.y = -88;
										case 2: // UP
											funnylayer0.offset.x = -22;
											funnylayer0.offset.y = 74;
										case 3: // RIGHT
											funnylayer0.offset.x = -120;
											funnylayer0.offset.y = 39;
									}
								}

								if (curStage == 'nesbeat'){
									switch (Math.abs(daNote.noteData))
									{
										case 0: // LEFT
											funnylayer0.offset.x = -10;
										case 1: // DOWN
											funnylayer0.offset.x = -20;
										case 2: // UP
											funnylayer0.offset.x = -14;
										case 3: // RIGHT
											funnylayer0.offset.x = -68;
									}
								}

								funnylayer0.animation.play(animToPlay, true);

								if (funnylayer0.animation.curAnim.name != 'idle' && funnyTimers != null)
								{
									for (timer in funnyTimers)
										{
											timer.cancel();
										}
								}

								funnyTimers.push(new FlxTimer().start(0.5, function(tmr:FlxTimer)
								{
									funnylayer0.animation.play('idle');
									funnylayer0.offset.x = 0;
									funnylayer0.offset.y = 0;
								}));
							}
						}
						else if (daNote.noteType == 'AS Bud Note')
						{
								gf.playAnim(animToPlay + altAnim, true);
								gf.holdTimer = 0;
								dad.playAnim(animToPlay + altAnim, true);
								dad.holdTimer = 0;
								if (curStage == 'allfinal' || curStage == 'nesbeat'){
									if (curStage == 'allfinal'){
										DAD_CAM_X = 520;
										DAD_CAM_Y = 350;
										DAD_ZOOM = 0.6;
										if (curStage == 'allfinal'){
											switch (Math.abs(daNote.noteData))
											{
												case 0: // LEFT
													funnylayer0.offset.x = 59;
													funnylayer0.offset.y = -5;
												case 1: // DOWN
													funnylayer0.offset.x = 33;
													funnylayer0.offset.y = -88;
												case 2: // UP
													funnylayer0.offset.x = -22;
													funnylayer0.offset.y = 74;
												case 3: // RIGHT
													funnylayer0.offset.x = -120;
													funnylayer0.offset.y = 39;
											}
										}
									}
								if (curStage == 'nesbeat'){
									switch (Math.abs(daNote.noteData))
									{
										case 0: // LEFT
											funnylayer0.offset.x = -10;
										case 1: // DOWN
											funnylayer0.offset.x = -20;
										case 2: // UP
											funnylayer0.offset.x = -14;
										case 3: // RIGHT
											funnylayer0.offset.x = -68;
									}
								}

								funnylayer0.animation.play(animToPlay, true);

								if (funnylayer0.animation.curAnim.name != 'idle' && funnyTimers != null)
								{
									for (timer in funnyTimers)
										{
											timer.cancel();
										}
								}
								funnyTimers.push(new FlxTimer().start(0.5, function(tmr:FlxTimer)
								{
									funnylayer0.animation.play('idle');
									funnylayer0.offset.x = 0;
									funnylayer0.offset.y = 0;
								}));
							}
						}
						else if (daNote.noteType == 'GF Duet'){
								gf.playAnim(animToPlay, true);
								gf.holdTimer = 0;
								dad.playAnim(animToPlay, true);
								dad.holdTimer = 0;
								GFSINGDAD = false;
						}
						else
						{
							dad.playAnim(animToPlay + altAnim, true);
							dad.holdTimer = 0;
						}
						if (dad.curCharacter == 'turmoil1' && health >= 0.4)
						{
							health -= 0.015;
						}
						if (dad.curCharacter == 'luigi-toolate' && curStage == 'meatworld')
						{
							if(health >= 0.2)
								health -= poison;
							hallTLL1.animation.play(animToPlay);
						}
						if (daNote.noteType == '')
						{
							if(curStage != 'secretbg')
								GFSINGDAD = false;
							if (dad.curCharacter == 'w4r' && curStage == 'allfinal'){
								DAD_CAM_X = 260;
								DAD_CAM_Y = 450;
								DAD_ZOOM = 0.7;
							}
						}
					}

					if(curStage != 'meatworld'){
					instALT.volume = 0;
					}else{ instALT.volume = 1;}
					if (SONG.needsVoices)
						vocals.volume = vocalvol;

					var time:Float = 0.15;
					if (daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end'))
					{
						time += 0.15;
					}
					StrumPlayAnim(true, Std.int(Math.abs(daNote.noteData)) % 4, time);
					daNote.hitByOpponent = true;

					if (ClientPrefs.flashing){
						if (dad.curCharacter == 'costumedark' && curStage == 'endstage'){
							for (tween in extraTween)
								{
									tween.cancel();
								}
							dad.alpha = 1;
							extraTween.push(FlxTween.tween(dad, {alpha: 0}, 0.325, {ease: FlxEase.quadInOut}));
						}
					}

					if(curStage == 'allfinal'){
						//if(dad.curCharacter == 'mario_ultra2'){
							iconA42.alpha = iconA4.alpha = iconP2.alpha * 0.7;
						//}
					}

					callOnLuas('opponentNoteHit', [
						notes.members.indexOf(daNote),
						Math.abs(daNote.noteData),
						daNote.noteType,
						daNote.isSustainNote
					]);

					if (!daNote.isSustainNote)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}

				if (daNote.mustPress && cpuControlled)
				{
					if (daNote.isSustainNote)
					{
						if (daNote.canBeHit)
						{
							goodNoteHit(daNote);
						}
					}
					else if (daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress))
					{
						goodNoteHit(daNote);
					}
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				var doKill:Bool = daNote.y < -daNote.height;
				if (hasDownScroll)
					doKill = daNote.y > FlxG.height;

				if (doKill)
				{
					if (daNote.mustPress && !cpuControlled && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit))
					{
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();

		if (pixelPerfect)
		{
			// FlxG.camera.x = 0;
			// FlxG.camera.y = 0;
			if(curStage == 'somari'){
			FlxG.camera.target = null;
			FlxG.camera.zoom = 1.0;
			}
			camHUD.setScale(0.7, 0.7);
		}

		if (!inCutscene)
		{
			if (!cpuControlled)
			{
				keyShit();
			}
			else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
			}
		}

		#if debug
		if (!endingSong && !startingSong)
		{
			if (FlxG.keys.justPressed.ONE)
			{
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if (FlxG.keys.justPressed.TWO)
			{ // Go 10 seconds into the future :O
				FlxG.sound.music.pause();
				instALT.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.strumTime + 800 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length)
				{
					var daNote:Note = unspawnNotes[0];
					if (daNote.strumTime + 800 >= Conductor.songPosition)
					{
						break;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					daNote.destroy();
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				instALT.time = Conductor.songPosition;
		
				vocals.play();
				instALT.play();
			}

			if (FlxG.keys.justPressed.THREE)
				{ // Go 10 seconds into the past :O doesn't respawn notes but helpful for if i press 2 too many times
					FlxG.sound.music.pause();
					instALT.pause();
					vocals.pause();
					Conductor.songPosition -= 10000;
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.strumTime + 800 < Conductor.songPosition)
						{
							daNote.active = false;
							daNote.visible = false;
	
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					});
					for (i in 0...unspawnNotes.length)
					{
						var daNote:Note = unspawnNotes[0];
						if (daNote.strumTime + 800 >= Conductor.songPosition)
						{
							break;
						}
	
						daNote.active = false;
						daNote.visible = false;
	
						daNote.kill();
						unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
						daNote.destroy();
					}
	
					FlxG.sound.music.time = Conductor.songPosition;
					FlxG.sound.music.play();
	
					vocals.time = Conductor.songPosition;
					instALT.time = Conductor.songPosition;
			
					vocals.play();
					instALT.play();
				}
			
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', PlayState.cpuControlled);
		
		//Fix for high fps lua crashes
		if(ClientPrefs.framerate <= maxLuaFPS){
			callOnLuas('onUpdatePost', [elapsed]);
		}
		else {
			numCalls[1]+=1;
			fpsElapsed[1]+=elapsed;
			if(numCalls[1] >= Std.int(ClientPrefs.framerate/maxLuaFPS)){
				//trace("New UpdatePost");
				callOnLuas('onUpdatePost', [fpsElapsed[1]]);
				fpsElapsed[1]=0;
				numCalls[1]=0;
			}
		}

		// #end
	}

	var isDead:Bool = false;

	function doDeathCheck()
	{
		if (health <= 0 && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if (ret != FunkinLua.Function_Stop)
			{
				boyfriend.stunned = true;
				gf.stunned = true;
				deathCounter++;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				if (getspeed != 0)
				{
					SONG.speed = getspeed;
				}


				if(!specialGameOver){
					instALT.stop();
					vocals.stop();
					FlxG.sound.music.stop();

					if (SONG.song == 'I Hate You' || SONG.song == 'Oh God No' && isWarp){
						ClientPrefs.deathIHY = true;
						ClientPrefs.saveSettings();
					}
					if (curStage == 'wetworld'){
						contrastFX.brightness.value = [1.0];
						contrastFX.contrast.value = [1.0];
					}
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, camFollowPos.x, camFollowPos.y, this));
				}else{
					paused = true;
					vocals.volume = 0;
					canPause = false;
					KillNotes();
					persistentUpdate = false;
					persistentDraw = true;
					endingSong = true;
					
					camDisplaceX = 0;
					camDisplaceY = 0;
					totalBeat = 0;

					switch(curStage){
						case 'somari':
							FlxG.sound.play(Paths.sound('ringout'));
							boyfriend.playAnim('death');
							gf.playAnim('die');
							for (tween in eventTweens)
								{
									tween.cancel();
								}
							
							eventTweens.push(FlxTween.tween(boyfriend, {y: boyfriend.y - 100}, 0.5, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
								{
									vocals.pause();
									instALT.pause();
									eventTweens.push(FlxTween.tween(boyfriend, {y: 1600}, 0.7, {ease: FlxEase.quadIn}));
								}}));
							eventTweens.push(FlxTween.tween(gf, {y: gf.y - 120}, 0.6, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
								{
									eventTweens.push(FlxTween.tween(gf, {y: 1600}, 1, {ease: FlxEase.quadIn}));
								}}));

							eventTimers.push(new FlxTimer().start(1.5, function(tmr:FlxTimer)
								{
									if(deathCounter == 3 && (isStoryMode || isWarp)){
										MusicBeatState.switchState(new BotplayState());
									}else{
										CustomFadeTransition.nextCamera = camOther;
										MusicBeatState.resetState();
									}
								}));
						case 'realbg':
							triggerEventNote('Show Song', '1', '');
							//l is real game over
							eventTweens.push(FlxTween.tween(camGame, {zoom: BF_ZOOM + 0.4}, 1.5, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(this, {defaultCamZoom: BF_ZOOM + 0.4}, 1.5, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(camFollowPos, {x: BF_CAM_X + 120}, 1.5, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(camFollowPos, {y: BF_CAM_Y + 60}, 1.5, {ease: FlxEase.quadInOut}));
							camFollow.x = BF_CAM_X + 120;
							camFollow.y = BF_CAM_Y + 60;

							var bowserLogo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('modstuff/gameovers/lisreal_bowserlogo'));
							bowserLogo.cameras = [camOther];
							bowserLogo.scale.set(11, 11);
							bowserLogo.screenCenter();

							triggerEventNote('Show Song', '1', '0');
							eventTweens.push(FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(FlxG.sound.music, {volume: 0}, 1, {ease: FlxEase.quadInOut}));

							triggerEventNote('Play Animation', 'faint', 'bf');
							eventTimers.push(new FlxTimer().start(2, function(tmr:FlxTimer)
								{
									boyfriendGroup.visible = false;
								}));
							eventTimers.push(new FlxTimer().start(1.5, function(tmr:FlxTimer)
								{
									add(bowserLogo);
									FlxG.sound.play(Paths.music('bowlaugh'));
									eventTweens.push(FlxTween.tween(bowserLogo.scale, {x: 0.58, y: 0.58}, 2.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
										{
											blackBarThingie.visible = true;
											blackBarThingie.alpha = 1;
											eventTimers.push(new FlxTimer().start(1.5, function(tmr:FlxTimer)
												{
													if(deathCounter == 3 && (isStoryMode || isWarp)){
														MusicBeatState.switchState(new BotplayState());
													}else{
														CustomFadeTransition.nextCamera = camOther;
														MusicBeatState.resetState();
													}
												}));
										}}));
								}));
						case 'warioworld':
							triggerEventNote('Show Song', '1', '');
							//apparition game over
							eventTweens.push(FlxTween.tween(camGame, {zoom: 1.1}, 0.5, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(this, {defaultCamZoom: 1.1}, 0.5, {ease: FlxEase.quadInOut}));

							eventTweens.push(FlxTween.tween(camHUD, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.5, {ease: FlxEase.quadInOut}));

							var warioOpen:BGSprite = new BGSprite('mario/Wario/Apparition_Game_Over', -65, 65, ['wario open mouth'], false);
							warioOpen.animation.addByPrefix('open', "wario open mouth", 20, false);
							warioOpen.animation.addByPrefix('close', "wario bite", 24, false);
							
							eventTimers.push(new FlxTimer().start(0.5, function(tmr:FlxTimer)
								{
									insert(members.indexOf(bfext) - 1, warioOpen);
									dad.visible = false;
									camZooming = false;
									warioOpen.animation.play('open', true);
									eventTweens.push(FlxTween.tween(warioOpen, {x: -100, y: 155}, 1.5));
									FlxG.sound.play(Paths.music(GameOverSubstate.deathSoundName));
									eventTimers.push(new FlxTimer().start(0.5, function(tmr:FlxTimer)
										{
											remove(bfFall);
											insert(members.indexOf(warioOpen) + 1, bfFall);
											bfFall.alpha = 1;
											bftors.destroy();
											bftorsmiss.destroy();
											bfext.destroy();
											bfextmiss.destroy();
											boyfriendGroup.visible = false;
											bfFall.animation.play('fall', true);
											eventTweens.push(FlxTween.tween(bfFall, {y: bfFall.y - 60}, 1, {ease: FlxEase.backOut, onComplete: function(twn:FlxTween)
												{
													eventTimers.push(new FlxTimer().start(0.9, function(tmr:FlxTimer)
														{
															remove(warioOpen);
															insert(members.indexOf(bfFall) + 1, warioOpen);
															warioOpen.animation.play('close', true);
															warioOpen.scale.set(0.95, 0.95);
															warioOpen.setPosition(-85, 65);
															bgwario.visible = false;
															eventTimers.push(new FlxTimer().start(0.1, function(tmr:FlxTimer)
																{
																	camGame.shake(0.01, 0.1);
																}));
															eventTimers.push(new FlxTimer().start(1, function(tmr:FlxTimer)
																{
																	warioDead = true;
																	FlxG.sound.playMusic(Paths.music(GameOverSubstate.loopSoundName));
																}));
														}));
												}}));
										}));
								}));
							case 'betamansion':
								triggerEventNote('Show Song', '1', '');
								//alone game over
								eventTweens.push(FlxTween.tween(FlxG.sound.music, {volume: 0}, 2, {ease: FlxEase.quadInOut}));

								eventTweens.push(FlxTween.tween(camGame, {zoom: BF_ZOOM + 0.2}, 1, {ease: FlxEase.quadInOut}));
								eventTweens.push(FlxTween.tween(this, {defaultCamZoom: BF_ZOOM + 0.2}, 1, {ease: FlxEase.quadInOut}));
								eventTweens.push(FlxTween.tween(camFollowPos, {x: BF_CAM_X + 220}, 1, {ease: FlxEase.quadInOut}));
								eventTweens.push(FlxTween.tween(camFollowPos, {y: BF_CAM_Y - 40}, 1, {ease: FlxEase.quadInOut}));
								camFollow.x = BF_CAM_X + 220;
								camFollow.y = BF_CAM_Y;
								canFade = false;



								triggerEventNote('Play Animation', 'singUPmiss', 'bf');
								eventTweens.push(FlxTween.tween(boyfriendGroup, {alpha: 0}, 4, {ease: FlxEase.quadInOut}));
								eventTweens.push(FlxTween.tween(starmanGF, {alpha: 0}, 4, {ease: FlxEase.quadInOut}));
								eventTweens.push(FlxTween.tween(camHUD, {alpha: 0}, 1.5, {ease: FlxEase.quadInOut}));
								eventTimers.push(new FlxTimer().start(2, function(tmr:FlxTimer)
									{
										eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 0.75}, 5, {ease: FlxEase.quadInOut}));
										var goodNight:FlxSprite = new FlxSprite().loadGraphic(Paths.image('modstuff/gameovers/aloneGoodNight'));
										goodNight.cameras = [camEst];
										goodNight.scale.set(1.5, 1.5);
										goodNight.screenCenter();
										goodNight.alpha = 0;
										add(goodNight);
										eventTweens.push(FlxTween.tween(goodNight, {alpha: 1}, 2, {startDelay: 0.5, ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){
											eventTweens.push(FlxTween.tween(goodNight, {alpha: 0}, 3, {startDelay: 1, ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){
												eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 1, {ease: FlxEase.quadInOut}));
												eventTimers.push(new FlxTimer().start(1, function(tmr:FlxTimer)
													{
														if(deathCounter == 3 && (isStoryMode || isWarp)){
															MusicBeatState.switchState(new BotplayState());
														}else{
															CustomFadeTransition.nextCamera = camOther;
															MusicBeatState.resetState();
														}
													}));
											}}));
										}}));

									}));
								

					}
				}
				for (tween in modchartTweens)
				{
					tween.active = true;
				}
				for (timer in modchartTimers)
				{
					timer.active = true;
				}

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, newName + legacycheck, discName.toLowerCase(), iconP2.getCharacter().toLowerCase());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote()
	{
		while (eventNotes.length > 0)
		{
			var early:Float = eventNoteEarlyTrigger(eventNotes[0]);
			var leStrumTime:Float = eventNotes[0][0];
			if (Conductor.songPosition < leStrumTime - early)
			{
				break;
			}

			var value1:String = '';
			if (eventNotes[0][3] != null)
				value1 = eventNotes[0][3];

			var value2:String = '';
			if (eventNotes[0][4] != null)
				value2 = eventNotes[0][4];

			triggerEventNote(eventNotes[0][2], value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String)
	{
		var pressed:Bool = Reflect.getProperty(controls, key);
		// trace('Control result: ' + pressed);
		return pressed;
	}

	public var eventTweens:Array<FlxTween> = [];
	public var extraTween:Array<FlxTween> = [];
	public var extraTimers:Array<FlxTimer> = [];
	public var funnyTimers:Array<FlxTimer> = [];
	public var windowTween:Array<FlxTween> = [];
	public var eventTimers:Array<FlxTimer> = [];
	public var ratingTimers:Array<FlxTimer> = [];

	public function triggerEventNote(eventName:String, value1:String, value2:String)
	{
		switch (eventName)
		{
			case 'Hey!':
				var value:Int = 2;
				switch (value1.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if (Math.isNaN(time) || time <= 0)
					time = 0.6;

				if (value != 0)
				{
					if (dad.curCharacter.startsWith('gf'))
					{ // Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					}
					else
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if (value != 1)
				{
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if (Math.isNaN(value))
					value = 1;
				gfSpeed = value;

			case 'Add Camera Zoom':
				if (ClientPrefs.camZooms)
				{
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if (Math.isNaN(camZoom))
						camZoom = 0.015;
					if (Math.isNaN(hudZoom))
						hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
					if (curStage == 'directstream')
					{
						camEst.zoom += hudZoom;
					}
				}

			case 'Camera Zoom Chain':

				var split1:Array<String> = value1.split(',');
				var gameZoom:Float = Std.parseFloat(split1[0].trim());
				var hudZoom:Float = Std.parseFloat(split1[1].trim());

				if (!Math.isNaN(gameZoom)) gameZ = 0.015;
				if (!Math.isNaN(hudZoom)) hudZ = 0.03;

				if(split1.length == 4){
					var shGame:Float = Std.parseFloat(split1[2].trim());
					var shHUD:Float = Std.parseFloat(split1[3].trim());

					if (!Math.isNaN(shGame)) gameShake = shGame;
					if (!Math.isNaN(shHUD)) hudShake = shHUD;
					shakeTime = true;
				}else{
					shakeTime = false;
				}

				var split2:Array<String> = value2.split(',');
				var toBeat:Int = Std.parseInt(split2[0].trim());
				var tiBeat:Float = Std.parseFloat(split2[1].trim());

				if (Math.isNaN(toBeat)) toBeat = 4;
				if (Math.isNaN(tiBeat)) tiBeat = 1;

				totalBeat = toBeat;
				timeBeat = tiBeat;


			case 'Screen Shake Chain':
				var split1:Array<String> = value1.split(',');
				var gmShake:Float = Std.parseFloat(split1[0].trim());
				var hdShake:Float = Std.parseFloat(split1[1].trim());

				if (!Math.isNaN(gmShake)) gameShake = gmShake;
				if (!Math.isNaN(hdShake)) hudShake = hdShake;

				var toBeat:Int = Std.parseInt(value2);
				if (!Math.isNaN(toBeat)) totalShake = 4;

				totalShake = toBeat;

			case 'Play Animation':
				// trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch (value2.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if (Math.isNaN(val2))
							val2 = 0;

						switch (val2)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.playAnim(value1, true);
				char.specialAnim = true;

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 0;
				if (Math.isNaN(val2))
					val2 = 0;

				isCameraOnForcedPos = false;
				if (!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2)))
				{
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch (value1.toLowerCase())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if (Math.isNaN(val))
							val = 0;

						switch (val)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.idleSuffix = value2;
				altAnims = value2;
				char.recalculateDanceIdle();
				if(char == dad && curStage != 'virtual') altdad = true;
				if(value2 == '') altdad = false;

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD, camEst];
				for (i in 0...targetsArray.length)
				{
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = Std.parseFloat(split[0].trim());
					var intensity:Float = Std.parseFloat(split[1].trim());
					if (Math.isNaN(duration))
						duration = 0;
					if (Math.isNaN(intensity))
						intensity = 0;
					if (ClientPrefs.flashing)
					{
						if (duration > 0 && intensity != 0)
						{
							targetsArray[i].shake(intensity, duration);
						}
					}
				}

			case 'Change Character':
				var charType:Int = Std.parseInt(value1);
				if (Math.isNaN(charType))
					charType = 0;

				switch (charType)
				{
					case 0:
						if (boyfriend.curCharacter != value2)
						{
							if (!boyfriendMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							boyfriend.visible = false;
							boyfriend = boyfriendMap.get(value2);
							if (!boyfriend.alreadyLoaded)
							{
								boyfriend.alpha = 1;
								boyfriend.alreadyLoaded = true;
							}
							boyfriend.visible = true;
							iconP1.changeIcon(boyfriend.healthIcon);
							iconP1.y = healthBar.y - (iconP1.height / 2);
						}

					case 1:
						if (dad.curCharacter != value2)
						{
							if (!dadMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							dad.visible = false;
							dad = dadMap.get(value2);
							if (!dad.curCharacter.startsWith('gf'))
							{
								if (wasGf)
								{
									gf.visible = true;
								}
							}
							else
							{
								gf.visible = false;
							}
							if (!dad.alreadyLoaded)
							{
								if (curStage != 'nesbeat')
								{
									dad.alpha = 1;
								}
								else
								{
									dad.alpha = 0;
								}
								dad.alreadyLoaded = true;
							}
							dad.visible = true;
							iconP2.changeIcon(dad.healthIcon);
							iconP2.y = healthBar.y - (iconP2.height / 2);

							#if desktop
							// Updating Discord Rich Presence (with Time Left)
							DiscordClient.changePresence(detailsText, newName + legacycheck, discName.toLowerCase(), iconP2.getCharacter().toLowerCase(), true, songLength);
							#end
						}

					case 2:
						if (gf.curCharacter != value2)
						{
							if (!gfMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							gf.visible = false;
							gf = gfMap.get(value2);
							if (!gf.alreadyLoaded)
							{
								gf.alpha = 1;
								gf.alreadyLoaded = true;
							}
						}
				}
				reloadHealthBarColors();

				if (curStage == 'nesbeat')
				{
					dad.alpha = 1;
				}

			case 'Cambiar Zoom Default':
				var camaraActual:Float = Std.parseFloat(value1);
				if (Math.isNaN(camaraActual))
					camaraActual = defaultCamZoom;

				eventTweens.push(FlxTween.tween(FlxG.camera, {zoom: camaraActual}, 0.5, {ease: FlxEase.quadInOut}));

			case 'Sacar Lava':
				var lavacord:Float = Std.parseFloat(value1);
				var lavachange:Float = Std.parseFloat(value2);
				if (Math.isNaN(lavachange))
					lavachange = 0;

				if (!ClientPrefs.lowQuality)
				{
					if (Math.isNaN(lavacord))
						lavacord = 730;
				}
				else
				{
					if (Math.isNaN(lavacord))
						lavacord = 716;
				}

				if (lavachange == 0)
				{
					if (!hasDownScroll)
					{
						eventTweens.push(FlxTween.tween(ihyLava, {y: lavacord}, 0.25, {ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.tween(lavaEmitter, {y: lavacord + 50}, 0.25, {ease: FlxEase.quadOut}));
					}
					else
					{
						if (!ClientPrefs.lowQuality)
						{
							eventTweens.push(FlxTween.tween(ihyLava, {y: lavacord * -1 + 350}, 0.25, {ease: FlxEase.quadOut}));
							eventTweens.push(FlxTween.tween(lavaEmitter, {y: lavacord * -1 + 700}, 0.25, {ease: FlxEase.quadOut}));
						}
						else
						{
							eventTweens.push(FlxTween.tween(ihyLava, {y: lavacord * -1 + 50}, 0.25, {ease: FlxEase.quadOut}));
							eventTweens.push(FlxTween.tween(lavaEmitter, {y: lavacord * -1 + 400}, 0.25, {ease: FlxEase.quadOut}));
						}
					}
				}

				if (lavachange == 1)
				{
					if (!hasDownScroll)
					{
						

						lavaTween = FlxTween.tween(ihyLava, {y: lavacord}, 2, {ease: FlxEase.quadInOut, type: PINGPONG});
					}
					else
					{
						if (!ClientPrefs.lowQuality){
						lavaTween = FlxTween.tween(ihyLava, {y: lavacord * -1 + 350}, 2, {ease: FlxEase.quadInOut, type: PINGPONG});
						}else{
						lavaTween = FlxTween.tween(ihyLava, {y: lavacord * -1 + 50}, 2, {ease: FlxEase.quadInOut, type: PINGPONG});
						}
					}
				}
				if (lavachange == 2)
				{
					if (!hasDownScroll)
					{
						eventTweens.push(FlxTween.tween(ihyLava, {y: lavacord}, 5, {ease: FlxEase.quadInOut}));
					}
					else
					{
						if (!ClientPrefs.lowQuality){
						eventTweens.push(FlxTween.tween(ihyLava, {y: lavacord * -1 + 350}, 5, {ease: FlxEase.quadInOut}));
						}else{
						eventTweens.push(FlxTween.tween(ihyLava, {y: lavacord * -1 + 50}, 5, {ease: FlxEase.quadInOut}));
						}
					}
				}
				if (lavachange == 3)
				{
					lavaTween.cancel();
				}

			case 'Triggers Universal':
				var songName = SONG.song;

				if(SONG.song.endsWith('Old')){
					songName = SONG.song.replace(' Old', '');
				}

				triggerEventNote('Triggers ' + songName, '' + value1, '' + value2);

			case 'Triggers Its a me':
				var trigger:Float = Std.parseFloat(value1);
				var trigger2:Float = Std.parseFloat(value2);
				if (Math.isNaN(trigger))
					trigger = 0;
				if (Math.isNaN(trigger2))
					trigger2 = 0;

				switch(trigger)
				{
					case 0:
						fireL.alpha = 1;
						fireR.alpha = 1;
						eventTweens.push(FlxTween.tween(fireL, {y: fireL.y - 800}, 15, {ease: FlxEase.linear}));
						eventTweens.push(FlxTween.tween(fireR, {y: fireR.y - 800}, 15, {ease: FlxEase.linear}));
						eventTweens.push(FlxTween.tween(fireOverlay, {alpha: 1}, 15, {ease: FlxEase.quadInOut}));
				

				case 1:
					eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 3));
					eventTweens.push(FlxTween.tween(camHUD, {alpha: 0}, 5));
					eventTweens.push(FlxTween.tween(camGame, {zoom: 1.3}, 5, {ease: FlxEase.sineIn}));
					if (!ClientPrefs.lowQuality){
						effect.setStrength(40, 40);
						camGame.setFilters([new ShaderFilter(effect.shader)]);
						FlxTween.num(1, 20, 3, function(v)
						{
							effect.setStrength(v, v);
						});
					}
				}

			case 'Triggers Starman Slaughter':
				var trigger:Float = Std.parseFloat(value1);
				var trigger2:Float = Std.parseFloat(value2);
				if (Math.isNaN(trigger))
					trigger = 0;
				if (Math.isNaN(trigger2))
					trigger2 = 0;

				switch(trigger)
				{
					case 0:
						//96
						BF_CAM_X = 1050;
					case 1:
						//100
						BF_CAM_X = 1550;
					case 2:
						//132
						add(iconGF);
						iconGF.y = (!hasDownScroll ? 820 : -150);
						eventTweens.push(FlxTween.tween(iconGF, {y: iconP2.y - (!hasDownScroll ? 35 : -15)}, 3, {ease: FlxEase.expoOut}));
						eventTweens.push(FlxTween.tween(gfGroup, {y: 0}, 3, {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween)
							{
								extraTween.push(FlxTween.tween(gfGroup, {y: gfGroup.y - 80}, 2, {ease: FlxEase.quadInOut, type: PINGPONG}));
							}}));
						extraTween.push(FlxTween.tween(gfGroup, {x: gfGroup.x - 100}, 3, {ease: FlxEase.quadInOut, type: PINGPONG}));
						GF_ZOOM = 0.7;
						GF_CAM_X = 850;
						ZOOMCHARS = true;

					case 3:
						//196
						GF_CAM_X = 550;
						GF_ZOOM = 0.5;
					case 4:
						//256
						var dadx:Float = dadGroup.x;
						var dady:Float = dadGroup.y;
						for (tween in extraTween)
							{
								tween.cancel();
							}
						extraTween.push(FlxTween.tween(iconGF, {y: (!hasDownScroll ? 820 : -150)}, 1.5, {ease: FlxEase.expoIn}));
						extraTween.push(FlxTween.tween(gfGroup, {x: 3500}, 1.5, {ease: FlxEase.quadInOut}));
						extraTween.push(FlxTween.tween(gfGroup, {y: -400}, 1.5, {ease: FlxEase.cubeIn, onComplete: function(twn:FlxTween)
							{
								gfGroup.scrollFactor.set(0.55, 0.55);
								triggerEventNote('Change Character', '2', 'yoshi-exe');
								triggerEventNote('Play Animation', 'prepow', 'gf');
								gfGroup.x = 685;
								gfGroup.y = -1200;
								extraTween.push(FlxTween.tween(gfGroup, {y: 20}, 0.20, {startDelay: 1.04, onComplete: function(twn:FlxTween)
									{
										triggerEventNote('Screen Shake','0.8, 0.02','');
										triggerEventNote('Play Animation', 'pow', 'gf');
										triggerEventNote('Play Animation', 'xd', 'dad');
										starmanPOW.visible = false;
										extraTween.push(FlxTween.tween(dadGroup, {y: 1500}, 0.6, {ease:FlxEase.quadIn, onComplete: function(twn:FlxTween)
											{
												dadGroup.x = dadx;
												dadGroup.y = dady;
												triggerEventNote('Change Character', '1', 'peach-exe');
												dad.visible = false;
											}}));
									}}));
							}}));
					case 5:
						//262
						BF_ZOOM = 0.7;
						DAD_ZOOM = 0.7;
						GF_ZOOM = 0.7;
						DAD_CAM_Y = 800;
					case 6:
						//266
						extraTween.push(FlxTween.tween(camFollowPos, {x: 550, y: 250}, 1.25, {startDelay: 0.25, ease: FlxEase.quadInOut}));
						extraTween.push(FlxTween.tween(camGame, {zoom: 0.65}, 1.5, {ease: FlxEase.quadInOut}));
						FOLLOWCHARS = false;
						ZOOMCHARS = false;
					case 7:
						//269
						// extraTween.push(FlxTween.tween(camFollowPos, {x: 1550, y: 800}, 1.38, {ease: FlxEase.expoIn}));
						ZOOMCHARS = true;
						BF_ZOOM = 0.6;
						DAD_ZOOM = 0.6;
						peachCuts.x = -2000;
						peachCuts.y = -700;
						peachCuts.alpha = 1;
						peachCuts.animation.play('floats');
						iconGF.y = iconP2.y - (!hasDownScroll ? 35 : -15);
						iconGF.loadGraphic(Paths.image('icons/icon-yoshiex'), true, Math.floor(iconGF.width), Math.floor(iconGF.height));
						iconGF.animation.add("win", [0], 10, true);
						iconGF.animation.add("lose", [1], 10, true);
						extraTween.push(FlxTween.tween(peachCuts, {y: -380}, 1.25, {ease: FlxEase.quadInOut}));
						extraTween.push(FlxTween.tween(peachCuts, {x: -235}, 1.5, {ease: FlxEase.backOut, onComplete: function(twn:FlxTween)
							{
								extraTween.push(FlxTween.tween(peachCuts, {y: -200}, 0.4, {startDelay: 0.1, ease: FlxEase.backIn, onComplete: function(twn:FlxTween)
									{
										peachCuts.animation.play('fall');
										eventTimers.push(new FlxTimer().start(0.5833, function(tmr:FlxTimer)
											{
												peachCuts.visible = false;
												dad.visible = true;
											}));
									}}));
							}}));
					case 8:
						//273
						extraTween.push(FlxTween.tween(camFollowPos, {x: BF_CAM_X, y: BF_CAM_Y}, 1.875, {ease: FlxEase.quadInOut}));
						FOLLOWCHARS = true;
						DAD_CAM_Y = 250;
					case 9:
						//336
						DAD_ZOOM = 0.5;
						BF_ZOOM = 0.5;
						defaultCamZoom = 0.5;
					case 10:
						//391
						eventTimers.push(new FlxTimer().start(1.875, function(tmr:FlxTimer)
							{
								dad.visible = false;
								peachCuts.visible = true;
								peachCuts.animation.play('dies');
								triggerEventNote('Play Animation', 'duro', 'gf');
								peachCuts.x = -500;
								peachCuts.y = -275;

								eventTimers.push(new FlxTimer().start(2.5, function(tmr:FlxTimer)
									{
										FlxFlicker.flicker(peachCuts, 2, 0.12, false);
									}));
							}));
						FOLLOWCHARS = false;
						ZOOMCHARS = false;
						extraTween.push(FlxTween.tween(camFollowPos, {x: DAD_CAM_X, y: DAD_CAM_Y + 75}, 2.5, {ease: FlxEase.quadInOut}));
					case 11:
						//396
						eventTimers.push(new FlxTimer().start(1.875, function(tmr:FlxTimer)
							{
								DAD_ZOOM = 0.6;
								BF_ZOOM = 0.6;
								BF_CAM_X = 1200;
								triggerEventNote('Play Animation', 'death', 'gf');
								extraTween.push(FlxTween.tween(iconGF, {alpha: 0}, 0.75, {ease: FlxEase.expoIn}));
								eventTimers.push(new FlxTimer().start(2.0833, function(tmr:FlxTimer)
									{
										gfGroup.visible = false;
									}));
							}));
						extraTween.push(FlxTween.tween(camFollowPos, {x: DAD_CAM_X + 150}, 2, {ease: FlxEase.quadInOut}));
						extraTween.push(FlxTween.tween(camGame, {zoom: DAD_ZOOM + 0.15}, 2, {ease: FlxEase.quadInOut}));
						// starmanPOW.visible = false;
					case 12:
						//404
						// BF_ZOOM = 0.8;
						// BF_CAM_X = 1550;
						// defaultCamZoom = 0.8;
						dad.visible = true;
						triggerEventNote('Change Character', '1', 'mariohorror-melt');
						triggerEventNote('Play Animation', 'jump', 'dad');
						dad.x -= 800;
						dad.y += 1200;
						defaultCamZoom = 0.5;
						extraTween.push(FlxTween.tween(camGame, {zoom: 0.5}, 0.5, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(dad, {x: dad.x + 800}, .95, {startDelay: 0.8, ease: FlxEase.linear}));
						eventTweens.push(FlxTween.tween(dad, {y: dad.y - 2200}, 0.6, {startDelay: 0.8, ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
							{
								triggerEventNote('Play Animation', 'fall', 'dad');
								eventTweens.push(FlxTween.tween(dad, {y: dad.y + 1000}, 0.35, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
									{
										triggerEventNote('Play Animation', 'singDOWN', 'dad');
										FOLLOWCHARS = true;
										ZOOMCHARS = true;
									}}));
							}}));
					case 13:
						//406 this does nothing lololol
						// BF_ZOOM = 0.9;
						// BF_CAM_X = 1650;
						// defaultCamZoom = 0.9;
					case 14:
						//408
						BF_CAM_X = 1550;
						BF_ZOOM = 0.5;
						//peachCuts.visible = false;
					case 16:
						//512
						extraTween.push(FlxTween.tween(camFollowPos, {x: 550}, 1, {ease: FlxEase.expoOut}));
						extraTween.push(FlxTween.tween(camFollowPos, {y: 250}, 1, {ease: FlxEase.expoOut}));

						extraTween.push(FlxTween.tween(dadGroup, {alpha: 0}, 2, {startDelay: 1.875}));
						extraTween.push(FlxTween.tween(camHUD, 	{alpha: 0}, 2, {startDelay: 1.875}));

						extraTween.push(FlxTween.tween(timeBarBG, 		{alpha: 0}, 0.5));
						extraTween.push(FlxTween.tween(timeBar, 		{alpha: 0}, 0.5));
						extraTween.push(FlxTween.tween(timeTxt, 		{alpha: 0}, 0.5));
						extraTween.push(FlxTween.tween(customHB, 		{alpha: 0}, 0.5));
						extraTween.push(FlxTween.tween(iconP1, 			{alpha: 0}, 0.5));
						extraTween.push(FlxTween.tween(iconP2, 			{alpha: 0}, 0.5));

						//3,875
					case 17:
						//514
						ZOOMCHARS = false;
						defaultCamZoom = 0.7;
						extraTween.push(FlxTween.tween(camGame, {zoom: 0.7}, 3, {ease: FlxEase.linear}));
						
						boyfriendGroup.visible = false;
						blackBarThingie.visible = true;
						platform2.visible = false;
						FlxG.camera.flash(FlxColor.RED, 0.5);
						triggerEventNote('Screen Shake','3.8, 0.01','');
				}

			case 'Triggers All-Stars':
				var trigger:Float = Std.parseFloat(value1);
				var trigger2:Float = Std.parseFloat(value2);
				if (Math.isNaN(trigger))
					trigger = 0;
				if (Math.isNaN(trigger2))
					trigger2 = 0;

				switch(trigger)
				{
					case 0:
						switch(trigger2)
						{
							case 0:
								act2IntroGF.animation.play('idle');
								act2IntroGF.visible = true;
								eventTweens.push(FlxTween.tween(act2IntroGF, {alpha: 1}, 0.1, {}));
								eventTweens.push(FlxTween.tween(act2IntroGF.scale, {x: 0.01}, 3, {ease: FlxEase.expoOut}));
								eventTweens.push(FlxTween.tween(act2IntroGF.scale, {y: 0.01}, 3, {ease: FlxEase.expoOut}));

								// eventTweens.push(FlxTween.tween(act2IntroGF, {x: 100}, 3, {ease: FlxEase.expoOut}));
								eventTweens.push(FlxTween.tween(act2IntroGF, {y: act2IntroGF.y - 400}, 3, {ease: FlxEase.circOut}));
								eventTweens.push(FlxTween.tween(act2IntroGF, {angle: 5}, 3, {ease: FlxEase.expoOut}));
							case 1:
								eventTweens.push(FlxTween.tween(act2IntroGF, {alpha: 0}, 0.6, {}));
							case 2:
								act2IntroEyes.visible = true;
								act2IntroEyes.animation.play('idle');
								eventTweens.push(FlxTween.tween(act2IntroEyes.scale, {x: 1.8}, 0.8, {ease: FlxEase.expoIn}));
								eventTweens.push(FlxTween.tween(act2IntroEyes.scale, {y: 1.8}, 0.8, {ease: FlxEase.expoIn}));
								eventTweens.push(FlxTween.tween(act2IntroEyes, {x: act2IntroEyes.x - 185}, 0.8, {ease: FlxEase.expoIn}));
								eventTweens.push(FlxTween.tween(act2IntroEyes, {y: 120}, 0.8, {ease: FlxEase.circOut}));
							case 3:
								eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 0}, 0.7, {ease: FlxEase.expoOut}));
								eventTweens.push(FlxTween.tween(act2IntroEyes, {alpha: 0}, 0.2, {ease: FlxEase.expoOut}));
								eventTweens.push(FlxTween.tween(act2Fog, {alpha: 0.7}, 0.7, {ease: FlxEase.expoOut}));
								act2IntroEyes.visible = false;
								act2IntroGF.visible = false;
								camHUD.visible = true;
								DAD_ZOOM = 0.6;
								DAD_CAM_X = 520;
								DAD_CAM_Y = 350;
							case 4:
						}
					case 1:
						switch(trigger2)
						{
							case 0:
								//does nothing lol!
							case 1:
								//act 1 intro
								camHUD.visible = false;
								blackBarThingie.alpha = 1;
								act1Intro.alpha = 1;
								act1Intro.animation.play('idle');
							case 2:
								if (ClientPrefs.flashing)
									{
										FlxG.camera.flash(FlxColor.RED, 0.8);
									}
									else
									{
										FlxG.camera.flash(FlxColor.BLACK, 0.8);
									}
								act1Fog.visible = true;
								camHUD.visible = true;
								blackBarThingie.alpha = 0;
								act1Intro.alpha = 0;
								resyncVocals();
						}
						
					
					case 2:
					//	ACT 2
						switch(trigger2)
						{
							case 0:
								resyncVocals();
								DAD_ZOOM = 2;
								DAD_CAM_X = 480;
								DAD_CAM_Y = -220;
								BF_ZOOM = 0.8;
								BF_CAM_X = 520;
								BF_CAM_Y = 450;

								act1BGGroup.visible = false;
								act1FG.visible = false;
								act1Gradient.visible = false;
								act1Fog.visible = false;
								//part 1
								titleText.text = 'All-Stars (Act 2)';
								autorText.text = 'Sandi ft. Kenny L';

								blackBarThingie.alpha = 1;
								camHUD.alpha = 0;

								triggerEventNote('Change Character', '1', 'omega');
								triggerEventNote('Change Character', '0', 'bf_behind');
								dad.x = 320;
								dad.y = -130;
								dad.scrollFactor.set(0.5, 0.5);
								gf.visible = false;

								remove(dadGroup);
								remove(gfGroup);
								insert(members.indexOf(act2Sky) + 1, dadGroup);
								insert(members.indexOf(act2BGGroup) + 1, gfGroup);
								
								act2BFPipe.visible = true;
								act2BGGroup.visible = true;
								act2Stat.visible = true;
								act2Sky.visible = true;
								act2Fog.visible = true;
								act2Fog.alpha = 0;

							case 1:
								//luigi
								triggerEventNote('Change Character', '2', 'lg2');
								reloadHealthBarColors();
								GF_CAM_X = 520;
								GF_CAM_Y = 350;
								GF_ZOOM = 0.7;
								gfGroup.x = 200;
								gfGroup.y = 670;
								gf.visible = true;
								iconLG.visible = true;
								iconP2.visible = false;

								FOLLOWCHARS = true;
								ZOOMCHARS = true;

								add(iconY0);
								add(iconW4);
								add(iconLG);

								gfGroup.scrollFactor.set(0.9, 0.9);
								eventTweens.push(FlxTween.tween(gf, {y: gf.y - 800}, 2, {ease: FlxEase.circOut}));
								eventTweens.push(FlxTween.tween(act2LPipe, {y: act2LPipe.y - 800}, 2, {ease: FlxEase.circOut}));
						
								if (hasDownScroll){
									iconW4.y = iconP2.y + 75 - 250;
									iconY0.y = iconP2.y - 75 - 250;
								}
								else{
									iconW4.y = iconP2.y + 75 + 250;
									iconY0.y = iconP2.y - 75 + 250;
								}
				
								iconLG.y = iconP2.y;

								eventTweens.push(FlxTween.tween(act2Sky.velocity, {x: 10}, 0.8, {ease: FlxEase.quadInOut}));
							case 2:
								//wario
								triggerEventNote('Change Character', '1', 'w4r');
								reloadHealthBarColors();

								remove(dadGroup);
								insert(members.indexOf(gfGroup) + 1, dadGroup);

								DAD_CAM_X = 260;
								DAD_CAM_Y = 450;
								DAD_ZOOM = 0.7;
								dad.x = -370;
								dad.y = 910;
								dad.visible = true;
								dad.scrollFactor.set(0.95, 0.95);
								iconW4.visible = true;
								eventTweens.push(FlxTween.tween(dad, {y: dad.y - 800}, 2, {ease: FlxEase.circOut}));
								eventTweens.push(FlxTween.tween(act2WPipe, {y: act2WPipe.y - 800}, 2, {ease: FlxEase.circOut}));
								if (hasDownScroll)
									eventTweens.push(FlxTween.tween(iconW4, {y: iconW4.y + 230}, 2, {ease: FlxEase.circOut}));
								else
									eventTweens.push(FlxTween.tween(iconW4, {y: iconW4.y - 280}, 2, {ease: FlxEase.circOut}));
							case 3:
								//yoshi
								funnylayer0.visible = true;
								iconY0.visible = true;
								funnylayer0.x = 850;
								funnylayer0.y = 1000;

								eventTweens.push(FlxTween.tween(act2Sky.velocity, {x: -700}, 1.6, {ease: FlxEase.cubeOut}));

								eventTweens.push(FlxTween.tween(funnylayer0, {y: funnylayer0.y - 800}, 2, {ease: FlxEase.circOut}));
								eventTweens.push(FlxTween.tween(act2YPipe, {y: act2YPipe.y - 800}, 2, {ease: FlxEase.circOut}));
								if (hasDownScroll)
									eventTweens.push(FlxTween.tween(iconY0, {y: iconY0.y + 280}, 2, {ease: FlxEase.circOut}));
								else
									eventTweens.push(FlxTween.tween(iconY0, {y: iconY0.y - 230}, 2, {ease: FlxEase.circOut}));
							case 4:
								//start act3 transition
								extraTween.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 0.8, {ease: FlxEase.quadInOut}));
								extraTween.push(FlxTween.tween(act2Fog, {alpha: 0}, 0.8, {ease: FlxEase.quadInOut}));
								extraTween.push(FlxTween.tween(camHUD, {alpha: 0}, 3.6, {ease: FlxEase.quadInOut}));
								extraTween.push(FlxTween.tween(camHUD, {angle: 15}, 3.6, {ease: FlxEase.quadIn}));
								extraTween.push(FlxTween.tween(camHUD, {y: 500}, 3.6, {ease: FlxEase.quadIn}));
							case 5:
								//omega scream
								triggerEventNote('Play Animation', 'scream', 'dad');
								ZOOMCHARS = false;
								FOLLOWCHARS = false;
								extraTimers.push(new FlxTimer().start(1.1, function(tmr:FlxTimer)
									{
										ZOOMCHARS = true;
										FOLLOWCHARS = true;
									}));
								extraTimers.push(new FlxTimer().start(0.2, function(tmr:FlxTimer)
									{
										triggerEventNote('Screen Shake', '0.8, 0.01', '');
									}));
								extraTween.push(FlxTween.tween(camFollowPos, {y: DAD_CAM_Y - 250}, 0.8, {startDelay: 0.2, ease: FlxEase.cubeOut}));
								extraTween.push(FlxTween.tween(camGame, {zoom: DAD_ZOOM + 0.5}, 1, {ease: FlxEase.quadInOut}));
							case 6:
								//change camera for bow
								FOLLOWCHARS = false;
								ZOOMCHARS = false;
								extraTween.push(FlxTween.tween(camFollowPos, {y: 130}, 0.6, {ease: FlxEase.quadOut}));
								extraTween.push(FlxTween.tween(camGame, {zoom: 0.9}, 0.6, {ease: FlxEase.quadOut}));
							case 7: 
								//hide omega
								dad.visible = false;
							case 8:
								//white flash
								extraTween.push(FlxTween.tween(act2Sky, {x: act2Sky.x - 75}, 0.35, {ease: FlxEase.quadOut}));
								if (ClientPrefs.flashing){
									act2WhiteFlash.visible = true;
									act2WhiteFlash.alpha = 1;
									extraTween.push(FlxTween.tween(act2WhiteFlash, {alpha: 0}, 0.35, {ease: FlxEase.quadInOut}));
								}
						}
					case 3:
						switch(trigger2)
						{
							case 0:
								//act 3
								resyncVocals();

								titleText.text = 'All-Stars (Act 3)';
								autorText.text = 'Scrumbo_ ft. FriedFrick';

								triggerEventNote('Change Character', '0', 'bfASsad');
								triggerEventNote('Change Character', '1', 'gx');

								iconLG.visible = false;
								iconW4.visible = false;
								iconY0.visible = false;

								DAD_ZOOM = 0.8;
								DAD_CAM_X = -800;
								DAD_CAM_Y = 400;
								DAD_CAM_EXTEND = BF_CAM_EXTEND = 20;
								BF_ZOOM = 0.6;
								BF_CAM_X = 350;
								BF_CAM_Y = 475;

								dad.x = -1400;
								dad.y = -1310;
								dad.scrollFactor.set(1, 1);

								act3BGGroup.visible = true;
								act3Fog.visible = true;
								act3Fog.alpha = 0;

								remove(act3BGGroup);
								insert(members.indexOf(dadGroup) - 1, act3BGGroup);

								act3UltraHead2.alpha = 0.00001;
				
								act2BFPipe.visible = false;
								act2BGGroup.visible = false;
								act2Sky.visible = false;
								act2Stat.visible = false;
								funnylayer0.visible = false;
								gf.visible = false;

								triggerEventNote('Play Animation', 'cut', 'bf');

								act3Spotlight.visible = true;
								act3Spotlight.alpha = 0.7;
								extraTween.push(FlxTween.tween(act3Fog, {alpha: 0.7}, 1, {ease: FlxEase.quadIn}));
								extraTween.push(FlxTween.tween(blackBarThingie, {alpha: 0}, 1, {ease: FlxEase.quadOut}));
								extraTween.push(FlxTween.tween(camFollowPos, {x: DAD_CAM_X}, 3.2, {startDelay: 1.6, ease: FlxEase.quadInOut}));
								extraTween.push(FlxTween.tween(camFollowPos, {y: DAD_CAM_Y}, 3.2, {startDelay: 1.6, ease: FlxEase.quadInOut}));
								extraTween.push(FlxTween.tween(camGame, {zoom: DAD_ZOOM}, 3.2, {startDelay: 1.6, ease: FlxEase.quadOut}));
							case 1:
								//lower gx
								eventTweens.push(FlxTween.tween(dad, {y: dad.y + 900}, 1.6, {ease: FlxEase.quadInOut}));
								extraTween.push(FlxTween.tween(act3Spotlight, {alpha: 0}, 3.2, {ease: FlxEase.quadInOut}));
							case 2:
								//reset gx camera
								DAD_ZOOM = 0.65;
								DAD_CAM_X = -400;
							case 3:
								//first lyrics
								act3UltraHead1.animation.play('sing');
							case 4:
								//second lyrics
								act3UltraHead1.visible = false;
								act3UltraHead2.alpha = 1;
								act3UltraHead2.animation.play('sing');
								act3UltraBody.animation.play('change', true);

								ZOOMCHARS = false;
								DAD_CAM_X = BF_CAM_X = -240;
								DAD_CAM_Y = BF_CAM_Y = 400;
								DAD_CAM_EXTEND = BF_CAM_EXTEND = 30;
								triggerEventNote('Set Cam Zoom', '0.5', '');

								extraTween.push(FlxTween.tween(camGame, {zoom: 0.5}, 0.8, {ease: FlxEase.cubeInOut}));
								extraTween.push(FlxTween.tween(this, {defaultCamZoom: 0.5}, 0.8, {ease: FlxEase.cubeInOut}));
							case 5:
								//reset hude cam
								camHUD.angle = 0;
								camHUD.y = 0;
								extraTween.push(FlxTween.tween(camHUD, {alpha: 1}, 2.4, {ease: FlxEase.quadInOut}));
								iconP2.visible = true;
							case 6:
								//hide pupils
								act3UltraPupils.visible = false;
							case 7:
								//start act 4 transition
								FOLLOWCHARS = false;
								act3UltraHead2.animation.play('laugh', true);
								extraTween.push(FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.quadInOut}));
								extraTween.push(FlxTween.tween(camFollowPos, {y: BF_CAM_Y + 350}, 1.6, {ease: FlxEase.quadInOut}));
								extraTween.push(FlxTween.tween(camGame, {zoom: 0.6}, 1.2, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
									{
										extraTween.push(FlxTween.tween(act3Fog, {alpha: 0}, 0.35, {ease: FlxEase.quadInOut}));
										extraTween.push(FlxTween.tween(camGame, {zoom: 8}, 0.35, {ease: FlxEase.expoIn, onComplete: function(twn:FlxTween)
											{
												blackBarThingie.alpha = 1;
											}}));
									}}));
						}

					case 4:
						switch(trigger2)
						{
							case 0:
								//act 4
								resyncVocals();
								titleText.text = 'All-Stars (Act 4)';
								autorText.text = 'FriedFrick\n ft. theWAHbox and RedTV53';

								ZOOMCHARS = true;
								FOLLOWCHARS = true;
								DAD_CAM_X = 190;
								DAD_CAM_Y = 240;
								DAD_ZOOM = 2.5;
								DAD_CAM_EXTEND = 40;
								BF_CAM_X = 720;
								BF_CAM_Y = 480;
								BF_ZOOM = 1.3;
								BF_CAM_EXTEND = 15;
								insert(members.indexOf(iconP2) - 1, iconA4);
								insert(members.indexOf(iconA4) - 1, iconA42);
								iconA4.visible = false;
								iconA42.visible = false;

								if (hasDownScroll){
									iconA4.y = iconW4.y;
									iconA42.y = iconA4.y - 90;
								}
								else{
									iconA4.y = iconY0.y;
									iconA42.y = iconA4.y + 70;
								}

								triggerEventNote('Change Character', '0', 'bf_ultrafinale');
								triggerEventNote('Change Character', '1', 'mario_ultra2');
								dadGroup.x = 100;
								dadGroup.y = 100;
								boyfriendGroup.x = 810;
								boyfriendGroup.y = -75;

								extraTimers.push(new FlxTimer().start(1 / act4SpawnNum, function(tmr:FlxTimer){
									for (i in 0... act4SpawnNum){
										var objsize:Float = FlxG.random.int(60, 115) / 100;

										var act4Obj:BGSprite = new BGSprite('mario/allfinal/act4/floating objects', 2200, 200 + FlxG.random.int(-250, 250), 0.5, 0.5, ['floating objects']);
										act4Obj.animation.addByIndices('1', 'floating objects', [0], "", 24, true);
										act4Obj.animation.addByIndices('2', 'floating objects', [1], "", 24, true);
										act4Obj.animation.addByIndices('3', 'floating objects', [2], "", 24, true);
										act4Obj.animation.addByIndices('4', 'floating objects', [3], "", 24, true);
										act4Obj.animation.addByIndices('5', 'floating objects', [4], "", 24, true);
										act4Obj.animation.addByIndices('6', 'floating objects', [5], "", 24, true);
										act4Obj.animation.addByIndices('7', 'floating objects', [6], "", 24, true);
										act4Obj.animation.addByIndices('8', 'floating objects', [7], "", 24, true);
										act4Obj.animation.addByIndices('9', 'floating objects', [8], "", 24, true);
										act4Obj.animation.addByIndices('10', 'floating objects', [9], "", 24, true);
										act4Obj.animation.play(FlxG.random.int(1,10) + '', true);
										act4Obj.angle = FlxG.random.int(0,360);
										act4Obj.scrollFactor.set(0.65 + (objsize / 5), 0.65 + (objsize / 5));
										act4Obj.scale.set(objsize, objsize);
										if (boyfriend.curCharacter == 'bf_ultrafinale2')
											act4Obj.color = 0xff4e4e4e;
										// act4Obj.ID = Math.floor(6 + (objsize * 100));
										act4Floaters.insert(members.indexOf(act4Ripple)  + Math.floor(6 + (objsize * 100)), act4Obj);

										var tweenspeed:Float = FlxG.random.int(95, 220) / (7 + (act4SpawnNum * 3));

										if (FlxG.random.bool(50))
											extraTween.push(FlxTween.tween(act4Obj, {angle: act4Obj.angle + FlxG.random.int(90, 360)}, tweenspeed));
										else
											extraTween.push(FlxTween.tween(act4Obj, {angle: act4Obj.angle - FlxG.random.int(90, 360)}, tweenspeed));
										
										extraTween.push(FlxTween.tween(act4Obj, {x: -450}, tweenspeed, {onComplete: function(twn:FlxTween)
											{
												act4Obj.destroy();
											}}));
									}
									// tmr.reset(1 / act4SpawnNum);
								}, 0));

								act3BGGroup.visible = false;
								act3Fog.visible = true;

								act4BGGroup.visible = true;
								act4Pipe1.visible = true;
								dad.visible = true;

								remove(dadGroup);
								insert(members.indexOf(act4Floaters) + 1, dadGroup);
								insert(members.indexOf(blackBarThingie) + 1, act4Intro);
							case 1:
								//sad perspective transition
								BF_CAM_X = 1000;
								BF_CAM_Y = 550;
								BF_ZOOM = 1.5;
								extraTween.push(FlxTween.tween(customHB, {alpha: 0}, 1.6, {ease: FlxEase.quadInOut}));
								extraTween.push(FlxTween.tween(iconP1, {alpha: 0}, 1.6, {ease: FlxEase.quadInOut}));
								extraTween.push(FlxTween.tween(iconP2, {alpha: 0}, 1.6, {ease: FlxEase.quadInOut}));
								extraTween.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 1.6, {ease: FlxEase.quadInOut}));
								extraTween.push(FlxTween.tween(camFollowPos, {x: BF_CAM_X, y: BF_CAM_Y}, 1.6, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
								{
									camFollowPos.x += 40;
									camFollowPos.y -= 250;
								}}));
								extraTween.push(FlxTween.tween(camGame, {zoom: BF_ZOOM}, 1.6, {ease: FlxEase.quadInOut}));
							case 2:
								//enter sad perspective
								iconA4.visible = false;
								act4BGGroup.visible = false;
								act4Pipe1.visible = false;
								dad.visible = false;
								act4SpawnNum = 1;

								act4BG2Group.visible = true;
								act4Pipe2.visible = true;
								act4Spotlight.visible = true;
								act4Floaters.forEachAlive(function(act4Obj:BGSprite){
									act4Obj.color = 0xff4e4e4e;
								});

								triggerEventNote('Change Character', '0', 'bf_ultrafinale2');
								BF_CAM_Y = 425;
								BF_ZOOM = 0.7;
								extraTween.push(FlxTween.tween(blackBarThingie, {alpha: 0}, 0.8, {ease: FlxEase.quadInOut}));
								insert(members.indexOf(boyfriendGroup) + 1, act4Spotlight);
							case 3:
								//gf memory
								BF_ZOOM = 0.6;
								extraTween.push(FlxTween.tween(act4Spotlight, {alpha: 1}, 20, {ease: FlxEase.linear}));
								extraTween.push(FlxTween.tween(act4Memory1, {y: act4Memory1.y - 300}, 9, {ease: FlxEase.linear}));
								extraTween.push(FlxTween.tween(act4Memory1, {alpha: 0.4}, 4.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
								{
									extraTween.push(FlxTween.tween(act4Memory1, {alpha: 0}, 4.5, {ease: FlxEase.quadOut}));
								}}));
							case 4:
								//gx memory
								extraTween.push(FlxTween.tween(act4Memory2, {y: act4Memory2.y + 300}, 9, {ease: FlxEase.linear}));
								extraTween.push(FlxTween.tween(act4Memory2, {alpha: 0.4}, 4.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
								{
									extraTween.push(FlxTween.tween(act4Memory2, {alpha: 0}, 4.5, {ease: FlxEase.quadOut}));
								}}));
							case 5:
								//end perspective transition
								ZOOMCHARS = false;
								extraTween.push(FlxTween.tween(camGame, {zoom: 0.5}, 0.8, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
									{
										act4SpawnNum = 4;
										extraTween.push(FlxTween.tween(camGame, {zoom: 1.2}, 0.8, {ease: FlxEase.cubeIn}));
									}}));
							case 6:
								//finale perspective
								act4Floaters.forEachAlive(function(act4Obj:BGSprite){
									act4Obj.color = FlxColor.WHITE;
								});
								if (ClientPrefs.flashing)
									{
										FlxG.camera.flash(FlxColor.WHITE, 0.8);
									}
									else
									{
										FlxG.camera.flash(FlxColor.BLACK, 0.8);
									}
								
								triggerEventNote('Change Character', '0', 'bf_ultrafinale3');
								triggerEventNote('Change Character', '1', 'mario_ultra3');
								triggerEventNote('Set Cam Zoom', '1.05', '');

								boyfriendGroup.x += 270;
								boyfriendGroup.y += 225;
								dadGroup.x += 250;

								act4BG2Group.visible = false;
								act4Pipe2.visible = false;
								act4Spotlight.visible = false;
								add(act4Lightning);
								act4Lightning.visible = true;
								act4BGGroup.visible = true;
								customHB.alpha = 1;
								iconP1.alpha = 1;
								iconP2.alpha = 1;
								act4Ripple.x += 300;
								act4Ripple.y += 75;
								act4Stat.x += 150;
								act4Stat.y += 75;

								DAD_CAM_X = BF_CAM_X -= 50;
								DAD_CAM_Y = BF_CAM_Y;
								DAD_CAM_EXTEND = BF_CAM_EXTEND = 20;
								extraTween.push(FlxTween.tween(camFollowPos, {x: DAD_CAM_X, y: DAD_CAM_Y}, 0.1));
							case 7:
								//S1E8 Boyfriend Dies and Doesn't Come Back
								FlxG.camera.flash(FlxColor.RED, 1);
								act2WhiteFlash.color = FlxColor.RED;
								act2WhiteFlash.visible = true;
								act2WhiteFlash.alpha = 1;
								camHUD.visible = false;

								FOLLOWCHARS = false;

								dadGroup.visible = false;
								boyfriendGroup.visible = false;
								act3Fog.visible = false;
								act4BGGroup.visible = false;
								act4Lightning.visible = false;
								act4Floaters.visible = false;
								
								remove(act4DeadBF);
								add(act4DeadBF);
								add(act4GameOver);

								act4DeadBF.animation.play('die');
								act4DeadBF.alpha = 1;
								act4GameOver.alpha = 0;
								ZOOMCHARS = true;
								camGame.zoom = BF_ZOOM;
								triggerEventNote('Set Cam Zoom', '0.7', '');
							case 8:
								//bf dies part 3
								ZOOMCHARS = false;
								extraTween.push(FlxTween.tween(camGame, {zoom: 0.1}, 7.2, {ease: FlxEase.quadIn}));
								extraTween.push(FlxTween.tween(act4DeadBF, {alpha: 0}, 4.8, {ease: FlxEase.quadIn}));
							case 9:
								//bf dies part 3
								extraTween.push(FlxTween.tween(act4GameOver, {alpha: 1}, 4.8, {ease: FlxEase.quadInOut}));
							case 10:
								//bf dies part 4
								extraTween.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 4.8, {ease: FlxEase.quadInOut}));
							case 11:
								act4SpawnNum = 3;
							case 12:
								act4SpawnNum = 2;
							case 13:
								//bf die zoom in
								extraTween.push(FlxTween.tween(camGame, {zoom: BF_ZOOM + 0.4}, 0.8, {ease: FlxEase.cubeIn}));
								extraTween.push(FlxTween.tween(camFollowPos, {x: BF_CAM_X + 150, y: BF_CAM_Y + 50}, 0.8, {ease: FlxEase.cubeIn, onComplete: function(twn:FlxTween)
									{	
									camFollowPos.x = BF_CAM_X;
									camFollowPos.y = BF_CAM_Y;
									}}));
							case 14:
								//voiceline thing
								act4Intro.scale.set(0.01, 0.01);
								act4Intro.animation.play('anim', true);
								extraTween.push(FlxTween.tween(act4Intro, {alpha: 1}, 0.5, {ease: FlxEase.sineOut}));
								extraTween.push(FlxTween.tween(act4Intro.scale, {x: 1, y: 1}, 0.8, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween)
									{	
										extraTween.push(FlxTween.tween(act4Intro.scale, {x: 1.2, y: 1.2}, 10, {ease: FlxEase.quadInOut}));
									}}));
							case 15:
								//FIGHT
								// triggerEventNote('Play Animation', 'singRIGHT', 'dad');
								extraTween.push(FlxTween.tween(blackBarThingie, {alpha: 0}, 0.7, {ease: FlxEase.quadOut}));
								extraTween.push(FlxTween.tween(act3Fog, {alpha: 0.7}, 0.7, {ease: FlxEase.quadOut}));
								extraTween.push(FlxTween.tween(act4Intro, {alpha: 0}, 0.7, {ease: FlxEase.quadOut}));
								camHUD.alpha = 1;
								DAD_CAM_X = 570;
								DAD_CAM_Y = 440;
								DAD_ZOOM = 1;
						}
					case 5:
						//switch iconA4
						var a4Icon:String = value2;
						iconA4.visible = true;
						iconA4.animation.play(a4Icon, true);
						iconA42.angle = iconA4.angle = 0;
						extraTween.push(FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut}));
						extraTween.push(FlxTween.tween(iconA42, {angle: iconA42.angle + 360}, 0.25, {ease: FlxEase.backOut}));

						if (a4Icon == 'peachex')
							iconA42.visible = true;
						else
							iconA42.visible = false;
					case 6:
						switch (trigger2){
							case 0:
								GameOverSubstate.characterName = 'bfASdeath';
							case 1:
								GameOverSubstate.characterName = 'gfASdeath';
						}
						
				}

			case 'Triggers So Cool':
				var triggerP:Float = Std.parseFloat(value1);
				if (Math.isNaN(triggerP)) triggerP = 0;
				switch (triggerP)
				{
					case 0:
						//16
						miyamoto.animation.play('talk');
						miyamoto.offset.y = 2;
					case 1:
						//23
						miyamoto.animation.play('hand');
					case 2:
						//24
						eventTweens.push(FlxTween.tween(bgred, {alpha: 0}, 1, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(dad, {x: 580}, 1, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(miyamoto, {x: -2250}, 1, {ease: FlxEase.quadInOut}));
					case 3:
						//32
						eventTweens.push(FlxTween.tween(nametag, {alpha: 1, x: 200}, 1, {ease: FlxEase.quadOut}));
				}

			case 'Triggers Nourishing Blood':
				var triggerMR:Float = Std.parseFloat(value1);
				if (Math.isNaN(triggerMR))
					triggerMR = 0;
				switch (triggerMR)
				{
					case 0:
						FlxG.camera.flash(FlxColor.WHITE, 0.5);
						flintbg.visible = true;
						flintwater.visible = true;
						triggerEventNote('Change Character', '0', 'bfcave');
						triggerEventNote('Change Character', '2', 'gfcave');
						triggerEventNote('Change Character', '1', 'grandcave');
						gdRunners.visible = false;
						thegang.visible = false;
						boyfriendGroup.x = 1258;
						boyfriendGroup.y = 480;
						gfGroup.x = 593;
						gfGroup.y = 393;
						dadGroup.x = -1;
						dadGroup.y = 556;

						DAD_CAM_X = 460;
						DAD_CAM_Y = 750;
						BF_CAM_X = 810;
						BF_CAM_Y = 750;
					case 1:
						triggerEventNote('Change Character', '0', 'bfGD');
						triggerEventNote('Change Character', '2', 'gfGD');
						triggerEventNote('Change Character', '1', 'grand');
						boyfriendGroup.x = 1270;
						boyfriendGroup.y = 310;
						gfGroup.x = 500;
						gfGroup.y = 250;
						dadGroup.x = -200;
						dadGroup.y = 330;
						flintbg.visible = false;
						flintwater.visible = false;
						thegang.visible = true;
						DAD_CAM_X = 120;
						DAD_CAM_Y = 650;
						BF_CAM_X = 1120;
						BF_CAM_Y = 750;
					case 2:
						thegang.visible = true;
						thegang.scale.x = 0.1;
						thegang.scale.y = 0.5;
						eventTweens.push(FlxTween.tween(camGame, {zoom: 0.7}, 0.25, {ease: FlxEase.backOut}));
						eventTweens.push(FlxTween.tween(thegang.scale, {x: 1, y: 1}, 0.25, {ease: FlxEase.backOut}));
						gdRunners.visible = true;
					case 3:
						eventTweens.push(FlxTween.tween(hamster, {y: -1700}, 0.15, {ease: FlxEase.sineOut}));
						eventTweens.push(FlxTween.tween(hamster, {y: -330}, 0.25, {startDelay: 0.15, ease: FlxEase.sineIn}));
						eventTweens.push(FlxTween.tween(hamster, {x: -400}, 0.33, {
							onComplete: function(twn:FlxTween)
							{
								hamster.visible = false;
							}
						}));
					case 4:
						FOLLOWCHARS = !FOLLOWCHARS;
						
					//:dave:
					case 5:
						//132
						blockzoom = true;
						eventTweens.push(FlxTween.tween(camHUD, {zoom: 1}, (1 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.elasticOut}));

						for (tween in extraTween)
							{
								tween.cancel();
							}
						extraTween.push(FlxTween.tween(camHUD, {angle: 0}, (2 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.quadOut}));
					case 6:
						//160
						blockzoom = false;
						// for (i in 0... 8){
						// 	var thenote:Int = i;
						// 	var testicle:StrumNote = strumLineNotes.members[thenote % strumLineNotes.length];

						// 	noteAR.push(testicle.x);
						// }
					case 7:
						//294
						eventTweens.push(FlxTween.tween(camGame, {zoom: 0.8}, (1.9 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.expoIn}));
						eventTweens.push(FlxTween.tween(this, {defaultCamZoom: 0.8}, (1.9 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.expoIn}));
				}

			case 'Triggers MARIO SING AND GAME RYTHM 9':
				var triggerP:Float = Std.parseFloat(value1);
				if (Math.isNaN(triggerP)) triggerP = 0;
				switch (triggerP)
				{	
					//buddy
					case 0:
						//1
						if(!paused){
							eventTweens.push(FlxTween.tween(platformlol, {y: platformlol.y - 126}, 3, {type: PINGPONG, loopDelay: 1}));
							eventTweens.push(FlxTween.tween(boyfriend, {y: boyfriend.y - 126}, 3, {type: PINGPONG, loopDelay: 1}));
							eventTweens.push(FlxTween.tween(gf, {y: gf.y - 126}, 3, {type: PINGPONG, loopDelay: 1}));
							}
					case 1:
						if(value2 == 'none'){
							pixelLights.visible = false;
							remove(bgstars);
							insert(members.indexOf(building) - 1, bgstars);
						}else{
							pixelLights.visible = true;
							pixelLights.animation.play(value2);
							if(value2 == 'full'){
								remove(bgstars);
								insert(members.indexOf(pixelLights) + 1, bgstars);
							}else{
								remove(bgstars);
								insert(members.indexOf(building) - 2, bgstars);
							}
						}
				}
			case 'Triggers No Party':
				var triggerP:Float = Std.parseFloat(value1);
				if (Math.isNaN(triggerP)) triggerP = 0;
				switch (triggerP)
				{
					case 0:
						eventTweens.push(FlxTween.tween(bfspot, {alpha: 1}, 6));
						//eventTweens.push(FlxTween.tween(this, {BF_ZOOM: 1.2}, 6, {ease: FlxEase.quadInOut}));
						FlxTween.num(1, 1.2, 6, {ease: FlxEase.quadInOut}, function(v)
							{
								BF_ZOOM = v;
							});
					case 1:
						eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 1.5));
					case 2:
						FlxG.camera.flash(FlxColor.WHITE, 0.5);
						BF_ZOOM = 1;
						bfspot.alpha = 0;
						blackBarThingie.alpha = 0;
					case 3:
						
						FlxG.sound.play(Paths.sound('lightOn'));
						drawspot.flipY = !hasDownScroll;
						drawspot.alpha = 1;
						drawspot.scale.set(1.3, 1.3);
						drawspot.y = hasDownScroll ? -100 : -20;
						drawspot.angle = 2;

						var coords:Float = -20;
						if(!hasDownScroll) coords = -100;
						
						eventTweens.push(FlxTween.tween(drawspot.scale, {x: 1, y: 1}, 1, {ease: FlxEase.expoOut}));
						eventTweens.push(FlxTween.tween(drawspot, {y: coords}, 2, {ease: FlxEase.expoOut}));
						extraTween.push(FlxTween.tween(drawspot, {angle: -2}, 2, {ease: FlxEase.quadInOut, type: PINGPONG}));
					case 4:
						for (tween in extraTween)
							{
								tween.cancel();
							}

						var coords:Float = -100;
						if(!hasDownScroll) coords = -20;
						eventTweens.push(FlxTween.tween(drawspot, {angle: 0}, 1, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(drawspot, {alpha: 0}, 1.5, {startDelay: 0.5}));
						eventTweens.push(FlxTween.tween(drawspot, {y: coords}, 2, {ease: FlxEase.backIn}));

					case 5:
						djDone.scale.x = 20;
						djDone.scale.y = 20;
						add(djDone);
						FlxG.sound.play(Paths.sound('finish'));
						extraTween.push(FlxTween.tween(djDone, {x: djDone.x + 3}, 0.04, {type: PINGPONG}));
						extraTween.push(FlxTween.tween(djDone, {y: djDone.y + 3}, 0.02, {type: PINGPONG}));
						eventTweens.push(FlxTween.tween(djDone.scale, {x: 2, y: 2}, 0.7, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
							{
								for (tween in extraTween)
									{
										tween.cancel();
									}
							}}));

						eventTweens.push(FlxTween.tween(djDone, {y: djDone.y - 200}, 0.8, {startDelay: 1.5, ease: FlxEase.backIn}));
					case 6:
						thetextC.visible = !thetextC.visible;
						thetext.visible = !thetextC.visible;
				}

			case 'Triggers Last Course':
				var trigger:Float = Std.parseFloat(value1);
				var trigger2:Float = Std.parseFloat(value2);
				if (Math.isNaN(trigger))
					trigger = 0;
				if (Math.isNaN(trigger2))
					trigger2 = 0;

				switch (trigger){
					case 0:
						//1
						ZOOMCHARS = false;
						defaultCamZoom = 1.2;
						camGame.zoom = 1.2;
						eventTweens.push(FlxTween.tween(camGame, {zoom: 1}, 5, {ease: FlxEase.cubeInOut}));
					case 2:
						//14
						FOLLOWCHARS = false;
						defaultCamZoom = 0.9;
						eventTweens.push(FlxTween.tween(camGame, {zoom: 0.9}, 6.4, {ease: FlxEase.cubeInOut}));
						eventTweens.push(FlxTween.tween(camFollowPos, {x: 420}, 5, {ease: FlxEase.cubeInOut}));
						eventTweens.push(FlxTween.tween(camFollowPos, {y: 500}, 5, {ease: FlxEase.cubeInOut}));
					case 3:
						//32
						FOLLOWCHARS = true;
					case 4:
						//192
						BF_CAM_X = 600;
					case 5:
						//208
						BF_CAM_X = 970;
					case 6:
						//219
						FOLLOWCHARS = false;
						eventTweens.push(FlxTween.tween(camFollowPos, {x: 720}, 0.42, {ease: FlxEase.cubeIn}));
						eventTweens.push(FlxTween.tween(camFollowPos, {y: 500}, 0.42, {ease: FlxEase.cubeIn}));
					case 7:
						//220
						triggerEventNote('Set Cam Zoom', '0.75', '');
						eventTweens.push(FlxTween.tween(camGame, {zoom: 0.75}, 0.4, {ease: FlxEase.cubeOut}));
					case 8:
						//224
						FOLLOWCHARS = true;
				}
			

			case 'Triggers No Hope':
				var trigger:Float = Std.parseFloat(value1);
				if (Math.isNaN(trigger))
					trigger = 0;

				switch(trigger){

					case 0:
						triggerEventNote('Change Character', '1', 'devilmariotalk');
						triggerEventNote('Play Animation', 'talk', 'Dad');
						eventTweens.push(FlxTween.tween(camFollowPos, {x: DAD_CAM_X, y: DAD_CAM_Y}, 3, {ease: FlxEase.quadInOut}));

					case 1:
						triggerEventNote('Alt Idle Animation', 'Dad', '-alt');
						powerTrail = new FlxTrail(dad, null, 4, 5, 0.5, 0.069); // nice
						insert(members.indexOf(dadGroup) - 1, powerTrail);

					case 2:
						triggerEventNote('Alt Idle Animation', 'Dad', '');
						powerTrail.visible = false;

					case 3:
						powerWarning.screenCenter();
						var oldY:Float = powerWarning.y;
						powerWarning.y -= 1000;
						powerWarning.alpha = 1;
						powerWarning.scale.set(0.1, 0.1);
						powerWarning.visible = true;
						var vanish:Float = 1.5;

						if (value2 == ''){
							vanish = 3;	
							FlxG.sound.play(Paths.sound('psPre'));
						}

						eventTweens.push(FlxTween.tween(powerWarning, {y: oldY}, 1, {ease: FlxEase.expoOut}));
						eventTweens.push(FlxTween.tween(powerWarning.scale, {x: 0.4, y: 0.4}, 1.2, {ease: FlxEase.expoOut}));
						eventTweens.push(FlxTween.tween(powerWarning, {alpha: 0}, 1, {startDelay: vanish}));
				}

			case 'Triggers Golden Land':
				var tiempoN:Float = 0.001;
				var triggerGL:Float = Std.parseFloat(value1);
				var blackcoso:Float = Std.parseFloat(value2);
				if (Math.isNaN(triggerGL))
					triggerGL = 0;
				if (Math.isNaN(blackcoso))
					blackcoso = 1;

				switch (triggerGL)
				{
					case 0:
						if (PlayState.SONG.song != 'Golden Land Old')
						{
							landbg.visible = false;
							estaland.visible = true;
							bricksland.visible = false;
							brickslandEXE.visible = true;
							triggerEventNote('Play Animation', 'idle', 'gf');
							gfGroup.y += 450;
						}
						else
						{

							if (!ClientPrefs.flashing)
							{
								tiempoN = 1;
							}
							else
							{
								tiempoN = 0.001;
							}

							PauseSubState.muymalo = 2;

							eventTweens.push(FlxTween.tween(bgfeo, {alpha: 1}, tiempoN, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(aguaExe, {alpha: 1}, tiempoN, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(sueloExe, {alpha: 1}, tiempoN, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(gfwasTaken, {alpha: 1}, tiempoN, {ease: FlxEase.quadInOut}));
							estaland.visible = true;
						}

					case 1:
						if (PlayState.SONG.song != 'Golden Land Old')
						{
							triggerEventNote('Screen Shake', '0.15, 0.05', '');
							eventTweens.push(FlxTween.tween(gfGroup, {y: gfGroup.y - 450}, 1, {ease: FlxEase.quadOut}));
						}
						else
						{
							eventTweens.push(FlxTween.tween(gfwasTaken, {y: 450}, 1, {ease: FlxEase.quadOut}));
						}

					case 2:
						eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: blackcoso}, 0.5, {ease: FlxEase.quadInOut}));
					case 3: // pense en esta wea como 1 mes despues de completar la cancion djawnkdan lmao
						quitarvida = true;
					case 4:
						quitarvida = false;
					case 5:
						eventTweens.push(FlxTween.tween(camHUD, {alpha: 0.1}, 0.5));
					case 6:
						eventTweens.push(FlxTween.tween(camGame, {zoom: 1.3}, 1.34, {ease: FlxEase.expoIn}));
					case 7:
						DAD_X = 380;
						DAD_Y = 350;
						DAD_ZOOM = 0.9;
						triggerEventNote('Screen Shake', '0.4, 0.008', '');
						triggerEventNote('Play Animation', 'laugh', 'dad');
						eventTweens.push(FlxTween.tween(camFollowPos, {x: 380, y: 350}, 1.34, {ease: FlxEase.cubeOut}));
						eventTweens.push(FlxTween.tween(camHUD, {alpha: 0.4}, 0.2));
						eventTweens.push(FlxTween.tween(camGame, {zoom: 0.9}, 0.2, {ease: FlxEase.cubeOut}));
					case 8:
						DAD_X = 420;
						DAD_Y = 450;
						DAD_ZOOM = 0.8;
						eventTweens.push(FlxTween.tween(camHUD, {alpha: 1}, 0.2));
				}
			case 'Ocultar HUD':
				var bruhHUD:Float = Std.parseFloat(value1);
				if (Math.isNaN(bruhHUD))
					bruhHUD = 0;
				switch (bruhHUD)
				{
					case 0:
						eventTweens.push(FlxTween.tween(camHUD, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut}));

					case 1:
						eventTweens.push(FlxTween.tween(camHUD, {alpha: 1}, 0.001, {ease: FlxEase.quadInOut}));

					case 2:
						eventTweens.push(FlxTween.tween(camHUD, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut}));
				}

			case 'chat message':
				DirectChat.addMessage();

				livechat.applyMarkup(DirectChat.finalchat, [
					new FlxTextFormatMarkerPair(chatcolor1, "$"),
					new FlxTextFormatMarkerPair(chatcolor2, "#"),
					new FlxTextFormatMarkerPair(chatcolor3, "%"),
					new FlxTextFormatMarkerPair(chatcolor4, "&"),
					new FlxTextFormatMarkerPair(chatcolor5, ";"),
				]);


			case 'Pico Shoot':
				for (tween in extraTween)
				{
					tween.cancel();
				}

				for (timer in extraTimers)
				{
					timer.cancel();
				}

				gunShotPico.alpha = 1;
				boyfriend.alpha = 0;
				dadGroup.alpha = 0;

				var newangle:Float;

				if (FlxG.random.bool(50))
				{
					newangle = 5;
				}
				else
				{
					newangle = -5;
				}

				camGame.angle = newangle;


				if(!(curBeat >= 204 && curBeat <= 268))
					triggerEventNote('Screen Shake', '0.15, 0.007', '0.15, 0.007');

				gunShotPico.animation.play('Shoot');
				extraTween.push(FlxTween.tween(dadGroup, {alpha: 1}, 0.7, {ease: FlxEase.quadOut}));

				extraTween.push(FlxTween.tween(camGame, {angle: 0}, 0.2, {ease: FlxEase.quadOut}));

				extraTimers.push(new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{
					gunShotPico.alpha = 0;
					boyfriend.alpha = 1;
				}));

			case 'Turmoil Attack':
				// ((1 / (Conductor.bpm / 60)))

				FlxG.sound.play(Paths.sound('warningT2'));
				warning.alpha = 1;
				var wary:Float = warning.y;
				warning.y = wary - 50;
				warning.scale.set(0.7, 0.7);
				eventTweens.push(FlxTween.tween(warning, {y: wary, alpha: 0.2}, 0.5 * (1 / (Conductor.bpm / 60)), {ease: FlxEase.expoOut}));
				eventTweens.push(FlxTween.tween(buttonxml, {alpha: 1}, 0.2, {ease: FlxEase.quadOut}));

				eventTimers.push(new FlxTimer().start(((1 / (Conductor.bpm / 60))), function(tmr:FlxTimer)
				{
					FlxG.sound.play(Paths.sound('warningT2'));
					warning.alpha = 1;
					eventTweens.push(FlxTween.tween(warning.scale, {y: 0.8, x: 0.8}, 0.5 * (1 / (Conductor.bpm / 60)), {ease: FlxEase.elasticOut}));
					eventTweens.push(FlxTween.tween(warning, {alpha: 0.2}, 0.5 * (1 / (Conductor.bpm / 60)), {ease: FlxEase.quadOut}));
				}));

				eventTimers.push(new FlxTimer().start(((2 / (Conductor.bpm / 60))), function(tmr:FlxTimer)
				{
					FlxG.sound.play(Paths.sound('warningT2'));
					warning.alpha = 1;
					eventTweens.push(FlxTween.tween(warning.scale, {y: 1, x: 1}, 0.5 * (1 / (Conductor.bpm / 60)), {ease: FlxEase.elasticOut}));
					eventTweens.push(FlxTween.tween(warning, {alpha: 0}, 0.5 * (1 / (Conductor.bpm / 60)), {ease: FlxEase.quadOut}));
				}));

				eventTimers.push(new FlxTimer().start(0.2083 - (3 * (1 / (Conductor.bpm / 60))), function(tmr:FlxTimer)
				{
					triggerEventNote('Play Animation', 'preattack', 'dad');
				}));

				eventTimers.push(new FlxTimer().start((3 * (1 / (Conductor.bpm / 60))), function(tmr:FlxTimer)
				{
					triggerEventNote('Play Animation', 'attack', 'dad');
					FlxG.sound.play(Paths.sound('TURMOIL-LENGUETAZO'));
					triggerEventNote('Screen Shake', '0.15, 0.007', '0.15, 0.007');

					eventTimers.push(new FlxTimer().start(0.0483, function(tmr:FlxTimer)
					{
						if (!isDodging && !cpuControlled)
						{
							boyfriend.playAnim('singRIGHTmiss', true);
							var newhealth:Float = health - 1.2;
							eventTweens.push(FlxTween.tween(this, {health: newhealth}, 0.2, {ease: FlxEase.quadOut}));
						}
						if (cpuControlled)
						{
							buttonxml.animation.play('press');
							boyfriend.playAnim('dodge', true);
						}
					}));

					eventTweens.push(FlxTween.tween(buttonxml, {alpha: 0}, 0.5 * (1 / (Conductor.bpm / 60)), {startDelay: 0.5, ease: FlxEase.quadOut}));
				}));

			case 'Power Attack':
				marioattack.x = -70;
				marioattack.y = -40;
				dad.visible = false;
				marioattack.visible = true;
				marioattack.animation.play("prevAttack", true);

				var newzoom:Float = defaultCamZoom + 0.2;
				var thetime:Float = 0.6875;
				FlxG.sound.play(Paths.sound('psPre'));

				eventTweens.push(FlxTween.tween(powervitte, {alpha: 1}, thetime, {ease: FlxEase.quadIn}));
				eventTweens.push(FlxTween.tween(camGame, {zoom: newzoom}, thetime, {ease: FlxEase.quadIn}));
				
				eventTimers.push(new FlxTimer().start(thetime, function(tmr:FlxTimer)
					{
						triggerEventNote('Screen Shake', '0.15, 0.007', '0.15, 0.007');
						FlxG.sound.play(Paths.sound('psAtt'));

						eventTweens.push(FlxTween.tween(powervitte, {alpha: 0}, 0.5, {ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.tween(camGame, {zoom: newzoom - 0.2}, 0.5, {ease: FlxEase.quadOut}));

						if (cpuControlled)
							{
								boyfriend.playAnim('dodge', true);
							}else{
								if(!isDodging){
									var newhealth:Float = health - 1;
									eventTweens.push(FlxTween.tween(this, {health: newhealth}, 0.2, {ease: FlxEase.quadOut}));
								}
							}
						marioattack.x = 200;
						marioattack.y = 90;
						marioattack.animation.play("Attack", true);
						eventTimers.push(new FlxTimer().start(0.5, function(tmr:FlxTimer)
							{
								marioattack.visible = false;
								dad.visible = true;
							}));
					}));

			case 'Char Attack':
				if(curStage == 'exeport'){
					triggerEventNote('MX salto', '', '');
				}else if(curStage == 'turmoilsweep'){
					triggerEventNote('Turmoil Attack', '', '');
				}else if (curStage == 'castlestar'){
					triggerEventNote('Power Attack', '', '');
				}


			case 'MX salto':
				if (ClientPrefs.flashing)
				{
					if(PlayState.SONG.song == 'Powerdown Old'){
						FlxFlicker.flicker(imgwarb, 0.24, 0.12, false);
						eventTimers.push(new FlxTimer().start(0.24, function(tmr:FlxTimer)
						{
							FlxFlicker.flicker(imgwar, 0.24, 0.12, false);
						}));
					}else{
					for (i in 0...4)
						{
							eventTimers.push(new FlxTimer().start((1 / (Conductor.bpm / 60)) * i, function(tmr:FlxTimer)
								{
									switch(i){
										case 0:
											imgwarb.visible = true;
											imgwarb.scale.set(10, 10);
											imgwarb.y += 50; 
											eventTweens.push(FlxTween.tween(imgwarb, {y: (FlxG.height - imgwarb.height) / 2}, (1 / (Conductor.bpm / 60)), {ease: FlxEase.expoOut}));
											eventTweens.push(FlxTween.tween(imgwarb.scale, {x: 8, y: 8}, (1 / (Conductor.bpm / 60)), {ease: FlxEase.elasticOut}));
											eventTweens.push(FlxTween.angle(imgwarb, 35, 0, (1 / (Conductor.bpm / 60)), {ease: FlxEase.elasticOut}));

										case 1:
											imgwar.visible = true;
											imgwarb.visible = false;
											imgwar.scale.set(9, 9);
											imgwar.color = 0xFFFFFFFF;
											imgwar.alpha = 1;
											eventTweens.push(FlxTween.tween(imgwar.scale, {x: 8, y: 8}, (1 / (Conductor.bpm / 60)), {ease: FlxEase.elasticOut}));
											eventTweens.push(FlxTween.angle(imgwar, -20, 0, (1 / (Conductor.bpm / 60)), {ease: FlxEase.elasticOut}));

										case 2:
											eventTweens.push(FlxTween.tween(imgwar.scale, {x: 7, y: 7}, 0.5 * (1 / (Conductor.bpm / 60)), {ease: FlxEase.bounceOut}));
											eventTweens.push(FlxTween.color(imgwar, (1 / (Conductor.bpm / 60)), FlxColor.WHITE, 0xFF737373, {ease: FlxEase.circOut}));
										case 3:
											eventTweens.push(FlxTween.tween(imgwar, {alpha: 0}, (1 / (Conductor.bpm / 60))));
									}
								}));
						}
					}
				}
				else
				{
					imgwarb.visible = true;
					eventTimers.push(new FlxTimer().start(0.24, function(tmr:FlxTimer)
					{
						imgwar.visible = true;
					}));
					eventTimers.push(new FlxTimer().start(0.72, function(tmr:FlxTimer)
					{
						imgwar.visible = false;
						imgwarb.visible = false;
					}));
				}
				FlxG.sound.play(Paths.sound('warningmx'));

				var numberjump:Float = 800;

				if (PlayState.SONG.song == 'Powerdown Old')
				{
					numberjump = 400;
				}

				eventTweens.push(FlxTween.tween(dad, {y: enemyY - numberjump}, 0.24, {
					startDelay: 0.24,
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						if (cpuControlled && PlayState.SONG.song != 'Powerdown Old') bfJump();

						eventTweens.push(FlxTween.tween(dad, {y: enemyY}, 0.24, {
							ease: FlxEase.quadIn,
							onComplete: function(twn:FlxTween)
							{
								if (ClientPrefs.flashing)
								{
									camGame.shake(0.03, 0.2);
								}
								if (PlayState.SONG.song != 'Powerdown Old'){
								gf.playAnim('hurt', true);
								gf.specialAnim = true;
								}
								if (!isDodging && !cpuControlled)
								{
									boyfriend.playAnim('hurt', true);
									if (ClientPrefs.filtro85){
									FlxG.game.blendMode = BlendMode.OVERLAY;
									estatica.alpha = 0.5;
									eventTweens.push(FlxTween.tween(estatica, {alpha: 0.05}, 0.5, {
										ease: FlxEase.quadOut,
										onComplete: function(twn:FlxTween)
										{
											FlxG.game.blendMode = BlendMode.NORMAL;
										}
									}));
									}
									var newhealth:Float = health - 1.2;
									eventTweens.push(FlxTween.tween(this, {health: newhealth}, 0.2, {ease: FlxEase.quadOut}));
								}
								if (cpuControlled && (curStage == 'turmoilsweep' || PlayState.SONG.song == 'Powerdown Old'))
								{
									boyfriend.playAnim('dodge', true);
								}
							}
						}));
					}
				}));

			case 'Triggers Powerdown':
				var triggerMX:Float = Std.parseFloat(value1);
				if (Math.isNaN(triggerMX))
					triggerMX = 0;

				switch (triggerMX)
				{
					case 0:
						if (PlayState.SONG.song == 'Powerdown Old')
						{
							eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 0.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									eventTweens.push(FlxTween.tween(mxLaugh, {alpha: 1}, 1, {startDelay: 1, ease: FlxEase.quadInOut}));
								}
							}));
						}
						else
						{
							eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 1, {
								onComplete: function(twn:FlxTween)
								{
									mxLaughNEW.y = 200;
									mxLaughNEW.scale.set(0.8, 0.8);
									eventTweens.push(FlxTween.tween(mxLaughNEW.scale, {x: 1, y: 1}, 1.3, {startDelay: 1, ease: FlxEase.cubeOut}));
									eventTweens.push(FlxTween.tween(mxLaughNEW, {y: 80}, 1.3, {startDelay: 1, ease: FlxEase.cubeOut}));
									eventTweens.push(FlxTween.tween(mxLaughNEW, {alpha: 1}, 0.3, {startDelay: 1, ease: FlxEase.quadInOut}));
									eventTimers.push(new FlxTimer().start(0.375, function(tmr:FlxTimer)
									{
										mxLaughNEW.animation.play('freddyfazbear');
									}));
								}
							}));
						}

					case 1:
						if (PlayState.SONG.song == 'Powerdown Old')
						{
							eventTweens.push(FlxTween.tween(mxLaugh, {alpha: 0}, 1, {ease: FlxEase.quadInOut}));
							eventTimers.push(new FlxTimer().start(2, function(tmr:FlxTimer)
							{
								blackBarThingie.alpha = 0;
								if (ClientPrefs.flashing)
								{
									FlxG.camera.flash(FlxColor.RED, 0.5);
								}
								else
								{
									FlxG.camera.flash(FlxColor.BLACK, 0.5);
								}
							}));
						}
						else
						{
							eventTweens.push(FlxTween.tween(mxLaughNEW, {alpha: 0}, 0.5, {startDelay: 0.2, ease: FlxEase.quadInOut}));
						}
					case 2:
						if (PlayState.SONG.song == 'Powerdown Old')
						{
							wahooText.alpha = 1;
							eventTweens.push(FlxTween.angle(wahooText, 0, 40, 2, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(wahooText.scale, {x: 2, y: 2}, 2, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(wahooText, {alpha: 0}, 2, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(wahooText, {x: 600}, 0.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									eventTweens.push(FlxTween.tween(wahooText, {x: 700}, 1.5, {ease: FlxEase.quadInOut}));
								}
							}));
						}
						else
						{
							blackBarThingie.alpha = 0;
							if (ClientPrefs.flashing)
							{
								FlxG.camera.flash(FlxColor.RED, 0.5);
							}
							else
							{
								FlxG.camera.flash(FlxColor.BLACK, 0.5);
							}

							eventTweens.push(FlxTween.angle(wahooText, 0, 40, 2, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(wahooText.scale, {x: 2, y: 2}, 2, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(wahooText, {alpha: 0}, 2, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(wahooText, {x: 600}, 0.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									eventTweens.push(FlxTween.tween(wahooText, {x: 700}, 1.5, {ease: FlxEase.quadInOut}));
								}
							}));

							dad.visible = false;
							gfGroup.visible = false;
							killMX.alpha = 1;
							killMX.animation.play('yupi');
						}

					case 3:
						eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(customHB, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(iconP1, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(iconP2, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut}));

					case 4:
						screencolor.alpha = 0.1;
						eventTweens.push(FlxTween.tween(screencolor, {alpha: 0}, (0.5 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.quadOut}));

						if (value2 == '')
						{
							turnevil.alpha = 0.9;
							eventTweens.push(FlxTween.tween(turnevil, {alpha: 0.3}, (0.5 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.quadOut}));
						}
					case 5:
						eventTweens.push(FlxTween.tween(customHB, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(iconP1, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(iconP2, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut}));
						blackBarThingie.alpha = 0;
						screencolor.alpha = 0;
						FlxG.camera.flash(FlxColor.BLACK, 0.5);
						epicbgthings.visible = true;
						triggerEventNote('Show Song', '0', '');
						triggerEventNote('Change Character', '1', 'mxV2');
						triggerEventNote('Change Character', '2', 'gfnew');
						PauseSubState.muymalo = 2;
						// iconP2.y -= 50;
						dadGroup.x -= 475;
						gfGroup.y -= 170;
						enemyY = dad.y;
						lightmx.visible = false;

					case 6:
						if(ClientPrefs.filtro85) eventTweens.push(FlxTween.tween(estatica, {alpha: 1}, 2.5));
					case 7:
						midsongVid.visible = true;
						midsongVid.playVideo(Paths.video('powerdownscene'));
						midsongVid.finishCallback = function()
						{
							midsongVid.visible = false;
							FlxG.camera.flash(FlxColor.RED, 1);
						}
				}

			case 'Triggers Demise':
				var triggerMX:Float = Std.parseFloat(value1);
				if (Math.isNaN(triggerMX))
					triggerMX = 0;
				switch (triggerMX)
				{
					case 0:
						var hatext:FlxText = new FlxText(900, -270, 600, 'HA!', 120);
						hatext.setFormat(Paths.font("mariones.ttf"), 120, FlxColor.WHITE, LEFT);
						add(hatext);
						hatext.angle = FlxG.random.float(-20, 20);
	
						eventTweens.push(FlxTween.tween(hatext, {x: 500, y: ((hatext.angle * 20) - 270), alpha: 0}, 1, {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween)
							{
								remove(hatext);
							}}));

					case 1:
						demisetran.x = -1600;
						eventTweens.push(FlxTween.tween(demisetran, {x: 2600}, 1.4));
						eventTimers.push(new FlxTimer().start(2 * (1 / (Conductor.bpm / 60)), function(tmr:FlxTimer)
							{
								triggerEventNote('Change Character', '1', 'mx_demiseUG');
								triggerEventNote('Change Character', '0', 'bf_demiseUG');
								underdembg.visible = 	   	true;
								underdemLevel.visible =    	true;
								underdemGround1.visible =  	true;
								underdemGround2.visible =  	true;
								underfloordemise.visible = 	true;
								underroofdemise.visible =  	true;
								dembg.visible = 		   	false;
								demLevel.visible = 		   	false;
								floordemise.visible = 		false;
								demGround.visible = 		false;
			
								demFore1.visible = 			false;
								demFore2.visible = 			false;
								demFore3.visible = 			false;
								demFore4.visible = 			false;
							}));

					case 2:
						demisetran.x = -1600;
						eventTweens.push(FlxTween.tween(demisetran, {x: 2600}, 1.4));

						eventTimers.push(new FlxTimer().start(2 * (1 / (Conductor.bpm / 60)), function(tmr:FlxTimer)
							{
								triggerEventNote('Change Character', '1', 'mx_demise');
								triggerEventNote('Change Character', '0', 'bf_demise');
								underdembg.visible = 	   	false;
								underdemLevel.visible =    	false;
								underdemGround1.visible =  	false;
								underdemGround2.visible =  	false;
								underfloordemise.visible = 	false;
								underroofdemise.visible =  	false;
								dembg.visible = 		   	true;
								demLevel.visible = 		   	true;
								floordemise.visible = 		true;
								demGround.visible = 		true;
			
								demFore1.visible = 			true;
								demFore2.visible = 			true;
								demFore3.visible = 			true;
								demFore4.visible = 			true;
							}));

					case 3:
						eventTweens.push(FlxTween.tween(whenyourered, {alpha: 1}, 1, {ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.tween(underdemFore1, {alpha: 0}, 1, {ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.tween(underdemFore2, {alpha: 0}, 1, {ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.color(boyfriend, 	1, FlxColor.WHITE, FlxColor.BLACK, {ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.color(dad,		1, FlxColor.WHITE, FlxColor.BLACK, {ease: FlxEase.quadOut}));
						eventTimers.push(new FlxTimer().start(1.03, function(tmr:FlxTimer)
							{
								eventTweens.push(FlxTween.tween(camGame, {zoom: 0.4}, 20.21));
							}));
					case 4:
						eventTweens.push(FlxTween.tween(whenyourered, {alpha: 0}, 2, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(underdemFore1, {alpha: 1}, 2, {ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.tween(underdemFore2, {alpha: 1}, 2, {ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.color(boyfriend, 	2, FlxColor.BLACK, FlxColor.WHITE, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.color(dad,		2, FlxColor.BLACK, FlxColor.WHITE, {ease: FlxEase.quadInOut}));
					
					case 5:
						boyfriend.alpha = 0;
						dad.alpha = 0;
	
						demcut1.visible = true;
						demcut2.visible = true;
						demcut3.visible = true;
						demcut4.visible = true;
	
						demcut1.animation.play('idle', true);
						demcut2.animation.play('idle', true);
						demcut3.animation.play('idle', true);
						demcut4.animation.play('idle', true);
	
						eventTweens.push(FlxTween.tween(floordemise, {alpha: 0}, 0.5));
						eventTweens.push(FlxTween.tween(demGround, {alpha: 0}, 0.5));
						eventTweens.push(FlxTween.tween(camGame, {zoom: 1.2}, 0.5));
						eventTweens.push(FlxTween.tween(camHUD, {alpha: 0.1}, 0.5));
						eventTweens.push(FlxTween.tween(camFollowPos, {x: 200, y: 500}, 0.4, {ease:FlxEase.expoOut}));

						eventTimers.push(new FlxTimer().start((1 / (Conductor.bpm / 60)), function(tmr:FlxTimer)
							{
								eventTweens.push(FlxTween.tween(camGame, {zoom: 0.8}, 5));
								eventTweens.push(FlxTween.tween(camFollowPos, {x: 1200, y: -100}, 6, {ease:FlxEase.quadInOut}));
							}));

					
					case 6:
						eventTweens.push(FlxTween.tween(floordemise, {alpha: 1},  1));
						eventTweens.push(FlxTween.tween(demGround, {alpha: 1}, 1));
					case 7:
						eventTweens.push(FlxTween.tween(gordobondiola, {x: 1000, y: -900}, 1.85, {ease: FlxEase.expoIn}));

						eventTweens.push(FlxTween.color(demcut1,		0.4, FlxColor.WHITE, 0xFF5E5E5E));
						eventTweens.push(FlxTween.color(demcut2,		0.4, FlxColor.WHITE, 0xFF5E5E5E));
						eventTweens.push(FlxTween.color(demcut3,		0.4, FlxColor.WHITE, 0xFF5E5E5E));
						eventTweens.push(FlxTween.color(demcut4,		0.4, FlxColor.WHITE, 0xFF5E5E5E));
						eventTweens.push(FlxTween.tween(camHUD, {alpha: 1}, 0.5));
					case 8: 
						eventTweens.push(FlxTween.color(demcut1,		0.4, 0xFF5E5E5E, FlxColor.WHITE));
						eventTweens.push(FlxTween.color(demcut2,		0.4, 0xFF5E5E5E, FlxColor.WHITE));
						eventTweens.push(FlxTween.color(demcut3,		0.4, 0xFF5E5E5E, FlxColor.WHITE));
						eventTweens.push(FlxTween.color(demcut4,		0.4, 0xFF5E5E5E, FlxColor.WHITE));
					case 9:
						FOLLOWCHARS = !FOLLOWCHARS;
					case 10:
						ZOOMCHARS = !ZOOMCHARS;
					case 11:
						demFlash = !demFlash;
				}

			case 'Triggers Oh God No':
				var triggerHate:Float = Std.parseFloat(value1);
				if (Math.isNaN(triggerHate))
					triggerHate = 0;

				switch (triggerHate)
				{
					case 0:
						ZOOMCHARS = false;
						defaultCamZoom = 0.45;
						DAD_CAM_X = 600;
						DAD_CAM_Y = 350;
						DAD_CAM_EXTEND = 0;

						transitionOGN(true, true);
						eventTweens.push(FlxTween.tween(fire1, {alpha: 0}, 1, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(fire2, {alpha: 0}, 1, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(camEst, {alpha: 0}, 1, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(blackOGNThingie, {alpha: 1}, 1, {ease: FlxEase.quadInOut}));
						extraTween.push(FlxTween.tween(this, {defaultCamZoom: 0.8}, 11));

					case 1:
						extraTween.push(FlxTween.tween(gf, {alpha: 0.3}, 11));
					
					case 2:

					for (tween in extraTween)
						{
							tween.cancel();
						}
						DAD_CAM_X = 620;
						DAD_CAM_Y = 290;
						DAD_CAM_EXTEND = BF_CAM_EXTEND;
						transitionOGN(false, true);
						degrad.alpha = 1;
						eventTweens.push(FlxTween.tween(fire1, {alpha: 1}, 1, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(fire2, {alpha: 1}, 1, {ease: FlxEase.quadInOut}));
						extraTween.push(FlxTween.tween(degrad, {alpha: 0.6}, 0.5, {ease: FlxEase.quadInOut, type: PINGPONG}));
						extraTween.push(FlxTween.tween(gf, {alpha: 0}, 1, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(camEst, {alpha: 1}, 1, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(blackOGNThingie, {alpha: 0}, 1, {ease: FlxEase.quadInOut}));
						extraTween.push(FlxTween.tween(this, {defaultCamZoom: 0.7}, 1, {onComplete: function(twn:FlxTween){ZOOMCHARS = true;}}));

						//more nate code
					case 3:
						//297
						eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 1));
					case 4:
						//305
						camGame.alpha = 0;
						luigiCut.y += 200;
						eventTweens.push(FlxTween.tween(luigiCut, {y: luigiCut.y - 200, alpha: 1}, 1.5, {ease: FlxEase.cubeOut}));
						luigiCut.animation.play("anim");
					case 5:
						//310
						eventTweens.push(FlxTween.tween(fire1, {y: 1000}, 5, {startDelay: 5, type: LOOPING, onComplete: function(twn:FlxTween)
							{
								fire1.x = FlxG.random.float(-900, 230);
							}}));
						eventTweens.push(FlxTween.tween(fire2, {y: 1000}, 5, {startDelay: 7, type: LOOPING, onComplete: function(twn:FlxTween)
							{
								fire2.x = FlxG.random.float(230, 1360);
							}}));
						eventTweens.push(FlxTween.tween(fire3, {y: 1000}, 4, {startDelay: 8, type: LOOPING, onComplete: function(twn:FlxTween)
							{
								fire3.x = FlxG.random.float(-900, 230);
							}}));
						eventTweens.push(FlxTween.tween(fire4, {y: 1000}, 4, {startDelay: 1, type: LOOPING, onComplete: function(twn:FlxTween)
							{
								fire4.x = FlxG.random.float(230, 1360);
							}}));
					case 6:
						//312
						camGame.alpha = 1;
						blackBarThingie.alpha = 0;
						luigiCut.alpha = 0;
						FlxG.camera.flash(FlxColor.WHITE, 0.5);

				}

			case 'Triggers I Hate You':
				var triggerHate:Float = Std.parseFloat(value1);
				if (Math.isNaN(triggerHate))
					triggerHate = 0;

				switch (triggerHate)
				{
					case 0:
						if(PlayState.SONG.song == 'I Hate You Old'){
							eventTweens.push(FlxTween.tween(eyelessboo, {alpha: 1, x: -100}, 0.6, {ease: FlxEase.quadOut}));
							eventTweens.push(FlxTween.tween(eyelessboo2, {alpha: 1, x: 1100}, 0.5, {ease: FlxEase.quadOut}));
							eventTweens.push(FlxTween.tween(eyelessboo3, {alpha: 1, x: 1050}, 0.8, {ease: FlxEase.quadOut}));
						}else{
							eventTweens.push(FlxTween.tween(eyelessboo, {alpha: 1, x: -300}, 2, {ease: FlxEase.expoOut}));
							eventTweens.push(FlxTween.tween(eyelessboo2, {alpha: 1, x: 1300}, 3, {ease: FlxEase.expoOut}));
							eventTweens.push(FlxTween.tween(eyelessboo3, {alpha: 1, x: 1250}, 2.5, {ease: FlxEase.expoOut}));
						}
					case 1:
						if (ClientPrefs.flashing)
						{
							bgsign.alpha = 1;
							camGame.shake(0.05, 0.2);
						}

					case 2:
						eventTimers.push(new FlxTimer().start(0.1, function(tmr:FlxTimer)
						{
							blueMario.visible = true;
						}));
						blueMario.animation.play('hey', false);

					case 3:
						eventTimers.push(new FlxTimer().start(0.1, function(tmr:FlxTimer)
						{
							blueMario2.visible = true;
						}));
						blueMario2.animation.play('hey', false);
					case 4:
						eventTweens.push(FlxTween.tween(startbf, {alpha: 0}, 1, {ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 0}, 1, {ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.quadInOut}));
					case 5:
						capenose.visible = false;
						boyfriend.animation.play('prejump');
						triggerEventNote('Play Animation', 'prejump', 'boyfriend');
					case 6:
						triggerEventNote('Play Animation', 'spin', 'boyfriend');
						eventTweens.push(FlxTween.tween(boyfriendGroup, {y: -100}, 0.2, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
							{
								eventTweens.push(FlxTween.tween(boyfriendGroup, {y: 60}, 0.2, {ease: FlxEase.quadIn}));
							}}));


						eventTweens.push(FlxTween.tween(boyfriendGroup, {x: 50}, 0.4, {onComplete: function(twn:FlxTween)
							{
								triggerEventNote('Play Animation', 'attack', 'boyfriend');
								triggerEventNote('Play Animation', 'fall', 'dad');
								triggerEventNote('Screen Shake', '0.15, 0.007', '0.15, 0.007');

								extraTween.push(FlxTween.tween(dadGroup, {x: -1600}, 1.5));
								extraTween.push(FlxTween.tween(dadGroup, {angle: -67}, 1.5, {ease: FlxEase.quadOut}));
								extraTween.push(FlxTween.tween(dadGroup, {y: -300}, 0.6, {ease: FlxEase.cubeOut, onComplete: function(twn:FlxTween)
									{
										extraTween.push(FlxTween.tween(dadGroup, {y: 1900}, 0.9, {ease: FlxEase.quadIn}));

										new FlxTimer().start(0.19, function(tmr:FlxTimer)
											{
												capenose.visible = true;
												capenose.x = boyfriendGroup.x + 260;

											});
									}}));
							}}));

							new FlxTimer().start((7 * (1 / (Conductor.bpm / 60))), function(tmr:FlxTimer)
								{
									for (tween in extraTween)
										{
											tween.cancel();
										}
									triggerEventNote('Play Animation', 'hand', 'dad');
									dadGroup.setPosition(-1200, 500);
									dadGroup.angle = 0;
									eventTweens.push(FlxTween.tween(dadGroup, {y: 800}, 2, {startDelay: 0.3, onComplete: function(twn:FlxTween)
										{
											dadGroup.visible = false;
										}}));
								});
					case 9:
						FOLLOWCHARS = false;
						isCameraOnForcedPos = true;
						eventTweens.push(FlxTween.tween(camFollowPos, {x: DAD_CAM_X, y: DAD_CAM_Y}, 2.5, {ease:FlxEase.cubeInOut}));
					case 10:
						camZooming = false;
						ZOOMCHARS = false;
						eventTweens.push(FlxTween.tween(camFollowPos, {y: DAD_CAM_Y + 250}, 10, {ease:FlxEase.cubeInOut}));
						eventTweens.push(FlxTween.tween(this, {defaultCamZoom: 1}, 10, {ease:FlxEase.cubeInOut}));
						eventTweens.push(FlxTween.tween(camGame, {zoom: 1}, 10, {ease:FlxEase.cubeInOut}));
					case 11:
						blackBarThingie.alpha = 1;

				}

			case 'Triggers Apparition':
				var triggerWa:Float = Std.parseFloat(value1);
				if (Math.isNaN(triggerWa))
					triggerWa = 0;

				switch (triggerWa)
				{
					case 0:
						eventTweens.push(FlxTween.tween(dad, {alpha: 1}, 1, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(dad.scale, {x: 1.2, y: 1.2}, 1, {ease: FlxEase.quadInOut}));
					case 1:
						eventTweens.push(FlxTween.color(boyfriend, 10, FlxColor.WHITE, 0xfff96d63, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.color(dad, 10, FlxColor.WHITE, 0xfff96d63, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.color(bftors, 10, FlxColor.WHITE, 0xfff96d63, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.color(bfext, 10, FlxColor.WHITE, 0xfff96d63, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.color(bgwario, 10, FlxColor.WHITE, 0xfff96d63, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(fogbad, {alpha: 0.6}, 10, {ease: FlxEase.quadInOut}));
					case 2:
						eventTweens.push(FlxTween.color(boyfriend, 0.5, 0xfff96d63, FlxColor.WHITE, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.color(dad, 0.5, 0xfff96d63, FlxColor.WHITE, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.color(bftors, 0.5, 0xfff96d63, FlxColor.WHITE, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.color(bfext, 0.5, 0xfff96d63, FlxColor.WHITE, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.color(bgwario, 0.5, 0xfff96d63, FlxColor.WHITE, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(fogbad, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut}));
					case 4:
						eventTweens.push(FlxTween.tween(dad, {alpha: 0}, 3, {startDelay: 1, ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.tween(dad, {y: dad.y + 140, x: dad.x + 50}, 4, {ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.tween(dad.scale, {x: 0.6, y: 0.6}, 4, {ease: FlxEase.quadOut}));
					case 5:
						camHUD.visible = false;
						camGame.visible = false;
						camEst.visible = false;
						camOther.visible = false;
				}

			case 'Triggers Race Traitors':
				var triggerMR:Float = Std.parseFloat(value1);
				if (Math.isNaN(triggerMR))
					triggerMR = 0;
				var triggerBox:Float = Std.parseFloat(value2);
				if (Math.isNaN(triggerBox))
					triggerBox = 0;
				var lowAnim:String = "";
				switch (triggerMR)
				{
					case 0:
						if (PlayState.SONG.song != 'Racetraitors Old'){
						triggerEventNote('Change Character', '1', 'racet1');
						}
						eventTweens.push(FlxTween.tween(dad, {x: 50}, 1, {
							ease: FlxEase.expoOut,
							onComplete: function(twn:FlxTween)
							{
								jodaflota = true;
							}
						}));

					case 1:
						if (dad.curCharacter != value2)
						{
							if (!dadMap.exists(value2))
							{
								addCharacterToList(value2, 1);
							}

							dad.visible = false;
							dad = dadMap.get(value2);
							if (!dad.alreadyLoaded)
							{
								dad.alpha = 1;
								dad.alreadyLoaded = true;
							}
							dad.visible = true;
							dad.x = 50;

							if (PlayState.SONG.song == 'Racetraitors Old'){
								iconP1.changeIcon('icon-bfr');
								iconP2.changeIcon('icon-race');
								reloadHealthBarColors();
							}

							if (dad.curCharacter == "race" && jodaflota)
							{
								var upDad:Float = 20000;
								// var justone:Bool = false;
								if (upDad == 20000)
								{
									upDad = dad.x;
								}
								eventTweens.push(FlxTween.tween(dad, {x: upDad + 100}, 1.5, {ease: FlxEase.quadInOut, type: PINGPONG}));
							}

						}
					case 2:
						caja.animation.play('random');
						if (!hasDownScroll)
						{
							eventTweens.push(FlxTween.tween(caja, {y: 50}, 1, {ease: FlxEase.quadInOut}));
						}
						else
						{
							eventTweens.push(FlxTween.tween(caja, {y: 570}, 1, {ease: FlxEase.quadInOut}));
						}
					case 3:
						if (!hasDownScroll)
						{
							caja.y = 40;
							eventTweens.push(FlxTween.tween(caja, {y: 50}, 0.2, {ease: FlxEase.quadOut}));
						}
						else
						{
							caja.y = 560;
							eventTweens.push(FlxTween.tween(caja, {y: 570}, 0.2, {ease: FlxEase.quadOut}));
						}
						caja.animation.play('shell');
					case 4:
						if (!hasDownScroll)
						{
							caja.y = 40;
							eventTweens.push(FlxTween.tween(caja, {y: 50}, 0.2, {ease: FlxEase.quadOut}));
						}
						else
						{
							caja.y = 560;
							eventTweens.push(FlxTween.tween(caja, {y: 570}, 0.2, {ease: FlxEase.quadOut}));
						}
						caja.animation.play('ghost');
					case 5:
						if (!hasDownScroll)
						{
							caja.y = 40;
							eventTweens.push(FlxTween.tween(caja, {y: 50}, 0.2, {ease: FlxEase.quadOut}));
						}
						else
						{
							caja.y = 560;
							eventTweens.push(FlxTween.tween(caja, {y: 570}, 0.2, {ease: FlxEase.quadOut}));
						}
						caja.animation.play('bomb');
					case 6:
						if (!hasDownScroll)
						{
							eventTweens.push(FlxTween.tween(caja, {y: -200}, 1, {ease: FlxEase.quadInOut}));
						}
						else
						{
							eventTweens.push(FlxTween.tween(caja, {y: 760}, 1, {ease: FlxEase.quadInOut}));
						}
					case 7:
						redS.animation.play('idle');
						eventTweens.push(FlxTween.tween(redS, {x: iconP1.x}, (1 * (1 / (Conductor.bpm / 60))), {
							ease: FlxEase.backIn,
							onComplete: function(twn:FlxTween)
							{
								if (ClientPrefs.flashing)
								{
									camGame.shake(0.02, 0.1);
								}
								FlxG.sound.play(Paths.sound('shellhit'));
								var newhealth:Float = health - 0.4;
								eventTweens.push(FlxTween.tween(this, {health: newhealth}, 0.2, {ease: FlxEase.quadOut}));

								redS.animation.play('hit');

								new FlxTimer().start(0.5, function(tmr:FlxTimer)
								{
									redS.x = -200;
								});
							}
						}));
					case 8:
						if (!hasDownScroll)
						{
							caja.y = 40;
							eventTweens.push(FlxTween.tween(caja, {y: 50}, 0.2, {ease: FlxEase.quadOut}));
						}
						else
						{
							caja.y = 560;
							eventTweens.push(FlxTween.tween(caja, {y: 570}, 0.2, {ease: FlxEase.quadOut}));
						}
						caja.animation.play('1up');
						getspeed = SONG.speed; // get and save the number
						eventTweens.push(FlxTween.tween(SONG, {speed: triggerBox}, 16));

					case 9:
						eventTweens.push(FlxTween.tween(xboxigualGOD, {x: 460}, 0.5, {ease: FlxEase.quadIn}));

					case 10:
						blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
						blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
						blackBarThingie.cameras = [camEst];
						blackBarThingie.scrollFactor.set(0, 0);
						add(blackBarThingie);
				}
			case 'Triggers Alone':
				var triggerMR:Float = Std.parseFloat(value1);
				if (Math.isNaN(triggerMR))
					triggerMR = 0;
				switch (triggerMR)
				{
					case 0:
						if (ClientPrefs.flashing)
						{
							FlxG.camera.flash(FlxColor.WHITE, 1);
							if (PlayState.SONG.song == 'Alone Old')
							{
								FlxG.sound.play(Paths.sound('thunder_1'));
							}
							bfcolgao.animation.play('idle');
							bfcolgao.alpha = 1;
							eventTweens.push(FlxTween.tween(bfcolgao, {alpha: 0}, 2, {ease: FlxEase.quadOut}));
						}
						if (PlayState.SONG.song != 'Alone Old')
							{
								eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 0}, 5));
								eventTweens.push(FlxTween.tween(lluvia, {alpha: 0.6}, 5));
							}
					case 1:
						if (ClientPrefs.flashing)
						{
							FlxG.camera.flash(FlxColor.WHITE, 1);
							if (PlayState.SONG.song == 'Alone Old')
							{
								FlxG.sound.play(Paths.sound('thunder_1'));
							}
						}
					case 2:
						if (ClientPrefs.flashing)
						{
							FlxG.camera.flash(FlxColor.WHITE, 1);

							if (PlayState.SONG.song == 'Alone Old')
							{
								FlxG.sound.play(Paths.sound('thunder_1'));
								lluvia.visible = true;
							}
						}
					case 3:
						if (PlayState.SONG.song != 'Alone Old')
							{
								var gota:BGSprite = new BGSprite('mario/LuigiBeta/gota', 1270, 700, ['rain'], false);
								gota.antialiasing = ClientPrefs.globalAntialiasing;
								gota.x = FlxG.random.int(0, 1270);
								gota.y = FlxG.random.int(600, 1000);
								if(gota.y > 850){
									add(gota);
								}else{
									insert(members.indexOf(dadGroup) - 1, gota);
								}
								
								gota.alpha = 0.4;
								gota.dance(true);

								eventTweens.push(FlxTween.tween(gota, {alpha: 0}, 2, {startDelay: 0.3, onComplete: function(twn:FlxTween)
								{
									gota.destroy();

								}}));
							}

					case 4:
						eventTweens.push(FlxTween.tween(iconP1,         {alpha: 1}, 2));
						eventTweens.push(FlxTween.tween(iconP2,         {alpha: 1}, 2));
						eventTweens.push(FlxTween.tween(customHB,       {alpha: 1}, 2));
						eventTweens.push(FlxTween.tween(timeBar,        {alpha: 1}, 2));
						eventTweens.push(FlxTween.tween(timeTxt,        {alpha: 1}, 2));

					case 5:
						eventTweens.push(FlxTween.tween(iconP1,         {alpha: 0}, 2));
						eventTweens.push(FlxTween.tween(iconP2,         {alpha: 0}, 2));
						eventTweens.push(FlxTween.tween(customHB,       {alpha: 0}, 2));
						eventTweens.push(FlxTween.tween(timeBar,        {alpha: 0}, 2));
						eventTweens.push(FlxTween.tween(timeTxt,        {alpha: 0}, 2));

					case 6:
						eventTweens.push(FlxTween.tween(starmanGF,      {alpha: 0.8}, 2));
						eventTweens.push(FlxTween.tween(boyfriendGroup, {alpha: 0.8}, 2, {onComplete: function(twn:FlxTween)
							{
								canFade = true;
							}}));
					case 7:
						//alone mario
						eventTimers.push(new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								add(iconGF);
								iconGF.y = iconP2.y - (!hasDownScroll ? 15 : -15);
								gfGroup.alpha = 0;
								eventTweens.push(FlxTween.tween(iconGF, {alpha: 0.7}, 2, {ease: FlxEase.quadOut}));
								eventTweens.push(FlxTween.tween(gfGroup, {alpha: 0.9}, 2, {ease: FlxEase.quadOut}));
								eventTweens.push(FlxTween.tween(gfGroup.scale, {x: 1, y: 1}, 3, {ease: FlxEase.quadOut}));
								eventTweens.push(FlxTween.tween(gfGroup.scrollFactor, {x: 0.95, y: 0.95}, 3, {ease: FlxEase.quadOut}));
								eventTweens.push(FlxTween.tween(gfGroup, {x: 630, y: -420}, 1.5, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
									{
										eventTweens.push(FlxTween.tween(gfGroup, {x: 600, y:  -360}, 1.5, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
											{
												eventTweens.push(FlxTween.tween(gfGroup, {x: gfGroup.x - 550}, 5, {ease: FlxEase.quadInOut, type: PINGPONG}));
												eventTweens.push(FlxTween.tween(gfGroup, {y: gfGroup.y + 100}, 1.75, {ease: FlxEase.quadInOut, type: PINGPONG}));
											}}));
									}}));
							}));

						triggerEventNote('Set Cam Zoom', '0.55', '');
						FOLLOWCHARS = false;
						ZOOMCHARS = false;
						DAD_CAM_X = 720;
						DAD_CAM_Y = 75;
						eventTweens.push(FlxTween.tween(camGame, {zoom: 0.65}, 2, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(camFollowPos, {x: DAD_CAM_X, y: DAD_CAM_Y - 175}, 2, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
							{
								FOLLOWCHARS = true;
								ZOOMCHARS = true;
							}}));
					case 8:
						eventTweens.push(FlxTween.tween(gfGroup, {y: -900}, 1.75, {ease: FlxEase.cubeIn}));
						eventTweens.push(FlxTween.tween(gfGroup, {alpha: 0}, 1.75, {ease: FlxEase.cubeIn}));
						eventTweens.push(FlxTween.tween(iconGF, {alpha: 0}, 1.75, {ease: FlxEase.quadInOut}));
					case 10:
						DAD_CAM_X = 420;
						DAD_CAM_Y = 450;
						triggerEventNote('Set Cam Zoom', '0.8', '');
					case 11:
						eventTweens.push(FlxTween.tween(starmanGF,      {alpha: 0}, 2.4));
						eventTweens.push(FlxTween.tween(boyfriendGroup, {alpha: 0}, 2.4, {onComplete: function(twn:FlxTween)
							{
								canFade = false;
							}}));
					case 12:
						eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 2));
					case 13:
						for(i in 0... value2.length){
							var textletter = value2.charAt(i);
							var ghostText:FlxText = new FlxText(900, 570, 720, '', 120);
							ghostText.setFormat(Paths.font("vcr.ttf"), 30, 0xFF198C0E, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
							ghostText.cameras = [camHUD];
							ghostText.borderSize = 1.25;
							ghostText.alpha = 0;
							ghostText.y += 40;
							ghostText.x += 80;
							ghostText.ID = i;
							add(ghostText);

							for(p in 0... value2.length){
								if(p != i) ghostText.text += '  ';
								else ghostText.text = textletter;
							}

							extraTween.push(FlxTween.tween(ghostText, {y: (ghostText.y - 40) - FlxG.random.int(0, 5), alpha: 1, angle: 0}, FlxG.random.float(1, 1.8), {ease: FlxEase.expoOut}));
							extraTween.push(FlxTween.tween(ghostText, {y: ghostText.y + 40, alpha: 0}, FlxG.random.float(1.4, 1.6), {startDelay: (3 * (1 / (Conductor.bpm / 60))), ease: FlxEase.cubeIn, onComplete: function(twn:FlxTween)
								{
									ghostText.destroy();
								}}));


						}

				}
			case 'Triggers Bad Day':
				var trigger:Float = Std.parseFloat(value1);
				var trigger2:Float = Std.parseFloat(value2);
				if (Math.isNaN(trigger))
					trigger = 0;
				if (Math.isNaN(trigger2))
					trigger2 = 0;
				switch (trigger)
				{
					case 0:
						DAD_CAM_X = 500;
						DAD_CAM_Y = 390;
						eventTweens.push(FlxTween.tween(badPoisonVG, {alpha: 0}, 0.2, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(badGrad1, {alpha: 0}, 0.2, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(badGrad2, {alpha: 0}, 0.2, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(camHUD, {alpha: 0}, 0.75, {ease: FlxEase.quadInOut}));
						byecirc.alpha = 1;
						byecirc.animation.play('p1');
						// byecirc.x = 0;
						// byecirc.y = 0;
					case 1:
						byecirc.animation.play('p2');
						byecirc.alpha = 1;
					case 2:
						eventTweens.push(FlxTween.tween(dadGroup, {x: 90}, 0.8, {}));
						triggerEventNote('Play Animation', 'jump1', 'dad');
						eventTweens.push(FlxTween.tween(dadGroup, {y: -350}, 0.55, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
							{
								triggerEventNote('Play Animation', 'jump2', 'dad');
								eventTweens.push(FlxTween.tween(dadGroup, {y: -180}, 0.25, {ease: FlxEase.quadIn}));
							}}));
					case 3:
						blackBarThingie.visible = false;
						triggerEventNote('Play Animation', 'singDOWN', 'dad');
						triggerEventNote('Set Cam Pos', '', '');
						camHUD.visible = true;
						FOLLOWCHARS = true;
						ZOOMCHARS = true;
						DAD_ZOOM = 1.4;
						if (ClientPrefs.flashing)
							{
								FlxG.camera.flash(FlxColor.WHITE, 0.8);
							}
							else
							{
								FlxG.camera.flash(FlxColor.BLACK, 0.8);
							}
					case 4:
						//lets a go
						DAD_CAM_X = 380;
						DAD_CAM_Y = 410;
						DAD_ZOOM = 1.7;
					case 5:
						//lets a go end
						DAD_CAM_X = 520;
						DAD_CAM_Y = 380;
						DAD_ZOOM = 1.4;
					case 6:
						switch(trigger2)
						{
							case 0:
								//fucking shell mechanic no way
								triggerEventNote('Play Animation', 'shell', 'dad');
								extraTimers.push(new FlxTimer().start(0.4, function(tmr:FlxTimer)
									{
										FlxG.sound.play(Paths.sound('bad-day/smw_shell_kick'), 0.5);
										var badShell:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mario/BadMario/shell'));
										badShell.scale.set(4, 4);
										badShell.setPosition(dad.x + 140, dad.y + 80);
										add(badShell);
										eventTweens.push(FlxTween.tween(badShell, {y: badShell.y + 40}, 0.5 / (Conductor.bpm / 60), {ease: FlxEase.quadIn}));
										eventTweens.push(FlxTween.tween(badShell, {x: badShell.x + 360}, 0.5 / (Conductor.bpm / 60), {onComplete: function(twn:FlxTween)
											{
												triggerEventNote('Play Animation', 'hit', 'bf');
												eventTweens.push(FlxTween.tween(this, {health: health - (!cpuControlled ? 0.25 : 0.1)}, 0.2, {ease: FlxEase.quadOut}));
												FlxG.sound.play(Paths.sound('bad-day/smw_stomp'), 0.5);
												eventTweens.push(FlxTween.tween(badShell, {angle: 360}, 0.2, {type: LOOPING}));
												eventTweens.push(FlxTween.tween(badShell, {x: badShell.x - 90}, 0.8));
												eventTweens.push(FlxTween.tween(badShell, {y: 900}, 0.8, {ease: FlxEase.backIn, onComplete: function(twn:FlxTween)
													{
														badShell.kill();
													}}));
											}}));
									}));
							case 1:
								//fucking poison mushroom mechanic no way
								triggerEventNote('Play Animation', 'shroom', 'dad');
								extraTimers.push(new FlxTimer().start(0.4, function(tmr:FlxTimer)
									{
										FlxG.sound.play(Paths.sound('bad-day/smw_shell_kick'), 0.5);
										var badShroom:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mario/BadMario/shroom'));
										badShroom.scale.set(4, 4);
										badShroom.setPosition(dad.x + 140, dad.y + 80);
										add(badShroom);
										eventTweens.push(FlxTween.tween(badShroom, {y: 900}, 1 / (Conductor.bpm / 60), {ease: FlxEase.quadIn}));
										eventTweens.push(FlxTween.tween(badShroom, {x: badShroom.x + 200}, 1 / (Conductor.bpm / 60), {onComplete: function(twn:FlxTween)
										{
											badShroom.kill();
										}}));
									}));
						}
						
					case 7:
						//mario leaves
						//head start
						dad.flipX = true;
						triggerEventNote('Play Animation', 'walk', 'dad');//no walk anim yet
						eventTweens.push(FlxTween.tween(dadGroup, {x: -230}, 1.5 / (Conductor.bpm / 60), {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
							{
								eventTimers.push(new FlxTimer().start(1.5 / (Conductor.bpm / 60), function(tmr:FlxTimer)
									{
										triggerEventNote('Play Animation', 'run', 'dad');//no run anim yet
										dad.flipX = false;
										eventTweens.push(FlxTween.tween(dadGroup, {x: 90}, 0.6 / (Conductor.bpm / 60)));
									}));
							}}));
						//jump
						eventTimers.push(new FlxTimer().start(3.6 / (Conductor.bpm / 60), function(tmr:FlxTimer)
							{
								eventTweens.push(FlxTween.tween(dadGroup, {x: 1200}, 2 / (Conductor.bpm / 60)));
								if (FlxG.random.bool(0.5)){
									triggerEventNote('Play Animation', 'vile creature', 'dad');
								}
								else{
									triggerEventNote('Play Animation', 'jump3', 'dad'); // make mario play the running jump here
								}
								FlxG.sound.play(Paths.sound('bad-day/smw_jump'), 0.7);
								eventTweens.push(FlxTween.tween(dadGroup, {y: -400}, 0.8 / (Conductor.bpm / 60), {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
									{
										//bounce on gf
										eventTweens.push(FlxTween.tween(dadGroup, {y: -280}, 0.6 / (Conductor.bpm / 60), {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
											{
												FlxG.sound.play(Paths.sound('bad-day/smw_stomp2'), 0.5);
												gf.playAnim('hit', true);
												gf.specialAnim = true;
												eventTweens.push(FlxTween.tween(dadGroup, {y: -360}, 0.3 / (Conductor.bpm / 60), {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
													{
														eventTweens.push(FlxTween.tween(dadGroup, {y: -120}, 0.3 / (Conductor.bpm / 60), {ease: FlxEase.quadIn}));
													}}));
											}}));
									}}));
							}));
						
					case 8:
						//mario comes back
						badHUDMario.visible = false;
						BF_CAM_X = 650;
						BF_CAM_Y = 380;
						BF_ZOOM = 1.1;
						dadGroup.setPosition(-70, -540);
						eventTweens.push(FlxTween.tween(dadGroup, {x: 90}, 1 / (Conductor.bpm / 60)));
						eventTweens.push(FlxTween.tween(dadGroup, {y: -180}, 1 / (Conductor.bpm / 60), {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
							{
								triggerEventNote('Play Animation', 'singDOWN', 'dad');
							}}));
					case 9:
						//camera more focused on bf
						BF_CAM_X = 730;
						BF_CAM_Y = 420;
						BF_ZOOM = 1.3;
					case 10:
						//mario fucks shit up
						//jump up to notes and begin moving across
						gf.specialAnim = false;
						add(badHUDMario);
						if (!ClientPrefs.downScroll){
							badHUDMario.setPosition(1280, 100);
							badHUDMario.animation.play('spin', true);
							FlxG.sound.play(Paths.sound('bad-day/smw_spinjump'), 0.6);
							eventTweens.push(FlxTween.tween(badHUDMario, {x: playerStrums.members[3].x + 35}, 1.5 / (Conductor.bpm / 60)));
							eventTweens.push(FlxTween.tween(badHUDMario, {y: -110}, 0.9 / (Conductor.bpm / 60), {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
								{
									eventTweens.push(FlxTween.tween(badHUDMario, {y: -10}, 0.6 / (Conductor.bpm / 60), {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
										{
											eventTweens.push(FlxTween.tween(badHUDMario, {x: playerStrums.members[0].x - 110 - 400}, 7.5 / (Conductor.bpm / 60)));
										}}));
								}}));
						}
						else{
							badHUDMario.setPosition(playerStrums.members[3].x + 105, 800);
							// eventTimers.push(new FlxTimer().start(1.1 / (Conductor.bpm / 60), function(tmr:FlxTimer)
							// 	{
							// 		badHUDMario.x -= 80;
							// 		badHUDMario.animation.play('jump', true);
							// 		// FlxG.sound.play(Paths.sound('bad-day/smw_jump'), 0.5);
							// 		eventTweens.push(FlxTween.tween(badHUDMario, {x: badHUDMario.x - 40}, 0.8 / (Conductor.bpm / 60), {ease: FlxEase.quadIn}));
							// 		eventTweens.push(FlxTween.tween(badHUDMario, {y: 660}, 0.4 / (Conductor.bpm / 60), { ease: FlxEase.quadOut}));
							// 	}));
						}
								
					case 11:
						//mario fucks shit up 2
						//hop up and down
						if (!ClientPrefs.downScroll){
							triggerEventNote('Triggers Universal', '13', '');
							eventTweens.push(FlxTween.tween(badHUDMario, {y: -80}, 0.5 / (Conductor.bpm / 60), {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
								{
									eventTweens.push(FlxTween.tween(badHUDMario, {y: -10}, 0.5 / (Conductor.bpm / 60), {ease: FlxEase.quadIn}));
								}}));
						}
						else{
							badHUDMario.x -= 80;
							badHUDMario.animation.play('jump', true);
							FlxG.sound.play(Paths.sound('bad-day/smw_jump'), 0.7);
							eventTweens.push(FlxTween.tween(badHUDMario, {x: badHUDMario.x - 45}, 0.8 / (Conductor.bpm / 60), {startDelay: 0.1, ease: FlxEase.quadIn}));
							eventTweens.push(FlxTween.tween(badHUDMario, {y: 660}, 0.4 / (Conductor.bpm / 60), {startDelay: 0.1, ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
								{
									badHUDMario.animation.play('fall', true);
									FlxG.sound.play(Paths.sound('bad-day/smw_stomp2'), 0.5);
									eventTweens.push(FlxTween.tween(badHUDMario, {y: 800}, 0.4 / (Conductor.bpm / 60), {ease: FlxEase.linear}));
								}}));
							}
					case 12:
						//mario fucks shit up 3
						//last hop to fall on health bar
						if (!ClientPrefs.downScroll){
							triggerEventNote('Triggers Universal', '13', '');
							eventTweens.push(FlxTween.tween(badHUDMario, {y: -80}, 0.5 / (Conductor.bpm / 60), {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
								{
									eventTweens.push(FlxTween.tween(badHUDMario, {y: 575}, 2 / (Conductor.bpm / 60), {ease: FlxEase.quadIn}));
								}}));
						}
						else{
							// FlxG.sound.play(Paths.sound('bad-day/smw_stomp2'), 0.7);
							// eventTweens.push(FlxTween.tween(badHUDMario, {y: 800}, 0.4 / (Conductor.bpm / 60)));
							triggerEventNote('Triggers Universal', '11', '');
							eventTimers.push(new FlxTimer().start(1.5 / (Conductor.bpm / 60), function(tmr:FlxTimer)
								{
									FlxG.sound.play(Paths.sound('bad-day/smw_shell_kick'), 0.5);
									var badShell:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mario/BadMario/shell'));
									badShell.scale.set(5, 5);
									badShell.screenCenter(X);
									badShell.y = 710;
									badShell.angle -= 30;
									badShell.cameras = [camHUD];
									insert(members.indexOf(badHUDMario) + 1, badShell);
									triggerEventNote('Triggers Universal', '13', '');
									eventTweens.push(FlxTween.tween(badShell, {angle: 30}, 1 / (Conductor.bpm / 60)));
									eventTweens.push(FlxTween.tween(badShell, {y: 60}, 1 / (Conductor.bpm / 60), {onComplete: function(twn:FlxTween)
										{
											eventTweens.push(FlxTween.tween(badShell, {angle: 360}, 0.2, {type: LOOPING}));
											eventTweens.push(FlxTween.tween(badShell, {x: badShell.x + 90}, 1.5));
											eventTweens.push(FlxTween.tween(badShell, {y: 900}, 1.5, {ease: FlxEase.backIn, onComplete: function(twn:FlxTween)
												{
													badShell.kill();
												}}));
										}}));
								}));
						}
						
					case 13:
						//mario's little flash thingy
						var badFlash:FlxSprite = new FlxSprite(badHUDMario.x + 70, badHUDMario.y + 150);
						badFlash.frames = Paths.getSparrowAtlas('mario/BadMario/HUD_Mario');
						badFlash.animation.addByPrefix('idle', 'flash', 10, false);
						badFlash.antialiasing = false;
						badFlash.cameras = [camHUD];
						badFlash.scale.set(5, 5);
						if (!ClientPrefs.downScroll){
							FlxG.sound.play(Paths.sound('bad-day/smw_stomp2'), 0.5);
						}
						else{
							badFlash.screenCenter(X);
							badFlash.y = 730;
							badFlash.x += 80;
						}
						insert(members.indexOf(badHUDMario) + 1, badFlash);
						badFlash.animation.play('idle', true);
					case 14:
						//break health bar
						healthBar.cameras = [camEst];
						customHB.cameras = [camEst];
						customHBweegee.cameras = [camEst];
						iconP1.cameras = [camEst];
						iconP2.cameras = [camEst];
						
						if (!ClientPrefs.downScroll){
							for (tween in eventTweens)
								{
									tween.cancel();
								}
							// camEst.origin.set(0, 200);
							eventTweens.push(FlxTween.tween(camEst, {y: 500}, 0.8, {ease: FlxEase.backIn}));
							eventTweens.push(FlxTween.tween(camEst, {angle: 20}, 0.8, {ease: FlxEase.cubeIn}));
							triggerEventNote('Screen Shake', '0.15, 0.03', '0.1, 0.05');
							FlxG.sound.play(Paths.sound('bad-day/smw_thud'), 1);
							//mario bounce off health bar
							eventTweens.push(FlxTween.tween(badHUDMario, {x: badHUDMario.x - 70}, 1.2 / (Conductor.bpm / 60)));
							eventTweens.push(FlxTween.tween(badHUDMario, {y: badHUDMario.y - 100}, 0.5 / (Conductor.bpm / 60), {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
								{
									eventTweens.push(FlxTween.tween(badHUDMario, {y: 800}, 0.7 / (Conductor.bpm / 60), {ease: FlxEase.quadIn}));
								}}));
						}
						else{
							FlxG.sound.play(Paths.sound('bad-day/smw_break_block'), 0.5);
							camEst.shake(0.07, 0.2);
							// camEst.origin.set(0, -200);
							eventTimers.push(new FlxTimer().start(0.5 / (Conductor.bpm / 60), function(tmr:FlxTimer)
								{
									eventTweens.push(FlxTween.tween(camEst, {y: 800}, 1, {ease: FlxEase.quadIn}));
									eventTweens.push(FlxTween.tween(camEst, {x: -80}, 1, {ease: FlxEase.quadIn}));
									eventTweens.push(FlxTween.tween(camEst, {angle: 15}, 1, {ease: FlxEase.quadIn}));
								}));
						}
					case 15:
						//yahoo
						camEst.setPosition(0, 0);
						camEst.angle = 0;
						healthBar.cameras = [camHUD];
						customHB.cameras = [camHUD];
						customHBweegee.cameras = [camHUD];
						iconP1.cameras = [camHUD];
						iconP2.cameras = [camHUD];
						badGrad1.visible = true;
						badGrad2.visible = true;
						if (ClientPrefs.flashing)
							{
								FlxG.camera.flash(FlxColor.WHITE, 1.5);
							}
							else
							{
								FlxG.camera.flash(FlxColor.BLACK, 1.5);
							}
				}

			case 'Triggers Grand Dad' | 'Triggers Nourishing Blood':
				var triggerMR:Float = Std.parseFloat(value1);
				if (Math.isNaN(triggerMR))
					triggerMR = 0;
				switch (triggerMR)
				{
					case 0:
						FlxG.camera.flash(FlxColor.WHITE, 0.5);
						flintbg.visible = true;
						flintwater.visible = true;
						triggerEventNote('Change Character', '0', 'bfcave');
						triggerEventNote('Change Character', '2', 'gfcave');
						triggerEventNote('Change Character', '1', 'grandcave');
						gdRunners.visible = false;
						thegang.visible = false;
						boyfriendGroup.x = 1263;
						boyfriendGroup.y = 509.5;
						gfGroup.x = 597;
						gfGroup.y = 421;
						dadGroup.x = 0;
						dadGroup.y = 560;

						DAD_CAM_X = 460;
						DAD_CAM_Y = 750;
						BF_CAM_X = 810;
						BF_CAM_Y = 750;
					case 1:
						triggerEventNote('Change Character', '0', 'bfGD');
						triggerEventNote('Change Character', '2', 'gfGD');
						triggerEventNote('Change Character', '1', 'grand');
						boyfriendGroup.x = 1270;
						boyfriendGroup.y = 310;
						gfGroup.x = 500;
						gfGroup.y = 250;
						dadGroup.x = -200;
						dadGroup.y = 330;
						flintbg.visible = false;
						flintwater.visible = false;
						thegang.visible = true;
						DAD_CAM_X = 120;
						DAD_CAM_Y = 650;
						BF_CAM_X = 1120;
						BF_CAM_Y = 750;
					case 2:
						thegang.visible = true;
						thegang.scale.x = 0.1;
						thegang.scale.y = 0.5;
						eventTweens.push(FlxTween.tween(camGame, {zoom: 0.7}, 0.25, {ease: FlxEase.backOut}));
						eventTweens.push(FlxTween.tween(thegang.scale, {x: 1, y: 1}, 0.25, {ease: FlxEase.backOut}));
						gdRunners.visible = true;
					case 3:
						eventTweens.push(FlxTween.tween(hamster, {y: -1700}, 0.15, {ease: FlxEase.sineOut}));
						eventTweens.push(FlxTween.tween(hamster, {y: -330}, 0.25, {startDelay: 0.15, ease: FlxEase.sineIn}));
						eventTweens.push(FlxTween.tween(hamster, {x: -400}, 0.33, {
							onComplete: function(twn:FlxTween)
							{
								hamster.visible = false;
							}
						}));
					case 4:
						FOLLOWCHARS = !FOLLOWCHARS;
				}

			case 'Timebar Gimmick':
				var time:Float = Std.parseFloat(value1);
				if (Math.isNaN(time))
					time = 3;

				if (PlayState.SONG.song == 'Demise')
				{
					extraTween.push(FlxTween.tween(timeBarBG, {x: timeBarBG.x + 12}, 0.04, {type: PINGPONG}));
					extraTween.push(FlxTween.tween(timeBarBG, {y: timeBarBG.y + 6}, 0.02, {type: PINGPONG}));

					extraTween.push(FlxTween.tween(timeBar, {x: timeBar.x + 12}, 0.04, {type: PINGPONG}));
					extraTween.push(FlxTween.tween(timeBar, {y: timeBar.y + 6}, 0.02, {type: PINGPONG}));

					extraTween.push(FlxTween.tween(timeTxt, {x: timeTxt.x + 12}, 0.04, {type: PINGPONG}));
					extraTween.push(FlxTween.tween(timeTxt, {y: timeTxt.y + 6}, 0.02, {type: PINGPONG}));

					eventTweens.push(FlxTween.tween(this, {minustime: 0}, time));

					eventTimers.push(new FlxTimer().start(time, function(tmr:FlxTimer)
						{
							for (tween in extraTween)
								{
									tween.cancel();
								}
						}));
				}
				else
				{
					eventTweens.push(FlxTween.tween(this, {minustime: 0}, time, {ease: FlxEase.quadInOut}));
				}

			// TODO: finish unbeatable end event
			case 'Triggers Unbeatable':
				var triggerMR:Float = Std.parseFloat(value1);
				var triggerMR2:Float = Std.parseFloat(value2);
				if (Math.isNaN(triggerMR2))
					triggerMR2 = 0;
				// trace('i love porn ${triggerMR} and so does ${triggerMR2}');
				if (!Math.isNaN(triggerMR)){
					switch (triggerMR)
					{
						case -1:
							//he he case -1
							FlxTween.tween(blackinfrontobowser, {alpha: 0.3}, 10, {ease: FlxEase.quadInOut});
						case 0:
							eventTweens.push(FlxTween.tween(camHUD, {alpha: 1}, 5, {ease: FlxEase.quadInOut}));
						case 0.5:
							dad.alpha = 1;
							titleText.text = 'Unbeatable(Level 1)';
							autorText.text = 'RedTV53 ft. Ironik';
							blackinfrontobowser.alpha = 0;
							resyncVocals();
						case 1:
							eventTweens.push(FlxTween.tween(dad, {alpha: 0}, 2, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(iconP2, {alpha: 0}, 2, {ease: FlxEase.quadInOut}));
						case 2:
							titleText.text = 'Unbeatable(Level 2)';
							autorText.text = 'scrumbo_';
							var weanose:Float;
							weanose = dad.y;
							dad.alpha = 1;
							triggerEventNote('Change Character', '1', 'hunter');
							iconP2.alpha = 0;
							dad.y += 800;
							dad.x -= 75;

							resyncVocals();

							duckleafs.visible = true;
							ducktree.visible = true;
							if (health > 1)
							{
								eventTweens.push(FlxTween.tween(this, {health: 1}, 1, {ease: FlxEase.quadOut}));
							}
							eventTweens.push(FlxTween.tween(iconP2, {alpha: 1}, 1, {ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(duckbg, {alpha: 1}, 1, {ease: FlxEase.quadOut}));
							eventTweens.push(FlxTween.tween(duckfloor, {alpha: 1}, 2, {ease: FlxEase.quadOut}));

							eventTweens.push(FlxTween.tween(duckleafs, {x: 800}, 1, {startDelay: 1, ease: FlxEase.quadOut}));
							eventTweens.push(FlxTween.tween(ducktree, {x: 0}, 1, {startDelay: 1, ease: FlxEase.quadOut}));

							eventTweens.push(FlxTween.tween(dad, {y: (weanose)}, 1, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									eventTweens.push(FlxTween.tween(dad, {y: (weanose + 100)}, 1, {ease: FlxEase.quadInOut}));
								}
							}));
						case 3:
							var whiteSquare:FlxSprite = new FlxSprite().makeGraphic(Std.int(iconP1.width / 2), Std.int(iconP1.height / 2), FlxColor.WHITE);
							whiteSquare.cameras = [camHUD];
							whiteSquare.setPosition(iconP1.x + 60, iconP1.y + 30);
							whiteSquare.visible = ClientPrefs.flashing;
							add(whiteSquare);

							eventTimers.push(new FlxTimer().start(0.05, function(tmr:FlxTimer)
								{
									whiteSquare.destroy();
									iconP1.color = 0x000000;
									whiteSquare.visible = true;
									eventTimers.push(new FlxTimer().start(0.05, function(tmr:FlxTimer)
										{
											iconP1.color = 0xFFFFFF;
										}));
								}));
							var newhealth:Float = health - 0.1;
							eventTweens.push(FlxTween.tween(this, {health: newhealth}, 0.1, {ease: FlxEase.quadOut}));
							if (ClientPrefs.flashing)
							{
								duckbg.color = 0xFFDAAFA9;
							}
							else
							{
								duckbg.color = 0xFF7B99AF;
							}
							eventTimers.push(new FlxTimer().start(0.2, function(tmr:FlxTimer)
							{
								duckbg.color = 0xFF5595DA;
							}));
							triggerEventNote('Add Camera Zoom', '0.010', '');
							triggerEventNote('Screen Shake', '0.05, 0.007', '0.05, 0.003');

						case 4:
							var elpato:Int = FlxG.random.int(0, 2);
							var track:Int = FlxG.random.int(0, 4);
							var timeDuck:Float = 1;

							var duck:BGSprite = new BGSprite('mario/beatus/duck' + elpato, 250, 650, 0.7, 0.7, ['duck up'], true);
							duck.animation.addByPrefix('upB', "duck up", 12, true);
							duck.animation.addByPrefix('idleB', "duck fly", 12, true);
							duck.scale.set(6.5, 6.5);
							duck.updateHitbox();
							duck.antialiasing = false;
							duck.animation.play('upB');
							insert(members.indexOf(duckfloor) - 1, duck);

							switch (track)
							{
								case 0:
									timeDuck = 3;
									duck.y = -200;
									duck.x = 1500;
									duck.animation.play('idleB');
									duck.flipX = true;
									eventTweens.push(FlxTween.tween(duck, {x: -400, y: 300}, timeDuck));
								case 1:
									timeDuck = 3.5;
									duck.y = 800;
									duck.x = 100;
									eventTweens.push(FlxTween.tween(duck, {x: 600, y: -500}, timeDuck));

								case 2:
									timeDuck = 3;
									duck.animation.play('idleB');
									duck.y = 0;
									duck.x = -800;
									eventTweens.push(FlxTween.tween(duck, {x: 1600, y: 300}, timeDuck));
								
								case 3:
									timeDuck = 3;
									duck.y = 200;
									duck.x = 1500;
									duck.flipX = true;
									eventTweens.push(FlxTween.tween(duck, {x: 200, y: -300}, timeDuck));
								case 4:
									timeDuck = 3;
									duck.y = 200;
									duck.x = -800;
									eventTweens.push(FlxTween.tween(duck, {x: 1600, y: -500}, timeDuck));

							}
							extraTimers.push(new FlxTimer().start(timeDuck, function(tmr:FlxTimer)
								{
									duck.destroy();
								}));
								
						case 5: // COLOR TV X BOWSER BG
							estatica.alpha = 0.6;
							eventTweens.push(FlxTween.tween(estatica, {alpha: 0.05}, 0.5, {ease: FlxEase.quadInOut}));
							triggerEventNote('Change Character', '1', 'koopa');

							duckleafs.visible = ducktree.visible = duckfloor.visible = duckbg.visible = false;

							bowbg.visible = bowbg2.visible = bowplat.visible = bowlava.visible = false;

							cutbg.visible = cutstatic.visible = true;
							cutskyline.visible = false;
							cutbg.animation.play('bowser');
							resyncVocals();

							var newhealth:Float = health - 0.1;
							eventTweens.push(FlxTween.tween(this, {health: newhealth}, 0.1, {ease: FlxEase.quadOut}));

						case 5.5:
							triggerEventNote('Change Character', '1', 'mrSYS');
							dad.alpha = 1;
							if(value2 != 'cheese'){
								estatica.alpha = 0.6;
								eventTweens.push(FlxTween.tween(estatica, {alpha: 0.05}, 0.5, {ease: FlxEase.quadInOut}));
							}

							duckleafs.visible = ducktree.visible = duckfloor.visible = duckbg.visible = false;

							bowbg.visible = bowbg2.visible = bowplat.visible = bowlava.visible = false;

							cutbg.visible = cutstatic.visible = cutskyline.visible = false;
							// cutbg.animation.play('bowser');
							
						case 6: // COLOR TV X DUCK HUNT BG
							switch(triggerMR2){
								case 0:
									triggerEventNote('Change Character', '1', 'hunter');
								case 1:
									triggerEventNote('Change Character', '2', 'hunter');
									triggerEventNote('Triggers Unbeatable', '30', '');
									healthBar.createFilledBar(FlxColor.fromRGB(gf.healthColorArray[0], gf.healthColorArray[1], gf.healthColorArray[2]),
										FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
									GF_CAM_X = DAD_CAM_X;
									GF_CAM_Y = DAD_CAM_Y;
									gf.x = dad.x - 25;
									gf.y = dad.y + 50;
									gf.visible = true;
									gf.alpha = 1;
									dad.alpha = 0.00001;
								case 2:
									triggerEventNote('Change Character', '1', 'mrSYS');
									triggerEventNote('Triggers Unbeatable', '30', '');
									dad.alpha = 1;
									dad.y += 1000;
									remove(gfGroup);
									insert(members.indexOf(dadGroup) - 1, gfGroup);
									eventTweens.push(FlxTween.tween(dad, {y: dad.y - 1000}, 1.25, {ease: FlxEase.backOut}));
									eventTweens.push(FlxTween.tween(gf, {x: gf.x - 425, y: gf.y + 50}, 0.75, {ease: FlxEase.cubeOut}));
							}

							resyncVocals();

							var newhealth:Float = health - 0.5;
							eventTweens.push(FlxTween.tween(this, {health: newhealth}, 0.1, {ease: FlxEase.quadOut}));

							if(triggerMR2 != 2){
								if(ClientPrefs.flashing && ClientPrefs.filtro85)
									angel.strength = 0.325;

								estatica.alpha = 0.6;
								eventTweens.push(FlxTween.tween(estatica, {alpha: 0.05}, 0.5, {ease: FlxEase.quadInOut}));
							}

							cutbg.visible = cutstatic.visible = true;
							cutskyline.visible = false;
							cutbg.animation.play('duck');

						case 7: // BOWSER BG X DUCK HUNT BG
							switch(triggerMR2){
								case 0:
									triggerEventNote('Change Character', '1', 'koopa');
									triggerEventNote('Triggers Unbeatable', '30', '');
									estatica.alpha = 0.6;
									eventTweens.push(FlxTween.tween(estatica, {alpha: 0.05}, 0.5, {ease: FlxEase.quadInOut}));
								case 1:
									// add(funnylayer0);
									triggerEventNote('Change Character', '1', 'mrSYSwb');
									healthBar.createFilledBar(FlxColor.fromRGB(10, 255, 137),
										FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

									remove(funnylayer0);
									insert(members.indexOf(dadGroup) - 1, funnylayer0);
									funnylayer0.x = 600;
									funnylayer0.y = 100;
									funnylayer0.x += 700;
									funnylayer0.y += 700;
									funnylayer0.visible = true;
									eventTweens.push(FlxTween.tween(funnylayer0, {x: funnylayer0.x - 700, y: funnylayer0.y - 700}, 1.25, {ease: FlxEase.backOut}));
							}

							resyncVocals();

							var newhealth:Float = health - 0.5;
							eventTweens.push(FlxTween.tween(this, {health: newhealth}, 0.1, {ease: FlxEase.quadOut}));
							
							if(ClientPrefs.flashing && ClientPrefs.filtro85)
								angel.strength = 0.325;

							cutbg.visible = cutskyline.visible = cutstatic.visible = true;
							cutbg.animation.play('bowser');
							cutskyline.animation.play('duck');
						case 8: //end static
							var time:Float = Std.parseFloat(value1);
							if (Math.isNaN(time))
								time = 1.4;
							healthFake = health;
							healthBar.parentVariable = 'healthFake';
							endingnes = true;
							eventTweens.push(FlxTween.tween(this, {healthFake: 0}, time, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
								{
									estatica.visible = false;
								}}));
						case 9:
							eventTweens.push(FlxTween.tween(timeBar,        {alpha: 0}, 1));
							eventTweens.push(FlxTween.tween(timeTxt,        {alpha: 0}, 1));
							eventTweens.push(FlxTween.tween(customHB,       {alpha: 0}, 1));
							eventTweens.push(FlxTween.tween(iconP1,       {alpha: 0}, 1));
							eventTweens.push(FlxTween.tween(iconP2, {alpha: 0}, 1));
							nomiss = true;
						case 10:
							scoreTxt.alpha = timeBar.alpha = timeTxt.alpha = healthBar.alpha = healthBarBG.alpha = 
							customHB.alpha = customHBweegee.alpha = iconP1.alpha = iconP2.alpha = 1;
							
							nomiss = false;
						case 11: //BOWSER START
							switch(triggerMR2){
								case 0:
									eventTweens.push(FlxTween.tween(duckleafs, {y: duckleafs.y + 1200}, 1.5, {ease: FlxEase.quadIn}));
									eventTweens.push(FlxTween.tween(ducktree, {y: ducktree.y + 1200}, 1.5, {ease: FlxEase.quadIn}));
									eventTweens.push(FlxTween.tween(duckfloor, {y: duckfloor.y + 1200}, 1.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween){
										duckleafs.visible = ducktree.visible = duckfloor.visible = false;
									}}));
									eventTweens.push(FlxTween.color(duckbg, 2, duckbg.color, FlxColor.BLACK, {ease: FlxEase.cubeInOut}));
								case 1:
									bowbg.visible = bowbg2.visible = bowlava.visible = bowplat.visible = true;
									bowbg2.y -= 200;
									bowbg.y += 1000;
									bowplat.x += 800;
									eventTweens.push(FlxTween.tween(bowbg2, {y: bowbg2.y + 200}, 0.5, {ease: FlxEase.quadOut}));
									if (health > 1)
										{
											eventTweens.push(FlxTween.tween(this, {health: 1}, 1, {ease: FlxEase.quadOut}));
										}
								case 2:
									eventTweens.push(FlxTween.tween(bowbg, {y: bowbg.y - 1000}, 0.5, {ease: FlxEase.quadOut}));
								case 3:
									eventTweens.push(FlxTween.tween(bowplat, {x: 800}, 0.5, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween){
										eventTweens.push(FlxTween.tween(bowplat, {x: 600}, 1.5, {type: PINGPONG, loopDelay: 0.5}));
									}}));
								case 4:
									titleText.text = 'Unbeatable(Level 3)';
									autorText.text = 'theWAHbox ft. RedTV53';
									triggerEventNote('Change Character', '1', 'koopa');
									var weanose:Float;
									weanose = dad.y;
									dad.alpha = 1;
									dad.y += 800;

									resyncVocals();
									
									eventTweens.push(FlxTween.tween(bowlava, {y: 550}, 1.5, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){
										eventTweens.push(FlxTween.tween(bowlava, {y: 775}, 1.25, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){
											eventTweens.push(FlxTween.tween(bowlava, {y: 750}, 0.5, {ease: FlxEase.quadInOut}));
										}}));
									}}));
									eventTweens.push(FlxTween.tween(dad, {y: (weanose - 100)}, 1, {
										ease: FlxEase.quadInOut,
										onComplete: function(twn:FlxTween)
										{
											eventTweens.push(FlxTween.tween(dad, {y: (weanose)}, 1, {ease: FlxEase.quadInOut}));
											
										}
									}));
									eventTweens.push(FlxTween.tween(iconP2, {alpha: 1}, 1.5, {ease: FlxEase.expoOut}));
							}
                        case 12: //lava rise
                        case 13: //idk
                            screencolor.alpha = 0.7;
                            eventTweens.push(FlxTween.tween(screencolor, {alpha: 0}, (1 / (Conductor.bpm / 60))));
						case 14: //black fade in cuz why not
							FlxTween.tween(blackinfrontobowser, {alpha: 0.7}, 5, {ease: FlxEase.quadInOut});
						case 15:
							FlxTween.tween(blackinfrontobowser, {alpha: 0}, 0.7, {ease: FlxEase.quadInOut});

						case 16: //white fade
							ycbuWhite.color = FlxColor.BLACK;
							remove(beatText);
							insert(members.indexOf(ycbuWhite) + 1, beatText);
							FlxTween.tween(camHUD, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut});
							FlxTween.tween(ycbuWhite, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){
								triggerEventNote('Triggers Unbeatable', '5.5', 'cheese');
							}});
						case 17:
							switch(triggerMR2){
								case 0:
									ycbuWhite.color = FlxColor.WHITE;
									ycbuLakitu.visible = ycbuGyromite.visible = gf.visible = funnylayer0.visible = false;
									camGame.zoom = 0.9;
									FOLLOWCHARS = true;
									ZOOMCHARS = true;
								case 1:
									triggerEventNote('Change Character', '1', 'mrSYSwb');
									remove(dadGroup);
									insert(members.indexOf(otherBeatText) + 1, dadGroup);
									dadGroup.alpha = 0;
									FlxTween.tween(dadGroup, {alpha: 1}, 0.75, {ease: FlxEase.cubeOut});
								case 2:
									triggerEventNote('Change Character', '1', 'mrSYS');
									triggerEventNote('Triggers Unbeatable', '15', '');
									FlxTween.tween(ycbuWhite, {alpha: 0}, 0.25, {ease: FlxEase.quadOut});
									FlxTween.tween(camHUD, {alpha: 1}, 0.25, {ease: FlxEase.quadOut});

									insert(members.indexOf(iconP2) + 1, iconLG);
									insert(members.indexOf(iconP2) + 1, iconW4);
									insert(members.indexOf(iconP2) + 1, iconY0);
									iconP2.visible = false;
									iconLG.visible = iconW4.visible = iconY0.visible = true;
									iconW4.alpha = iconY0.alpha = 0;
									
									remove(beatText);
									insert(members.indexOf(starmanGF) - 1, beatText);

									titleText.text = 'Unbeatable(Level 4)';
									autorText.text = 'RedTV53 ft. FriedFrick';

									resyncVocals();

									if(ClientPrefs.flashing && ClientPrefs.filtro85)
										angel.strength = 0.325;
									if (health > 1)
										{
											health = 1;
										}
							}
						case 18: 
							var split:Array<String> = value2.split(',');
							dupeTimer = Std.parseInt(split[1]);
							shit = Std.parseFloat(split[0]);
						case 19:
							ycbuWhite.alpha = 1;
							FlxTween.tween(ycbuWhite, {alpha: 0}, 0.25, {ease: FlxEase.quadOut});

							blackinfrontobowser.alpha = 0.85;
							cutbg.visible = cutskyline.visible = cutstatic.visible = false;
						case 20:
							triggerEventNote('Triggers Unbeatable', '5.5', '');
							triggerEventNote('Change Character', '1', 'mrSYS');
							blackinfrontobowser.alpha = 0;
							ycbuWhite.alpha = ycbuGyromite.alpha = ycbuLakitu.alpha = 1;
							cutbg.visible = cutskyline.visible = cutstatic.visible = funnylayer0.visible = gf.visible = false;
							ycbuLakitu.x = 0;
							ycbuGyromite.x = 800;
							ycbuGyromite.y = ycbuLakitu.y = 400;
							remove(ycbuGyromite);
							insert(members.indexOf(beatText) + 1, ycbuGyromite);
							if(triggerMR2 == 1){
								triggerEventNote('Change Character', '1', 'mrSYSwb');
								ycbuWhite.color = FlxColor.BLACK;
								ycbuWhite.alpha = 1;
								remove(ycbuWhite);
								insert(members.indexOf(beatText) - 1, ycbuWhite);
								remove(beatText);
								insert(members.indexOf(ycbuWhite) + 1, beatText);
								remove(ycbuGyromite);
								insert(members.indexOf(beatText) + 1, ycbuGyromite);
								remove(gfGroup);
								insert(members.indexOf(ycbuLakitu) + 1, gfGroup);
								remove(dadGroup);
								insert(members.indexOf(gfGroup) + 1, dadGroup);
								// remove(ycbuLakitu);
								// insert(members.indexOf(ycbuGyromite) + 1, ycbuLakitu);
								ycbuGyromite.y = ycbuLakitu.y -= 350;
								gf.visible = funnylayer0.visible = true;

								eventTweens.push(FlxTween.tween(iconLG, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut}));
								eventTweens.push(FlxTween.tween(iconW4, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut}));
								eventTweens.push(FlxTween.tween(iconY0, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut}));
								eventTweens.push(FlxTween.tween(iconP1, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut}));
								eventTweens.push(FlxTween.tween(iconP2, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut}));
								eventTweens.push(FlxTween.tween(customHB, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut}));
							}
							else{
								FlxTween.tween(ycbuWhite, {alpha: 0}, 0.25, {ease: FlxEase.quadOut});
							}
						case 21:
							fireBar.visible = true;
							fireBar.angle = hasDownScroll ? -180 : 180;
							fireBar.y = hasDownScroll ? -400 : 750;
							eventTweens.push(FlxTween.tween(fireBar, {y: hasDownScroll ? -100 : 450}, (2 / (Conductor.bpm / 60)), {ease: FlxEase.expoOut}));
						case 22:
							eventTweens.push(FlxTween.tween(fireBar, {y: 750}, (2 / (Conductor.bpm / 60)), {ease: FlxEase.backIn}));
							eventTimers.push(new FlxTimer().start((2 / (Conductor.bpm / 60)), function(tmr:FlxTimer)
								{
									fireBar.visible = false;
								}));
						case 23:
							remove(ycbuWhite);
							remove(otherBeatText);
							insert(members.indexOf(ycbuLakitu) - 1, otherBeatText);
							insert(members.indexOf(otherBeatText) - 1, ycbuWhite);
							triggerEventNote('Triggers Unbeatable', '30', '0.5');
							ycbuGyromite.alpha = 0;
							ycbuLakitu.alpha = 0;
							ycbuWhite.alpha = 1;
							dad.alpha = 0;
							switch(triggerMR2){
								case 0:
									triggerEventNote('Change Character', '1', 'hunter');
									var weanose:Float;
									weanose = dad.y;
									dad.y += 950;
									dad.alpha = 1;
									eventTweens.push(FlxTween.tween(dad, {y: weanose}, 1.25, {ease: FlxEase.backOut}));
									remove(dadGroup);
									insert(members.indexOf(otherBeatText) + 1, dadGroup);
								case 1:
									triggerEventNote('Change Character', '1', 'koopa');
									var weanose:Float;
									weanose = dad.y;
									dad.y += 1000;
									dad.alpha = 1;
									eventTweens.push(FlxTween.tween(dad, {y: weanose}, 1.25, {ease: FlxEase.backOut}));
									remove(dadGroup);
									insert(members.indexOf(otherBeatText) + 1, dadGroup);
								case 2:
									ycbuGyromite.screenCenter(X);
									ycbuGyromite.visible = true;
									ycbuGyromite.y = FlxG.height;
									eventTweens.push(FlxTween.tween(ycbuGyromite, {y: 200}, 1.25, {ease: FlxEase.backOut}));
									ycbuGyromite.alpha = 1;
									remove(ycbuGyromite);
									insert(members.indexOf(otherBeatText) + 1, ycbuGyromite);
								case 3:
									ycbuLakitu.screenCenter(X);
									ycbuLakitu.visible = true;
									ycbuLakitu.y = FlxG.height;
									eventTweens.push(FlxTween.tween(ycbuLakitu, {y: 200}, 1.25, {ease: FlxEase.backOut}));
									ycbuLakitu.alpha = 1;
									remove(ycbuLakitu);
									insert(members.indexOf(otherBeatText) + 1, ycbuLakitu);
							}
						case 24:
							//1106 clowncar
							clownCar.visible = true;
							clownCar.screenCenter();
							clownCar.y += 175;
							clownCar.color = FlxColor.BLACK;
							triggerEventNote('Triggers Unbeatable', '5.5', 'cheese');
							dad.alpha = 0;
							eventTimers.push(new FlxTimer().start(0.25, function(tmr:FlxTimer)
								{
									eventTweens.push(FlxTween.color(clownCar, 0.4, FlxColor.BLACK, FlxColor.WHITE));
									eventTweens.push(FlxTween.tween(clownCar, {y: -1100}, 2, {ease: FlxEase.quintIn}));
									eventTweens.push(FlxTween.tween(clownCar.scale, {x: 4, y: 4}, 2, {ease: FlxEase.cubeOut}));
								}));
						case 25:
							triggerEventNote('ycbu text', '', '');
							FlxG.camera.flash(FlxColor.WHITE, 2);
							triggerEventNote('Screen Shake','2, 0.003','2, 0.003');
							cutbg.visible = cutskyline.visible = cutstatic.visible = funnylayer0.visible = gf.visible = false;
							dadGroup.alpha = 0;
							remove(boyfriendGroup);
							remove(starmanGF);
						case 26:
							eventTweens.push(FlxTween.num(0, 1000000, 0.75, 
								{ease: FlxEase.cubeOut},
								function(v)
								{
									triggerEventNote('ycbu text', 'score;' + Math.floor(v), '1');
								}));
						case 27:
							//you cannot beat us chant before finale
							switch(triggerMR2){
								case 0:
									//lakitu
									remove(ycbuLakitu);
									insert(members.indexOf(otherBeatText) + 3, ycbuLakitu);
									ZOOMCHARS = false;
									FOLLOWCHARS = false;
									ycbuLakitu.x = -600;
									ycbuLakitu.y = FlxG.height;
									ycbuLakitu.visible = true;
									eventTweens.push(FlxTween.tween(ycbuLakitu, {x: -50}, 1, {ease: FlxEase.quadOut}));
									eventTweens.push(FlxTween.tween(ycbuLakitu, {y: 400}, 1, {ease: FlxEase.quadIn}));
									eventTweens.push(FlxTween.tween(camGame, {zoom: 1.4}, 5.9, {ease: FlxEase.quintIn}));
								case 1:
									//bowser
									remove(funnylayer0);
									insert(members.indexOf(otherBeatText) + 1, funnylayer0);
									funnylayer0.x = 650;
									funnylayer0.y = FlxG.height;
									funnylayer0.visible = true;
									eventTweens.push(FlxTween.tween(funnylayer0, {y: -100}, 1.5, {ease: FlxEase.backOut}));
								case 2:
									//gyromite
									remove(ycbuGyromite);
									insert(members.indexOf(otherBeatText) + 4, ycbuGyromite);
									ycbuGyromite.x = 1300;
									ycbuGyromite.y = FlxG.height;
									ycbuGyromite.visible = true;
									eventTweens.push(FlxTween.tween(ycbuGyromite, {x: 850}, 1, {ease: FlxEase.quadOut}));
									eventTweens.push(FlxTween.tween(ycbuGyromite, {y: 400}, 1, {ease: FlxEase.quadIn}));
								case 3:
									//duck hunt
									remove(gfGroup);
									insert(members.indexOf(otherBeatText) + 2, gfGroup);
									gf.x = dad.x - 470;
									gf.y = FlxG.height;
									gf.visible = true;
									gf.alpha = 1;
									eventTweens.push(FlxTween.tween(gf, {y: dad.y - 180}, 1.5, {ease: FlxEase.backOut}));
							}
						case 28:
							//hardstyle side stuff
							switch(triggerMR2){
								case 0:
									//hide all
									triggerEventNote('ycbu text', '', '');
									if(ClientPrefs.flashing && ClientPrefs.filtro85)
										angel.strength = 0.325;
									ycbuLightningL.visible = ycbuLightningR.visible = ycbuHeadL.visible = ycbuHeadR.visible = false;
								case 1:
									//show all
									triggerEventNote('ycbu text', '', '');
									if(ClientPrefs.flashing && ClientPrefs.filtro85)
										angel.strength = 0.325;
									ycbuHeadL.velocity.y = 600;
									ycbuHeadR.velocity.y = -600;
									ycbuLightningL.screenCenter(X);
									ycbuLightningR.screenCenter(X);
									ycbuLightningL.x -= 440;
									ycbuLightningR.x += 455;
									ycbuLightningL.visible = ycbuLightningR.visible = ycbuHeadL.visible = ycbuHeadR.visible = true;
								case 2:
									//reverse direction
									if (Math.abs(ycbuHeadL.velocity.y) != 1 && ycbuHeadL.animation.curAnim.name == 'LOL' && ClientPrefs.flashing && ClientPrefs.filtro85){
										angel.strength = 0.1;
									}
									
									eventTweens.push(FlxTween.tween(ycbuHeadL, {y: ycbuHeadL.y + (ycbuHeadL.velocity.y)}, 0.1, {ease: FlxEase.quadOut}));
									eventTweens.push(FlxTween.tween(ycbuHeadR, {y: ycbuHeadR.y + (ycbuHeadR.velocity.y)}, 0.1, {ease: FlxEase.quadOut}));
									eventTweens.push(FlxTween.tween(ycbuHeadL.velocity, {y: ycbuHeadL.velocity.y * -1}, 0.1, {ease: FlxEase.quadOut}));
									eventTweens.push(FlxTween.tween(ycbuHeadR.velocity, {y: ycbuHeadR.velocity.y * -1}, 0.1, {ease: FlxEase.quadOut}));
								case 3:
									//skip
									if (ycbuHeadL.animation.curAnim.name == 'LOL' && ClientPrefs.flashing && ClientPrefs.filtro85){
										angel.strength = 0.1;
									}
									eventTweens.push(FlxTween.tween(ycbuHeadL, {y: ycbuHeadL.y + (250 * (ycbuHeadL.velocity.y / Math.abs(ycbuHeadL.velocity.y)))}, 0.25, {ease: FlxEase.quadOut}));
									eventTweens.push(FlxTween.tween(ycbuHeadR, {y: ycbuHeadR.y + (250 * (ycbuHeadR.velocity.y / Math.abs(ycbuHeadR.velocity.y)))}, 0.25, {ease: FlxEase.quadOut}));
								case 4:
									//stop
									ycbuHeadL.velocity.y /= Math.abs(ycbuHeadL.velocity.y);
									ycbuHeadR.velocity.y /= Math.abs(ycbuHeadR.velocity.y);
								case 5:
									//start
									ycbuHeadL.velocity.y *= 420;
									ycbuHeadR.velocity.y *= 420;
								case 6:
									//swap spots
									var firstX:Float = ycbuHeadL.x;
									eventTweens.push(FlxTween.tween(ycbuHeadL, {x: ycbuHeadR.x}, 0.2, {ease: FlxEase.quadOut}));
									eventTweens.push(FlxTween.tween(ycbuHeadR, {x: firstX}, 0.2, {ease: FlxEase.quadOut}));
									firstX = ycbuLightningL.x;
									eventTweens.push(FlxTween.tween(ycbuLightningL, {x: ycbuLightningR.x}, 0.2, {ease: FlxEase.quadOut}));
									eventTweens.push(FlxTween.tween(ycbuLightningR, {x: firstX}, 0.2, {ease: FlxEase.quadOut}));
								case 7:
									//swap to heads
									ycbuHeadL.animation.play('LOL', true);
									ycbuHeadR.animation.play('LOL', true);
									ycbuHeadL.spacing.y = 0;
									ycbuHeadR.spacing.y = 0;
									ycbuHeadL.flipX = true;
									ycbuHeadR.flipX = false;
									ycbuHeadL.screenCenter(X);
									ycbuHeadL.x -= 450;
									ycbuHeadR.screenCenter(X);
									ycbuHeadR.x += 445;
								case 8:
									//swap to gyromite
									ycbuHeadL.animation.play('gyromite', true);
									ycbuHeadR.animation.play('gyromite', true);
									ycbuHeadL.spacing.y = 150;
									ycbuHeadR.spacing.y = 150;
									ycbuHeadL.flipX = false;
									ycbuHeadR.flipX = true;
									ycbuHeadL.x = -50;
									ycbuHeadR.x = 830;
								case 9:
									//swap to lakitu
									ycbuHeadL.animation.play('lakitu', true);
									ycbuHeadR.animation.play('lakitu', true);
									ycbuHeadL.spacing.y = 150;
									ycbuHeadR.spacing.y = 150;
									ycbuHeadL.flipX = true;
									ycbuHeadR.flipX = false;
									ycbuHeadL.x = -50;
									ycbuHeadR.x = 840;
							}
						case 29:
							switch(triggerMR2){
								case 0:
									ycbuCrosshair.visible = true;
									camHUD.visible = false;
									if (ycbuCrosshair.color == FlxColor.WHITE){
										ycbuCrosshair.color = FlxColor.RED;
									}
									else{
										ycbuCrosshair.color = FlxColor.WHITE;
									}
								case 1:
									ycbuCrosshair.visible = false;
									camHUD.visible = true;
							}
						case 30:
							// this one is very important
							var newhealth:Float = health - ((triggerMR2 == 0) ? 1 : triggerMR2);
							if (newhealth < 0.2)
								newhealth = 0.2;
							eventTweens.push(FlxTween.tween(this, {health: newhealth}, 0.1, {ease: FlxEase.quadOut}));
						case 31:
							//bullet bill
							var ycbuBullet:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mario/beatus/bullet'));
							ycbuBullet.scale.set(7, 7);
							ycbuBullet.cameras = [camHUD];
							ycbuBullet.y = FlxG.random.int(40, 680);
							ycbuBullet.antialiasing = false;
							add(ycbuBullet);
							switch(triggerMR2){
								case 0:
									ycbuBullet.x = 1320;
									var bulletX:Int;
									bulletX = -60;
									eventTweens.push(FlxTween.tween(ycbuBullet, {x: bulletX}, 1.5, {onComplete: function(twn:FlxTween){
										ycbuBullet.kill();
									}}));
								case 1:
									ycbuBullet.x = -60;
									ycbuBullet.flipX = true;
									var bulletX:Int;
									bulletX = 1320;
									eventTweens.push(FlxTween.tween(ycbuBullet, {x: bulletX}, 1.5, {onComplete: function(twn:FlxTween){
										ycbuBullet.kill();
									}}));
							}
						case 32:
							//podoboos
							var ycbuPodoboo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mario/beatus/fire'));
							ycbuPodoboo.scale.set(6, 6);
							ycbuPodoboo.updateHitbox();
							ycbuPodoboo.antialiasing = false;
							ycbuPodoboo.angle = 0;
							switch(triggerMR2){
								case 0:
									ycbuPodoboo.setPosition(FlxG.random.int(125, 275), 900);
									triggerEventNote('Triggers Unbeatable', '32', '2');
									if(ClientPrefs.flashing){
										eventTweens.push(FlxTween.color(duckbg, 0.5, 0xFF740000, FlxColor.BLACK, {ease: FlxEase.quadOut}));
										triggerEventNote('Add Camera Zoom', '0.006', '');
										triggerEventNote('Screen Shake', '0.15, 0.003', '0.15, 0.002');
									}
								case 1:
									ycbuPodoboo.setPosition(FlxG.random.int(25, 350), 900);
								case 2:
									ycbuPodoboo.setPosition(FlxG.random.int(775, 1100), 900);
							}
							insert(members.indexOf(bowlava) - 1, ycbuPodoboo);
							
							eventTweens.push(FlxTween.tween(ycbuPodoboo, {angle: FlxG.random.bool(50) ? 180 : -180}, (0.5 / (Conductor.bpm / 60)), {startDelay: (0.75 / (Conductor.bpm / 60)), ease: FlxEase.quadInOut}));
							eventTweens.push(FlxTween.tween(ycbuPodoboo, {y: 300}, (1 / (Conductor.bpm / 60)), {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween){
								eventTweens.push(FlxTween.tween(ycbuPodoboo, {y: 900}, (1 / (Conductor.bpm / 60)), {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween){
									ycbuPodoboo.kill();
								}}));
							}}));
						case 33:
							switch(triggerMR2){
								case 1:
									//show duck hunt
									eventTweens.push(FlxTween.tween(iconW4, {alpha: 1}, 0.2, {ease: FlxEase.quadOut}));
								case 2:
									//show bowser
									eventTweens.push(FlxTween.tween(iconY0, {alpha: 1}, 0.2, {ease: FlxEase.quadOut}));
								case 3:
									var iconPos3x:Float = ycbuIconPos3.x;
									var iconPos3y:Float = ycbuIconPos3.y;
									eventTweens.push(FlxTween.tween(ycbuIconPos1, {x: ycbuIconPos2.x, y: ycbuIconPos2.y}, 0.2, {ease: FlxEase.quadOut}));
									eventTweens.push(FlxTween.tween(ycbuIconPos3, {x: ycbuIconPos1.x, y: ycbuIconPos1.y}, 0.2, {ease: FlxEase.quadOut}));
									eventTweens.push(FlxTween.tween(ycbuIconPos2, {x: iconPos3x, y: iconPos3y}, 0.2, {ease: FlxEase.quadOut}));
							}
							if (triggerMR2 != 3){
								var iconPos3x:Float = ycbuIconPos3.x;
								var iconPos3y:Float = ycbuIconPos3.y;
								eventTweens.push(FlxTween.tween(ycbuIconPos3, {x: ycbuIconPos2.x, y: ycbuIconPos2.y}, 0.2, {ease: FlxEase.quadOut}));
								eventTweens.push(FlxTween.tween(ycbuIconPos2, {x: ycbuIconPos1.x, y: ycbuIconPos1.y}, 0.2, {ease: FlxEase.quadOut}));
								eventTweens.push(FlxTween.tween(ycbuIconPos1, {x: iconPos3x, y: iconPos3y}, 0.2, {ease: FlxEase.quadOut}));
							}
					}
				}
			case 'ycbu text':
				var pibetexto:String = value1.replace(';', '\n');
				var trigger2:Float = Std.parseFloat(value2);
				if (Math.isNaN(trigger2))
					trigger2 = 0;
				switch(trigger2){
					case 1 | 2:
						ycbuGyromite.animation.play('idle', true);
						ycbuLakitu.animation.play('idle', true);
					case 3:
						ycbuLakitu.alpha = 0;
					case 4:
						ycbuGyromite.animation.play('idle', true);
						ycbuHeadL.animation.play('gyromite', true);
						ycbuHeadR.animation.play('gyromite', true);
					case 5:
						ycbuLakitu.animation.play('idle', true);
						ycbuHeadL.animation.play('lakitu', true);
						ycbuHeadR.animation.play('lakitu', true);
				}

				if(trigger2 == 1){
					if (ClientPrefs.flashing)
						otherBeatText.color = 0xFFF87858;
					otherBeatText.text = pibetexto;
					otherBeatText.updateHitbox();
					otherBeatText.screenCenter();
				}
				else{
					if (ClientPrefs.flashing)
						beatText.color = 0xFFF87858;
					beatText.text = pibetexto;
					beatText.updateHitbox();
					beatText.screenCenter();
				}

				for (timer in extraTimers)
					{
						timer.cancel();
					}
				extraTimers.push(new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						if(trigger2 == 1){
							otherBeatText.color = FlxColor.BLACK;
						}
						else{
							beatText.color = FlxColor.WHITE;
						}
					}));

			case 'Triggers Promotion':
				var triggerMR:Float = Std.parseFloat(value1);
				if (Math.isNaN(triggerMR))
					triggerMR = 0;
				switch (triggerMR)
				{
					case 0:
						tvTransition.animation.play('dothething');
						tvTransition.visible = true;
						new FlxTimer().start(0.08, function(tmr:FlxTimer)
						{
							blackBarThingie.alpha = 1;
							camHUD.alpha = 0;
						});
					case 1:
						promoBG.visible = false;
						promoBGSad.visible = false;
						promoDesk.visible = false;
						boyfriend.visible = false;
						gf.visible = false;

						darkFloor.visible = true;

						defaultCamZoom = 0.7;

						add(stanlines);
						stanlines.alpha = 0;

						if (health > 1)
						{
							health = 1;
						}

						triggerEventNote('Change Character', '1', 'stanley');
						dad.x = 697;
						dad.y = 215;

						eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 0}, 4, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(camHUD, {alpha: 1}, 4, {ease: FlxEase.quadInOut}));
						PauseSubState.muymalo = 2;

					case 2:
						eventTweens.push(FlxTween.tween(bgLuigi, {alpha: 1}, 0.4, {ease: FlxEase.quadInOut}));
					case 3:
						eventTweens.push(FlxTween.tween(bgPeach, {alpha: 1}, 0.4, {ease: FlxEase.quadInOut}));
					case 4:
						stanlines.alpha = 1;
						stanlines.animation.play('line' + stantext, true);
						// trace('line' + stantext, stanlines.animation.curAnim.name);
						stantext += 1;
						stanlines.angle = FlxG.random.int(30, -30);
						stanlines.x = 550;
						stanlines.y = 500;
						if (FlxG.random.int(0, 100) > 50)
						{
							// trace(stanlines.x - 150, (2 * (1 / (Conductor.bpm / 60))) - 0.05);
							eventTweens.push(FlxTween.tween(stanlines, {x: stanlines.x - 150}, (2 * (1 / (Conductor.bpm / 60))) - 0.05, {ease: FlxEase.quadOut}));
						}
						else
						{
							// trace(stanlines.x + 150, (2 * (1 / (Conductor.bpm / 60))) - 0.05);
							eventTweens.push(FlxTween.tween(stanlines, {x: stanlines.x + 150}, (2 * (1 / (Conductor.bpm / 60))) - 0.05, {ease: FlxEase.quadOut}));
						}
						if (FlxG.random.int(0, 100) > 50)
						{
							// trace(stanlines.y - 75, (2 * (1 / (Conductor.bpm / 60))) - 0.05);
							eventTweens.push(FlxTween.tween(stanlines, {y: stanlines.y - 75}, (2 * (1 / (Conductor.bpm / 60))) - 0.05, {ease: FlxEase.quadOut}));
						}
						else
						{
							// trace(stanlines.y + 75, (2 * (1 / (Conductor.bpm / 60))) - 0.05);
							eventTweens.push(FlxTween.tween(stanlines, {y: stanlines.y + 75}, (2 * (1 / (Conductor.bpm / 60))) - 0.05, {ease: FlxEase.quadOut}));
						}

						FlxTween.tween(stanlines, {alpha: 0}, (1 * (1 / (Conductor.bpm / 60))) - 0.05, {startDelay: (1 * (1 / (Conductor.bpm / 60)))});
					case 5:
						promoDesk.animation.play('flash');
						triggerEventNote('Play Animation', 'depression', 'dad');
						dad.idleSuffix = '-alt';
						extraTween.push(FlxTween.tween(camFollowPos, {x: 1009, y:544}, 3, {ease: FlxEase.quadInOut}));
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
						{
							promoDesk.animation.play('luigi');
							new FlxTimer().start(0.8, function(tmr:FlxTimer)
							{
								promoBGSad.visible = true;
								eventTweens.push(FlxTween.tween(promoBG, {alpha: 0}, 1, {ease: FlxEase.quadInOut}));
							});
						});
					case 6:
						// not sure what this does but i will add it lol 408
						for (tween in extraTween)
							{
								tween.cancel();
							}
					case 7:
						// end fade out 440
						eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 4));
						eventTweens.push(FlxTween.tween(camHUD, {alpha: 0}, 4));
				}

			case 'Triggers Abandoned':
				var trigger:Float = Std.parseFloat(value1);
				if (Math.isNaN(trigger))
					trigger = 0;
				switch (trigger)
				{
					case 0:
						flooding = true;
					case 1:
						flooding = false;
						eventTweens.push(FlxTween.tween(flood, {y: 720}, 3, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								//i don't think anything would fuck up but this is just failsafe incase the water gets
								//stuck or smth again idk how that would happen but i don't want it to so blehhh
								flood.y = 720;
							}}));
					case 2:
						flooding = false;
					case 3:
						eventTweens.push(FlxTween.tween(flood, {y: flood.y - 120}, 0.25, {ease: FlxEase.quadOut}));
						triggerEventNote('Play Animation', 'Hey', 'dad');
					case 3.5:
						eventTweens.push(FlxTween.tween(flood, {y: flood.y - 400}, 0.7, {ease: FlxEase.quadInOut}));
					case 4:
						eventTweens.push(FlxTween.tween(redStat, {alpha: 0.8}, 0.4, {ease: FlxEase.quadIn}));
					case 5:
						eventTweens.push(FlxTween.tween(redTV, {alpha: 0}, 1.1, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(redTVStat, {alpha: 0}, 1.1, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(redTVImg, {alpha: 0}, 1.1, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(redStat, {alpha: 0.8}, 1.1, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
						{
							if (ClientPrefs.flashing)
								{
									FlxG.camera.flash(FlxColor.WHITE, 0.5);
								}
								else
								{
									FlxG.camera.flash(FlxColor.RED, 0.5);
								}
							blackBarThingie.alpha = 0;
							redStat.alpha = 0;
							contrastFX.brightness.value = [0.3];
							contrastFX.contrast.value = [2.0];
						}}));
					case 6:
						redTV.visible = false;
						redTVStat.visible = false;
						redTVImg.visible = false;
						eventTweens.push(FlxTween.tween(redStat, {alpha: 0.8}, 0.4, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
							{
								if (ClientPrefs.flashing)
									{
										FlxG.camera.flash(FlxColor.WHITE, 0.5);
									}
									else
									{
										FlxG.camera.flash(FlxColor.RED, 0.5);
									}
								redStat.alpha = 0;
								contrastFX.brightness.value = [0.8];
								contrastFX.contrast.value = [1.0];
							}}));
					case 7:
						add(warningPopup);
						eventTweens.push(FlxTween.tween(warningPopup, {alpha: 1}, 0.5));
					case 8:
						eventTweens.push(FlxTween.tween(warningPopup, {alpha: 0}, 1, {ease: FlxEase.quadInOut}));
					case 9:
						var nexty:Float = luigilaugh.y;
						luigilaugh.y += 500;
						luigilaugh.alpha = 1;
						eventTweens.push(FlxTween.tween(luigilaugh, {y: nexty}, 2, {ease: FlxEase.expoOut}));
						eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 1));
						luigilaugh.animation.play('laugh');
					case 10:
						fondaso.visible = true;
						atra.visible = true;
						adel.visible = true;
						adel2.visible = false;
						if (ClientPrefs.flashing)
							{
								FlxG.camera.flash(FlxColor.WHITE, 0.5);
							}
							else
							{
								FlxG.camera.flash(FlxColor.RED, 0.5);
							}
						redStat.alpha = 0;
						luigilaugh.alpha = 0;
						blackBarThingie.alpha = 0;
						triggerEventNote('Change Character', '1', 'luigi_fountain3d');
						triggerEventNote('Change Character', '0', 'bf-back3d');
					case 11:
						eventTweens.push(FlxTween.tween(thefog, {alpha: 0.9}, 0.5));
					case 12:
						thefog.alpha = 0;
					case 13:
						eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 0.45, {ease: FlxEase.quadIn}));
						eventTweens.push(FlxTween.tween(redStat, {alpha: 0.8}, 0.45, {ease: FlxEase.quadIn}));
					case 14:
						eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 1}, (24 * (1 / (Conductor.bpm / 60)))));
						eventTweens.push(FlxTween.tween(camHUD, {alpha: 0}, (24 * (1 / (Conductor.bpm / 60)))));
					case 15:
						if (ClientPrefs.flashing)
						{
							redStat.alpha = 0;
						}
					case 16:
						if (ClientPrefs.flashing)
						{
							redStat.alpha = 0.8;
						}
					case 17:
						//4
						enemyY = dadGroup.y;
						extraTween.push(FlxTween.tween(dadGroup, {y: enemyY - 100}, 8, {ease: FlxEase.quadInOut, type: PINGPONG}));
			}

			case 'Triggers The End':
				var trigger:Float = Std.parseFloat(value1);
				var trigger2:Float = Std.parseFloat(value2);
				if (Math.isNaN(trigger))
					trigger = 0;
				if (Math.isNaN(trigger2))
					trigger2 = 0;
				
				switch (trigger)
				{
					case 0:
						// 4
						eventTweens.push(FlxTween.tween(elfin, {alpha: 1}, 2));
						funnylayer0.alpha = 0;
					case 1:
						// 12
						eventTweens.push(FlxTween.tween(elfin, {alpha: 0}, 4));
					case 2:
						// 32
						blackBarThingie.alpha = 0.6;
						camHUD.alpha = 1;
						elfin.visible = false;
					case 3:
						// 56 cam change
						DAD_CAM_X = 200;
					case 4:
						// 58
						eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 0.8));
					case 5:
						// 60
						letsago.alpha = 1;
						letsago.animation.play('go');
					case 6:
						// 64
						PauseSubState.muymalo = 2;
						letsago.alpha = 0;
						eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 0}, 0.2));
						eventTweens.push(FlxTween.tween(funnylayer0, {alpha: 1}, 0.2));
						DAD_CAM_X = 420;
						DAD_CAM_Y = 350;
					case 7:
						// 293
						eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 0.6));
						eventTweens.push(FlxTween.tween(funnylayer0, {alpha: 0}, 0.6));
						eventTweens.push(FlxTween.tween(camHUD, {alpha: 0}, 0.6));
					case 8:
						// 295
						DAD_CAM_X = 180;
					case 9:
						// 296
						defaultCamZoom = 1;
						DAD_ZOOM = 1;
						BF_ZOOM = 1;

						castle0.visible = false;
						bg.visible = false;
						floor.visible = false;
						mesa.visible = false;
						boyfriend.visible = false;
						blackBarThingie.alpha = 0;
					case 9.5:
						triggerEventNote('Triggers Universal', '9', '');
						triggerEventNote('Change Character', '1', 'costumedark');
						triggerEventNote('Play Animation', 'wahoo', 'dad');
					case 10:
						// 298
						PauseSubState.muymalo = 3;
						eventTweens.push(FlxTween.tween(camHUD, {alpha: 1}, 0.6));
						defaultCamZoom = 1.1;
						DAD_ZOOM = 1.1;
						BF_ZOOM = 1.1;
					case 11:
						// 370
						eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: 1}, 0.6));
						eventTweens.push(FlxTween.tween(camHUD, {alpha: 0}, 1));
				}

			case 'Triggers Dark Forest':
				var trigger:Float = Std.parseFloat(value1);
				if (Math.isNaN(trigger))
					trigger = 0;
				switch (trigger)
				{
					case 0: //cutscene part 1
						triggerEventNote('Change Character', '1', 'peachtalk1');
						triggerEventNote('Play Animation', 'talk', 'Dad');

					case 1: //GO TO THE TREEHOUSE
						for (tween in extraTween)
						{
							tween.cancel();
						}
						triggerEventNote('Change Character', '1', 'peachthe');

						casa0.visible = true;
						FOLLOWCHARS = true;
						ZOOMCHARS = true;

						var color1:Int = 0xFFBECDD4;
						dadGroup.color = 0xFF758186;
						boyfriendGroup.color = color1;
						capenose.color = color1;

						boyfriendGroup.visible = true;
						dad.visible = true;
						capenose.visible = true;
						dadGroup.y += -3750;
						boyfriendGroup.y = -3800;
						capenose.y = boyfriendGroup.y + 460;

						DAD_CAM_Y = -3450;
						BF_CAM_Y = -3250;
						eventTweens.push(FlxTween.tween(camGame, {zoom: 0.65}, 1.4, {ease:FlxEase.sineOut}));

						eventTweens.push(FlxTween.tween(boyfriendGroup, {y: -3550}, 1, {startDelay: 0.5 * (1 / (Conductor.bpm / 60)), ease: FlxEase.bounceOut}));
						eventTweens.push(FlxTween.tween(capenose, {y: -3090}, 1, {startDelay: 0.5 * (1 / (Conductor.bpm / 60)), ease: FlxEase.bounceOut}));

						enemyY = dadGroup.y;
						enemyX = dadGroup.x;

						eventTweens.push(FlxTween.tween(lluvia, {alpha: 0}, 0.5, {ease: FlxEase.quadOut}));

						eventTimers.push(new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							extraTween.push(FlxTween.tween(dadGroup, {x: enemyX - 220}, 4, {ease: FlxEase.quadInOut, type: PINGPONG}));
							extraTween.push(FlxTween.tween(dadGroup, {y: enemyY + 100}, 1.4, {ease: FlxEase.quadInOut, type: PINGPONG}));
						}));

					case 2: //THIRD ACT
						var color1:Int = 0xFFB8837F;
						var color2:Int = 0xFFFF8B82;
						triggerEventNote('Change Character', '1', 'peachtheG');

						for (tween in extraTween)
						{
							tween.cancel();
						}
						fresco.visible = false;

						seaweed1.visible = true;
						seaweed2.visible = true;
						seaweed3.visible = true;

						glitch0.visible = true;
						glitch1.visible = true;
						glitch2.visible = true;
						glitch3.visible = true;
						cososuelo.visible = true;

						leaf0.visible = true;
						leaf1.visible = true;
						leaf2.visible = true;

						bola0.visible = true;
						bola1.visible = true;

						DAD_CAM_Y = 150;
						BF_CAM_Y = 550;

						dad.color = color1;
						gfGroup.color = color1;
						boyfriendGroup.color = color1;
						capenose.color = color1;

						dadGroup.y = -200;
						dad.x = 100;
						boyfriendGroup.y = 250;
						capenose.y = boyfriendGroup.y + 460;
						

						enemyY = dadGroup.y;
						enemyX = dadGroup.x;

						eventTimers.push(new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							extraTween.push(FlxTween.tween(dadGroup, {x: enemyX - 220}, 4, {ease: FlxEase.quadInOut, type: PINGPONG}));
							extraTween.push(FlxTween.tween(dadGroup, {y: enemyY - 100}, 1.4, {ease: FlxEase.quadInOut, type: PINGPONG}));
						}));
						eventTweens.push(FlxTween.tween(fogred, {alpha: 0.8}, 0.5, {ease: FlxEase.quadOut}));

					case 3:
						if (ClientPrefs.flashing)
						{
							FlxG.camera.flash(FlxColor.WHITE, 1);
							lluvia.visible = true;
						}

					case 4:
						if (ClientPrefs.flashing)
						{
							var colornew:Int = 0xFF353F42; // color char when thunder
							var bgnew:Int = 0xFF808080; // color bg when thunder
							var colorback:Int = 0xFF93ADB5; // color char when finish
							//whiteThingie.alpha = 0.4;
							trueno.visible = true;
							trueno.animation.play('rayo');
							trueno.x = FlxG.random.float(-180, 600);
							trueno.flipX = FlxG.random.bool(50);
							FlxG.sound.play(Paths.sound('smw_thunder' + FlxG.random.int(1, 3)));

							eventTimers.push(new FlxTimer().start(0.2917, function(tmr:FlxTimer)
								{
									trueno.visible = false;
								}));

							//eventTweens.push(FlxTween.tween(whiteThingie, {alpha: 0}, 1.3, {startDelay: 0.2, ease: FlxEase.expoInOut}));

							eventTweens.push(FlxTween.color(dad, 1.3, colornew, colorback, {startDelay: 0.2, ease: FlxEase.quadOut}));
							eventTweens.push(FlxTween.color(gfGroup, 1.3, colornew, colorback, {startDelay: 0.2, ease: FlxEase.quadOut}));
							eventTweens.push(FlxTween.color(boyfriendGroup, 1.3, colornew, colorback, {startDelay: 0.2, ease: FlxEase.quadOut}));
							eventTweens.push(FlxTween.color(capenose, 1.3, colornew, colorback, {startDelay: 0.2, ease: FlxEase.quadOut}));

							eventTweens.push(FlxTween.color(lospapus, 1.3, bgnew, FlxColor.WHITE, {startDelay: 0.2, ease: FlxEase.quadOut}));
							eventTweens.push(FlxTween.color(atrasarboleda, 1.3, bgnew, FlxColor.WHITE, {startDelay: 0.2, ease: FlxEase.quadOut}));
							eventTweens.push(FlxTween.color(aas, 1.3, bgnew, FlxColor.WHITE, {startDelay: 0.2, ease: FlxEase.quadOut}));
							eventTweens.push(FlxTween.color(sopapo, 1.3, bgnew, FlxColor.WHITE, {startDelay: 0.2, ease: FlxEase.quadOut}));
							eventTweens.push(FlxTween.color(s3, 1.3, bgnew, FlxColor.WHITE, {startDelay: 0.2, ease: FlxEase.quadOut}));
							eventTweens.push(FlxTween.color(s2, 1.3, bgnew, FlxColor.WHITE, {startDelay: 0.2, ease: FlxEase.quadOut}));

							triggerEventNote('Screen Shake', '0.15, 0.03', '');
						}

					case 5:
						var color2:Int = 0xFFFF8B82;
						eventTweens.push(FlxTween.tween(camFollowPos, {y: 150}, (5 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.cubeInOut}));

						eventTweens.push(FlxTween.color(faropapu, 1.3, FlxColor.WHITE, color2, {startDelay: 0.2, ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.color(lospapus, 1.3, FlxColor.WHITE, color2, {startDelay: 0.2, ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.color(atrasarboleda, 1.3, FlxColor.WHITE, color2, {startDelay: 0.2, ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.color(aas, 1.3, FlxColor.WHITE, color2, {startDelay: 0.2, ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.color(sopapo, 1.3, FlxColor.WHITE, color2, {startDelay: 0.2, ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.color(s3, 1.3, FlxColor.WHITE, color2, {startDelay: 0.2, ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.color(s2, 1.3, FlxColor.WHITE, color2, {startDelay: 0.2, ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.color(lluvia, 0.5, 0x00000000, FlxColor.BLACK, {startDelay: 0.7, ease: FlxEase.quadOut}));

					case 6:
							//loop for tutorial ples
							glitch0.x = FlxG.random.float(-200, 1500);
							glitch1.x = FlxG.random.float(-200, 1500);
							glitch2.x = FlxG.random.float(-200, 1500);
							glitch3.x = FlxG.random.float(-200, 1500);

							glitch0.y = FlxG.random.float(200, 1200);
							glitch1.y = FlxG.random.float(200, 1200);
							glitch2.y = FlxG.random.float(200, 1200);
							glitch3.y = FlxG.random.float(200, 1200);

							glitch0.scale.set(FlxG.random.float(1, 5), FlxG.random.float(1, 5));
							glitch1.scale.set(FlxG.random.float(1, 5), FlxG.random.float(1, 5));
							glitch2.scale.set(FlxG.random.float(1, 5), FlxG.random.float(1, 5));
							glitch3.scale.set(FlxG.random.float(1, 5), FlxG.random.float(1, 5));
					case 7:
						var gota:BGSprite = new BGSprite('mario/LuigiBeta/gota', 1270, 700, ['rain'], false);
						gota.antialiasing = ClientPrefs.globalAntialiasing;
						gota.x = FlxG.random.int(-300, 2070);
						gota.y = FlxG.random.int(800, 1000);
						if(value2 == '1') gota.color = 0xFF000000;
						if(gota.y > 950){
							add(gota);
						}else{
							insert(members.indexOf(gfGroup) - 1, gota);
						}
						
						gota.alpha = 0.4;
						gota.dance(true);

						eventTweens.push(FlxTween.tween(gota, {alpha: 0}, 2, {startDelay: 0.3, onComplete: function(twn:FlxTween)
						{
							gota.destroy();

						}}));
					case 8:
						FOLLOWCHARS = false;
						ZOOMCHARS = false;
						eventTweens.push(FlxTween.tween(camGame, {zoom: 0.8}, 1.5, {ease:FlxEase.cubeInOut}));
						eventTweens.push(FlxTween.tween(camFollowPos, {x: DAD_CAM_X, y: DAD_CAM_Y}, 1.5, {ease:FlxEase.cubeInOut}));
					case 9:
						FOLLOWCHARS = true;
						ZOOMCHARS = true;
					//time for nate code :dave:
					case 10:
						//1
						extraTween.push(FlxTween.tween(dadGroup, {x: enemyX - 220}, 4, {ease: FlxEase.quadInOut, type: PINGPONG}));
						extraTween.push(FlxTween.tween(dadGroup, {y: enemyY + 100}, 1.4, {ease: FlxEase.quadInOut, type: PINGPONG}));
					case 11:
						//227
						eventTweens.push(FlxTween.tween(camFollowPos, {x: BF_CAM_X, y: BF_CAM_Y}, (2 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.cubeInOut}));
					case 12:
						//228
						FOLLOWCHARS = false;
						ZOOMCHARS = true;
						dad.visible = false;
						boyfriendGroup.visible = false;
						capenose.visible = false;
						fresco.alpha = 1;
						fresco.animation.play('llevar');
					case 13:
						//230
						eventTweens.push(FlxTween.tween(fresco, {y: -865}, (3 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.quadIn}));
						eventTweens.push(FlxTween.tween(camFollowPos, {y: -3250}, (4 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.expoInOut}));
					case 14:
						//372
						blackBarThingie.alpha = 1;
				}

			case 'Triggers Paranoia': // HERE COMES THE MADNESS HAHAHAHAHA
				var trigger:Float = Std.parseFloat(value1);
				if (Math.isNaN(trigger))
					trigger = 0;
				switch (trigger)
				{
					case 1:
						boyfriendGroup.alpha = 1;
						dadGroup.alpha = 1;
						blackBarThingie.alpha = 0;
						gfwasTaken.visible = false;
						FOLLOWCHARS = true;
						ZOOMCHARS = true;
						if (ClientPrefs.noVirtual)
							{
							camFollowPos.x = 520;
							camFollowPos.y = -1000;

							extraTween.push(FlxTween.tween(camFollowPos, {x: 920}, 3, {ease: FlxEase.quadInOut, type: PINGPONG}));
							extraTween.push(FlxTween.tween(camFollowPos, {y: 720}, 3, {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween)
								{
									extraTween.push(FlxTween.tween(camFollowPos, {y: 520}, 5, {ease: FlxEase.quadInOut, type: PINGPONG}));
									extraTween.push(FlxTween.tween(camFollow, {y: 320}, 5, {ease: FlxEase.quadInOut, type: PINGPONG}));
								}}));
							}
					case 2:
						if (ClientPrefs.noVirtual)
						{
							eventTimers.push(new FlxTimer().start(0.05, function(tmr:FlxTimer)
							{
								iconP1.changeIcon('icon-bfvsad');
								CppAPI.setOld();
								var relPath:String = FileSystem.absolutePath("assets\\images\\toolate.bmp");
								relPath = relPath.replace("/", "\\");
								CppAPI.setWallpaper(relPath);
								CppAPI.hideWindows();
								virtuabg.alpha = 1;
								blackBarThingie.alpha = 1;
								crazyFloor.visible = true;
								clashmario.visible = false;
								yourhead.visible = true;
							}));
						}
						else
						{
							blackBarThingie.alpha = 1;
							clashmario.visible = false;
							yourhead.visible = true;
						}
					case 3:
						turtle.offset.x = 130;
						turtle2.offset.x = 40;
						turtle.visible = true;
						turtle2.visible = true;
						turtle.animation.play('glitch');
						turtle2.animation.play('glitch');
						eventTimers.push(new FlxTimer().start(0.8, function(tmr:FlxTimer)
							{
								turtle.animation.play('idle');
								turtle2.animation.play('idle');
								turtle.offset.x = 0;
								turtle2.offset.x = 0;
							}));
						

					case 4:
						if (ClientPrefs.noVirtual)
						{
							for (tween in extraTween)
								{
									tween.cancel();
								}
							CppAPI.restoreWindows();
							startresize = true;
							Lib.application.window.borderless = false;

							if (!ClientPrefs.hideTime)
							{
								timeBarBG.visible = true;
								timeBar.visible = true;
								timeTxt.visible = true;
							}
							if (!ClientPrefs.hideHud)
							{
								scoreTxt.visible = true;
							}

							windowTween.push(FlxTween.tween(this, {winy: ogwinY, winx: ogwinX}, 1, {ease: FlxEase.expoOut}));
							windowTween.push(FlxTween.tween(this, {resizex: ogwinsizeX, resizey: ogwinsizeY}, 1, {
								ease: FlxEase.expoOut,
								onComplete: function(twn:FlxTween)
								{
									startresize = false;
									Lib.application.window.resize(resizex, resizey);
									Lib.application.window.move(winx, winy);
								}
							}));
							virtuabg.alpha = 0;
							blackBarThingie.alpha = 0;
							crazyFloor.visible = false;
						}
						else
						{
							virtuabg.alpha = 0;
							blackBarThingie.alpha = 0;
						}
					case 5:

					case 6:
						FOLLOWCHARS = false;
						ZOOMCHARS = false;
						turtle.animation.play('glitch', true, true, 10);
						turtle2.animation.play('glitch', true, true, 10);
						eventTimers.push(new FlxTimer().start(0.41, function(tmr:FlxTimer)
							{
								turtle.visible = false;
								turtle2.visible = false;
							}));
						eventTweens.push(FlxTween.tween(vwall, {alpha: 0}, 0.5, {startDelay: 0.2, ease: FlxEase.sineIn}));
						eventTweens.push(FlxTween.tween(camFollowPos, {x: 1200, y: 60}, 0.7, {ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.tween(camGame, {zoom: 1.4}, 4, {ease: FlxEase.quadIn}));
						eventTweens.push(FlxTween.tween(this, {defaultCamZoom: 1.4}, 4, {ease: FlxEase.quadIn}));
						eventTimers.push(new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							gfwasTaken.visible = true;
							gfwasTaken.animation.play('dies');
							// camFollowPos.x += 400;
						}));
					case 7:
						if (ClientPrefs.flashing){
						// set the mult
						dupe.mult = Std.parseFloat(value2);
						dupe.mirror = false;
						}
					case 8:
						// set the mult timer
						if (ClientPrefs.flashing) dupeTimer = Std.parseInt(value2);
					case 9:
						// set the mult max b4 returning to zero
						//ahhh im dupemaxxing!! im dupemaxxing!!!
						if (ClientPrefs.flashing) dupeMax =  Std.parseInt(value2);
				}

			case 'Triggers Day Out':
				var trigger:Float = Std.parseFloat(value1);
				if (Math.isNaN(trigger))
					trigger = 0;
				var trigger2:Float = Std.parseFloat(value2);
				if (Math.isNaN(trigger2))
					trigger2 = 0;
				switch (trigger)
				{
					case 0:
						FOLLOWCHARS = false;
						eventTweens.push(FlxTween.tween(camFollowPos, {x: DAD_CAM_X, y: DAD_CAM_Y}, 1.5, {ease: FlxEase.quadOut}));
						mrwalk.alpha = 1;
						dadGroup.visible = false;

						gfwalk.alpha = 1;
						gflol.visible = false;

						bfwalk.alpha = 1;
						boyfriendGroup.visible = false;

						lgwalk.alpha = 1;
						gfGroup.visible = false;

						gfwalk.animation.play('why');
						bfwalk.animation.play('why');
						mrwalk.animation.play('why');
						lgwalk.animation.play('why');

						gfspeak.alpha = 1;

						eventTweens.push(FlxTween.tween(gfwalk, {y: gfwalk.y + 400, x: gfwalk.x + 2533}, 6, {startDelay: 7.71}));
						eventTweens.push(FlxTween.tween(bfwalk, {y: bfwalk.y + 400, x: bfwalk.x + 2533}, 6, {startDelay: 7.85}));
						eventTweens.push(FlxTween.tween(mrwalk, {y: mrwalk.y + 400, x: mrwalk.x + 2533}, 6, {startDelay: 6.19}));
						eventTweens.push(FlxTween.tween(lgwalk, {y: lgwalk.y + 400, x: lgwalk.x + 2533}, 6, {startDelay: 9.14}));
					case 1:
						//13
						FOLLOWCHARS = false;
						eventTweens.push(FlxTween.tween(camFollowPos, {x: 1050, y: 450}, 2.5, {ease: FlxEase.cubeInOut}));
						eventTweens.push(FlxTween.tween(FlxG.camera, {zoom: 1}, 2.4, {ease: FlxEase.quadInOut}));
						defaultCamZoom = 1;
					case 2:
						//32
						FOLLOWCHARS = true;
						camZooming = true;
						triggerEventNote('Camera Follow Pos','','');
						defaultCamZoom = 0.75;
					case 3:
						//188
						gflol.animation.play('why');
						FOLLOWCHARS = false;
						eventTweens.push(FlxTween.tween(camFollowPos, {x: 320, y: 450}, 1, {ease: FlxEase.quadOut}));
					case 4:
						//196
						FOLLOWCHARS = true;
						triggerEventNote('Camera Follow Pos','','');
					case 5:
						// 329
						FOLLOWCHARS = false;
						triggerEventNote('Camera Follow Pos','320','450');
					case 6:
						// 339
						FOLLOWCHARS = false;
						GFSINGDAD = false;
						GFSINGBF = false;
						eventTweens.push(FlxTween.tween(camFollowPos, {x: 920, y: 450}, 3, {ease: FlxEase.quadInOut}));
						triggerEventNote('Camera Follow Pos','','');
					case 7:
						eventTweens.push(FlxTween.tween(camFollowPos, {x: 320, y: 450}, 2.4, {ease: FlxEase.cubeInOut}));
						eventTweens.push(FlxTween.tween(FlxG.camera, {zoom: 0.7}, 2.4, {ease: FlxEase.cubeInOut}));
						boyfriendGroup.alpha = 1;
						gflol.alpha = 1;
					case 8:
						eventTweens.push(FlxTween.tween(camFollowPos, {x: 720, y: 450}, 1.4, {ease: FlxEase.cubeOut}));
					case 9:
						switch (trigger2){
							case 0:
								GameOverSubstate.characterName = 'bf-ldo';
							case 1:
								GameOverSubstate.characterName = 'luigi-ldo';
						}
				}

			case 'Triggers Dictator':
				var trigger:Float = Std.parseFloat(value1);
				var trigger2:Float = Std.parseFloat(value2);
				if (Math.isNaN(trigger))
					trigger = 0;
				if (Math.isNaN(trigger2))
					trigger2 = 0;
				
				switch (trigger)
				{
					case 0:
						//0
						snapCamFollowToPos(220, -390);
						FOLLOWCHARS = false;
					case 1:
						//4
						DAD_CAM_X = 220;
						DAD_CAM_Y = 430;
						isCameraOnForcedPos = false;
						eventTweens.push(FlxTween.tween(camFollowPos, {y: 380}, 4, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(camGame, {zoom: 1.2}, (22.5 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.quadInOut}));
						isCameraOnForcedPos = true;
					case 2:
						//27
						eventTweens.push(FlxTween.tween(camGame, {zoom: 1.3}, 1, {startDelay: (0.5 * (1 / (Conductor.bpm / 60))), ease: FlxEase.backOut}));
					case 3:
						//30
						eventTweens.push(FlxTween.tween(camGame, {zoom: 0.8}, (2 * (1 / (Conductor.bpm / 60))), { ease: FlxEase.quadIn}));
					case 4:
						//32
						FOLLOWCHARS = true;
						isCameraOnForcedPos = false;
					case 5:
						//128, 224
						GFSINGBF = true;
						GFSINGDAD = true;
						defaultCamZoom = 0.7;
					case 6:
						//144, 244
						GFSINGBF = false;
						GFSINGDAD = false;
					case 7:
						//308
						FOLLOWCHARS = false;
						isCameraOnForcedPos = false;
						extraTween.push(FlxTween.tween(camFollowPos, {x: 1020, y: 550}, (2 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.quadIn}));
						eventTweens.push(FlxTween.tween(camGame, {zoom: 1}, 0.3, {ease: FlxEase.quadOut}));
						defaultCamZoom = 1;
						isCameraOnForcedPos = true;
					case 8:
						//310
						for (tween in extraTween)
							{
								tween.cancel();
							}
						isCameraOnForcedPos = false;
						extraTween.push(FlxTween.tween(camFollowPos, {y: 50}, (1 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.quadOut}));
						isCameraOnForcedPos = true;
						FOLLOWCHARS = false;
						explosionBOM.alpha = 1;
						explosionBOM.animation.play('BOOM');
					case 9:
						//311
						blackBarThingie.alpha = 1;
					case 10:
						GF_ZOOM += 0.03;

					case 11:
						secretWarning.animation.play('bye', true);
						secretWarning.x -= 470;
						// secretWarning.y += 10;
					case 12:
						secretWarning.visible = true;
						secretWarning.y -= 800;
						eventTweens.push(FlxTween.tween(secretWarning, {y: secretWarning.y + 800}, 1.5, {ease: FlxEase.quadOut}));
						add(secretWarning);
				}

			case 'Triggers Thalassophobia':
				var trigger:Float = Std.parseFloat(value1);
				if (Math.isNaN(trigger))
					trigger = 0;
				switch (trigger)
				{
					case 0:
						blackBarThingie.alpha = 0;
						if (ClientPrefs.flashing)
						{
							FlxG.camera.flash(FlxColor.WHITE, 1);
						}
						else
						{
							if (blackBarThingie.alpha != 0)
							FlxG.camera.flash(FlxColor.BLACK, 1);
						}
					
					case 1:
						blackBarThingie.alpha = 1;

					case 2:
						candrain = !candrain;

					case 3:
						//16
						FlxTween.tween(blackBarThingie, {alpha: 0}, 3);
						FOLLOWCHARS = false;
						eventTweens.push(FlxTween.tween(camFollowPos, {x: 1020, y: 750}, ((11 / (Conductor.bpm / 60))),
							{startDelay: ((1 / (Conductor.bpm / 60))), ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(camGame, {zoom: 0.7}, ((11 / (Conductor.bpm / 60))),
							{startDelay: ((1 / (Conductor.bpm / 60))), ease: FlxEase.quadInOut}));
						isCameraOnForcedPos = true;
					case 4:
						//32
						FOLLOWCHARS = true;
						eventTweens.push(FlxTween.tween(camGame, {zoom: 0.8}, 1, {ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.tween(this, {defaultCamZoom: 0.8}, 1, {ease: FlxEase.quadOut}));
					case 5:
						//96
						eventTweens.push(FlxTween.tween(iconP1, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(iconP2, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(customHB, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut}));
					case 6:
						//160
						lifemetter.y = !hasDownScroll ? 0 : 600;
						if(ClientPrefs.middleScroll) lifemetter.x = 1000;
						eventTweens.push(FlxTween.tween(lifemetter, {y: !hasDownScroll ? 50 : 550, alpha: 1}, 2, {ease: FlxEase.expoOut}));
					case 7:
						//432
						luigilife = 8;
					case 8:
						//454
						eventTweens.push(FlxTween.tween(eel, {x: 2000}, 10));

				}

			case 'Triggers Overdue':
				var trigger:Float = Std.parseFloat(value1);
				if (Math.isNaN(trigger))
					trigger = 0;
				switch (trigger)
				{
					case 0:
						var alphaNew:Float = Std.parseFloat(value2);
						if (Math.isNaN(alphaNew))
							alphaNew = 0.8;
						blackBarThingie.visible = true;
						eventTweens.push(FlxTween.tween(blackBarThingie, {alpha: alphaNew}, 1));
						if(alphaNew != 0){
						triggerEventNote('Screen Shake','2, 0.002','2.2, 0.002');
						}

					case 1:
						var poisonNew:Float = Std.parseFloat(value2);
						if (Math.isNaN(poisonNew))
							poisonNew = 0;
						if (poisonNew == 0.005)
							PauseSubState.muymalo = 2;
						poison = poisonNew;
						
					case 2:
						isCameraOnForcedPos = true;
						eventTweens.push(FlxTween.tween(camFollowPos, {x: -80, y: 450}, 1.64, {ease: FlxEase.expoInOut}));

					case 3:
						eventTweens.push(FlxTween.tween(camGame, {zoom: 0.75}, 0.4, {ease: FlxEase.cubeInOut}));
						meatForeGroup.visible = true;
						meatworldGroup.visible = true;
						meatForeGroup.forEach(function(meat:BGSprite)
							{
								if(meat.ID > 0) meat.alpha = 1;
								switch(meat.ID){
									case 1:
										eventTweens.push(FlxTween.tween(meat, {y: (-1350 + 1969 - 400) + (meat.height / 2)}, 0.3, {ease: FlxEase.cubeIn}));
									case 2:
										eventTweens.push(FlxTween.tween(meat, {y: -1350 + 411 - 400}, 0.3, {ease: FlxEase.cubeIn, onComplete: function(twn:FlxTween){
											FlxG.sound.play(Paths.sound('teethslam'), 0.5);
											
										}}));
								}
							});
					case 4:
						remove(streetGroup);
						remove(streetFore);

						streetGroup.destroy();
						streetFore.destroy();

						boyfriendGroup.setPosition(950, 200);
						dadGroup.setPosition(-250, 225);

						FOLLOWCHARS = true;
						ZOOMCHARS = true;
						BF_ZOOM = 0.45;
						DAD_ZOOM = 0.35;

						meatworldGroup.forEach(function(meat:BGSprite)
							{
								meat.alpha = 1;
							});

						meatForeGroup.forEach(function(meat:BGSprite)
							{
								meat.alpha = 1;
								switch(meat.ID){
									case 1:
										eventTweens.push(FlxTween.tween(meat, {y: (-1350 + 1969) + (meat.height / 2)}, 0.4, {ease: FlxEase.cubeInOut}));
										eventTweens.push(FlxTween.tween(meatfog, {alpha: 0.6}, 0.4, {ease: FlxEase.cubeInOut}));
									case 2:
										eventTweens.push(FlxTween.tween(meat, {y: -1350 + 411 - 1300}, 0.4, {ease: FlxEase.cubeIn, onComplete: function(twn:FlxTween){
											meat.visible = false;
										}}));
								}
							});
					
					case 5:
						add(iconGF);
						gfGroup.x = 900;
						BF_ZOOM = 0.5;
						DAD_ZOOM = 0.4;
						BF_CAM_X = 1000;
						BF_CAM_Y = 450;
						eventTweens.push(FlxTween.tween(gfGroup, {y: gfGroup.y + 40}, 2, {startDelay: 0.2, ease: FlxEase.quadInOut, type: PINGPONG}));
						eventTweens.push(FlxTween.tween(gfGroup, {x: gfGroup.x - 30}, 4, {startDelay: 0.2, ease: FlxEase.quadInOut, type: PINGPONG}));
						eventTweens.push(FlxTween.tween(camFollowPos, {x: BF_CAM_X, y: BF_CAM_Y}, 5, {ease: FlxEase.sineInOut}));
						eventTweens.push(FlxTween.tween(camGame, {zoom: BF_ZOOM}, 5, {ease: FlxEase.sineInOut}));
						eventTweens.push(FlxTween.tween(gfGroup, {alpha: 0.7}, 5));
						eventTweens.push(FlxTween.tween(iconGF, {alpha: 0.7}, 5));

					case 6:
						eventTweens.push(FlxTween.tween(castleFloor, {alpha: 1}, 10));
						eventTweens.push(FlxTween.tween(castleCeiling, {alpha: 1}, 10));
						castleFloor.x = -1000;
						castleCeiling.x = -1000;
						castleFloor.y = 1000 - 350;
						castleCeiling.y = -750 - 350;
						castleFloor.alpha = 1;
						castleCeiling.alpha = 1;

						castleFloor.animation.play('idle');
						castleCeiling.animation.play('idle');

						meatworldGroup.forEach(function(meat:BGSprite)
							{
								eventTweens.push(FlxTween.tween(meat, {alpha: 0}, 10));
							});
						meatForeGroup.forEach(function(meat:BGSprite)
							{
								eventTweens.push(FlxTween.tween(meat, {alpha: 0}, 10));
								eventTweens.push(FlxTween.tween(meatfog, {alpha: 0}, 10));
							});

					case 7:
						dadGroup.y = 150;
						eventTweens.push(FlxTween.tween(dadGroup, {x: -2350}, 0.8));
						gf.visible = false;

						hallTLL1.y = -850 - 350;
						hallTLL2.y = -600 - 350;
						hallTLL3.y = -350 - 350;
						fgTLL.y = -600 - 350;
						fgTLL.scrollFactor.set(1.4, 1.4);
						triggerEventNote('Change Character', '0', 'pico_run');
						triggerEventNote('Set Cam Pos', '1000, 500', 'bf');
						triggerEventNote('Set Cam Pos', '1000, 150', 'dad');
						triggerEventNote('Set Cam Zoom', '0.5', 'bf');
						triggerEventNote('Set Cam Zoom', '0.35', 'dad');
						triggerEventNote('fuckoff', '', '');
						boyfriendGroup.setPosition(BF_X - 150, BF_Y);

						hallTLL1.animation.play('idle');
						eventTweens.push(FlxTween.tween(hallTLL1, {alpha: 1}, 0.2));

						hallTLL2.animation.play('idle');
						eventTweens.push(FlxTween.tween(hallTLL2, {alpha: 1}, 0.2));

						hallTLL3.animation.play('idle');
						eventTweens.push(FlxTween.tween(hallTLL3, {alpha: 1}, 0.2));

						eventTweens.push(FlxTween.tween(fgTLL, {alpha: 1}, 1.5));

						castleFloor.animation.play('loop', true);
						castleCeiling.animation.play('loop', true);

						PauseSubState.muymalo = 3;

						flipchar = true;
						healthBar.flipX = true;
						healthBarBG.flipX = true;
						iconP1.flipX = true;
						overFuckYou = true;

					case 8:
						eventTweens.push(FlxTween.tween(hallTLL1, {alpha: 0}, 1.5));
						eventTweens.push(FlxTween.tween(hallTLL2, {alpha: 0}, 1.5));
						eventTweens.push(FlxTween.tween(hallTLL3, {alpha: 0}, 1.5));
						eventTweens.push(FlxTween.tween(fgTLL, {alpha: 0}, 1.5));
						eventTweens.push(FlxTween.tween(iconP2, {alpha: 0}, 1.5));
					case 9:
						camGame.alpha = 0;
						camHUD.alpha = 0;
					
						//:dave:
					case 10:
						//144
						eventTweens.push(FlxTween.tween(gunAmmo, {y: 450}, 3, {ease: FlxEase.expoOut}));
						eventTweens.push(FlxTween.tween(gunAmmo, {alpha: 0.2}, 3, {startDelay: 5, ease: FlxEase.quadInOut}));
					case 12:
						//545
						eventTweens.push(FlxTween.tween(boyfriendGroup, {x: boyfriendGroup.x + 200}, 6, {ease: FlxEase.quadInOut, type: PINGPONG}));
					case 13:
						eventTweens.push(FlxTween.tween(gunAmmo, {alpha: 0}, 0.5, {ease: FlxEase.quadOut}));
						eventTweens.push(FlxTween.tween(iconGF, {alpha: 0}, 0.5));
					case 14:
						//264
						BF_CAM_X = 675;
						BF_CAM_Y = 600;
						BF_ZOOM = 0.45;
						FOLLOWCHARS = false;
						ZOOMCHARS = false;
						eventTweens.push(FlxTween.tween(camFollowPos, {x: BF_CAM_X, y: BF_CAM_Y}, 1.1, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(camGame, {zoom: BF_ZOOM}, 0.7, {ease: FlxEase.quadInOut}));
						eventTweens.push(FlxTween.tween(this, {defaultCamZoom: BF_ZOOM}, 0.7, {ease: FlxEase.quadInOut}));
					case 15:
						//348
						DAD_ZOOM = BF_ZOOM = 0.25;
						DAD_CAM_X = 500;
						DAD_CAM_Y = 150;
						BF_CAM_X = 1000;
						BF_CAM_Y = 350;
					case 16:
						//414
						DAD_ZOOM = BF_ZOOM = 0.35;
						DAD_CAM_X = 300;
						DAD_CAM_Y = 300;
						BF_CAM_X = 900;
						BF_CAM_Y = 500;
				}

			case 'Write DS':
				var timer:Float = Std.parseFloat(value1);
				if (Math.isNaN(timer)) timer = 4; //NUMERO EN BEATS DE LA CANCION 
				if (value2 == '') value2 = 'sorry';

					var coords:Float = 535;
					if(!hasDownScroll) coords = 10;

					eventTweens.push(FlxTween.tween(backing, {y: coords}, 4 * (1 / (Conductor.bpm / 60)), {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
						{
							thetext.text = value2;
							thetext.visible = true;
							canvas.visible = true;
							writeText.visible = true;
							writeText.y = backing.y + 11;
							thetext.y = backing.y + 85 - thetext.pixels.rect.height / 2;
							thetextC.y = backing.y + 85 - thetext.pixels.rect.height / 2;
							if(value2 == 'criminal'){
								thetextC.visible = true;
								thetext.visible = false;
							}
							canvas.y = backing.y;
							dsTimer = ((timer * 0.9) * (1 / (Conductor.bpm / 60)));

						}}));

			case 'Add Subtitle':
				var newcolor:String = "";
				subTitle.text = value1;

				if (value2.startsWith('0xFF'))
				{ // uses hexadecimal value
					newcolor = value2;
				}
				else
					switch (value2)
					{ // uses default color
						case "Red":
							newcolor = "0xFFFF1F1F";
						case "Blue":
							newcolor = "0xFF1A4AE8";
						case "Yellow":
							newcolor = "0xFFFF1F1F";
						case "Green":
							newcolor = "0xFF198C0E";
						case "Purple":
							newcolor = "0xFF8B1AE8";
						case "Lime":
							newcolor = "0xFF2BE81A";
					}

				if (value2 != "")
				{
					subTitle.color = Std.parseInt(newcolor);
				}
				else
				{
					subTitle.color = FlxColor.WHITE;
				}

			case 'Show Song':
				var triggerMR:Float = Std.parseFloat(value1);
				if (Math.isNaN(triggerMR))
					triggerMR = 0;
				switch (triggerMR)
				{
					case 0:
						if (curStage == 'somari')
						{
							titleNES.visible = true;
							titleNES.animation.play("show");
						}
						else if (curStage == 'endstage')
						{
							linefount.visible = true;
						}
						else if (curStage == 'piracy'){
							add(djStart);
							eventTweens.push(FlxTween.tween(djStart, {x: 110}, 1, {ease: FlxEase.backOut, onComplete: function(twn:FlxTween)
								{
									eventTweens.push(FlxTween.tween(djStart, {x: -300}, 1, {startDelay: 1, ease: FlxEase.backIn}));
								}}));
						}
						else
						{
							titleText.visible = true;
							autorText.visible = true;
							line1.visible = true;
							line2.visible = true;
							titleText.y = 304.5;
							autorText.y = titleText.y + 70;
							line2.y 	= titleText.y + 57;
							line1.y 	= line2.y - 2;
							autorText.screenCenter(X);
							titleText.screenCenter(X);
							eventTweens.push(FlxTween.tween(titleText, {alpha: 1, y: titleText.y + 30}, 0.5, {ease: FlxEase.cubeOut}));
							eventTweens.push(FlxTween.tween(autorText, {alpha: 1, y: autorText.y + 30}, 0.5, {ease: FlxEase.cubeOut}));
							eventTweens.push(FlxTween.tween(line1, {alpha: 1, y: 	 line1.y 	 + 30}, 0.5, {ease: FlxEase.cubeOut}));
							eventTweens.push(FlxTween.tween(line2, {alpha: 1, y: 	 line2.y 	 + 30}, 0.5, {ease: FlxEase.cubeOut}));
						}
						if(isWarp){
							Lib.application.window.title = "Friday Night Funkin': Mario's Madness | " + titleText.text + ' | ' + autorText.text;
						}

						if(PlayState.SONG.song == 'All-Stars'){
							newName = titleText.text;
							Lib.application.window.title = "Friday Night Funkin': Mario's Madness | " + titleText.text + ' | ' + autorText.text;
							autor = autorText.text;

							#if desktop
							// Updating Discord Rich Presence (with Time Left)
							DiscordClient.changePresence(detailsText, newName + legacycheck, discName.toLowerCase(), iconP2.getCharacter().toLowerCase(), true, songLength);
							#end
						}

						if(PlayState.SONG.song == 'Unbeatable'){
							newName = titleText.text;
							Lib.application.window.title = "Friday Night Funkin': Mario's Madness | Unbeatable | RedTV53 ft. theWAHbox, scrumbo_, FriedFrick & Ironik";
							autor = autorText.text;
							titleText.cameras = [camOther];
							autorText.cameras = [camOther];
							line1.cameras = [camOther];
							line2.cameras = [camOther];

							#if desktop
							// Updating Discord Rich Presence (with Time Left)
							DiscordClient.changePresence(detailsText, newName + legacycheck, discName.toLowerCase(), iconP2.getCharacter().toLowerCase(), true, songLength);
							#end
						}

					case 1:
						if (curStage == 'somari')
						{
							titleNES.animation.play("hide");
						}
						else if (curStage == 'endstage')
						{
							linefount.visible = false;
						}
						else
						{
							eventTweens.push(FlxTween.tween(titleText, {alpha: 0}, 0.5, {ease: FlxEase.cubeOut}));
							eventTweens.push(FlxTween.tween(autorText, {alpha: 0}, 0.5, {ease: FlxEase.cubeOut}));
							eventTweens.push(FlxTween.tween(line1, {alpha: 0}, 0.5, {ease: FlxEase.cubeOut}));
							eventTweens.push(FlxTween.tween(line2, {alpha: 0}, 0.5, {ease: FlxEase.cubeOut}));

							eventTimers.push(new FlxTimer().start(0.5, function(tmr:FlxTimer)
								{
									titleText.visible = false;
									autorText.visible = false;
									line1.visible = false;
									line2.visible = false;
								}));
						}
				}

				case 'Set Cam Zoom':
					switch(value2){
						case 'bf' | 'boyfriend':
							BF_ZOOM = Std.parseFloat(value1);
						case 'gf' | 'girlfriend':
							GF_ZOOM = Std.parseFloat(value1);
						case 'dad' | 'opponent':
							DAD_ZOOM = Std.parseFloat(value1);
						default:
							BF_ZOOM = Std.parseFloat(value1);
							GF_ZOOM = Std.parseFloat(value1);
							DAD_ZOOM = Std.parseFloat(value1);
							defaultCamZoom = Std.parseFloat(value1);
					}
				case 'Set Cam Pos':
					var split:Array<String> = value1.split(',');
					var xPos:Float = Std.parseFloat(split[0].trim());
					var yPos:Float = Std.parseFloat(split[1].trim());
					if (Math.isNaN(xPos))
						xPos = 0;
					if (Math.isNaN(yPos))
						yPos = 0;
					switch(value2){
						case 'bf' | 'boyfriend':
							BF_CAM_X = xPos;
							BF_CAM_Y = yPos;
						case 'gf' | 'girlfriend':
							GF_CAM_X = xPos;
							GF_CAM_Y = yPos;
						case 'dad' | 'opponent':
							DAD_CAM_X = xPos;
							DAD_CAM_Y = yPos;
					}
		}

		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function snapCamFollowToPos(x:Float, y:Float)
	{
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	function finishSong():Void
	{
		var finishCallback:Void->Void = endSong; // In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		instALT.volume = 0;
		instALT.pause();
		if (ClientPrefs.noteOffset <= 0)
		{
			finishCallback();
		}
		else
		{
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer)
			{
				finishCallback();
			});
		}
	}

	var transitioning = false;

	public function endSong():Void
	{
		// Should kill you if you tried to cheat
		if (!startingSong)
		{
			notes.forEach(function(daNote:Note)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.0475;
				}
			});
			for (daNote in unspawnNotes)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.0475;
				}
			}

			if (doDeathCheck())
			{
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		if (curStage == 'hatebg' || curStage == 'forest')
		{
			worldText.visible = false;
		}
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;
		virtualmode = false;

		#if ACHIEVEMENTS_ALLOWED
		if (achievementObj != null)
		{
			return;
		}
		else
		{
			var achieve:Int = checkForAchievement([1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 13, 14, 15]);
			if (achieve > -1)
			{
				startAchievement(achieve);
				return;
			}
		}
		#end

		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if (ret != FunkinLua.Function_Stop && !transitioning)
		{
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if (Math.isNaN(percent))
					percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}

			if (curStage == 'piracy' || curStage == 'somari'){
				if (ClientPrefs.showFPS)
					Main.fpsVar.visible = true;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					// FlxG.sound.playMusic(Paths.music('freakyMenu'));
					if(SONG.song.toLowerCase() == 'starman-slaughter' || SONG.song.toLowerCase() == 'starman slaughter'){
						var blackthing = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
						blackthing.setGraphicSize(Std.int(blackthing.width * 10));
						blackthing.alpha = 0;
						blackthing.cameras = [camHUD];
						add(blackthing);

						FlxTween.tween(blackthing, {alpha: 1}, 1, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								if(!ClientPrefs.storySave[0]){
									isWarp = true;
									WarpState.startCut = true;
								} 
								ClientPrefs.storySave[0] = true;
								ClientPrefs.saveSettings();
								startVideo('post_ss_cutscene');
								
							}
						});
					}
					else
						MusicBeatState.switchState(new WarpState());
					// if ()
					if (!usedPractice)
					{

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}
						FlxG.save.flush();
					}
					usedPractice = false;
					changedDifficulty = false;
					cpuControlled = false;
				}
				else
				{
					var difficulty:String = '' + CoolUtil.difficultyStuff[storyDifficulty][1];

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					if (curStage == 'execlassic')
					{
						var blackthing = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
						blackthing.setGraphicSize(Std.int(blackthing.width * 10));
						blackthing.alpha = 0;
						blackthing.cameras = [camHUD];
						add(blackthing);

						FlxTween.tween(blackthing, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					PauseSubState.tengo = Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty;
					FlxG.sound.music.stop();

					if (curStage == 'execlassic')
					{
						new FlxTimer().start(1.5, function(tmr:FlxTimer)
						{
							cancelFadeTween();
							// resetSpriteCache = true;
							LoadingState.loadAndSwitchState(new PlayState());
						});
					}
					else
					{
						cancelFadeTween();
						// resetSpriteCache = true;
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else if (isWarp)
			{
				var blackthing = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				blackthing.setGraphicSize(Std.int(blackthing.width * 10));
				blackthing.alpha = 0;
				blackthing.cameras = [camHUD];
				add(blackthing);

				switch(SONG.song){
					case 'Thalassophobia':
						if(ClientPrefs.worldsALT[1] == 0){
							ClientPrefs.worldsALT[1] = 1;
							}else if(ClientPrefs.worldsALT[1] == 2 && ClientPrefs.worlds[(WarpState.curSelected - 1)] < 4){
								ClientPrefs.worlds[(WarpState.curSelected - 1)] = 4;
								WarpState.unlockpath = true;
							}


				case 'I Hate You':
					if(ClientPrefs.worldsALT[1] == 0){
						ClientPrefs.worldsALT[1] = 2;
					}else if(ClientPrefs.worldsALT[1] == 1 && ClientPrefs.worlds[(WarpState.curSelected - 1)] < 4){
						ClientPrefs.worlds[(WarpState.curSelected - 1)] = 4;
						WarpState.unlockpath = true;
					}
				case 'Powerdown':
					if(ClientPrefs.worlds[3] == 4){
						ClientPrefs.worlds[3] = 5;
						WarpState.unlockpath = true;
					}
				case 'Demise':
					if(ClientPrefs.worlds[3] == 5){
						ClientPrefs.worlds[3] = 6;
					}
				case 'Overdue':
					if(ClientPrefs.worldsALT[3] == 0){
						ClientPrefs.worldsALT[3] = 1;
					}else if(ClientPrefs.worldsALT[3] == 2){
						ClientPrefs.worldsALT[3] = 3;
						ClientPrefs.worlds[3] = 4;
						WarpState.unlockpath = true;
					}
					WarpState.isPico = true;
					ClientPrefs.saveSettings();
				case 'No Party':
					if(ClientPrefs.worldsALT[3] == 0){
						ClientPrefs.worldsALT[3] = 2;
					}else if(ClientPrefs.worldsALT[3] == 1){
						ClientPrefs.worldsALT[3] = 3;
						ClientPrefs.worlds[3] = 4;
						WarpState.unlockpath = true;
					}
				case 'The End':
				if(ClientPrefs.worlds[4] == 2){
					WarpState.pipeCut = true;
					ClientPrefs.worlds[4] = 3; 
				}
				case 'Unbeatable':
					ClientPrefs.storySave[8] = true;
				default:
					if(WarpState.worldSelected == (ClientPrefs.worlds[(WarpState.curSelected - 1)] + 1)){
						ClientPrefs.worlds[(WarpState.curSelected - 1)] += 1;
						ClientPrefs.saveSettings();
						WarpState.unlockpath = true;
					}else{
						trace("tiene valor " + WarpState.worldSelected + " que no es igual a " + (ClientPrefs.worlds[(WarpState.curSelected - 1)] + 1));
					}
					
				}
				ClientPrefs.saveSettings();

				if (ClientPrefs.iHYPass && ClientPrefs.mXPass && ClientPrefs.warioPass && ClientPrefs.betaPass && !ClientPrefs.finish1)
				{
					FlxTween.tween(blackthing, {alpha: 1}, 1, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							startVideo('continue');
							ClientPrefs.finish1 = true;
							isWarp = false;
						}
					});
				}
				else
				{
					if(SONG.song == 'All-Stars'){
						CreditsState.autoscroll = true;
						ClientPrefs.storySave[7] = true;
						isWarp = false;
						ClientPrefs.saveSettings();
						MusicBeatState.switchState(new CreditsState());
					}else{
					cancelFadeTween();
					CustomFadeTransition.nextCamera = camOther;
					if (FlxTransitionableState.skipNextTransIn)
					{
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new WarpState());
					}
				}
				usedPractice = false;
				changedDifficulty = false;
				cpuControlled = false;
			}
			else
			{
				FlxG.sound.music.stop();
				if (curSong == 'Racetraitors')
				{
					ClientPrefs.carPass = true;
					ClientPrefs.saveSettings();
				}
				trace('WENT BACK TO FREEPLAY??');
				cancelFadeTween();
				CustomFadeTransition.nextCamera = camOther;
				if (FlxTransitionableState.skipNextTransIn)
				{
					CustomFadeTransition.nextCamera = null;
				}
					MusicBeatState.switchState(new MainMenuState());
				usedPractice = false;
				changedDifficulty = false;
				cpuControlled = false;
			}
			for (tween in eventTweens)
				{
					tween.cancel();
				}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;

	function startAchievement(achieve:Int)
	{
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}

	function achievementEnd():Void
	{
		achievementObj = null;
		if (endingSong && !inCutscene)
		{
			endSong();
		}
	}
	#end

	public function KillNotes()
	{
		while (notes.length > 0)
		{
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + 8);

		// boyfriend.playAnim('hey');
		vocals.volume = vocalvol;


		var placement:String = Std.string(combo);

		var xchangetext:Float = 0;

		if (PlayState.SONG.song == 'Oh God No')
		{
			xchangetext = -130;
		}

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = (FlxG.width * 0.55) + xchangetext;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.5)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.25)
		{
			daRating = 'good';
			score = 200;
		}

		if(curStage == 'somari'){
			switch(daRating){
				case 'shit':
					score += 50;
				case 'bad':
					score += 10;
				case 'good':
					score += 200;
				case 'sick':
					score += 450;
			}
		}

		if(note.noteType != 'Bullet Bill' && note.noteType != 'Bullet2'){
			if (daRating == 'sick' && !note.noteSplashDisabled)
				{
					spawnNoteSplashOnNote(note);
				}					
		}else{
			bulletCounter += 1;
			if(note.noteType == 'Bullet Bill')
				bulletSub = note;
			if(bulletCounter >= 2){
				bulletCounter = 0;
				spawnNoteSplashOnNote(bulletSub);
				FlxG.sound.play(Paths.sound('SHbullethit'), 0.6);
			}
			new FlxTimer().start(0.15, function(tmr:FlxTimer)
				{
					bulletCounter = 0;
				});
			//FlxG.sound.play(Paths.sound("Boom - says the heavy"));
		}

		if (!practiceMode && !cpuControlled)
		{
			songScore += score;
			songHits++;
			RecalculateRating();
			if (scoreTxtTween != null)
			{
				scoreTxtTween.cancel();
			}
			if (curStage != 'somari' && curStage != 'endstage' && curStage != 'piracy' && (curStage != 'warioworld' || PlayState.SONG.song == 'Apparition Old'))
			{
				scoreTxt.scale.x = 1.1;
				scoreTxt.scale.y = 1.1;
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						scoreTxtTween = null;
					}
				});
			}
			else
			{
				if (songScore >= 1999999)
				{
					songScore = 1999999; // this is like the shitties way to do this idk
				}
			}
		}

		/* if (combo > 60)
			daRating = 'sick';
		else if (combo > 12)
			daRating = 'good'
		else if (combo > 4)
			daRating = 'bad';
	 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage == 'landstage')
		{
			pixelShitPart1 = 'gb';
			// pixelShitPart2 = '-pixel';
		}

		if (curStage == "somari")
		{
			rating.loadGraphic(Paths.image('pixelUI/judgements'));
			rating.width = rating.width / 2;
			rating.height = rating.height / 6;
			rating.loadGraphic(Paths.image('pixelUI/judgements'), true, Math.floor(rating.width), Math.floor(rating.height));
			rating.antialiasing = false;
			if (!goodlol)
			{
				rating.animation.add("sick", [0]);
			}
			else
			{
				rating.animation.add("sick", [2]);
			}
			rating.animation.add("good", [4]);
			rating.animation.add("bad", [6]);
			rating.animation.add("shit", [8]);
			rating.screenCenter();
			rating.animation.play(daRating);
			rating.visible = !ClientPrefs.hideHud;
			rating.x = 878;
			rating.y = 506;
			if (daRating != 'sick' || songMisses != 0)
			{
				goodlol = true;
			}
		}
		else if (curStage == 'endstage' || (curStage == 'warioworld' && (PlayState.SONG.song != 'Apparition Old' && PlayState.SONG.song != 'Forbidden Star')))
		{
			rating.visible = false;
			for (timer in ratingTimers)
			{
				timer.cancel();
			}
			ratingTxt.text = daRating.toUpperCase() + '\n' + combo;

			ratingTimers.push(new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				ratingTxt.text = "";
			}));
		}
		else
		{
			rating.loadGraphic(Paths.image('rating/' + pixelShitPart1 + daRating + pixelShitPart2));
			rating.screenCenter();
			rating.x = coolText.x - 40;
			rating.y -= 60;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			rating.visible = !ClientPrefs.hideHud;
		}

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('rating/' + pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.visible = !ClientPrefs.hideHud;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (curStage == "somari")
		{
			rating.scale.set(4, 4);
			rating.antialiasing = false;
			comboSpr.visible = false;
		}
		else if (curStage == "endstage" || (curStage == 'warioworld' && (PlayState.SONG.song != 'Apparition Old' && PlayState.SONG.song != 'Forbidden Star')))
		{
			comboSpr.visible = false;
		}
		else if (curStage == "piracy")
			{
				rating.scale.set(0.3, 0.3);
				rating.y += 160;
			}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if (combo >= 1000)
		{
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('numbers/' + pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				numScore.x += 150;
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.hideHud;

			if (curStage == 'somari' || curStage == 'endstage' || (curStage == 'warioworld' && (PlayState.SONG.song != 'Apparition Old' && PlayState.SONG.song != 'Forbidden Star')) || curStage == "piracy")
			{
				numScore.visible = false;
			}
			if (curStage == 'virtual')
			{
				numScore.color = 0xFFFF0000;
			}

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		/* 
		trace(combo);
		trace(seperatedScore);
	 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		if (curStage == "somari")
		{
			FlxTween.tween(rating, {y: rating.y - 20}, 0.2);
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				rating.alpha = 0;
			});
		}
		if (curStage == 'virtual')
		{
			comboSpr.color = 0xFFFF0000;
			rating.color = 0xFFFF0000;
		}
		else
		{
			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001
			});
		}

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;

		var upP = controls.NOTE_UP_P;
		var rightP = controls.NOTE_RIGHT_P;
		var downP = controls.NOTE_DOWN_P;
		var leftP = controls.NOTE_LEFT_P;

		var upR = controls.NOTE_UP_R;
		var rightR = controls.NOTE_RIGHT_R;
		var downR = controls.NOTE_DOWN_R;
		var leftR = controls.NOTE_LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
		var controlReleaseArray:Array<Bool> = [leftR, downR, upR, rightR];
		var controlHoldArray:Array<Bool> = [left, down, up, right];

		// FlxG.watch.addQuick('asdfa', upP);
		if (!boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					goodNoteHit(daNote);
				}
			});

			if ((controlHoldArray.contains(true) || controlArray.contains(true)) && !endingSong)
			{
				var canMiss:Bool = !ClientPrefs.ghostTapping;
				if (controlArray.contains(true))
				{
					for (i in 0...controlArray.length)
					{
						// heavily based on my own code LOL if it aint broke dont fix it
						var pressNotes:Array<Note> = [];
						var notesDatas:Array<Int> = [];
						var notesStopped:Bool = false;

						var sortedNotesList:Array<Note> = [];
						notes.forEachAlive(function(daNote:Note)
						{
							if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.noteData == i)
							{
								sortedNotesList.push(daNote);
								notesDatas.push(daNote.noteData);
								canMiss = true;
							}
						});
						sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

						if (sortedNotesList.length > 0)
						{
							for (epicNote in sortedNotesList)
							{
								for (doubleNote in pressNotes)
								{
									if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 10)
									{
										doubleNote.kill();
										notes.remove(doubleNote, true);
										doubleNote.destroy();
									}
									else
										notesStopped = true;
								}

								// eee jack detection before was not super good
								if (controlArray[epicNote.noteData] && !notesStopped)
								{
									goodNoteHit(epicNote);
									pressNotes.push(epicNote);
								}
							}
						}
						else if (canMiss)
							ghostMiss(controlArray[i], i, true);
						
						if (!keysPressed[i] && controlArray[i])
							keysPressed[i] = true;
					}
				}

				#if ACHIEVEMENTS_ALLOWED
				var achieve:Int = checkForAchievement([11]);
				if (achieve > -1)
				{
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss')
				&& boyfriend.animation.curAnim.name != 'death')
				boyfriend.dance();
		}

		playerStrums.forEach(function(spr:StrumNote)
		{
			if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			if (controlReleaseArray[spr.ID])
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
		});
	}

	function ghostMiss(statement:Bool = false, direction:Int = 0, ?ghostMiss:Bool = false)
	{
		if (statement)
		{
			noteMissPress(direction, ghostMiss);
			callOnLuas('noteMissPress', [direction]);
		}
	}

	function noteMiss(daNote:Note):Void
	{ 	// You didn't hit the key and let it go offscreen, also used by Hurt Notes
		// Dupe note remove
		notes.forEachAlive(function(note:Note)
		{
			if (daNote != note
				&& daNote.mustPress
				&& daNote.noteData == note.noteData
				&& daNote.isSustainNote == note.isSustainNote
				&& Math.abs(daNote.strumTime - note.strumTime) < 10)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});

		songMisses++;
		if(nomiss){
			health = 0;
		}
		if(!nodamage){
		
		if(curStage != 'somari'){
			health -= daNote.missHealth; // For testing purposes
		}
		// trace(daNote.missHealth);
		vocals.volume = 0;
		RecalculateRating();

		var animToPlay:String = '';
		switch (Math.abs(daNote.noteData) % 4)
		{
			case 0:
				animToPlay = 'singLEFTmiss';
			case 1:
				animToPlay = 'singDOWNmiss';
			case 2:
				animToPlay = 'singUPmiss';
			case 3:
				animToPlay = 'singRIGHTmiss';
		}

		if (curStage == 'forest' || curStage == 'hatebg' && PlayState.SONG.song != 'I Hate You Old' && PlayState.SONG.song != 'Oh God No')
		{
			capenose.animation.play('miss');
		}

		if (curStage == 'exesequel' || curStage == 'betamansion' || curStage == 'nesbeat'){
			starmanGF.animation.play('sad');
		}

		if (curStage == 'somari'){
			if(ring == 0){
				health = 0;
			}
			else{
				FlxFlicker.flicker(boyfriendGroup, 3, 0.2, true);
				FlxG.sound.play(Paths.sound('ringloss'));
				eventTimers.push(new FlxTimer().start(0.5, function(tmr:FlxTimer){
					boyfriend.dance();
				}));
			}
			if (gf.curCharacter == 'eeveefriend')
				{
					gf.playAnim('sad' + FlxG.random.int(1, 4));
				}
			if(ring > 5){
				ring = Std.int(ring / 2);
			}else{
				ring = 0;
			}
			boyfriend.playAnim('hit', true);
			nodamage = true;

			eventTimers.push(new FlxTimer().start(3, function(tmr:FlxTimer){
				nodamage = false;
			}));
		}

		if(curStage != 'secretbg')
			GFSINGBF = false;
		
		if (daNote.noteType == 'GF Sing')
		{
			gf.playAnim(animToPlay, true);
			GFSINGBF = true;
			if (gf.curCharacter == 'luigi-ldo')
			{
				iconP1.changeIcon(gf.healthIcon);
				reloadHealthBarColors();
			}
		}
		if (daNote.noteType == 'GF Duet')
			{
				gf.playAnim(animToPlay, true);
				boyfriend.playAnim(animToPlay, true);
				GFSINGBF = false;
			}
		else
		{
			var daAlt = '';
			if (daNote.noteType == 'Alt Animation')
				daAlt = '-alt';
			if(curStage != 'somari'){
			boyfriend.playAnim(animToPlay + daAlt, true);
			}
			if (gf.curCharacter == 'luigi-ldo')
			{
				iconP1.changeIcon(boyfriend.healthIcon);
				reloadHealthBarColors();
			}
			if (daNote.noteType == 'Bad Poison')
			{
				FlxG.sound.play(Paths.sound('bad-day/smw_scroll'), 0.8);
				eventTweens.push(FlxTween.tween(badPoisonVG, {alpha: badPoisonVG.alpha + 0.15}, 0.1, {ease: FlxEase.quadOut}));
			}
			if (daNote.noteType == 'Bullet')
			{
				//trace("youre bad");
				ammo -= 1;
				FlxG.sound.play(Paths.sound('FAILGUN'));

				gunAmmo.animation.play('Bullet ' + ammo);

				for (tween in windowTween)
					{
						tween.cancel();
					} //running out of tween arrays srry
					  //como me dijo vampymatsu una vez = "RECICLA"
				windowTween.push(FlxTween.tween(gunAmmo, {alpha: 0.2}, 3, {startDelay: 5, ease: FlxEase.quadInOut}));
				eventTweens.push(FlxTween.color(gunAmmo, 0.5, FlxColor.BLACK, FlxColor.WHITE));

				if (ammo < 0)
				{
					health = 0;
				}
			}
			if(daNote.noteType == "Bullet Bill" || daNote.noteType == "Bullet2"){
				bulletTimer = 1;
			}
		}
		}

		callOnLuas('noteMiss', [
			notes.members.indexOf(daNote),
			daNote.noteData,
			daNote.noteType,
			daNote.isSustainNote
		]);
	}

	function noteMissPress(direction:Int = 1, ?ghostMiss:Bool = false):Void // You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			if(!nodamage){
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				if (gf.curCharacter == 'eeveefriend')
				{
					gf.playAnim('sad' + FlxG.random.int(1, 4));
				}
				else{
					if (curStage == 'exesequel' || curStage == 'betamansion' || curStage == 'nesbeat'){
						starmanGF.animation.play('sad');
					}
				}
			}
			combo = 0;

			if (!practiceMode)
				songScore -= 10;
			if (!endingSong)
			{
				if (ghostMiss)
					ghostMisses++;
				songMisses++;
				if(nomiss){
					health = 0;
				}
			}
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
		});*/

			if (!GFSINGBF || curStage == 'secretbg'){
				switch (direction)
				{
					case 0:
						boyfriend.playAnim('singLEFTmiss', true);
					case 1:
						boyfriend.playAnim('singDOWNmiss', true);
					case 2:
						boyfriend.playAnim('singUPmiss', true);
					case 3:
						boyfriend.playAnim('singRIGHTmiss', true);
				}
			}
			else
			{
				switch (direction)
				{
					case 0:
						gf.playAnim('singLEFTmiss', true);
					case 1:
						gf.playAnim('singDOWNmiss', true);
					case 2:
						gf.playAnim('singUPmiss', true);
					case 3:
						gf.playAnim('singRIGHTmiss', true);
				}
			}
			vocals.volume = 0;
			if (curStage == 'hatebg' && PlayState.SONG.song != 'I Hate You Old' && PlayState.SONG.song != 'Oh God No')
			{
				capenose.animation.play('miss');
			}
			if (curStage == 'forest')
			{
				capenose.animation.play('miss');
			}
			if (curStage == 'somari'){
				if(ring == 0){
					health = 0;
				}
				else{
					FlxFlicker.flicker(boyfriendGroup, 3, 0.2, true);
					FlxG.sound.play(Paths.sound('ringloss'));
					eventTimers.push(new FlxTimer().start(0.5, function(tmr:FlxTimer){
						boyfriend.dance();
					}));
				}
				ring = 0;

				if (gf.curCharacter == 'eeveefriend')
					{
						gf.playAnim('sad' + FlxG.random.int(1, 4));
					}
				boyfriend.playAnim('hit', true);
				nodamage = true;
				eventTimers.push(new FlxTimer().start(3, function(tmr:FlxTimer){
					nodamage = false;
				}));
			}
			}
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (curStage == 'hatebg' && PlayState.SONG.song != 'I Hate You Old' && PlayState.SONG.song != 'Oh God No')
		{
			capenose.animation.play('idle');
		}

		if (curStage == 'forest')
		{
			capenose.animation.play('idle');
		}

		if (!note.wasGoodHit)
		{
			if (cpuControlled && (note.ignoreNote || note.hitCausesMiss))
				return;

			if (note.hitCausesMiss)
			{
				noteMiss(note);
				if (!note.noteSplashDisabled && !note.isSustainNote)
				{
					spawnNoteSplashOnNote(note);
				}

				switch (note.noteType)
				{
					case 'Hurt Note': // Hurt note
						if (boyfriend.animation.getByName('hurt') != null)
						{
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}

				if (note.noteType == 'Nota veneno')
				{
					healthDrain += 0.0020;
					timerDrain = 2;
				}

				if (note.noteType == 'jumpscareM')
					{
						FlxG.sound.play(Paths.sound('CAUSA'));
						for (tween in extraTween)
							{
								tween.cancel();
							}
						if (ClientPrefs.flashing){
							camEst.shake(0.02, 1);
							camGame.shake(0.01, 1);
							camHUD.shake(0.01, 1);
						}

						blackBarThingie.alpha = 1;
						susto.alpha = 1;
						estatica.alpha = 0.2;
						susto.scale.set(1, 1);
						extraTween.push(FlxTween.tween(blackBarThingie, {alpha: 0}, 0.6, {startDelay: 0.2}));
						extraTween.push(FlxTween.tween(susto, {alpha: 0}, 0.6, {startDelay: 0.2}));
						extraTween.push(FlxTween.tween(estatica, {alpha: 0}, 0.6, {startDelay: 0.2}));
						extraTween.push(FlxTween.tween(susto.scale, {x: 1.2, y: 1.2}, 0.2, {ease:FlxEase.expoOut}));
					}

				if (note.noteType == 'Nota bomba')
				{
					health -= 1;
				}
				if(note.noteType == 'Bullet Bill'){
					// if(note.prevNote.noteType != 'Bullet2'){
					// 	health -= 1;
					// } else if (note.prevNote.noteType == 'Bullet2' && !note.prevNote.wasGoodHit){
					// 	health -= 1;
					// }
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				popUpScore(note);
				combo += 1;
				if (combo > 9999)
					combo = 9999;
			}
			health += note.hitHealth;

			if(curStage != 'secretbg')
				GFSINGBF = false;

			if (note.noteType == 'Water Note')
				{
					eventTweens.push(FlxTween.tween(flood, {y: flood.y + 60}, 0.35, {ease: FlxEase.quadInOut}));
					FlxG.sound.play(Paths.sound('waterswitch'), vocalvol);
				}
				
			if (!note.noAnimation)
			{
				var daAlt = '';
				if (note.noteType == 'Alt Animation')
					daAlt = '-alt';

				var animToPlay:String = '';
				if (!boyfriend.specialAnim && note.noteType != 'Bullet')
				{
					if (curStage != 'directstream')
					{
						switch (Std.int(Math.abs(note.noteData)))
						{
							case 0:
								animToPlay = 'singLEFT';
							case 1:
								animToPlay = 'singDOWN';
							case 2:
								animToPlay = 'singUP';
							case 3:
								animToPlay = 'singRIGHT';
						}
						if (curStage == 'superbad'){
							badGrad2.alpha = ((ClientPrefs.flashing ? 0.4 : 0.2));
							switch (Std.int(Math.abs(note.noteData)))
							{
								case 0:
									badGrad2.color = FlxColor.MAGENTA;
								case 1:
									badGrad2.color = FlxColor.CYAN;
								case 2:
									badGrad2.color = FlxColor.LIME;
								case 3:
									badGrad2.color = FlxColor.RED;
							}
						}
					}
					else
					{
						switch (Std.int(Math.abs(note.noteData)))
						{
							case 0:
								animToPlay = 'singLEFT';
								camBG.animation.play('left');
							case 1:
								animToPlay = 'singDOWN';
								camBG.animation.play('down');
							case 2:
								animToPlay = 'singUP';
								camBG.animation.play('up');
							case 3:
								animToPlay = 'singRIGHT';
								camBG.animation.play('right');
						}
					}
				}

				if (note.noteType == 'GF Sing')
				{
					gf.playAnim(animToPlay + daAlt, true);
					gf.holdTimer = 0;
					GFSINGBF = true;
					if (gf.curCharacter == 'luigi-ldo')
					{
						iconP1.changeIcon(gf.healthIcon);
						reloadHealthBarColors();
					}
				}
				else if (note.noteType == 'GF Duet')
				{
					boyfriend.playAnim(animToPlay + daAlt, true);
					boyfriend.holdTimer = 0;
					gf.playAnim(animToPlay + daAlt, true);
					gf.holdTimer = 0;
				}
				else
				{
					boyfriend.playAnim(animToPlay + daAlt, true);
					boyfriend.holdTimer = 0;
					if (gf.curCharacter == 'luigi-ldo')
					{
						iconP1.changeIcon(boyfriend.healthIcon);
						reloadHealthBarColors();
					}
				}

				if (note.noteType == 'Bullet')
				{
					triggerEventNote('Pico Shoot', '', '');
				}

				if (note.noteType == 'Hey!')
				{
					if (boyfriend.animOffsets.exists('hey'))
					{
						boyfriend.playAnim('hey', true);
						if (curStage != 'nesbeat'){
							boyfriend.specialAnim = true;
							boyfriend.heyTimer = 0.6;
						}
					}

					if (curStage != 'nesbeat'){
						if (gf.animOffsets.exists('cheer'))
						{
							gf.playAnim('cheer', true);
							gf.specialAnim = true;
							gf.heyTimer = 0.6;
						}
					}
					else{
						starmanGF.animation.play('hey', true);
					}
				}

				if (note.noteType == 'Coin Note')
				{
					if (luigilife >= 8)
					{
						luigilife = 8;
					}
					else
					{
						luigilife++;
					}
					for (tween in extraTween)
						{
							tween.cancel();
						}
					extraTween.push(FlxTween.tween(dad, {y: (enemyY + 250) - (luigilife * 50)}, 0.5, {ease: FlxEase.quadOut}));
					FlxG.sound.play(Paths.sound('refill'));
				}

				if (note.noteType == 'Ring Note')
				{
					ring++;
					FlxG.sound.play(Paths.sound('ringhit'));
				}
			}

			if (cpuControlled)
			{
				var time:Float = 0.15;
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			}
			else
			{
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
						if(SONG.notes[Math.floor(curStep / 16)].mustHitSection)
							strumCameraRoll(spr.ID);
					}
				});
			}
			note.wasGoodHit = true;
			vocals.volume = vocalvol;

			var isSus:Bool = note.isSustainNote; // GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note)
	{
		if (ClientPrefs.noteSplashes && note != null)
		{
			var strum:StrumNote = playerStrums.members[note.noteData];
			if (strum != null)
			{
				if (curStage == 'somari')
				{
					spawnNoteSplash(strum.x + 155, strum.y + 170, note.noteData, note);
				}
				else
				{
					spawnNoteSplash(strum.x, strum.y, note.noteData, note);
				}
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null)
	{
		var skin:String = 'noteSplashes';
		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
			skin = PlayState.SONG.splashSkin;

		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if (note != null)
		{
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	public static function onWinClose()
	{
		trace('BUT UN C PAPU MISTERIOSO CIERRA EL JUEGO');

		if (ClientPrefs.noVirtual && curStage == 'virtual')
		{
			CppAPI.restoreWindows();
			CppAPI.setWallpaper('old');
		}
	}

	private var preventLuaRemove:Bool = false;

	override function destroy()
	{
		preventLuaRemove = true;
		for (i in 0...luaArray.length)
		{
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];
		super.destroy();
			if (Lib.application.window.width == 800 && Lib.application.window.height == 600)
			{
				Lib.application.window.move(Lib.application.window.x - 240, Lib.application.window.y - 60);
				Lib.application.window.resize(1280, 720);
			}
			else if (PlayState.curStage == 'piracy')
			{
				Lib.application.window.resize(1280, 720);
				Lib.application.window.move(PlayState.ogwinX, PlayState.ogwinY);
			}
			if (PlayState.curStage == 'somari')
			{
				Lib.application.window.resize(1280, 720);
				Lib.application.window.resizable = true;
				Lib.application.window.fullscreen = false;
				Lib.application.window.maximized = false;
			}
			if (PlayState.curStage == 'virtual')
			{
				Lib.application.window.resizable = true;
				Lib.application.window.maximized = false;
				Lib.application.window.borderless = false;

				Lib.application.window.resize(PauseSubState.restsizeX, PauseSubState.restsizeY);
				Lib.application.window.move(PauseSubState.restX, PauseSubState.restY);
				CppAPI.restoreWindows();
				CppAPI.setWallpaper('old');
			}

			FlxG.mouse.load(TitleState.mouse.pixels, 2);

			Lib.current.scaleX = 1;
			Lib.current.scaleY = 1;
	}

	public function cancelFadeTween()
	{
		if (FlxG.sound.music.fadeTween != null)
		{
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua)
	{
		if (luaArray != null && !preventLuaRemove)
		{
			luaArray.remove(lua);
		}
	}

	var lastStepHit:Int = -1;

	override function stepHit()
	{
		if(FlxG.sound.music.time >= -ClientPrefs.noteOffset)
			{
				if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
					|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
				{
					resyncVocals();
				}
			}
		super.stepHit();

		if (curStep == lastStepHit)
		{
			return;
		}

		if (curStage == 'virtual' && ClientPrefs.noVirtual)
		{
			switch (curStep)
			{
				case 320:
					startwindow = true;
					winx = changex - 20;
					winy = changey + 50;
				case 324:
					winx = changex + 20;
					winy = changey - 50;
				case 328:
					winx = changex + 100;
					winy = changey + 100;
				case 332:
					winx = changex + 100;
					winy = changey - 100;
					windowTween.push(FlxTween.tween(this, {winx: changex / 4, winy: Std.int(changey / 4)}, 0.2, {startDelay: 0.2, ease: FlxEase.backIn}));

				case 336:
					for (tween in windowTween)
					{
						tween.cancel();
					}
					winx = Std.int(changex / 4);
					winy = Std.int(changey / 4);

					windowTween.push(FlxTween.tween(this, {winy: Std.int(changey + (changex / 4))}, 3, {ease: FlxEase.quadInOut, type: PINGPONG}));
					windowTween.push(FlxTween.tween(this, {winx: Std.int(changex + (changex / 2))}, 5, {ease: FlxEase.quadInOut, type: PINGPONG}));
				case 384:
					for (tween in windowTween)
						{
							tween.percent += 0.20;
							eventTimers.push(new FlxTimer().start(0.1, function(tmr:FlxTimer)
								{
									tween.active = false;
								}));

						}
				case 392:
					for (tween in windowTween)
						{
							tween.active = true;
							tween.percent += 0.20;
							eventTimers.push(new FlxTimer().start(0.1, function(tmr:FlxTimer)
								{
									tween.active = false;
								}));
						}
				case 400:
					for (tween in windowTween)
						{
							tween.percent += 0.20;
							tween.active = true;
						}
				case 448:
					for (tween in windowTween)
					{
						tween.cancel();
					}
					windowTween.push(FlxTween.tween(this, {winy: changey}, 0.5, {ease: FlxEase.expoOut}));
					windowTween.push(FlxTween.tween(this, {winx: changex}, 0.5, {ease: FlxEase.expoOut}));

					windowTween.push(FlxTween.tween(this, {winy: changey + 50}, 5, {startDelay: 0.5, ease: FlxEase.cubeInOut, type: PINGPONG}));

				case 576:
					//startwindow = false;
					windowTween.push(FlxTween.tween(this, {winx: changex + 50}, 3, {ease: FlxEase.cubeInOut, type: PINGPONG}));

				case 935:
						for (tween in windowTween)
							{
								tween.cancel();
							}
						windowTween.push(FlxTween.tween(this, {winx: ogwinX}, 0.5, {ease: FlxEase.cubeInOut}));
						windowTween.push(FlxTween.tween(this, {winy: ogwinY}, 0.5, {ease: FlxEase.cubeInOut}));
						eventTimers.push(new FlxTimer().start(0.5, function(tmr:FlxTimer)
							{
								startwindow = false;
							}));

				case 1008:
					timeBarBG.visible = false;
					timeBar.visible = false;
					timeTxt.visible = false;
					scoreTxt.visible = false;

					startresize = true;
					winx = ogwinX;
					winy = ogwinY;
					windowTween.push(FlxTween.tween(this, {winy: 0, winx: 0}, 1.6, {ease: FlxEase.expoIn}));
					windowTween.push(FlxTween.tween(this, {resizex: fsX, resizey: fsY}, 1.6, {
						ease: FlxEase.expoIn,
						onComplete: function(twn:FlxTween)
						{
							CppAPI.setTransparency(Lib.application.window.title, 0x001957);
							startresize = false;
							Lib.application.window.borderless = false;
							Lib.application.window.resize(fsX, fsY);
							Lib.application.window.move(0, 0);
						}
					}));
			}
		}

		if (curStage == 'luigiout')
		{
			if (curStep % 2 == 0 && curStep % 4 != 0)
			{ // SWING BEAT
		
				if((curStep - 2) % 16 == 0 && camZooming){
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
				}

				iconP1.scale.x = 1.1;
				iconP1.scale.y = 1.1;

				iconP2.scale.x = 1.1;
				iconP2.scale.y = 1.1;

				eventTweens.push(FlxTween.tween(iconP1.scale, {x: 1, y: 1}, (0.5 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.cubeOut}));
				eventTweens.push(FlxTween.tween(iconP2.scale, {x: 1, y: 1}, (0.5 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.cubeOut}));

				iconP1.updateHitbox();
				iconP2.updateHitbox();

				if (boyfriend.animation.curAnim.name != null && !boyfriend.animation.curAnim.name.startsWith("sing"))
				{
					boyfriend.dance();
				}
				if (dad.animation.curAnim.name != null && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned)
				{
					dad.dance();
				}
				if (gflol.animation.curAnim.finished || gflol.animation.curAnim.name == 'danceleft' || gflol.animation.curAnim.name == 'danceright')
				{
					if (gflol.animation.curAnim.name == 'danceleft')
					{
						gflol.animation.play('danceright');
					}
					else
					{
						gflol.animation.play('danceleft');
					}
				}
			}
		}

		if(curStage == 'betamansion' && PlayState.SONG.song != 'Alone Old'){
			if (lluvia.alpha != 0){
				triggerEventNote('Triggers Alone', '3', '');
			}
		}

		if (curStage == 'hatebg' && PlayState.SONG.song == 'Oh God No')
			{
				if(curStep == 1235){
					camEst.shake(0.01, 0.2); 
				}
				if(curStep == 1380){
				luigiCut.animation.play('end');
				luigiCut.alpha = 1;
				luigiCut.x -= 100;
				luigiCut.y += 100;
				blackBarThingie.alpha = 1;
				camGame.alpha = 0;
				camHUD.alpha = 0;
				camEst.shake(0.03, 0.4); 
				
				eventTweens.push(FlxTween.tween(luigiCut, {y: luigiCut.y - 100}, 4, {ease: FlxEase.cubeIn}));
				eventTweens.push(FlxTween.tween(luigiCut.scale, {x: 0.1, y: 0.1}, 4, {ease: FlxEase.cubeIn}));
				eventTweens.push(FlxTween.tween(luigiCut, {alpha: 0}, 1, {startDelay: 2}));
				}

				if(curStep >= 1384){
					camEst.shake(0.005, 0.1);
				}
			}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();


		if (curSong.toLowerCase() == 'abandoned')
			{
				switch (curBeat)
				{
			case 228:
				luigidies.visible = true;
				luigidies.playVideo(Paths.video("luigifuckingdies"));
				FlxTween.tween(luigidies, {alpha: 0.6}, 2, {ease: FlxEase.quadInOut});
				case 248:
				FlxTween.tween(luigidies, {alpha: 0}, 2.2, {ease: FlxEase.quadInOut});
	
				}
			}


		/*if(lastBeatHit >= curBeat) {
		trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
		return;
	}*/

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, hasDownScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				// FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}

			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
			if(curStage == 'nesbeat'){
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				{
					// BF TURN
					dad.visible = false;
					boyfriend.alpha = 1;
					boyfriend.visible = true;
					starmanGF.visible = true;
					starmanGF.alpha = 1;
					blackBarThingie.alpha = 0.3;
					if(ycbuGyromite.visible && ycbuLakitu.visible){
						ycbuGyromite.visible = false;
						ycbuLakitu.visible = false;	
					}
					
					alreadychange = true;
				}
				else
				{
					// OPPONENT TURN
					dad.visible = true;
					boyfriend.visible = false;
					starmanGF.visible = false;
					blackBarThingie.alpha = 0;

					alreadychange = false;
				}

				if (alreadychange && alreadychange2)
				{
					estatica.alpha = 0.6;
					eventTweens.push(FlxTween.tween(estatica, {alpha: 0.05}, 0.5, {ease: FlxEase.quadInOut}));
					alreadychange2 = false;
				}

				if (!alreadychange && !alreadychange2)
				{
					estatica.alpha = 0.6;
					eventTweens.push(FlxTween.tween(estatica, {alpha: 0.05}, 0.5, {ease: FlxEase.quadInOut}));
					alreadychange2 = true;
				}
			}

			if(curStage == 'meatworld'){
				if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
					{
						if(!alreadychange){
							meatworldGroup.forEach(function(meat:BGSprite)
								{
									if(meat.ID == 1){
									eventTweens.push(FlxTween.tween(meat, {x: 530}, 1.5, {ease: FlxEase.quadInOut}));
									}
								});
							alreadychange = true;
						}
					}else{
						if(alreadychange){
							meatworldGroup.forEach(function(meat:BGSprite)
								{
									if(meat.ID == 1){
									eventTweens.push(FlxTween.tween(meat, {x: 430}, 1.5, {ease: FlxEase.quadInOut}));
									}
								});
							alreadychange = false;
						}
					}
				}
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0 && curStage != 'luigiout' && !pixelPerfect)
		{	
			if (curStage == 'allfinal'){
				if (act2WhiteFlash.color != FlxColor.RED){
					FlxG.camera.zoom += 0.015;
					camHUD.zoom += 0.03;
				}
			}
			else{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}		

			if(curStage == 'bootleg' && blockzoom){
				eventTweens.push(FlxTween.tween(camHUD, {zoom: 1}, (1 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.elasticOut}));
				eventTweens.push(FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (1 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.elasticOut}));
			}

			if(curStage == 'directstream'){
				camEst.zoom += 0.03;
			}
		}

		if(totalBeat > 0){
			if(curBeat % timeBeat == 0){
				triggerEventNote('Add Camera Zoom', '' + gameZ, '' + hudZ);
				totalBeat -= 1;

				if(shakeTime){
					triggerEventNote('Screen Shake', (((1 / (Conductor.bpm / 60)) / 2) * timeBeat) + ', ' + gameShake, (((1 / (Conductor.bpm / 60)) / 2) * timeBeat) + ', ' + hudShake);
				}
			}
		}

		if(totalShake > 0){
			totalShake -= 1;
			triggerEventNote('Screen Shake', (1 / (Conductor.bpm / 60)) + ', ' + gameShake, (1 / (Conductor.bpm / 60)) + ', ' + hudShake);
		}

		// iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		//	iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		if (curStage != 'luigiout')
		{
			iconP1.scale.x = 1.1;
			iconP1.scale.y = 1.1;

			iconP2.scale.x = 1.1;
			iconP2.scale.y = 1.1;

			if (curStage == 'bootleg')
			{
				if (healthBar.percent > 80)
				{
					eventTweens.push(FlxTween.angle(iconP2, -40, -20, (0.5 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.backOut}));
				}
				else
				{
					iconP2.angle = 0;
				}
			}

			if(curStage == 'superbad'){
				if (healthBar.percent > 80)
					{
						for (tween in extraTween)
							{
								tween.cancel();
							}
						iconP2.flipX = false;
						iconP2.offset.x = 1000;
						iconP2.offset.y = 0;
						extraTween.push(FlxTween.tween(iconP2.offset, {x: -120}, 0.001, {type: PINGPONG, loopDelay: 0.2}));
					}
					else
					{
						for (tween in extraTween)
							{
								tween.cancel();
							}
						iconP2.flipX = !iconP2.flipX;
						iconP2.x = 0;
						iconP2.y -= 20;
						extraTween.push(FlxTween.tween(iconP2, {y: iconP1.y}, (0.5 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.cubeOut}));
					}
			}
			else{
				eventTweens.push(FlxTween.tween(iconP2.scale, {x: 1, y: 1}, (0.5 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.cubeOut}));
			}

			eventTweens.push(FlxTween.tween(iconP1.scale, {x: 1, y: 1}, (0.5 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.cubeOut}));

			iconP1.updateHitbox();
			iconP2.updateHitbox();

			if (gf.danceIdle)
			{
				if (curBeat % gfSpeed == 0
					&& !gf.stunned
					&& gf.animation.curAnim.name != null
					&& !gf.animation.curAnim.name.startsWith("sing"))
				{
					gf.dance();
				}
			}
			
			if (curBeat % 1 == 0)
			{
				if(curStage == 'exeport' && SONG.song != 'Powerdown Old'){
					creepyCloud.animation.play('idle', true);
					if(FlxG.random.int(1, 35) == 1){
						if(creppyleaf.animation.curAnim.name != 'blink')
							for (timer in extraTimers)
								{
									timer.cancel();
								}
							creppyleaf.animation.play('blink', true);
							extraTimers.push(new FlxTimer().start(0.75, function(tmr:FlxTimer)
								{
									creppyleaf.animation.play('idle', true);
								}));
					}
				}
			}

			if (curBeat % 2 == 0)
			{
				if(curStage == 'virtual'){
					if(turtle.animation.curAnim.name == 'idle'){
						turtle.animation.play('idle', true);
						turtle2.animation.play('idle', true);
					}
				}
				
				if (boyfriend.animation.curAnim.name != null && !boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.animation.curAnim.name != 'death' && boyfriend.animation.curAnim.name != 'hit')
				{
					boyfriend.dance();
					if (curStage == 'hatebg' && PlayState.SONG.song != 'I Hate You Old' && PlayState.SONG.song != 'Oh God No')
					{
						capenose.animation.play('idle');
					}
					if (curStage == 'forest')
					{
						capenose.animation.play('idle');
					}
				}
				if (dad.animation.curAnim.name != null && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned)
				{
					dad.dance();
				}
				if (gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned && !gf.danceIdle)
				{
					gf.dance();
				}
			}
			else if (dad.danceIdle
				&& dad.animation.curAnim.name != null
				&& !dad.curCharacter.startsWith('gf')
				&& !dad.animation.curAnim.name.startsWith("sing")
				&& !dad.stunned)
			{
				dad.dance();
			}
		}

		switch (curStage)
		{
			case 'promoshow':
				if (dad.curCharacter == 'stanley')
				{
					if (curBeat % 2 == 0)
					{
						if (!dad.animation.curAnim.name.startsWith("sing"))
							dad.animation.play('idle', true);

						bgLuigi.animation.play('idle', true);
						bgPeach.animation.play('idle', true);

						camGame.angle = cameraTilt;
						eventTweens.push(FlxTween.tween(camGame, {angle: 0}, (1 * (1 / (Conductor.bpm / 60))) - 0.05, {ease: FlxEase.quadIn}));
					}
					if (curBeat % 4 == 0)
					{
						if (!dad.animation.curAnim.name.startsWith("sing"))
							dad.animation.play('idle-alt', true);

						bgLuigi.animation.play('idle-alt', true);
						bgPeach.animation.play('idle-alt', true);

						camGame.angle = -cameraTilt;
						eventTweens.push(FlxTween.tween(camGame, {angle: 0}, (1 * (1 / (Conductor.bpm / 60))) - 0.05, {ease: FlxEase.quadIn}));
					}
				}

			case 'landstage':
				if (quitarvida && health >= 0.1)
				{ // me when the ParashockX's video
					health -= 0.035;
				}

			case 'hatebg':
				if (curBeat >= 320 && curBeat % 2 == 0)
				{
					blueMario.animation.play('dance', false);

					if(PlayState.SONG.song == 'I Hate You Old'){
					blueMario.y = 473;
					blueMario.x = -220;
					}else{
					blueMario.offset.x = -55;
					}
				}
				if (curBeat >= 330 && curBeat % 2 == 0)
				{
					blueMario2.animation.play('dance', false);
					if(PlayState.SONG.song == 'I Hate You Old'){
					blueMario2.y = 473;
					blueMario2.x = 1100;
					}else{
					blueMario2.offset.x = -55;
					}
				}

				if (PlayState.SONG.song == 'Oh God No')
				{

				}
				
			case 'exesequel' | 'betamansion' | 'nesbeat':
				if(PlayState.SONG.song != 'Alone Old'){
				if(dupeTimer != 0 && ClientPrefs.flashing && ClientPrefs.filtro85){
					angel.pixelSize = 0.5;
					angel.strength = shit;
				}
				if (curBeat % 2 == 0){
					if (starmanGF.animation.curAnim.name != 'hey' || (starmanGF.animation.curAnim.name == 'hey' && starmanGF.animation.curAnim.finished)){
						starmanGF.animation.play('danceRight', true);
					}
				}
				else{
					starmanGF.animation.play('danceLeft', true);
				}
				}

			case 'racing':
				if (PlayState.SONG.song != 'Racetraitors Old'){
					switch (curBeat)
					{
						case 4:
							eventTweens.push(FlxTween.tween(camGame, {zoom: 1}, 0.5, {ease: FlxEase.backOut}));
						case 11:
							eventTweens.push(FlxTween.tween(camGame, {zoom: 1.2}, 0.5, {ease: FlxEase.backOut}));
						case 16:
							eventTweens.push(FlxTween.tween(camGame, {zoom: 0.9}, 0.4, {ease: FlxEase.backOut}));
					}	
				}
			case 'forest':

			case 'directstream':
				if(FlxG.random.bool(50) && curBeat > 32)
					triggerEventNote('chat message', '', '');

			case 'bootleg':
				if (curBeat % 1 == 0)
				{
					startbutton.visible = !startbutton.visible;
				}
				thegang.animation.play('idle', true);

				if(curBeat >= 100 && curBeat < 132){
					for (tween in extraTween)
						{
							tween.cancel();
						}
					if(curBeat %2 == 0){
						extraTween.push(FlxTween.tween(camHUD, {angle: -3}, (0.1 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween)
							{
								extraTween.push(FlxTween.tween(camHUD, {angle: 0}, (0.9 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.expoIn, type: PINGPONG}));
							}}));
					}else{
					extraTween.push(FlxTween.tween(camHUD, {angle: 3}, (0.1 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
						{
							extraTween.push(FlxTween.tween(camHUD, {angle: 0}, (0.9 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.expoIn}));
						}}));
					}
				}

				if(curBeat >= 164 && curBeat < 228){
					for (tween in extraTween)
						{
							tween.cancel();
						}
					//if(curBeat %2 == 0){
					//	extraTween.push(FlxTween.tween(camHUD, {x: -30, y: -30}, (0.5 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
					//		{
					//			extraTween.push(FlxTween.tween(camHUD, {x: 0, y: 0}, (0.5 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.quadIn}));
					//		}}));
					//}else{
					//extraTween.push(FlxTween.tween(camHUD, {x: 30, y: -30}, (0.5 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
					//	{
					//		extraTween.push(FlxTween.tween(camHUD, {x: 0, y: 0}, (0.5 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.quadIn}));
					//	}}));
					//}

					// for (i in 0... 8){
					// 	var thenote:Int = i;
					// 	var tdur:Float = (0.5 * (1 / (Conductor.bpm / 60)));
					// 	var testicle:StrumNote = strumLineNotes.members[thenote % strumLineNotes.length];
					// 	if(curBeat %2 == 0){
					// 	extraTween.push(FlxTween.tween(testicle, {x: noteAR[i] - 30, y: strumLine.y -30}, tdur, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
					// 		{
					// 			extraTween.push(FlxTween.tween(testicle, {x: noteAR[i], y: strumLine.y}, tdur, {ease: FlxEase.quadIn}));
					// 		}}));
					// 	}else{
					// 	extraTween.push(FlxTween.tween(testicle, {x: noteAR[i] + 30, y: strumLine.y -30}, tdur, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
					// 		{
					// 			extraTween.push(FlxTween.tween(testicle, {x: noteAR[i], y: strumLine.y}, tdur, {ease: FlxEase.quadIn}));
					// 		}}));
					// 	}
					// }
				}

			case 'exeport':
			if (PlayState.SONG.song != 'Powerdown Old'){
				if (curBeat == 132)
				{
					turnevil.alpha = 1;
					eventTweens.push(FlxTween.tween(turnevil, {alpha: 0.3}, (0.5 * (1 / (Conductor.bpm / 60))), {ease: FlxEase.quadOut}));
					turnevil.animation.play('laugh');
				}

				if (curBeat == 134)
				{
					eventTweens.push(FlxTween.tween(turnevil, {x: -700, y: -700}, 2, {ease: FlxEase.expoOut}));
					eventTweens.push(FlxTween.tween(turnevil.scale, {x: 0.25, y: 0.25}, 2, {ease: FlxEase.expoOut}));
				}

				if (curBeat == 136)
				{
					turnevil.visible = false;
				}

				if (curBeat == 496)
				{

						killMX.visible = false;
						dad.visible = true;
					
				}
			}

			case 'demiseport':

				if(demFlash && ClientPrefs.flashing){
					eventTweens.push(FlxTween.color(demColor, (1 / (Conductor.bpm / 60)), 0xFF4D0000, FlxColor.BLACK));
				}

				// if(curBeat == 382){
				// 	eventTweens.push(FlxTween.tween(demisetran, {x: 2600}, 1.4));
				// }
				// if(curBeat == 384){
				// 	triggerEventNote('Change Character', '1', 'mx_demiseUG');
				// 	triggerEventNote('Change Character', '0', 'bf_demiseUG');
				// 	underdembg.visible = 	   	true;
				// 	underdemLevel.visible =    	true;
				// 	underdemGround1.visible =  	true;
				// 	underdemGround2.visible =  	true;
				// 	underfloordemise.visible = 	true;
				// 	underroofdemise.visible =  	true;
				// 	dembg.visible = 		   	false;
				// 	demLevel.visible = 		   	false;
				// 	floordemise.visible = 		false;
				// 	demGround.visible = 		false;

				// 	demFore1.visible = 			false;
				// 	demFore2.visible = 			false;
				// 	demFore3.visible = 			false;
				// 	demFore4.visible = 			false;
				// }

				// if(curBeat == 449){
				// 	eventTweens.push(FlxTween.tween(whenyourered, {alpha: 1}, 1, {ease: FlxEase.quadOut}));
				// 	eventTweens.push(FlxTween.tween(underdemFore1, {alpha: 0}, 1, {ease: FlxEase.quadOut}));
				// 	eventTweens.push(FlxTween.tween(underdemFore2, {alpha: 0}, 1, {ease: FlxEase.quadOut}));
				// 	eventTweens.push(FlxTween.color(boyfriend, 	1, FlxColor.WHITE, FlxColor.BLACK, {ease: FlxEase.quadOut}));
				// 	eventTweens.push(FlxTween.color(dad,		1, FlxColor.WHITE, FlxColor.BLACK, {ease: FlxEase.quadOut}));
				// }

				// if(curBeat == 516){
				// 	eventTweens.push(FlxTween.tween(whenyourered, {alpha: 0}, 2, {ease: FlxEase.quadInOut}));
				// 	eventTweens.push(FlxTween.tween(underdemFore1, {alpha: 1}, 2, {ease: FlxEase.quadOut}));
				// 	eventTweens.push(FlxTween.tween(underdemFore2, {alpha: 1}, 2, {ease: FlxEase.quadOut}));
				// 	eventTweens.push(FlxTween.color(boyfriend, 	2, FlxColor.BLACK, FlxColor.WHITE, {ease: FlxEase.quadInOut}));
				// 	eventTweens.push(FlxTween.color(dad,		2, FlxColor.BLACK, FlxColor.WHITE, {ease: FlxEase.quadInOut}));
				// }

				// if(curBeat == 550){
				// 	demisetran.x = -1600;
				// 	eventTweens.push(FlxTween.tween(demisetran, {x: 2600}, 1.4));
				// }

				// if(curBeat == 552){
				// 	triggerEventNote('Change Character', '1', 'mx_demise');
				// 	triggerEventNote('Change Character', '0', 'bf_demise');
				// 	underdembg.visible = 	   	false;
				// 	underdemLevel.visible =    	false;
				// 	underdemGround1.visible =  	false;
				// 	underdemGround2.visible =  	false;
				// 	underfloordemise.visible = 	false;
				// 	underroofdemise.visible =  	false;
				// 	dembg.visible = 		   	true;
				// 	demLevel.visible = 		   	true;
				// 	floordemise.visible = 		true;
				// 	demGround.visible = 		true;

				// 	demFore1.visible = 			true;
				// 	demFore2.visible = 			true;
				// 	demFore3.visible = 			true;
				// 	demFore4.visible = 			true;
				// }

				// if(curBeat == 561){
				// 	boyfriend.alpha = 0;
				// 	dad.alpha = 0;

				// 	demcut1.visible = true;
				// 	demcut2.visible = true;
				// 	demcut3.visible = true;
				// 	demcut4.visible = true;

				// 	demcut1.animation.play('idle', true);
				// 	demcut2.animation.play('idle', true);
				// 	demcut3.animation.play('idle', true);
				// 	demcut4.animation.play('idle', true);

				// 	eventTweens.push(FlxTween.tween(floordemise, {alpha: 0}, 0.5));
				// 	eventTweens.push(FlxTween.tween(demGround, {alpha: 0}, 0.5));
				// }
				// if(curBeat == 584){
				// 	eventTweens.push(FlxTween.tween(floordemise, {alpha: 1},  1));
				// 	eventTweens.push(FlxTween.tween(demGround, {alpha: 1}, 1));
				// }
				// if(curBeat == 590){
				// 	eventTweens.push(FlxTween.tween(gordobondiola, {x: 1000, y: -900}, 1.85, {ease: FlxEase.expoIn}));

				// 	eventTweens.push(FlxTween.color(demcut1,		0.8, FlxColor.WHITE, 0xFF5E5E5E));
				// 	eventTweens.push(FlxTween.color(demcut2,		0.8, FlxColor.WHITE, 0xFF5E5E5E));
				// 	eventTweens.push(FlxTween.color(demcut3,		0.8, FlxColor.WHITE, 0xFF5E5E5E));
				// 	eventTweens.push(FlxTween.color(demcut4,		0.8, FlxColor.WHITE, 0xFF5E5E5E));
				// }
				// if(curBeat == 595){
				// 	eventTweens.push(FlxTween.color(demcut1,		0.8, 0xFF5E5E5E, FlxColor.WHITE));
				// 	eventTweens.push(FlxTween.color(demcut2,		0.8, 0xFF5E5E5E, FlxColor.WHITE));
				// 	eventTweens.push(FlxTween.color(demcut3,		0.8, 0xFF5E5E5E, FlxColor.WHITE));
				// 	eventTweens.push(FlxTween.color(demcut4,		0.8, 0xFF5E5E5E, FlxColor.WHITE));
				// }

			case 'virtual':
				var fadechange:Int;
				var cancelArray:Array<Int>;
				var changeArray:Array<Int>;
				var changeArray2:Array<Int>;

				cancelArray = [116, 124, 132, 140, 142, 148, 156, 164, 172, 468, 470];
				changeArray = [16, 336, 372];
				changeArray2 = [324, 340, 500];

				if (curBeat >= 177 && curBeat <= 258 || cancelArray.contains(curBeat) || curBeat >= 550)
				{
					cantfade = true;
				}
				else
				{
					cantfade = false;
				}

				if (changeArray.contains(curBeat))
				{
					cantchange = true;
				}
				if (changeArray2.contains(curBeat))
				{
					cantchange = false;
				}

				if (curBeat == 256)
				{
					blackBarThingie.alpha = 1;
				}

				if (cantchange)
				{
					fadechange = 2;
				}
				else
				{
					fadechange = 4;
				}
				if (curBeat % fadechange == 0 && !cantfade)
				{
					yourhead.alpha = 0.8;
					yourhead.y = -200;
					eventTweens.push(FlxTween.tween(yourhead, {y: -122, alpha: 0.2}, 0.4, {ease: FlxEase.quadOut}));
				}

				if(dupeTimer != 0){
					if(curBeat % dupeTimer == 0){
						if(inc){
							angel.pixelSize = 2;
							dupe.mirror = false;
							dupe.mult += 1;
							if(dupe.mult == dupeMax)
								inc = false;
						}
						else{
							angel.pixelSize = 0.5;
							dupe.mirror = true;
							dupe.mult -= 1;
							if(dupe.mult == 1)
								inc = true;
						}
						angel.strength = ((0.25 / 4))  * dupe.mult;
					}	
				}

			case 'allfinal':

				var fuckyoupysch:Array<Int> = [57, 79, 97, 113, 185, 217, 241];
				for(i in 0... fuckyoupysch.length){
					if(curBeat == fuckyoupysch[i]){
						boyfriend.dance();
					}
				}

				if (curBeat % 2 == 0)
				{
					if (funnylayer0.animation.curAnim.name == 'idle')
						{
							funnylayer0.animation.play('idle');
							funnylayer0.offset.x = 0;
							funnylayer0.offset.y = 0;
						}
				}

				if (curBeat % 4 == 0)
				{
					if (SONG.notes[Math.floor(curStep / 16)].mustHitSection){
						eventTweens.push(FlxTween.tween(act3UltraPupils, {x: -175}, 1.5, {ease: FlxEase.quadInOut}));
					}
					else{
						eventTweens.push(FlxTween.tween(act3UltraPupils, {x: -220}, 1.5, {ease: FlxEase.quadInOut}));
					}
					eventTweens.push(FlxTween.tween(act3UltraHead1, {y: -210 + 30}, 0.1, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
						{
							eventTweens.push(FlxTween.tween(act3UltraHead1, {y: -210}, 0.4, {ease: FlxEase.quadInOut}));
						}}));
					eventTweens.push(FlxTween.tween(act3UltraHead2, {y: -300 + 30}, 0.1, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
						{
							eventTweens.push(FlxTween.tween(act3UltraHead2, {y: -300}, 0.4, {ease: FlxEase.quadInOut}));
						}}));
					eventTweens.push(FlxTween.tween(act3UltraPupils, {y: 105 + 30}, 0.1, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
						{
							eventTweens.push(FlxTween.tween(act3UltraPupils, {y: 105}, 0.4, {ease: FlxEase.quadInOut}));
						}}));
					if (curBeat <= 810){
						if (curBeat != 808)
							act3UltraBody.animation.play('idle', true);
					}
					else{
						if (curBeat <= 872)
							triggerEventNote('Set Cam Zoom', camGame.zoom + 0.005 + '', '');
						act3UltraBody.animation.play('idle-alt', true);
					}
				}

				if (curBeat == 264)
				{
					snapCamFollowToPos(520, -100);
				}

				if (curBeat == 265)
				{
					eventTweens.push(FlxTween.tween(camGame, {zoom: 1.2}, 1.13, {ease: FlxEase.quadOut}));
				}

			case 'nesbeat':
				if (curBeat % 2 == 0){
					if (funnylayer0.animation.curAnim.name == 'idle')
						{
							funnylayer0.animation.play('idle');
							funnylayer0.offset.x = 0;
							funnylayer0.offset.y = 0;
						}
				}
				
			case 'wetworld':

				if (SONG.notes[Math.floor(curStep / 16)].mustHitSection){
					eventTweens.push(FlxTween.tween(adel2, {alpha: 1}, 0.13));
					eventTweens.push(FlxTween.tween(adel, {alpha: 1}, 0.13));
					eventTweens.push(FlxTween.tween(boyfriend, {alpha: 1}, 0.13));
				}
				else{
					eventTweens.push(FlxTween.tween(adel2, {alpha: 0}, 0.13));
					eventTweens.push(FlxTween.tween(adel, {alpha: 0}, 0.13));
					eventTweens.push(FlxTween.tween(boyfriend, {alpha: 0}, 0.13));
				}

			case 'realbg':
				if (curBeat % 8 == 0 && curBeat >= 160 && !cpuControlled && candrain)
				{
					luigilife -= 1;
					if (luigilife <= 0)
					{
						luigilife = 0; // esto no sera usado (?) lmao
						health = 0;
					}
					for (tween in extraTween)
						{
							tween.cancel();
						}
					extraTween.push(FlxTween.tween(dad, {y: (enemyY + 250) - (luigilife * 50)}, 0.5, {ease: FlxEase.quadOut}));
				}
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat);
		callOnLuas('onBeatHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic
	{
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length)
		{
			var ret:Dynamic = luaArray[i].call(event, args);
			if (ret != FunkinLua.Function_Continue)
			{
				returnVal = ret;
			}
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic)
	{
		#if LUA_ALLOWED
		for (i in 0...luaArray.length)
		{
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float)
	{
		if(!SONG.notes[Math.floor(curStep / 16)].mustHitSection == isDad)
			strumCameraRoll(id);

		var spr:StrumNote = null;
		if (isDad)
		{
			spr = strumLineNotes.members[id];
		}
		else
		{
			spr = playerStrums.members[id];
		}

		if (spr != null)
		{
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingString:String;
	public var ratingPercent:Float;

	private function startFore(lastSprite:Int):Void{
		var coso:Int = FlxG.random.int(1, 4);
		var under:String = '';
		if(underfloordemise.visible){
			coso = FlxG.random.int(1, 2);
			under = 'under';
		}
		
		if(coso == lastSprite){
			startFore(coso);
		}
		else{
			var foreSprite:BGSprite = Reflect.getProperty(this, under + 'demFore' + coso);

			if(FlxG.random.bool(50)){
				if(!underfloordemise.visible){
				if(coso != 3){
					foreSprite.x = -3800;
					eventTweens.push(FlxTween.tween(foreSprite, {x: 3800}, 1.3));
					eventTimers.push(new FlxTimer().start(0.5, function(tmr:FlxTimer)
						{
							startFore(coso);
						}));
				}else{
					foreSprite.x = -1800;
					eventTweens.push(FlxTween.tween(foreSprite, {x: 6800}, 1.3));
					eventTimers.push(new FlxTimer().start(0.5, function(tmr:FlxTimer)
						{
							startFore(coso);
						}));

				}
				}else{
					foreSprite.x = -3800;
					eventTweens.push(FlxTween.tween(foreSprite, {x: 3800}, 1.3));
					eventTimers.push(new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							startFore(coso);
						}));
				}
			}
			else{
				eventTimers.push(new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						startFore(lastSprite);
					}));
			}
		}




	}

	private function writeGone():Void
		{
			thetext.visible = true;
			for (timer in eventTimers)
				{
					timer.cancel();
				}
			var check:Float = accuracy();
			writeText.text = check + '%';
			thetext.visible = false;
			canvas.visible = false; //295
			thetextC.visible = false;
			eventTimers.push(new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					writeText.visible = false;
				}));
			canvas.fill(FlxColor.TRANSPARENT);
			var coords:Float = 1200;
			if(!hasDownScroll) coords = -690;

			eventTweens.push(FlxTween.tween(backing, {y: coords}, 1.5, {ease: FlxEase.quadIn}));	
			if (!cpuControlled) {
				if (thetext.text == 'criminal') {
					eventTweens.push(FlxTween.tween(this, {health: health - ((100 - check) / 20) }, 0.4, {ease: FlxEase.circOut}));
				} else {
					eventTweens.push(FlxTween.tween(this, {health: health - ((100 - check) / 30) }, 0.4, {ease: FlxEase.circOut}));
				}
			}
		}

	private function accuracy():Float
		{
			thetext.setFormat(Paths.font("arial-rounded-mt-bold.ttf"), 85, 0xFF888888, FlxTextAlign.CENTER);
			var whiteBad:Int = 0;
			var whiteTotal:Int = 0;
			var grayBad:Int = 0;
			var grayTotal:Int = 0;
			var bounds:flash.geom.Rectangle = thetext.pixels.rect;
			var bounds2:flash.geom.Rectangle = canvas.pixels.rect;
			for (y in 0...Std.int(bounds2.bottom))
			{
				for (x in 0...Std.int(bounds2.right))
				{
					var blue:Bool = false;
					var shouldBe:Bool = false;
					var color:Int = canvas.pixels.getPixel32(x, y);
					if (color == -16776961)
					{
						blue = true;
					}
					var convertedX:Int = x - Std.int(thetext.x - canvas.x);
					var convertedY:Int = y - Std.int(thetext.y - canvas.y);
					if (bounds.contains(convertedX, convertedY))
					{
						var color2:Int = thetext.pixels.getPixel32(convertedX, convertedY);
						if (color2 == -7829368)
						{
							shouldBe = true;
							grayTotal += 1;
						}
						else
						{
							whiteTotal += 1;
						}
					}
					else
					{
						whiteTotal += 1;
					}
					if (blue && !shouldBe)
					{
						whiteBad += 1;
					}
					else if (!blue && shouldBe)
					{
						grayBad += 1;
					}
				}
			}
			thetext.setFormat(Paths.font("arial-rounded-mt-bold.ttf"), 95, 0xDD888888, FlxTextAlign.CENTER);
			var accuracy:Float = 100 * (((Math.log(((grayTotal - grayBad) / grayTotal) * 4.84 + 1) / Math.log(2.2)) / 2.24) - (whiteBad / whiteTotal) * 3);
			accuracy *= 10;
			accuracy = Math.round(accuracy) / 10; //making the time 00.0
			if (accuracy < 0 || (whiteBad / whiteTotal) > 0.8)
			{
				return 0;
			}
			else
			{
				
				return accuracy;
			}
		}

	private function strumCameraRoll(id:Int)
		{
			camDisplaceX = 0;
			camDisplaceY = 0;

			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection){
				switch(id){
					case 0:
						if (GFSINGBF)
							camDisplaceX = -GF_CAM_EXTEND;
						else
							camDisplaceX = -BF_CAM_EXTEND;
					case 1:
						if (GFSINGBF)
							camDisplaceY = GF_CAM_EXTEND;
						else
							camDisplaceY = BF_CAM_EXTEND;
					case 2:
						if (GFSINGBF)
							camDisplaceY = -GF_CAM_EXTEND;
						else
							camDisplaceY = -BF_CAM_EXTEND;
					case 3:
						if (GFSINGBF)
							camDisplaceX = GF_CAM_EXTEND;
						else
							camDisplaceX = BF_CAM_EXTEND;
				}
			}
			else{
				switch(id){
					case 0:
						if (GFSINGDAD)
							camDisplaceX = -GF_CAM_EXTEND;
						else
							camDisplaceX = -DAD_CAM_EXTEND;
					case 1:
						if (GFSINGDAD)
							camDisplaceY = GF_CAM_EXTEND;
						else
							camDisplaceY = DAD_CAM_EXTEND;
					case 2:
						if (GFSINGDAD)
							camDisplaceY = -GF_CAM_EXTEND;
						else
							camDisplaceY = -DAD_CAM_EXTEND;
					case 3:
						if (GFSINGDAD)
							camDisplaceX = GF_CAM_EXTEND;
						else
							camDisplaceX = DAD_CAM_EXTEND;
				}
			}
		}

	public function RecalculateRating()
	{
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('ghostMisses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if (ret != FunkinLua.Function_Stop)
		{
			ratingPercent = songScore / ((songHits + songMisses - ghostMisses) * 350);
			if (!Math.isNaN(ratingPercent) && ratingPercent < 0)
				ratingPercent = 0;

			if (Math.isNaN(ratingPercent))
			{
				ratingString = '?';
			}
			else if (ratingPercent >= 1)
			{
				ratingPercent = 1;
				ratingString = ratingStuff[ratingStuff.length - 1][0]; // Uses last string
			}
			else
			{
				for (i in 0...ratingStuff.length - 1)
				{
					if (ratingPercent < ratingStuff[i][1])
					{
						ratingString = ratingStuff[i][0];
						break;
					}
				}
			}

			setOnLuas('rating', ratingPercent);
			setOnLuas('ratingName', ratingString);
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(arrayIDs:Array<Int>):Int
	{
		for (i in 0...arrayIDs.length)
		{
			if (!Achievements.achievementsUnlocked[arrayIDs[i]][1])
			{
				switch (arrayIDs[i])
				{
					case 1 | 2 | 3 | 4 | 5 | 6 | 7:
						if (isStoryMode
							&& campaignMisses + songMisses < 1
							&& CoolUtil.difficultyString() == 'HARD'
							&& storyPlaylist.length <= 1
							&& WeekData.getWeekFileName() == ('week' + arrayIDs[i])
							&& !changedDifficulty
							&& !usedPractice)
						{
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 8:
						if (ratingPercent < 0.2 && !practiceMode && !cpuControlled)
						{
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 9:
						if (ratingPercent >= 1 && !usedPractice && !cpuControlled)
						{
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 10:
						if (Achievements.henchmenDeath >= 100)
						{
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 11:
						if (boyfriend.holdTimer >= 20 && !usedPractice)
						{
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 12:
						if (!boyfriendIdled && !usedPractice)
						{
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 13:
						if (!usedPractice)
						{
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length)
							{
								if (keysPressed[j])
									howManyPresses++;
							}

							if (howManyPresses <= 2)
							{
								Achievements.unlockAchievement(arrayIDs[i]);
								return arrayIDs[i];
							}
						}
					case 14:
						if (/*ClientPrefs.framerate <= 60 &&*/ ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing && !ClientPrefs.imagesPersist)
						{
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 15:
						if (Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice)
						{
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
				}
			}
		}
		return -1;
	}
	#end

	var curLight:Int = 0;
	var curLightEvent:Int = 0;

	static function formatMario(num:Float, size:Int):String {
        var finalVal:String = "";
        var stringNum:String = Std.string(Math.round(num));

        for (zero in 0...(size - stringNum.length))
            finalVal += "0";

        finalVal += stringNum;

        return finalVal;
    }
}
