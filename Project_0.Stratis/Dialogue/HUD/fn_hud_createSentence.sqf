#include "defineCommon.inc"




params[["_unit",objnull,[objnull]],["_sentence","",[""]]];

if(!hasinterface||{isnull _unit})exitWith{};

//_unit = selectRandom allunits;
//_sentence = selectRandom ["Hello","Bye","What are you doing","What can i do for you?","Where are you going"];

private _color = [side _unit,false] call BIS_fnc_sideColor;
private _colorHTML = _color call BIS_fnc_colorRGBtoHTML;
private _display = findDisplay 46;
private _frame =  _display getvariable ["Dialog_compas_frame" ,controlNull];
private _name = name _unit;
private _icon = controlNull;
_sentence = if(_unit isequalto player)then{
	//return
	parseText format ["<t align = 'right' shadow = '2' size = '1'><t color = '#FFA300'>%1",_sentence];
}else{
	

	_icon = _display ctrlCreate ["rscstructuredtext", -1,_frame];
	//_icon ctrlsetBackgroundColor [.5,.5,.5,.5];
	//_icon ctrlSetTextColor _color;
	_icon ctrlSetPosition [0,0,FLOAT_ICON_WITDH,0.2];
	_icon ctrlCommit 0;
	_icon ctrlSetStructuredText parseText format ["<t align = 'center' shadow = '2' size = '1'><t color = '#FFFFFF'><img image='%2'/><t color = '%1'><br/>%3:</t>",_colorHTML,STRING_ICON_UP_ARROW,_name];
	
	//return
	parseText format ["<t align = 'left' shadow = '2' size = '1'><t color = '%1'>%2:</t> <t color = '#FFFFFF'>%3",_colorHTML,_name,_sentence];
};

private _text = _display ctrlCreate ["rscstructuredtext", -1];
_text ctrlsetBackgroundColor [.5,.5,.5,.5];
//_text ctrlSetTextColor _color;
_text ctrlSetPosition [0,0,1,0.05];
_text ctrlCommit 0;
_text ctrlSetStructuredText _sentence;

_fadeTime = time + FLOAT_DISPLAYTIME; 
_removeTime = _fadeTime + FLOAT_FADE_OUT; 
private _ctrl_sets = _display getvariable ["Dialog_text_ctrlSet" ,[]];
_ctrl_sets pushBack [_icon, _text,_unit,_fadeTime,_removeTime];
_display setvariable ["Dialog_text_ctrlSet" ,_ctrl_sets];










