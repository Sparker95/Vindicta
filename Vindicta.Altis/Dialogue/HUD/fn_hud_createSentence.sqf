#include "defineCommon.inc"

/*
    By: Jeroen Notenbomer

    Create simple dialog for nearby and spoken to playable units.

	Input:
		_unit: unit who is talking
		_sentence: what is he talking about
		_target(optional): To whome is he talking, by default talking to nearby units
		
		_relayed(INTERNAL USE DONT USE): If this was a message from it self, to prefent endless loop
		
	Output:
		nil
*/


params[["_unit",objnull,[objnull]],["_sentence","",[""]],["_target",objnull,[objnull]],["_relayed",false,[false]]];

if(isnull _unit ||{isnull _unit})exitWith{};

diag_log format["Create Dialog from:'%1' to:'%2' saying:'%3'",name _unit,name _target,_sentence];
//set message to nearby players
//check if message was send by script, exclude relayed messag because we dont want to create a endless loop
if(!_relayed)exitWith{
	//check what players are close by
	{
		if(_unit distance _x < 5 || {_target == _x})then{
			[_unit, _sentence, _target,true] remoteExecCall ["Dialog_fnc_hud_createSentence",_x];
		};
	}forEach (allPlayers - entities "HeadlessClient_F");
};


//lip sycn
private _lipTimer = _unit getvariable ["setrandomlip_timer",0];
private _lipTimer_new = (count _sentence / 12) + time;
if(_lipTimer_new >_lipTimer)then{
	_unit setvariable ["setrandomlip_timer",_lipTimer_new];
	private _lipScript = _unit getvariable ["setrandomlip_script",scriptnull];
	terminate _lipScript;
	_lipScript = [_unit,_target] spawn {
		params["_unit","_target"];
		_unit setRandomLip true;
		waitUntil{
			if (!isNull _target) then { _unit lookAt _target; };
			sleep 0.3;
			( time > _unit getvariable ["setrandomlip_timer",0])
		};
		_unit setRandomLip false;
		_unit doWatch objnull;
	};
	_unit getvariable ["setrandomlip_script",_lipScript];
};

if(!hasinterface)exitWith{};

private _display = findDisplay 46;
private _frame =  _display getvariable ["Dialog_compas_frame" ,controlNull];

private _name = name _unit;
private _icon = controlNull;
private _structuredSentence = if(_unit isequalto player)then{
	//return
	parseText format ["<t font='RobotoCondensed' align = 'right' size = '1.05'><t color = '#FFA300'>%1",_sentence];
}else{

	private _color = [1, 1, 1, 1]; //[side _unit,false] call BIS_fnc_sideColor; // Some colors don't look readable...
	private _colorHTML = _color call BIS_fnc_colorRGBtoHTML;
	private _colorTextHTML = ["#FFFFFF","#898989"] select (_target != player);
	

	_icon = _display ctrlCreate ["rscstructuredtext", -1,_frame];
	//_icon ctrlsetBackgroundColor [.5,.5,.5,.5];
	//_icon ctrlSetTextColor _color;
	_icon ctrlSetPosition [666,0,FLOAT_ICON_WITDH,0.2];//spawn it out of site 
	_icon ctrlCommit 0;
	_icon ctrlSetStructuredText parseText format ["<t font='RobotoCondensed' align = 'center' size = '1.05'><t color = '#FFFFFF'><img image='%2'/><t color = '%1'><br/>%3:</t>",_colorHTML,STRING_ICON_UP_ARROW,_name];
	
	//return 
	parseText format ["<t font='RobotoCondensed' align = 'left' size = '1.05'><t color = '%1'>%2:</t> <t color = '%3'>%4",_colorHTML,_name,_colorTextHTML,_sentence];
};

private _text = _display ctrlCreate ["rscstructuredtext", -1];
_text ctrlsetBackgroundColor [0, 0, 0, 0.6];
//_text ctrlSetTextColor _color;
_text ctrlSetPosition [666,0,1,0.05];//spawn it out of site 
_text ctrlCommit 0;
_text ctrlSetStructuredText _structuredSentence;

private _fadeTime = time + FLOAT_DISPLAYTIME;
private _removeTime = _fadeTime + FLOAT_FADE_OUT;
private _ctrl_sets = _display getvariable ["Dialog_text_ctrlSet" ,[]];
_ctrl_sets pushBack [_icon, _text,_unit,_fadeTime,_removeTime];
_display setvariable ["Dialog_text_ctrlSet" ,_ctrl_sets];










