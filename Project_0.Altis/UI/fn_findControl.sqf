/*
Function: ui_fnc_findControl
Finds a control inside an existing display

Paramters: _display, _controlClassName

Returns: control or controlNull
*/

#define pr private

params [["_display", displayNull, [displayNull]], ["_controlClassName", "", [""]]];

pr _allControls = allControls _display;
pr _index = _allControls findIf {_controlClassName in [ctrlClassName _x, _x getVariable ["_trueClassName", ""]]};
if (_index != -1) then {
	_allControls select _index
} else {
	controlNull
};