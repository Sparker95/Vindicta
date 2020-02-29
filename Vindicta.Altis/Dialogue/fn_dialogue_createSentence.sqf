#include "defineCommon.inc"

/*
    By: Jeroen Notenbomer

    Create simple dialogue for nearby and spoken to playable units.
	Script needs to be run locally
	
	Input:
		_speaker: unit who is talking
		_listener(optional): To whome is he talking, by default talking to nearby units
		_sentence: What needs to be said
		_options: If you want to create a question with some answers
		
	Output:
		controlObj: the created sentence 
*/


params[["_speaker",objnull,[objnull]],["_listener",objnull,[objnull]],["_sentence","",[""]],["_options",[],[[]]]];

diag_log str ["createSentence1",_sentence];

if(!hasinterface)exitWith{};

disableSerialization;

private _display = findDisplay 46;

private _hud = call pr0_fnc_dialogue_createHUD;

//create ctrl to store everything in
private _ctrl_sentence = _display ctrlCreate ["rscstructuredtext", -1];
_ctrl_sentence ctrlsetBackgroundColor [0, 0, 0, 0.6];
//_ctrl_sentence ctrlSetTextColor _color;
_ctrl_sentence ctrlSetPosition [666,0,1,FLOAT_TEXT_HIGHT];//spawn it out of view
_ctrl_sentence ctrlCommit 0;

private _type = 		[TYPE_SENTENCE, TYPE_QUESTION]		select (count _options > 0);
private _removeTime = 	time + FLOAT_DISPLAYTIME; 
_ctrl_sentence setVariable ["_removeTime",_removeTime];

_ctrl_sentence setVariable ["_speaker", _speaker];
_ctrl_sentence setVariable ["_listener", _listener];
_ctrl_sentence setVariable ["_sentence", _sentence];
_ctrl_sentence setVariable ["_options", _options];
_ctrl_sentence setVariable ["_type", _type];

//create the text that is displayed.
[_ctrl_sentence] call pr0_fnc_dialogue_updateSentence;


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
		private _color = [side _speaker,false] call BIS_fnc_sideColor; // Some colors don't look readable...
		private _colorHTML = _color call BIS_fnc_colorRGBtoHTML;
		private _colorTextHTML = ["#FFFFFF","#898989"] select (_listener != player);
		
		
		_ctrl_icon = _display ctrlCreate ["rscstructuredtext", -1, _hud];
		_ctrl_icon ctrlSetPosition [666,0,FLOAT_ICON_WITDH,0.2];//spawn it out of view 
		_ctrl_icon ctrlSetStructuredText parseText format ["<t font='RobotoCondensed' align = 'center' size = '1.05'><t color = '#FFFFFF'><img image='%2'/><t color = '%1'><br/>%3:</t>",_colorHTML,STRING_ICON_UP_ARROW,name _speaker];
		_ctrl_icon ctrlSetFade 1;//start hidden and slowly fade in
		_ctrl_icon ctrlCommit 0;
		
		_ctrl_icon setVariable ["_ctrl_sentences", [_ctrl_sentence]];
		_ctrl_icon setVariable ["_speaker", _speaker];
		
		_ctrl_icons pushBack _ctrl_icon;
		_display setvariable ["pr0_dialogue_icon_list" ,_ctrl_icons];
	};
	
	//needs to be done here because used icon might have start fading away
	_ctrl_icon ctrlSetFade 0;
	_ctrl_icon ctrlCommit FLOAT_FADE_TIME;
	
	diag_log "_hud ctrlSetFade 0";
	_hud ctrlSetFade 0;
	_hud ctrlCommit FLOAT_FADE_TIME;
	
};
_ctrl_sentence setVariable ["_ctrl_icon",_ctrl_icon];

//update list so it will be updated automaticly in dialogue_init
private _ctrl_sentences = _display getvariable ["pr0_dialogue_sentence_list" ,[]];
_ctrl_sentences pushBack _ctrl_sentence;
_display setvariable ["pr0_dialogue_sentence_list" ,_ctrl_sentences];

//if there are to many sentences on the screen remove one
if(count _ctrl_sentences > INT_SENTENCE_LIMIT)then{
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
	_script = [_speaker,_listener] spawn {
		params["_speaker","_listener"];
		_speaker setRandomLip true;
		waitUntil{
			if (!isNull _listener) then { _speaker lookAt _listener; };
			sleep 0.3;
			( time > _speaker getvariable ["pr0_dialogue_lip_timer",0]);
		};
		_speaker setRandomLip false;
		_speaker doWatch objnull;
	};
	_speaker setvariable ["pr0_dialogue_lip_script",_script];
};


_ctrl_sentence;






