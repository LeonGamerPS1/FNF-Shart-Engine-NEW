package backend;

#if newgrounds


using StringTools;
#end
/**
 * MADE BY GEOKURELI THE LEGENED GOD HERO MVP
 */
class NGio
{
	#if newgrounds
	/**
	 * True, if the saved sessionId was used in the initial login, and failed to connect.
	 * Used in MainMenuState to show a popup to establish a new connection
	 */
	public static var savedSessionFailed(default, null):Bool = false;
	public static var scoreboardsLoaded:Bool = false;
	public static var isLoggedIn(get, never):Bool;
	inline static function get_isLoggedIn()
	{
return false;
	}

	public static var scoreboardArray:Array<Score> = [];

	public static var ngDataLoaded(default, null):FlxSignal = new FlxSignal();
	public static var ngScoresLoaded(default, null):FlxSignal = new FlxSignal();

	public static var GAME_VER:String = "";
	
	static public function checkVersion(callback:String->Void)
	{
		
	}

	static public function init()
	{
		
	}
	
	/**
	 * Attempts to log in to newgrounds by requesting a new session ID, only call if no session ID was found automatically
	 * @param popupLauncher The function to call to open the login url, must be inside
	 * a user input event or the popup blocker will block it.
	 * @param onComplete A callback with the result of the connection.
	 */
	static public function login(?popupLauncher:(Void->Void)->Void, onComplete:ConnectionResult->Void)
	{
		
	}
	
	inline static public function cancelLogin():Void
	{

	}

	static function onNGLogin():Void
	{
	}
	
	static public function logout()
	{

	}

	// --- MEDALS
	static function onNGMedalFetch():Void
	{
	
	}

	// --- SCOREBOARDS
	static function onNGBoardsFetch():Void
	{
	
	}

	static function onNGScoresFetch():Void
	{
		
	}
	#end

	static public function logEvent(event:String)
	{
	}

	static public function unlockMedal(id:Int)
	{
		
	}

	static public function postScore(score:Int = 0, song:String)
	{
	
	}
}

enum ConnectionResult
{
	/** Log in successful */
	Success;
	/** Could not login */
	Fail(msg:String);
	/** User cancelled the login */
	Cancelled;
}
