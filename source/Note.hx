package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import PlayState;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;
	public var baseStrum:Float = 0;
	
	public var rStrumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var rawNoteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var originColor:Int = 0; // The sustain note's original note's color
	public var noteSection:Int = 0;
	public var hittingNotRequired:Bool = false;
	public var missingIsRequired:Bool = false;
	public var noteType:String = "normal";

	public var noteCharterObject:FlxSprite;

	public var noteScore:Float = 1;

	public var noteYOff:Int = 0;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var rating:String = "shit";

	public var modAngle:Float = 0; // The angle set by modcharts
	public var localAngle:Float = 0; // The angle to be edited inside Note.hx

	public var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];
	public var quantityColor:Array<Int> = [RED_NOTE, 2, BLUE_NOTE, 2, PURP_NOTE, 2, BLUE_NOTE, 2];
	public var arrowAngles:Array<Int> = [180, 90, 270, 0];

	public var isParent:Bool = false;
	public var parent:Note = null;
	public var spotInLine:Int = 0;
	public var sustainActive:Bool = true;

	public var children:Array<Note> = [];

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		if (inCharter)
		{
			this.strumTime = strumTime;
			rStrumTime = strumTime;
		}
		else
		{
			this.strumTime = strumTime;
			rStrumTime = strumTime - (FlxG.save.data.offset + PlayState.songOffset);
			#if sys
			if (PlayState.isSM)
			{
				rStrumTime = Math.round(rStrumTime + Std.parseFloat(PlayState.sm.header.OFFSET));
			}
			#end
		}


		if (this.strumTime < 0 )
			this.strumTime = 0;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		//defaults if no noteStyle was found in chart
		var noteTypeCheck:String = 'normal';

		if (inCharter)
		{
			frames = Paths.getSparrowAtlas('NOTE_assets');


			switch (PlayState.SONG.noteStyle)
			{
				case 'pixel':
					loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels','week6'), true, 17, 17);
			
					animation.add('greenScroll', [6]);
					animation.add('redScroll', [7]);
					animation.add('blueScroll', [5]);
					animation.add('purpleScroll', [4]);
			
					if (isSustainNote)
					{
						loadGraphic(Paths.image('weeb/pixelUI/arrowEnds','week6'), true, 7, 6);
			
						animation.add('purpleholdend', [4]);
						animation.add('greenholdend', [6]);
						animation.add('redholdend', [7]);
						animation.add('blueholdend', [5]);
			
						animation.add('purplehold', [0]);
						animation.add('greenhold', [2]);
						animation.add('redhold', [3]);
						animation.add('bluehold', [1]);
					}
			
					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();
				default:
					frames = Paths.getSparrowAtlas('NOTE_assets');
			
					animation.addByPrefix('greenScroll', 'green0');
					animation.addByPrefix('redScroll', 'red0');
					animation.addByPrefix('blueScroll', 'blue0');
					animation.addByPrefix('purpleScroll', 'purple0');
					animation.addByPrefix('sunScroll', 'sun0');
					animation.addByPrefix('sunExtraScroll', 'sun-extra0');
					animation.addByPrefix('sunBombScroll', 'sun-bomb0');
			
					animation.addByPrefix('purpleholdend', 'pruple end hold');
					animation.addByPrefix('greenholdend', 'green hold end');
					animation.addByPrefix('redholdend', 'red hold end');
					animation.addByPrefix('blueholdend', 'blue hold end');
					animation.addByPrefix('sunholdend', 'sun hold end');
					animation.addByPrefix('sunextraholdend', 'sun-extra hold end');
					animation.addByPrefix('sunbombholdend', 'sun-bomb hold end');
			
					animation.addByPrefix('purplehold', 'purple hold piece');
					animation.addByPrefix('greenhold', 'green hold piece');
					animation.addByPrefix('redhold', 'red hold piece');
					animation.addByPrefix('bluehold', 'blue hold piece');
					animation.addByPrefix('sunhold', 'sun hold piece');
					animation.addByPrefix('sunextrahold', 'sun-extra hold piece');
					animation.addByPrefix('sunbombhold', 'sun-bomb hold piece');
			
					setGraphicSize(Std.int(width * 0.7));
					updateHitbox();
					antialiasing = true;
			}
		}
		else
		{
			if (PlayState.SONG.noteStyle == null) {
				switch(PlayState.storyWeek) {case 6: noteTypeCheck = 'pixel';}
			} else {noteTypeCheck = PlayState.SONG.noteStyle;}
			


			switch (noteTypeCheck)
			{
				case 'pixel':
					loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels','week6'), true, 17, 17);
			
					animation.add('greenScroll', [6]);
					animation.add('redScroll', [7]);
					animation.add('blueScroll', [5]);
					animation.add('purpleScroll', [4]);
			
					if (isSustainNote)
					{
						loadGraphic(Paths.image('weeb/pixelUI/arrowEnds','week6'), true, 7, 6);
			
						animation.add('purpleholdend', [4]);
						animation.add('greenholdend', [6]);
						animation.add('redholdend', [7]);
						animation.add('blueholdend', [5]);
			
						animation.add('purplehold', [0]);
						animation.add('greenhold', [2]);
						animation.add('redhold', [3]);
						animation.add('bluehold', [1]);
					}
			
					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();
				default:
					frames = Paths.getSparrowAtlas('NOTE_assets');
			
					animation.addByPrefix('greenScroll', 'green0');
					animation.addByPrefix('redScroll', 'red0');
					animation.addByPrefix('blueScroll', 'blue0');
					animation.addByPrefix('purpleScroll', 'purple0');
					animation.addByPrefix('sunScroll', 'sun0');
					animation.addByPrefix('sunExtraScroll', 'sun-extra0');
					animation.addByPrefix('sunBombScroll', 'sun-bomb0');
			
					animation.addByPrefix('purpleholdend', 'pruple end hold');
					animation.addByPrefix('greenholdend', 'green hold end');
					animation.addByPrefix('redholdend', 'red hold end');
					animation.addByPrefix('blueholdend', 'blue hold end');
					animation.addByPrefix('sunholdend', 'sun hold end');
					animation.addByPrefix('sunextraholdend', 'sun-extra hold end');
					animation.addByPrefix('sunbombholdend', 'sun-bomb hold end');
			
					animation.addByPrefix('purplehold', 'purple hold piece');
					animation.addByPrefix('greenhold', 'green hold piece');
					animation.addByPrefix('redhold', 'red hold piece');
					animation.addByPrefix('bluehold', 'blue hold piece');
					animation.addByPrefix('sunhold', 'sun hold piece');
					animation.addByPrefix('sunextrahold', 'sun-extra hold piece');
					animation.addByPrefix('sunbombhold', 'sun-bomb hold piece');
			
					setGraphicSize(Std.int(width * 0.7));
					updateHitbox();
					antialiasing = true;
			}
			
		}

		x += swagWidth * noteData;
		animation.play(dataColor[noteData] + 'Scroll');
		originColor = noteData; // The note's origin color will be checked by its sustain notes

		if (FlxG.save.data.stepMania && !isSustainNote)
		{
			var strumCheck:Float = rStrumTime;

			// I give up on fluctuating bpms. something has to be subtracted from strumCheck to make them look right but idk what.
			// I'd use the note's section's start time but neither the note's section nor its start time are accessible by themselves
			//strumCheck -= ???

			var ind:Int = Std.int(Math.round(strumCheck / (Conductor.stepCrochet / 2)));

			var col:Int = 0;
			col = quantityColor[ind % 8]; // Set the color depending on the beats

			switch(noteType)
			{
				case 'sun':
					x += swagWidth * noteData;
					animation.play('sunScroll');
				case 'sun-extra':
					x += swagWidth * noteData;
					animation.play('sunExtraScroll');
					hittingNotRequired = true;
				case 'sun-bomb':
					x += swagWidth * noteData;
					animation.play('sunBombScroll');
					missingIsRequired = true;
					mustPress=false;
					
				default:
				switch (noteData)
				{
					case 0:
						x += swagWidth * 0;
						animation.play('purpleScroll');
					case 1:
						x += swagWidth * 1;
						animation.play('blueScroll');
					case 2:
						x += swagWidth * 2;
						animation.play('greenScroll');
					case 3:
						x += swagWidth * 3;
						animation.play('redScroll');
				}
			}
			localAngle -= arrowAngles[col];
			localAngle += arrowAngles[noteData];
			originColor = col;
		}
		
		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		// then what is this lol
		if (FlxG.save.data.downscroll && sustainNote) 
			flipY = true;

		var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed, 2));

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			switch(noteType)
			{
				case 'sun':
					animation.play('sunholdend');
				case 'sun-extra':
					animation.play('sunextraholdend');
				case 'sun-bomb':
					animation.play('sunbombholdend');
				default:
				switch (noteData)
				{
					case 2:
						animation.play('greenholdend');
					case 3:
						animation.play('redholdend');
					case 1:
						animation.play('blueholdend');
					case 0:
						animation.play('purpleholdend');
				}
			}
