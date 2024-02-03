package mobile.states;

import flixel.addons.transition.FlxTransitionableState;
import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets as OpenflAssets;
import flixel.addons.util.FlxAsyncLoop;
import openfl.utils.ByteArray;
import openfl.system.System;
import states.TitleState;
import haxe.io.Path;
#if (target.threaded)
import sys.thread.Thread;
#end

class CopyState extends MusicBeatState
{
	public static var locatedFiles:Array<String> = [];
	public static var maxLoopTimes:Int = 0;
	public static var to:String = '';

	public var loadingImage:FlxSprite;
	public var bottomBG:FlxSprite;
	public var loadedText:FlxText;
	public var copyLoop:FlxAsyncLoop;

	var loopTimes:Int = 0;
	var failedFiles:Array<String> = [];
	var canUpdate:Bool = true;
	var shouldCopy:Bool = false;

	static final textFilesExtensions:Array<String> = ['txt', 'xml', 'lua', 'hx', 'json', 'frag', 'vert'];

	override function create()
	{
		locatedFiles = [];
		maxLoopTimes = 0;
		checkExistingFiles();
		if (maxLoopTimes > 0)
		{
			shouldCopy = true;
			SUtil.showPopUp("Seems like you have some missing files that are necessary to run the game\nPress OK to begin the copy process", "Notice!");

			add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xffcaff4d));

			loadingImage = new FlxSprite(0, 0, Paths.image('funkay'));
			loadingImage.setGraphicSize(0, FlxG.height);
			loadingImage.updateHitbox();
			loadingImage.screenCenter();
			add(loadingImage);

			bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
			bottomBG.alpha = 0.6;
			add(bottomBG);

			loadedText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, '', 16);
			loadedText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
			add(loadedText);

			#if (target.threaded)
			Thread.create(() -> {
			#end
				var ticks:Int = 15;
				if (maxLoopTimes <= 15)
					ticks = 1;
				copyLoop = new FlxAsyncLoop(maxLoopTimes, copyAsset, ticks);
				add(copyLoop);
				copyLoop.start();
			#if (target.threaded)
			});
			#end
		}
		else
		{
			TitleState.ignoreCopy = true;
			FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new TitleState());
		}

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (shouldCopy && copyLoop != null)
		{
			if (copyLoop.finished && canUpdate)
			{
				if (failedFiles.length > 0)
				{
					SUtil.showPopUp(failedFiles.join('\n'), 'Failed To Copy ${failedFiles.length} File.');
					if (!FileSystem.exists('logs'))
						FileSystem.createDirectory('logs');
					File.saveContent('logs/' + Date.now().toString().replace(' ', '-').replace(':', "'") + '-CopyState' + '.txt', failedFiles.join('\n'));
				}
				canUpdate = false;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				new FlxTimer().start(0.4, (tmr:FlxTimer) ->
				{
					Paths.clearUnusedMemory();
					TitleState.ignoreCopy = true;
					MusicBeatState.switchState(new TitleState());
				});
			}
			if (maxLoopTimes == 0)
				loadedText.text = "Completed!";
			else
				loadedText.text = '$loopTimes/$maxLoopTimes';
		}
		super.update(elapsed);
	}

	public function copyAsset()
	{
		var file = locatedFiles[loopTimes];
		var toFile = Path.join([to, file]);
		loopTimes++;
		if (!FileSystem.exists(toFile))
		{
			var directory = Path.directory(toFile);
			if (!FileSystem.exists(directory))
				SUtil.mkDirs(directory);
			try
			{
				if (OpenflAssets.exists(getFile(file)))
				{
					if (textFilesExtensions.contains(Path.extension(file)))
						createContentFromInternal(file);
					else
						File.saveBytes(toFile, getFileBytes(getFile(file)));
				}
				else
				{
					failedFiles.push(getFile(file) + " (File Dosen't Exist)");
				}
			}
			catch (err:Dynamic)
			{
				failedFiles.push('${getFile(file)} ($err)');
			}
		}
	}

	public static function getFileBytes(file:String):ByteArray
	{
		switch (Path.extension(file))
		{
			case 'otf' | 'ttf':
				return ByteArray.fromFile(file);
			default:
				return OpenflAssets.getBytes(file);
		}
	}

	public static function getFile(file:String):String
	{
		@:privateAccess
		for(library in LimeAssets.libraries.keys()){
			if(OpenflAssets.exists('$library:$file') && library != 'default')
				return '$library:$file';
		}
		return file;
	}

	public function createContentFromInternal(file:String = 'assets/file.txt')
	{
		var fileName = Path.withoutDirectory(file);
		var directory = Path.directory(Path.join([to, file]));
		try
		{
			var fileData:String = OpenflAssets.getText(getFile(file));
			if (fileData == null)
				fileData = '';
			if (!FileSystem.exists(directory))
				SUtil.mkDirs(directory);
			File.saveContent(Path.join([directory, fileName]), fileData);
		}
		catch (error:Dynamic)
		{
			failedFiles.push('${getFile(file)} ($error)');
		}
	}

	public static function checkExistingFiles():Bool
	{
		locatedFiles = OpenflAssets.list();
		// removes unwanted assets
		var assets = locatedFiles.filter(folder -> folder.startsWith('assets/'));
		var mods = locatedFiles.filter(folder -> folder.startsWith('mods/'));
		locatedFiles = assets.concat(mods);

		var filesToRemove:Array<String> = [];
		for (file in locatedFiles)
		{
			var toFile = Path.join([to, file]);
			if (FileSystem.exists(toFile))
			{
				filesToRemove.push(file);
			}
		}

		for (file in filesToRemove)
			locatedFiles.remove(file);

		maxLoopTimes = locatedFiles.length;

		return (maxLoopTimes < 0);
	}
}
