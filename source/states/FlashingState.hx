package states;

import flixel.FlxSubState;

import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var background:FlxSprite;
	var warnText:FlxText;
	override function create()
	{
                FlxG.sound.playMusic(Paths.music('warning-screen'), 1); // Credits: Metroid (Nintedo game)
		
		super.create();


		var guh:String = "Hey, watch out!\n
		This Mod contains some flashing lights!\n
		Press A/ENTER to disable them now or go to Options Menu.\n
		Press B/ESCAPE to ignore this message.\n
		You've been warned!";

		background = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		background.scrollFactor.set();
		background.updateHitbox();
		background.screenCenter();
		background.color = 0xFF353535;
		add(background);

		controls.isInSubstate = false; // qhar I hate it
		warnText = new FlxText(0, 0, FlxG.width, guh, 32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);

		var creditsMusic:FlxText = new FlxText(11, FlxG.height - 40, 0, "Credits to Mario Party for the music mini games start", 25);
		creditsMusic.setFormat("VCR OSD Mono", 25, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		creditsMusic.borderSize = 2.8;
		add(creditsMusic);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x70000000, 0x0));
		grid.velocity.set(40, 40);
		add(grid);

		addVirtualPad(NONE, A_B);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if(!back) {
					ClientPrefs.data.flashing = false;
					ClientPrefs.saveSettings();
					FlxTween.tween(background, {alpha: 0}, 0.25, {startDelay: 0.25});
					FlxG.sound.play(Paths.sound('confirmMenu'));
					if (FlxG.sound.music != null)
				  	FlxTween.tween(FlxG.sound.music, {pitch: 0, volume: 0}, 1.5, {ease: FlxEase.sineInOut});
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							MusicBeatState.switchState(new TitleState());
						});
					});
				} else {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(background, {alpha: 0}, 0.25, {startDelay: 0.25});
					if (FlxG.sound.music != null)
					FlxTween.tween(FlxG.sound.music, {pitch: 0, volume: 0}, 2.5, {ease: FlxEase.sineInOut});
					FlxTween.tween(warnText, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
				}
			}
		}
		super.update(elapsed);
	}
}
