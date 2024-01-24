package;

class CppAPI
{
	#if windows
	public static function obtainRAM():Int
	{
		return WindowsData.obtainRAM();
	}

	public static function darkMode()
	{
		WindowsData.setWindowColorMode(DARK);
	}

	public static function lightMode()
	{
		WindowsData.setWindowColorMode(LIGHT);
	}

	public static function setWindowOppacity(a:Float)
	{
		WindowsData.setWindowAlpha(a);
	}

	public static function _setWindowLayered()
	{
		WindowsData._setWindowLayered();
	}

	public static function setWallpaper(path:String)
	{
		if(path == 'old') {
			if(Wallpaper.oldWallpaper != null) {
			path = Wallpaper.oldWallpaper;
			}else{
				return;
			}}
		Wallpaper.setWallpaper(path);
	}

	public static function setOld()
	{
		Wallpaper.setOld();
	}

	public static function hideTaskbar()
	{
		WindowsData.hideTaskbar();
	}

	public static function restoreTaskbar()
	{
		WindowsData.restoreTaskbar();
	}

	public static function hideWindows()
	{
		WindowsData.hideWindows();
	}

	public static function restoreWindows()
	{
		WindowsData.restoreWindows();
	}

	public static function setTransparency(winName:String, color:Int)
	{
		Transparency.setTransparency(winName, color);
	}
	
	public static function removeWindowIcon()
	{
		WindowsData.removeWindowIcon();
	}

	public static function reset()
	{
		Transparency.reset();
	}
	public static function allowHighDPI() {
		WindowsData.registerHighDpi();
	}
	#end
}
