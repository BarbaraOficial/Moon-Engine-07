package mobile.backend;

#if android
import lime.app.Application;
#end
import haxe.io.Path;
import haxe.CallStack;
import lime.system.System as LimeSystem;
import openfl.utils.Assets as OpenflAssets;
import lime.utils.Log as LimeLogger;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;

using StringTools;

enum StorageType
{
	EXTERNAL;
	EXTERNAL_DATA;
	EXTERNAL_OBB;
	MEDIA;
}

/**
 * A class for mobile
 * @author Mihai Alexandru (M.A. Jigsaw)
 * @modification's author: Lily (mcagabe19)
 */
class SUtil
{
	/**
	 * This returns the external storage path that the game will use by the type.
	 */
	public static function getStorageDirectory(type:StorageType = #if EXTERNAL EXTERNAL #elseif OBB EXTERNAL_OBB #elseif MEDIA MEDIA #else EXTERNAL_DATA #end):String
	{
		var daPath:String = '';

		#if android
		switch (type)
		{
			case EXTERNAL_DATA:
				daPath = AndroidContext.getExternalFilesDir(null);
			case EXTERNAL_OBB:
				daPath = AndroidContext.getObbDir();
			case EXTERNAL:
				daPath = AndroidEnvironment.getExternalStorageDirectory() + '/.' + Application.current.meta.get('file');
			case MEDIA:
				daPath = AndroidEnvironment.getExternalStorageDirectory() + '/Android/media/' + Application.current.meta.get('packageName');
		}
		#elseif ios
		daPath = LimeSystem.documentsDirectory;
		#end

		return daPath;
	}

	/**
	 * Uncaught error handler, original made by: Sqirra-RNG and YoshiCrafter29
	 */
	public static function uncaughtErrorHandler():Void
	{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError);
	}

	private static function onError(error:UncaughtErrorEvent):Void
	{
		final log:Array<String> = [error.error];

		for (item in CallStack.exceptionStack(true))
		{
			switch (item)
			{
				case CFunction:
					log.push('C Function');
				case Module(m):
					log.push('Module [$m]');
				case FilePos(s, file, line, column):
					log.push('$file [line $line]');
				case Method(classname, method):
					log.push('$classname [method $method]');
				case LocalFunction(name):
					log.push('Local Function [$name]');
			}
		}

		final msg:String = log.join('\n');

		#if sys
		try
		{
			if (!FileSystem.exists('logs'))
				FileSystem.createDirectory('logs');

			File.saveContent('logs/' + Date.now().toString().replace(' ', '-').replace(':', "'") + '.txt', msg + '\n');
		}
		catch (e:Dynamic)
		{
			#if (android && debug)
			AndroidToast.makeText("Error!\nCouldn't save the crash dump because:\n" + e, AndroidToast.LENGTH_LONG);
			#else
			LimeLogger.println("Error!\nCouldn't save the crash dump because:\n" + e);
			#end
		}
		#end

		showPopUp(msg, "Error!");

		#if DISCORD_ALLOWED
		DiscordClient.shutdown();
		#end

		#if js
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		js.Browser.window.location.reload(true);
		#else
		LimeSystem.exit(1);
		#end
	}

	/**
	 * This is mostly a fork of https://github.com/openfl/hxp/blob/master/src/hxp/System.hx#L595
	 */
	#if sys
	public static function mkDirs(directory:String):Void
	{
		var total:String = '';
		if (directory.substr(0, 1) == '/')
			total = '/';

		var parts:Array<String> = directory.split('/');
		if (parts.length > 0 && parts[0].indexOf(':') > -1)
			parts.shift();

		for (part in parts)
		{
			if (part != '.' && part != '')
			{
				if (total != '' && total != '/')
					total += '/';

				total += part;

				if (!FileSystem.exists(total))
					FileSystem.createDirectory(total);
			}
		}
	}

	public static function saveContent(fileName:String = 'file', fileExtension:String = '.json', fileData:String = 'you forgot to add something in your code lol'):Void
	{
		try
		{
			if (!FileSystem.exists('saves'))
				FileSystem.createDirectory('saves');

			File.saveContent('saves/' + fileName + fileExtension, fileData);
			showPopUp(fileName + " file has been saved", "Success!");
		}
		catch (e:Dynamic)
		{
			#if (android && debug)
			AndroidToast.makeText("Error!\nClouldn't save the file because:\n" + e, AndroidToast.LENGTH_LONG);
			#else
			LimeLogger.println("Error!\nClouldn't save the file because:\n" + e);
			#end
		}
	}
	#end

	#if android
	public static function doPermissionsShit():Void
	{
		if (!AndroidPermissions.getGrantedPermissions().contains(AndroidPermissions.READ_EXTERNAL_STORAGE) && !AndroidPermissions.getGrantedPermissions().contains(AndroidPermissions.WRITE_EXTERNAL_STORAGE))
		{
			AndroidPermissions.requestPermission(AndroidPermissions.READ_EXTERNAL_STORAGE);
			AndroidPermissions.requestPermission(AndroidPermissions.WRITE_EXTERNAL_STORAGE);
			showPopUp('If you accepted the permissions you are all good!' + '\nIf you didn\'t then expect a crash' + '\nPress Ok to see what happens', 'Notice!');
                        if (!AndroidEnvironment.isExternalStorageManager()) AndroidSettings.requestSetting("android.AndroidSettings.MANAGE_APP_ALL_FILES_ACCESS_PERMISSION");
		}
	}
	#end

	public static function showPopUp(message:String, title:String):Void
	{
		/*#if android
		AndroidTools.showAlertDialog(title, message, null, null);
		#elseif (windows || web)*/
                #if (windows || android || web)
		Lib.application.window.alert(message, title);
		#else
		LimeLogger.println('$title - $message');
		#end
	}
}
