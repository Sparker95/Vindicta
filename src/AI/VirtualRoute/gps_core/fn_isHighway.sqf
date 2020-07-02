#include "macros.h"
/*
	@Author : https://forums.bistudio.com/forums/topic/175210-get-road-type/?tab=comments#comment-3224716
	@Created : ??
	@Modified : --
	@Description : Still have a lot of false-positive
	@Return : Boolean
*/

#define HIGHWAY_RADIUS 6

params [
	["_road", objNull, [objNull]]
];

private _direction = [_road] call misc_fnc_getRoadDir;
private _roadPos = getPosATL _road;

//Get orthogonal direction
private _vectorDir = [
	sin (_direction + 90),
	cos (_direction + 90), 
	0
];

// check one side
_pos1 = _roadPos vectorAdd (_vectorDir vectorMultiply HIGHWAY_RADIUS);

//check opposite side
_vectorDir = _vectorDir vectorMultiply -1;
_pos2 = _roadPos vectorAdd (_vectorDir vectorMultiply HIGHWAY_RADIUS);

isOnRoad _pos1 && isOnRoad _pos2
