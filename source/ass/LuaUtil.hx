package ass;

// this file is for modchart things, this is to declutter playstate.hx
// Lua
#if windows
import flixel.tweens.FlxEase;
import openfl.filters.ShaderFilter;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import lime.app.Application;
import flixel.FlxSprite;
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;

class LuaUtil
{
	// public static var shaders:Array<LuaShader> = null;
	public static var lua:State = null;
	var game:PlayState = PlayState.instance;

	function callLua(func_name:String, args:Array<Dynamic>, ?type:String):Dynamic
	{
		var result:Any = null;

		Lua.getglobal(lua, func_name);

		for (arg in args)
		{
			Convert.toLua(lua, arg);
		}

		result = Lua.pcall(lua, args.length, 1, 0);
		var p = Lua.tostring(lua, result);
		var e = getLuaErrorMessage(lua);

		if (e != null)
		{
			if (p != null)
			{
				Application.current.window.alert("LUA ERROR:\n" + p + "\nhaxe things: " + e, "Early LUA System");
				lua = null;
				FlxG.switchState(new MainMenuState());
			}
			// trace('err: ' + e);
		}
		if (result == null)
		{
			return null;
		}
		else
		{
			return convert(result, type);
		}
	}

	function getType(l, type):Any
	{
		return switch Lua.type(l, type)
		{
			case t if (t == Lua.LUA_TNIL): null;
			case t if (t == Lua.LUA_TNUMBER): Lua.tonumber(l, type);
			case t if (t == Lua.LUA_TSTRING): (Lua.tostring(l, type) : String);
			case t if (t == Lua.LUA_TBOOLEAN): Lua.toboolean(l, type);
			case t: throw 'you don goofed up. lua type error ($t)';
		}
	}

	function getReturnValues(l)
	{
		var lua_v:Int;
		var v:Any = null;
		while ((lua_v = Lua.gettop(l)) != 0)
		{
			var type:String = getType(l, lua_v);
			v = convert(lua_v, type);
			Lua.pop(l, 1);
		}
		return v;
	}

	private function convert(v:Any, type:String):Dynamic
	{ // I didn't write this lol
		if (Std.is(v, String) && type != null)
		{
			var v:String = v;
			if (type.substr(0, 4) == 'array')
			{
				if (type.substr(4) == 'float')
				{
					var array:Array<String> = v.split(',');
					var array2:Array<Float> = new Array();

					for (vars in array)
					{
						array2.push(Std.parseFloat(vars));
					}

					return array2;
				}
				else if (type.substr(4) == 'int')
				{
					var array:Array<String> = v.split(',');
					var array2:Array<Int> = new Array();

					for (vars in array)
					{
						array2.push(Std.parseInt(vars));
					}

					return array2;
				}
				else
				{
					var array:Array<String> = v.split(',');
					return array;
				}
			}
			else if (type == 'float')
			{
				return Std.parseFloat(v);
			}
			else if (type == 'int')
			{
				return Std.parseInt(v);
			}
			else if (type == 'bool')
			{
				if (v == 'true')
				{
					return true;
				}
				else
				{
					return false;
				}
			}
			else
			{
				return v;
			}
		}
		else
		{
			return v;
		}
	}

	function getLuaErrorMessage(l)
	{
		var v:String = Lua.tostring(l, -1);
		Lua.pop(l, 1);
		return v;
	}

	public function setVar(var_name:String, object:Dynamic)
	{
		// trace('setting variable ' + var_name + ' to ' + object);

		Lua.pushnumber(lua, object);
		Lua.setglobal(lua, var_name);
	}

	public function set(variable:String, data:Dynamic)
	{
		if (lua == null)
		{
			return;
		}

		Convert.toLua(lua, data);
		Lua.setglobal(lua, variable);
	}

	public function getVar(var_name:String, type:String):Dynamic
	{
		var result:Any = null;

		// trace('getting variable ' + var_name + ' with a type of ' + type);

		Lua.getglobal(lua, var_name);
		result = Convert.fromLua(lua, -1);
		Lua.pop(lua, 1);

		if (result == null)
		{
			return null;
		}
		else
		{
			var result = convert(result, type);
			// trace(var_name + ' result: ' + result);
			return result;
		}
	}

