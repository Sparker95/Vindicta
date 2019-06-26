params ["_unit"];

[_unit,"Hello",player] call Dialog_fnc_hud_createSentence;
[player,"Hello",_unit] call Dialog_fnc_hud_createSentence;