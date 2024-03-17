package states;

import backend.Song;
import flixel.*;
import flixel.text.FlxText;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

class ResultsScreen extends MusicBeatSubstate
{
    var campaignScore = PlayState.campaignScore;
    var campaignMisses = PlayState.campaignMisses;
	
override function create()
{
     Timer = new FlxTimer();

                var bg = new FlxSprite(0, 0).loadGraphic(Paths.image('menuDesat'));
	        bg.setGraphicSize(FlxG.width, FlxG.height);
	        bg.screenCenter();
	        bg.scrollFactor.set();
	        add(bg);
		
		var side = FlxSprite(0, 0,).loadGraphic(Paths.image('side'));
		side.setGraphicSize(FlxG.width, FlxG.height);
		side.scrollFactor.set();
		add(side);
		
		var scoreText:FlxText = new FlxText(30, 217, 0, 'Score: 0');
		scoreText.scrollFactor.set();
		add(scoreTxt);
		
		var missesText:FlxText = new FlxText(30, 77, 0, 'Misses: 0');
		missesText.scrollFactor.set();
		add(missesText);
		
		var ratingText:FlxText = new FlxText(30, 80, 0, 'Rating: ');
		ratingText.scrollFactor.set();
		add(ratingText);
		
		var congratulations:Alphabet = new Alphabet(30, 30, 'Congratulations!');
		congratulations.scrollFactor.set();
		add(congratulations);
		
		if (PlayState.isStoryMode)
		{
			FlxTween.num(0, ${campaignScore}, 3.0, {type: FlxTweenType.ONESHOT, ease: FlxEase.cubeIn}, updateScoreResult);
			FlxTween.num(0, ${campaignMisses}, 3.0, {type: FlxTweenType.ONESHOT, ease: FlxEase.cubeIn}, updateMissResult);
		}
		else
		{
			FlxTween.num(0, ${score}, 3.0, {type: FlxTweenType.ONESHOT, ease: FlxEase.cubeIn}, updateScoreResult);
			FlxTween.num(0, ${misses}, 3.0, {type: FlxTweenType.ONESHOT, ease: FlxEase.cubeIn}, updateMissResult);
		}
		
		addVirtualPad(NONE, A);
		
		super.create();
}

override function update(elapsed:Float)
	{
		if (controls.ACCEPT || controls.BACK)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			Timer.start(1.0, changeState, 1);
		}
		
		super.update(elapsed);
	}
	
	// Project Engine code. Do not kill me please.
	function changeState(t:FlxTimer)
	{
		if (PlayState.isStoryMode)
			{
				if (PlayState.storyPlaylist.length <= 0)
				{
					MusicBeatState.switchState(new StoryMenuState());
				}
				else
				{
					var difficulty:String = Difficulty.getFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				MusicBeatState.switchState(new FreeplayState());
			}
	
// Project Engine code too :)	
function updateScoreResult(newValue:Float)
	{
		scoreText.text = 'Score: ' + Std.string(Std.int(newValue));
	}
	
// Another one from Project Engine lol
function updateMissResult(newValue:Float)
	{
		missesText.text = 'Misses: ' + Std.string(Std.int(newValue));
	}
}
