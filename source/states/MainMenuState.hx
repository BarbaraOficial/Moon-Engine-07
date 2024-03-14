package states;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
#if LUA_ALLOWED
import psychlua.*;
#else
import psychlua.LuaUtils;
import psychlua.HScript;
#end

class MainMenuState extends MusicBeatState
{
	public static var moonEngineVersion:String = '2.2.0';
	public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		'options'
	];

        var mainSide:FlxSprite;
	var mods:FlxSprite;
	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		
		#if desktop
		FlxG.mouse.visible = true;
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		mainSide = new FlxSprite(0).loadGraphic(Paths.image('mainSide'));
		mainSide.scrollFactor.x = 0;
		mainSide.scrollFactor.y = 0;
		mainSide.setGraphicSize(Std.int(mainSide.width * 0.75));
		mainSide.updateHitbox();
		mainSide.screenCenter();
		mainSide.antialiasing = ClientPrefs.data.antialiasing;
		mainSide.x = -50;
		mainSide.y = -90;
		add(mainSide);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			switch (ClientPrefs.data.languages){
     
                    case 'English':
		        menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
		
	            case 'Português (Brasil)':
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menuLanguages/portuguese/menu_' + optionShit[i]);

		    case 'Español':
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menuLanguages/spanish/menu_' + optionShit[i]);
			}
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.x = 100;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 6)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.updateHitbox();
			//menuItem.screenCenter(X);
		}
		
		switch (FlxG.random.int(0, 1)) {

			case 0:
        var charDance = new FlxSprite(700, 200);
        charDance.frames = Paths.getSparrowAtlas('mainmenu/menuCharacters/Boyfriend');
        charDance.animation.addByPrefix('Idle', 'BF IDLE', 24);
	charDance.animation.play('Idle');
	charDance.updateHitbox();
	charDance.scale.x = 1.5;
	charDance.scale.y = 1.5;
        add(charDance);


			case 1:
        var charDance = new FlxSprite(700, 200);
        charDance.frames = Paths.getSparrowAtlas('mainmenu/menuCharacters/Girlfriend');
        charDance.animation.addByPrefix('Idle', 'GF IDLE', 24);
	charDance.animation.play('Idle');
	charDance.updateHitbox();
	charDance.scale.x = 1.5;
	charDance.scale.y = 1.5;
        add(charDance);
				
		}

		#if MODS_ALLOWED
		mods = new FlxSprite(820, -15).loadGraphic(Paths.image('mainmenu/menuItems/mods'));
		mods.scale.x = 0.8;
		mods.scale.y = 0.8;
		add(mods);
		#end

		var moonVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Moon Engine v" + moonEngineVersion, 12);
		moonVer.scrollFactor.set();
		moonVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(moonVer);
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);
		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		#if ((LUA_ALLOWED || HSCRIPT_ALLOWED) && sys)
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'states/MainMenuState'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end

		addVirtualPad(UP_DOWN, A_B_E);

		super.create();

		FlxG.camera.follow(camFollow, null, 0);
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}
		
		#if MODS_ALLOWED
		if (FlxG.mouse.overlaps(mods))
		{
				if (FlxG.mouse.justPressed)
				{
					MusicBeatState.switchState(new ModsMenuState());
				}
			}
		#end

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;

					if (ClientPrefs.data.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						switch (optionShit[curSelected])
						{
							case 'story_mode':
								MusicBeatState.switchState(new StoryMenuState());
							case 'freeplay':
								MusicBeatState.switchState(new FreeplayState());

							#if MODS_ALLOWED
							case 'mods':
								MusicBeatState.switchState(new ModsMenuState());
							#end

							#if ACHIEVEMENTS_ALLOWED
							case 'awards':
								MusicBeatState.switchState(new AchievementsMenuState());
							#end

							case 'credits':
								MusicBeatState.switchState(new CreditsState());
							case 'options':
								MusicBeatState.switchState(new OptionsState());
								OptionsState.onPlayState = false;
								if (PlayState.SONG != null)
								{
									PlayState.SONG.arrowSkin = null;
									PlayState.SONG.splashSkin = null;
									PlayState.stageUI = 'normal';
								}
						}
					});

					for (i in 0...menuItems.members.length)
					{
						if (i == curSelected)
							continue;
						FlxTween.tween(mods, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
						FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								menuItems.members[i].kill();
							}
						});
					}
				}
			}
			else if (controls.justPressed('debug_1') || virtualPad.buttonE.justPressed)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		menuItems.members[curSelected].animation.play('idle');
		menuItems.members[curSelected].updateHitbox();
		//menuItems.members[curSelected].screenCenter(X);

		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.members[curSelected].animation.play('selected');
		menuItems.members[curSelected].centerOffsets();
		//menuItems.members[curSelected].screenCenter(X);

		camFollow.setPosition(menuItems.members[curSelected].getGraphicMidpoint().x,
			menuItems.members[curSelected].getGraphicMidpoint().y - (menuItems.length > 4 ? menuItems.length * 8 : 0));
	}
}
