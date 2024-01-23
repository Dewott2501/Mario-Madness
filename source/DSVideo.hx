import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
#if web
import openfl.events.NetStatusEvent;
import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;
#else
import openfl.events.Event;
import vlc.DSBitmap;
#end

// its just FlxVideo but with different positioning
class DSVideo extends FlxBasic
{
	#if VIDEOS_ALLOWED
	public var finishCallback:Void->Void;

	public static var vlcBitmap:DSBitmap;
	#end

	public var finished:Bool = false;

	public var state:FlxState;

	public function new(name:String, camera:FlxCamera, state:FlxState)
	{
		super();

		this.state = state;

		finishCallback = function()
		{
			finished = true;
		};

		#if web
		var player:Video = new Video();
		player.x = 0;
		player.y = 0;
		FlxG.addChildBelowMouse(player);
		var netConnect = new NetConnection();
		netConnect.connect(null);
		var netStream = new NetStream(netConnect);
		netStream.client = {
			onMetaData: function()
			{
				player.attachNetStream(netStream);
				player.width = 256;
				player.height = 384;
			}
		};
		netConnect.addEventListener(NetStatusEvent.NET_STATUS, function(event:NetStatusEvent)
		{
			if (event.info.code == "NetStream.Play.Complete")
			{
				netStream.dispose();
				if (FlxG.game.contains(player))
					FlxG.game.removeChild(player);

				if (finishCallback != null)
					finishCallback();
			}
		});
		netStream.play(name);
		#elseif desktop
		// by Polybius, check out PolyEngine! https://github.com/polybiusproxy/PolyEngine

		vlcBitmap = new DSBitmap();
		state.add(vlcBitmap.renderSprite);
		vlcBitmap.set_height(576);
		vlcBitmap.set_width(384);
		vlcBitmap.x = 448;
		vlcBitmap.y = 72;

		vlcBitmap.onComplete = onVLCComplete;
		vlcBitmap.onError = onVLCError;

		FlxG.stage.addEventListener(Event.ENTER_FRAME, fixVolume);
		vlcBitmap.repeat = 0;
		vlcBitmap.inWindow = false;
		vlcBitmap.fullscreen = false;
		fixVolume(null);

		FlxG.addChildBelowMouse(vlcBitmap);
		vlcBitmap.renderSprite.cameras = [camera];
		vlcBitmap.play(checkFile(name));
		#end
	}

	#if desktop
	function checkFile(fileName:String):String
	{
		var pDir = "";
		var appDir = "file:///" + Sys.getCwd() + "/";

		if (fileName.indexOf(":") == -1) // Not a path
			pDir = appDir;
		else if (fileName.indexOf("file://") == -1 || fileName.indexOf("http") == -1) // C:, D: etc? ..missing "file:///" ?
			pDir = "file:///";

		return pDir + fileName;
	}

	public static function onFocus()
	{
		if (vlcBitmap != null)
		{
			vlcBitmap.resume();
		}
	}

	public static function onFocusLost()
	{
		if (vlcBitmap != null)
		{
			vlcBitmap.pause();
		}
	}

	function fixVolume(e:Event)
	{
		// shitty volume fix
		vlcBitmap.volume = 0;
		if (!FlxG.sound.muted && FlxG.sound.volume > 0.01)
		{ // Kind of fixes the volume being too low when you decrease it
			vlcBitmap.volume = FlxG.sound.volume * 0.5 + 0.5;
		}
	}

	public function onVLCComplete()
	{
		vlcBitmap.renderSprite.visible = false;

		state.remove(vlcBitmap.renderSprite);

		vlcBitmap.stop();

		// Clean player, just in case!
		vlcBitmap.dispose();

		if (FlxG.game.contains(vlcBitmap))
		{
			FlxG.game.removeChild(vlcBitmap);
		}

		if (finishCallback != null)
		{
			finishCallback();
		}
	}

	function onVLCError()
	{
		trace("An error has occured while trying to load the video.\nPlease, check if the file you're loading exists.");
		if (finishCallback != null)
		{
			finishCallback();
		}
	}
	#end
}
