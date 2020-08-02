#include "..\common.h"

// Class: Location
/*
Method: (static)isPosSafe
Returns true if the place is good for spawning specific vehicle.
The main method of this function - checking vehicles inside the bounding box.
Houses and buildings are ignored.

Parameters: _pos, _dir, _className
_pos - position ATL
_dir - direction
_className - vehicle class name

Returns: Bool

Author: Sparker 29.07.2018
*/

//#define DEBUG

params [P_THISCLASS, P_ARRAY("_pos"), P_NUMBER("_dir"), P_STRING("_className") ];

// Bail if Z is below surface, as it happens with positions of bridges
#ifdef DEBUG
diag_log format ["--- is pos safe: %1, dir: %2, class name: %3", _pos, _dir, _className];
#endif

if (_pos#2 < -0.3) exitWith {
	#ifdef DEBUG
	diag_log format ["--- Position %1 is below ground!", _pos];
	#endif
	false
};

private _bb = [_className] call misc_fnc_boundingBoxReal;
private _bx = _bb#1#0; //width
private _by = _bb#1#1; //length
private _bz = _bb#1#2; //height

#ifdef DEBUG
diag_log format ["  Classname: %1, bounding box: %2", _className, _bb];
#endif

private _c = cos _dir;
private _s = sin _dir;

/*
Get positions of corners of bounding box and rotate them _dir degrees.
Positions are:
3	0
 \ /
  O
 / \
2   1
*/

private _posASL = ATLTOASL _pos;
private _pos_0 = _posASL vectorAdd [_bx*_c + _by*_s, -_bx*_s + _by*_c, 1];
private _pos_1 = _posASL vectorAdd [_bx*_c - _by*_s, -_bx*_s - _by*_c, 1];
private _pos_2 = _posASL vectorAdd [-_bx*_c - _by*_s, _bx*_s - _by*_c, 1];
private _pos_3 = _posASL vectorAdd [-_bx*_c + _by*_s, _bx*_s + _by*_c, 1];


// Debug drawing
#ifdef DEBUG
diag_log format ["--- Positions ATL: %1", [[ASLTOATL _pos_0], [ASLTOATL _pos_1], [ASLTOATL _pos_2], [ASLTOATL _pos_3]]];
{
	createVehicle ["Sign_Arrow_F", ASLTOATL _x, [], 0, "CAN_COLLIDE"];
} forEach [_pos_0, _pos_1, _pos_2, _pos_3];


[
	{
		(_this select 0) params ["_pos_0", "_pos_1", "_pos_2", "_pos_3"];
		private _color = [1,1,0,1];
		drawLine3D [_pos_0, _pos_2, _color];
		drawLine3D [_pos_1, _pos_3, _color];
		drawLine3D [_pos_1, _pos_2, _color];
		drawLine3D [_pos_0, _pos_3, _color];
	},
	0,
	[ASLToAGL _pos_0, ASLToAGL _pos_1, ASLToAGL _pos_2, ASLToAGL _pos_3]
] call CBA_fnc_addPerFrameHandler;

diag_log format ["  Pos 0...3 AGL: %1", [ASLToAGL _pos_0, ASLToAGL _pos_1, ASLToAGL _pos_2, ASLToAGL _pos_3]];
#endif

//Find objects
//First check with line intersections
private _o = lineIntersectsObjs [_pos_0, _pos_2, objNull, objNull, false, 16+32]; //CF_FIRST_CONTACT + CF_ALL_OBJECTS
_o append lineIntersectsObjs [_pos_1, _pos_3, objNull, objNull, false, 16+32]; //CF_FIRST_CONTACT + CF_ALL_OBJECTS
_o append lineIntersectsObjs [_pos_1, _pos_2, objNull, objNull, false, 16+32]; //CF_FIRST_CONTACT + CF_ALL_OBJECTS
_o append lineIntersectsObjs [_pos_0, _pos_3, objNull, objNull, false, 16+32]; //CF_FIRST_CONTACT + CF_ALL_OBJECTS
private _i = 0;
private _c = count _o;
private _good = true;
private _t = ""; //type of object
//private _checkHumans = (_vehType isKindOf ["man", configFile >> "cfgVehicles"]); //Ignore humans if _vehType is not a human

#ifdef DEBUG
diag_log format ["  fn_isPosSafe: line intersections: %1", _o];
#endif

while {_i < _c} do
{
	private _obj = _o select _i;
	//diag_log format ["type: %1", _t];
	if ( ( (_obj isKindOf "allVehicles") || (_obj isKindOf "ThingX") ) &&
	    (!(_obj isKindOf "Man")) ) exitWith {
    	_good = false;
    };
    _i = _i + 1;
};

if(!_good) exitWith
{
	#ifdef DEBUG
	diag_log "  Line intersects with a vehicle";
	#endif
	false
};

//Check for objects in sphere
private _posCheck = _pos; //_pos vectorAdd [0, 0, _bz];

//Test: create arrow
/*
private _arrow = "Sign_Arrow_F" createVehicle _pos;
_arrow setPosATL _posCheck;
*/

//diag_log format ["%1 %2", _posCheck, _bx];
private _radius = sqrt (_bx*_bx + _by*_by);
_o = nearestObjects [_posCheck, ["allVehicles", "ThingX"], (_radius + 1) max 1.7, true];
//player setPos _pos;

#ifdef DEBUG
diag_log format ["fn_isPosSafe: near objects %1: %2", _bx, _o];
#endif

_i = 0;
_c = count _o;
private _t = ""; //type of object
while {_i < _c && _good} do {
	private _obj = _o select _i;
	if (!(_obj isKindOf "Man")) then {
    	_good = false;
		#ifdef DEBUG
		diag_log "  Found a vehicle inside sphere!";
		#endif
    };
    _i = _i + 1;
};

#ifdef DEBUG
diag_log format ["  Position safe: %1", _good];
#endif

_good
