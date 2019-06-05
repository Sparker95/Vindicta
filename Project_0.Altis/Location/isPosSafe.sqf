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

pr0_fn_getGlobalRectAndSize = {
	params [["_pos", [], [[]]], ["_dir", 0, [0]], ["_bbox", [], [[]]] ];
	
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

params [ ["_thisClass", "", [""]], ["_pos", [], [[]]], ["_dir", 0, [0]], ["_className", "", [""]] ];

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

// private _bb = [_className] call misc_fnc_boundingBoxReal;
// private _bx = _bb select 1 select 0; //width
// private _by = _bb select 1 select 1; //lenth
// private _bz = _bb select 1 select 2; //height

// #ifdef DEBUG
// diag_log format ["  Classname: %1, bounding box: %2", _className, _bb];
// #endif

// private _c = cos _dir;
// private _s = sin _dir;

// /*
// Get positions of corners of bounding box and rotate them _dir degrees.
// Positions are:
// 3	0
//  \ /
//   O
//  / \
// 2   1
// */

// private _posASL = ATLTOASL _pos;
// private _pos_0 = _posASL vectorAdd [_bx*_c + _by*_s, -_bx*_s + _by*_c, 1];
// private _pos_1 = _posASL vectorAdd [_bx*_c - _by*_s, -_bx*_s - _by*_c, 1];
// private _pos_2 = _posASL vectorAdd [-_bx*_c - _by*_s, _bx*_s - _by*_c, 1];
// private _pos_3 = _posASL vectorAdd [-_bx*_c + _by*_s, _bx*_s + _by*_c, 1];

//private _rect = [_pos_0, _pos_1, _pos_2, _pos_3];

// // Debug drawing
// #ifdef DEBUG
// diag_log format ["--- Positions ATL: %1", [[ASLTOATL _pos_0], [ASLTOATL _pos_1], [ASLTOATL _pos_2], [ASLTOATL _pos_3]]];
// {
// 	createVehicle ["Sign_Arrow_F", ASLTOATL _x, [], 0, "CAN_COLLIDE"];
// } forEach [_pos_0, _pos_1, _pos_2, _pos_3];


// [{
// 	(_this select 0) params ["_pos_0", "_pos_1", "_pos_2", "_pos_3"];
// 	private _color = [1,1,0,1];
// 	drawLine3D [_pos_0, _pos_2, _color];
// 	drawLine3D [_pos_1, _pos_3, _color];
// 	drawLine3D [_pos_1, _pos_2, _color];
// 	drawLine3D [_pos_0, _pos_3, _color];
// },
// 0,
// [ASLToAGL _pos_0, ASLToAGL _pos_1, ASLToAGL _pos_2, ASLToAGL _pos_3]] call CBA_fnc_addPerFrameHandler;

// diag_log format ["  Pos 0...3 AGL: %1", [ASLToAGL _pos_0, ASLToAGL _pos_1, ASLToAGL _pos_2, ASLToAGL _pos_3]];
// #endif

([
	_pos, _dir, 
	[_className] call misc_fnc_boundingBoxReal
] call pr0_fn_getGlobalRectAndSize) params ["_rect3D", "_size"];

// private _o = 
// 		  lineIntersectsSurfaces [_rect3D#0, _rect3D#2, objNull, objNull, false];
// _o append lineIntersectsSurfaces [_rect3D#1, _rect3D#3, objNull, objNull, false];
// _o append lineIntersectsSurfaces [_rect3D#1, _rect3D#2, objNull, objNull, false];
// _o append lineIntersectsSurfaces [_rect3D#0, _rect3D#3, objNull, objNull, false];

// if(count _o > 0) exitWith
// {
// 	#ifdef DEBUG
// 	diag_log "  Line intersects with a surface";
// 	#endif
// 	false
// };

//private _radius = sqrt (_size#0*_size#0 + _size#1*_size#1);

// TODO: expand the class set here?
private _o = nearestObjects [_pos, [], 15, true] - (_pos nearRoads 15);

_o findIf {
	//private _className = typeOf _x;
	private _bbox = 0 boundingBoxReal _x;
	// if(_className != "") then {
	// 	[_className] call misc_fnc_boundingBoxReal
	// } else {
	// 	boundingBoxReal _x
	// };
	([getPos _x, getDir _x, _bbox] call pr0_fn_getGlobalRectAndSize) params ["_oRect3D", "_oSize"];
	if(_oSize#2 > 0.3) then {
		[_rect3D, _oRect3D] call misc_fnc_polygonCollision
	} else {
		false
	}
} == -1
