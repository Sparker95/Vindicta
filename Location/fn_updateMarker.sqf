/*
Updates the marker's text, color, etc.
Text of marker is: "alert state"  + "location type"
*/

params ["_loc"];

private _m = _loc getVariable ["l_marker", ""];

if(_m == "") exitWith {};

//Alert state
private _alertStateText = "x";
private _as = _loc getVariable ["l_alertState", 0];
switch (_as) do
{
	case G_AS_safe: {_alertStateText = "SAFE ";};
	case G_AS_aware: {_alertStateText = "AWARE ";};
	case G_AS_combat: {_alertStateText = "COMBAT ";};
};

//Side
private _sideText = "xx";
private _sideColor = "ColorPink";
private _gar = [_loc] call loc_fnc_getMainGarrison;
private _side = [_gar] call gar_fnc_getSide;
switch(_side) do
{
	case WEST: {_sideColor = "ColorWest";};
	case EAST: {_sideColor = "ColorEAST";};
	case INDEPENDENT: {_sideColor = "ColorGUER";};
};

//Location type
private _typeText = "xxx";
private _type = _loc getVariable ["l_type", 0];

switch(_type) do
{
	case LOC_TYPE_base: {_typeText = "Base";};
	case LOC_TYPE_outpost: {_typeText = "Outpost";};
	case LOC_TYPE_roadblock: {_typeText = "Roadblock";};
};

//Set marker properties
_m setMarkerShape 'ICON';
_m setMarkerSize [1, 1];
_m setMarkerColor _sideColor;
_m setMarkerType "mil_dot";
_m setMarkerText (_alertStateText + _typeText);