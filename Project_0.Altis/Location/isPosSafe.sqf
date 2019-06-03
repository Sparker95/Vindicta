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

private _bb = [_className] call misc_fnc_boundingBoxReal;
private _bx = _bb select 1 select 0; //width
private _by = _bb select 1 select 1; //lenth
private _bz = _bb select 1 select 2; //height

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


[{
	(_this select 0) params ["_pos_0", "_pos_1", "_pos_2", "_pos_3"];
	private _color = [1,1,0,1];
	drawLine3D [_pos_0, _pos_2, _color];
	drawLine3D [_pos_1, _pos_3, _color];
	drawLine3D [_pos_1, _pos_2, _color];
	drawLine3D [_pos_0, _pos_3, _color];
},
0,
[ASLToAGL _pos_0, ASLToAGL _pos_1, ASLToAGL _pos_2, ASLToAGL _pos_3]] call CBA_fnc_addPerFrameHandler;

diag_log format ["  Pos 0...3 AGL: %1", [ASLToAGL _pos_0, ASLToAGL _pos_1, ASLToAGL _pos_2, ASLToAGL _pos_3]];
#endif

private _o = 
		  lineIntersectsSurfaces [_pos_0, _pos_2, objNull, objNull, false];
_o append lineIntersectsSurfaces [_pos_1, _pos_3, objNull, objNull, false];
_o append lineIntersectsSurfaces [_pos_1, _pos_2, objNull, objNull, false];
_o append lineIntersectsSurfaces [_pos_0, _pos_3, objNull, objNull, false];

if(count _o > 0) exitWith
{
	#ifdef DEBUG
	diag_log "  Line intersects with a surface";
	#endif
	false
};

private _radius = sqrt (_bx*_bx + _by*_by);
// TODO: expand the class set here?
private _o = nearestObjects [_pos, ["allVehicles"], (_radius + 1) max 1.7, true];
count _o == 0