// This works both for normal colors and quantization colors
			updateHitbox();

			x -= width / 2;

			//if (noteTypeCheck == 'pixel')
			//	x += 30;
			if (inCharter)
				x += 30;

			if (prevNote.isSustainNote)
			{
				switch(noteType)
				{
					case 'sun':
						animation.play('sunhold');
					case 'sun-extra':
						animation.play('sunextrahold');
					case 'sun-bomb':
						animation.play('sunbombhold');
					default:
					switch (prevNote.noteData)
					{
						case 0:
							prevNote.animation.play('purplehold');
						case 1:
							prevNote.animation.play('bluehold');
						case 2:
							prevNote.animation.play('greenhold');
						case 3:
							prevNote.animation.play('redhold');
					}
				}
				prevNote.updateHitbox();

				prevNote.scale.y *= (stepHeight + 1) / prevNote.height; // + 1 so that there's no odd gaps as the notes scroll
				prevNote.updateHitbox();
				prevNote.noteYOff = Math.round(-prevNote.offset.y);

				// prevNote.setGraphicSize();

				noteYOff = Math.round(-offset.y);
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		angle = modAngle + localAngle;

		if (!modifiedByLua)
		{
			if (!sustainActive)
			{
				alpha = 0.3;
			}
		}

		if (mustPress)
		{
			// ass
			if (isSustainNote)
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
					canBeHit = true;
				else
					canBeHit = false;
			}

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