	function getActorByName(id:String):Dynamic
	{
		// pre defined names
		switch (id)
		{
			case 'boyfriend':
				@:privateAccess
				return game.boyfriend;
			case 'girlfriend':
				@:privateAccess
				return game.gf;
			case 'dad':
				@:privateAccess
				return game.dad;
		}
		// lua objects or what ever
		if (luaSprites.get(id) == null)
		{
			if (Std.parseInt(id) == null)
				return Reflect.getProperty(PlayState.instance, id);
			return game.strumLineNotes.members[Std.parseInt(id)];
		}
		return luaSprites.get(id);
	}

	public static var luaSprites:Map<String, FlxSprite> = [];

	function makeLuaSprite(spritePath:String, toBeCalled:String, drawBehind:Bool)
	{
		#if sys
		var data:BitmapData = BitmapData.fromFile(Sys.getCwd() + "assets/data/" + PlayState.SONG.song.toLowerCase() + '/' + spritePath + ".png");

		var sprite:FlxSprite = new FlxSprite(0, 0);
		var imgWidth:Float = FlxG.width / data.width;
		var imgHeight:Float = FlxG.height / data.height;
		var scale:Float = imgWidth <= imgHeight ? imgWidth : imgHeight;

		// Cap the scale at x1
		if (scale > 1)
		{
			scale = 1;
		}

		sprite.makeGraphic(Std.int(data.width * scale), Std.int(data.width * scale), FlxColor.TRANSPARENT);

		var data2:BitmapData = sprite.pixels.clone();
		var matrix:Matrix = new Matrix();
		matrix.identity();
		matrix.scale(scale, scale);
		data2.fillRect(data2.rect, FlxColor.TRANSPARENT);
		data2.draw(data, matrix, null, null, null, true);
		sprite.pixels = data2;

		luaSprites.set(toBeCalled, sprite);
		// and I quote:
		// shitty layering but it works!
		@:privateAccess
		{
			if (drawBehind)
			{
				game.removeObject(game.gf);
				game.removeObject(game.boyfriend);
				game.removeObject(game.dad);
			}
			game.addObject(sprite);
			if (drawBehind)
			{
				game.addObject(game.gf);
				game.addObject(game.boyfriend);
				game.addObject(game.dad);
			}
		}
		#end
		return toBeCalled;
	}

	public function die()
	{
		Lua.close(lua);
		lua = null;
	}

	// LUA SHIT

	function new()
	{
		trace('opening a lua state (because we are cool :))');
		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		trace("Lua version: " + Lua.version());
		trace("LuaJIT version: " + Lua.versionJIT());
		Lua.init_callbacks(lua);

		// shaders = new Array<LuaShader>();

		var result = LuaL.dofile(lua, Paths.lua(PlayState.SONG.song.toLowerCase() + "/modchart")); // execute le file

		if (result != 0)
		{
			Application.current.window.alert("LUA COMPILE ERROR:\n" + Lua.tostring(lua, result), "Kade Engine Modcharts");
			lua = null;
			LoadingState.loadAndSwitchState(new MainMenuState());
		}

		// get some fukin globals up in here bois

						

			
						set("difficulty", PlayState.storyDifficulty);
						set("bpm", Conductor.bpm);
						set("scrollspeed",  PlayState.SONG.speed);
				
						set("downscroll", PreferencesMenu.getPref('downscroll'));

						set("curStep", 0);
						set("curBeat", 0);
						set("crochet", Conductor.stepCrochet);
						set("safeZoneOffset", Conductor.safeZoneOffset);


			


						set("followXOffset",0);
						set("followYOffset",0);

						set("showOnlyStrums", false);
						set("strumLine1Visible", true);
						set("strumLine2Visible", true);

						set("screenWidth",FlxG.width);
						set("screenHeight",FlxG.height);
					

						set("mustHit", false);
					
		 

		// callbacks

		// sprites

		// set('strumLineY', game.strumLine.y);

		Lua_helper.add_callback(lua, "print", function(output:Any)
		{
			trace(output);
		});
		Lua_helper.add_callback(lua, "getValue", function(val:Any)
		{
			return val;
		});
	}

	public function executeState(name, args:Array<Dynamic>)
	{
		return Lua.tostring(lua, callLua(name, args));
	}

	public static function createModchartState():LuaUtil
	{
		return new LuaUtil();
	}
}
#end
