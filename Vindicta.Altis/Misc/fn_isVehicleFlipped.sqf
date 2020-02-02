/*
Function: misc_fnc_isVehicleFlipped
Returns true if the vehicle is flipped

Parameters: _vehicle

_vehicle - objectHandle of the vehicle
*/

// Since these vectors are normalized, we can calculate angle directly from Z component
// 0.25 is approximately 15 degrees
//#define pitchTooBig(veh) ( ((vectorDir veh) select 2) < 0.25 )
#define rollTooBig(veh) ( ((vectorUp veh) select 2) < 0.25 )

params ["_veh"];

/*
// Calculate roll (0..180)
private _vOrth = _veh vectorModelToWorld [1, 0, 0]; // Vector orthogonal to vector dir and vector up (directed to the left of the vehicle)
private _vOrthProj = [_vOrth select 0, _vOrth select 1, 0]; // Projection of _vOrth on the 
private _roll = acos (_vOrth vectorCos _vOrthProj);
if ((_vOrth select 2) < 0) then {_roll = 180-_roll;};

// Calculate pitch (0..180)
_vOrth = _veh vectorModelToWorld [0, 1, 0]; // Vector orthogonal to vector dir and vector up (directed to the left of the vehicle)
_vOrthProj = [_vOrth select 0, _vOrth select 1, 0]; // Projection of _vOrth on the
private _pitch = acos (_vOrth vectorCos _vOrthProj);
if ((_vOrth select 2) < 0) then {_pitch = 180-_pitch;};

//diag_log format ["Pitch: %1, Roll: %2, touching ground: %3", _pitch, _roll, isTouchingGround _veh];
*/
//( (_pitch > 70) || (_roll > 70) || (! (isTouchingGround _veh))) && !(canMove _veh)

( rollTooBig(_veh) || (! (isTouchingGround _veh))) && !(canMove _veh)