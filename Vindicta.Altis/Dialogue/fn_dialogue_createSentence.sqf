#include "defineCommon.inc"

/*
    By: Jeroen Notenbomer

    Show sentence on screen
	Script needs to be run locally. So better use CreateSimple.sqf!
	
	Input:
		_speaker: unit who is talking
		_sentence: What needs to be said
		_anwers: If you want to create a question with some answers
		
	Output:
		controlObj: the created sentence 
*/


params[["_speaker",objnull,[objnull]],["_sentence","",[""]],["_loudness",1,[0]],["_answers",[],[[]]]];

if(!hasinterface)exitWith{};

disableSerialization;

private _display = findDisplay 46;

private _hud = call pr0_fnc_dialogue_createHUD;


//fade if player is further away
private _fade = ((_speaker distance player) / FLOAT_MAX_LISTENING_DISTANCE * _loudness)*0.9;


/*remove random letters if far away
private _array = toArray _sentence;
{
	if(random 1 < _fade-0.4)then{_array set [_foreachIndex, 1]};
}forEach _array;
_sentence = toString _array;
*/


//create ctrl to store everything in
private _ctrl_sentence = _display ctrlCreate ["rscstructuredtext", -1];
//_ctrl_sentence ctrlsetBackgroundColor [0, 0, 0, 0.6];

//_ctrl_sentence ctrlSetPosition ( worldToScreen ASLToAGL eyepos _speaker + [0,FLOAT_TEXT_HIGHT]);
_ctrl_sentence ctrlSetPosition [0,FLOAT_POS_Y,1,0];
_ctrl_sentence ctrlSetFade 1;
_ctrl_sentence ctrlCommit 0;
_ctrl_sentence ctrlSetFade _fade;

private _type = 		[TYPE_SENTENCE, TYPE_QUESTION]		select (count _answers > 0);
private _removeTime = 	time + FLOAT_DISPLAYTIME; 
_ctrl_sentence setVariable ["_removeTime",_removeTime];

_ctrl_sentence setVariable ["_speaker", _speaker];
_ctrl_sentence setVariable ["_sentence", _sentence];
_ctrl_sentence setVariable ["_answers", _answers];
_ctrl_sentence setVariable ["_type", _type];
_ctrl_sentence setVariable ["_size_y",FLOAT_TEXT_HIGHT];

