#include "..\common.h"

// Class: Location
/*
Method: (static)isPosEvenSafer
Returns true if the place is guaranteed safe for spawning specific vehicle.
It is very conservative and as such will disallow spawning in buildings or too close 
to existing objects.

Parameters: _pos, _dir, _className
_pos - position ATL
_dir - direction
_className - vehicle class name

Returns: Bool

Author: Sparker 29.07.2018
*/

//#define DEBUG

pr0_fn_getGlobalRectAndSize = {
	params [P_ARRAY("_pos"), P_NUMBER("_dir"), P_ARRAY("_bbox") ];
	
	private _bx = _bbox select 1 select 0; //width
	private _by = _bbox select 1 select 1; //length
	private _bz = _bbox select 1 select 2; //height

	private _c = cos _dir;
	private _s = sin _dir;

	private _posASL = ATLTOASL _pos;
	private _pos_0 = _posASL vectorAdd [_bx*_c + _by*_s, -_bx*_s + _by*_c, 0];
	private _pos_1 = _posASL vectorAdd [_bx*_c - _by*_s, -_bx*_s - _by*_c, 0];
	private _pos_2 = _posASL vectorAdd [-_bx*_c - _by*_s, _bx*_s - _by*_c, 0];
	private _pos_3 = _posASL vectorAdd [-_bx*_c + _by*_s, _bx*_s + _by*_c, 0];
	private _rect = [_pos_0, _pos_1, _pos_2, _pos_3];
	[_rect, [_bx, _by, _bz]]
};

params [P_THISCLASS, P_ARRAY("_pos"), P_NUMBER("_dir"), P_STRING("_className") ];

// Bail if Z is below surface, as it happens with positions of bridges
if (_pos#2 < -0.3) exitWith {
	false
};

([
	_pos, _dir, 
	[_className] call misc_fnc_boundingBoxReal
] call pr0_fn_getGlobalRectAndSize) params ["_rect3D", "_size"];

// TODO: expand the class set here?
private _o = nearestObjects [_pos, [], 15, true] - (_pos nearRoads 15);

_o findIf {
	#ifndef _SQF_VM
	private _bbox = 0 boundingBoxReal _x;
	#else
	private _bbox = [[0,0,0],[1,1,1],1];
	#endif
	([getPos _x, getDir _x, _bbox] call pr0_fn_getGlobalRectAndSize) params ["_oRect3D", "_oSize"];
	if(_oSize#2 > 0.3) then {
		[_rect3D, _oRect3D] call misc_fnc_polygonCollision
	} else {
		false
	}
} == -1
