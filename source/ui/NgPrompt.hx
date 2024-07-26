package ui;

import backend.NGio;
import ui.Prompt;

class NgPrompt extends Prompt
{
	public function new (text:String, style:ButtonStyle = Yes_No)
	{
           super(text,style);
	}
	
	static public function showLogin()
	{
		return showLoginPrompt(true);
	}
	
	static public function showSavedSessionFailed()
	{
		return showLoginPrompt(false);
	}
	
	static function showLoginPrompt(fromUi:Bool)
	{
		
		return false;
	}
	
	static public function showLogout()
	{
		
	}
}