//create compas icon
private _ctrl_icon = controlNull;
if!(_speaker isequalto player)then{
	private _ctrl_icons = _display getvariable ["pr0_dialogue_icon_list" ,[]];
	
	//if a icon for the speaker exist use it
	{
		if (_speaker isEqualTo (_x getVariable ["_speaker", objNull]))exitWith{
			_ctrl_icon = _x;
			
			private _ctrl_sentences = _ctrl_icon getVariable ["_ctrl_sentences", []];
			_ctrl_sentences pushBack _ctrl_sentence;
			_ctrl_icon setVariable ["_ctrl_sentences", _ctrl_sentences];
			
		};
	}forEach _ctrl_icons;
	
	//nothing found? create one!
	if(isNull _ctrl_icon)then{
		

		_ctrl_icon = _display ctrlCreate ["rscstructuredtext", -1, _hud];
		_ctrl_icon ctrlSetPosition [666,0,FLOAT_ICON_WITDH,1];//spawn it out of view 
		_ctrl_icon ctrlSetFade 1;//start hidden and slowly fade in
		_ctrl_icon ctrlCommit 0;
		
		_ctrl_icon setVariable ["_ctrl_sentences", [_ctrl_sentence]];
		_ctrl_icon setVariable ["_speaker", _speaker];
		
		_ctrl_icons pushBack _ctrl_icon;
		_display setvariable ["pr0_dialogue_icon_list" ,_ctrl_icons];
	};

	_ctrl_icon setVariable ["_fade", _fade];

	//update all icons
	//we sort them so the person closed will show up on top
	private _ctrl_icons_sorted = [];
	{
		private _ctrl_icon = _x;
		//private _fade =  ctrlfade _x;
		private _fade = _ctrl_icon getVariable ["_fade",0];
		private _added = false;
		_ctrl_icons_sorted pushBack [_fade,_ctrl_icon];
	}forEach _ctrl_icons;


	_ctrl_icons_sorted sort true;

	private _breaks = "";
	private _count_breaks = 0;
	{
		_x params ["_fade", "_ctrl_icon"];
		private _speaker = _ctrl_icon getVariable ["_speaker", objNull];
		
		if(_count_breaks < 4)then{
			_count_breaks = _count_breaks +1;
			_breaks = _breaks + "<br/>";
		};

		private _color_unit = _speaker call pr0_fnc_dialogue_common_unitSideColor;
		_ctrl_icon ctrlSetStructuredText parseText format [
			"<t font='RobotoCondensed' align = 'center' size = '1'><t color = '#FFFFFF'>"+
			"<img image='%2'/><t color = '%1' shadow = '2'>%3<t size = '1'>%4</t>",
			_color_unit,STRING_ICON_UP_ARROW,_breaks,["Unknown",name _speaker]select (player knowsAbout _speaker == 4)
		];
		
	}forEach _ctrl_icons_sorted;
	

	//needs to be done here because used icon might have start fading away
	_ctrl_icon ctrlSetFade _fade;
	_ctrl_icon ctrlCommit FLOAT_FADE_TIME;
	
};
_ctrl_sentence setVariable ["_ctrl_icon",_ctrl_icon];

//update list so it will be updated automaticly in dialogue_init
private _ctrl_sentences = _display getvariable ["pr0_dialogue_sentence_list" ,[]];
_ctrl_sentences pushBack _ctrl_sentence;
_display setvariable ["pr0_dialogue_sentence_list" ,_ctrl_sentences];

//create the text that is displayed.
[_ctrl_sentence] call pr0_fnc_dialogue_updateSentence;

//check if a message on screen was ment for player so we dont remove them as fast
{
	private _ctrl_sentence = _x;
	if (_ctrl_sentence getVariable ["_speaker", objNull] isEqualTo player)exitWith{
		uiNamespace setVariable ["dialogue_player_involved_timer", time + FLOAT_TIME_INCREASE_SENTENCE_LIMIT];
	};
}forEach _ctrl_sentences;

//if there are to many sentences on the screen remove one
if(count _ctrl_sentences > 
	([INT_SENTENCE_LIMIT, INT_SENTENCE_LIMIT_PLAYER_INVOLVED] select 
		(time > uiNamespace getVariable ["dialogue_player_involved_timer",-666]))
)then{
	{
		private _ctrl_sentence = _x;
		private _type = _ctrl_sentence getVariable ["_type",TYPE_SENTENCE];
		
		//only remove normal sentences we dont want to remove unanswered questions
		if(_type == TYPE_SENTENCE)exitWith{
			_ctrl_sentence setVariable ["_removeTime",0];
		};
	}foreach _ctrl_sentences;
};

//lip sycn
private _timer = _speaker getvariable ["pr0_dialogue_lip_timer",0];
private _timer_new = (count _sentence / 12) + time;
if(_timer_new >_timer)then{
	_speaker setvariable ["pr0_dialogue_lip_timer",_timer_new];
	private _script = _speaker getvariable ["pr0_dialogue_lip_script",scriptnull];
	terminate _script;//close old
	_script = [_speaker] spawn {
		params["_speaker"];
		_speaker setRandomLip true;
		waitUntil{
			sleep 0.3;
			( time > _speaker getvariable ["pr0_dialogue_lip_timer",0]);
		};
		_speaker setRandomLip false;
		_speaker doWatch objnull;
	};
	_speaker setvariable ["pr0_dialogue_lip_script",_script];
};


_ctrl_sentence;






