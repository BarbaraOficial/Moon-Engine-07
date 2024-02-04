package states;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		var guh:String;

		if (controls.mobileC) {
			guh = "Sup kiddo, looks like you're running an   \n
			outdated version of Moon Engine (" + MainMenuState.moonEngineVersion + "),\n
			please update to " + TitleState.updateVersion + "!\n
			Press B to proceed anyway.\n
			\n
			Thank you for using Engine!";
		} else {
			guh = "Sup bro, looks like you're running an   \n
			outdated version of Moon Engine (" + MainMenuState.moonEngineVersion + "),\n
			please update to " + TitleState.updateVersion + "!\n
			Press ESCAPE to proceed anyway.\n
			\n
			Thank you for using Engine!";
		}

		warnText = new FlxText(0, 0, FlxG.width, guh, 32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);

		addVirtualPad(NONE, A_B);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT) {
				leftState = true;
				CoolUtil.browserLoad("https://gamebanana.com/tools/14569");
			}
			else if(controls.BACK) {
				leftState = true;
			}

			if(leftState)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						MusicBeatState.switchState(new MainMenuState());
					}
				});
			}
		}
		super.update(elapsed);
	}
}
