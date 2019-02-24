/*
Returns true if the place is good for spawning specific vehicle.
The main method of this function - checking vehicles inside the bounding box.
Houses and buildings are ignored.
_posAndDir - [_x, _y, _z, _dir], in format positionATL
*/

params ["_posAndDir", "_vehType"];

private _bb = [_vehType] call loc_fnc_boundingBoxReal;
private _bx = _bb select 1 select 0; //width
private _by = _bb select 1 select 1; //lenth
private _bz = _bb select 1 select 2; //height
private _pos = _posAndDir select [0, 3];
private _dir = _posAndDir select 3;

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


pos_0 = _pos_0;
pos_1 = _pos_1;
pos_2 = _pos_2;
pos_3 = _pos_3;


//Draw the 3D lines for debug
/*
onEachFrame {
	private _counter = 0;
	drawLine3D [ASLTOATL pos_0, ASLTOATL pos_2, [0.0,1,1,1]];
	drawLine3D [ASLTOATL pos_1, ASLTOATL pos_3, [0.0,1,1,1]];
};
*/

//Find objects
//First check with line intersections
private _o = lineIntersectsObjs [_pos_0, _pos_2, objNull, objNull, false, 16+32]; //CF_FIRST_CONTACT + CF_ALL_OBJECTS
_o append lineIntersectsObjs [_pos_1, _pos_3, objNull, objNull, false, 16+32]; //CF_FIRST_CONTACT + CF_ALL_OBJECTS
private _i = 0;
private _c = count _o;
private _good = true;
private _t = ""; //type of object
//private _checkHumans = (_vehType isKindOf ["man", configFile >> "cfgVehicles"]); //Ignore humans if _vehType is not a human
//diag_log format ["fn_isPosSafe: line intersections: %1", _o];
while {_i < _c} do
{
	_t = typeOf (_o select _i);
	//diag_log format ["type: %1", _t];
	if ((_t isKindOf ["allVehicles", configFile >> "cfgVehicles"]) &&
	    (!(_t isKindOf ["man", configFile >> "cfgVehicles"]))) exitWith
    {
    	_good = false;
    };
    _i = _i + 1;
};

if(!_good) exitWith
{
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
_o = nearestObjects [_posCheck, ["allVehicles"], _bx max 1.7, true];
//player setPos _pos;
//diag_log format ["fn_isPosSafe: near objects %1: %2", _bx, _o];
_i = 0;
_c = count _o;
private _t = ""; //type of object
while {_i < _c && _good} do
{
	_t = typeOf (_o select _i);
	if (!(_t isKindOf ["man", configFile >> "allVehicles"])) then
    {
    	_good = false;
    };
    _i = _i + 1;
};

_good
