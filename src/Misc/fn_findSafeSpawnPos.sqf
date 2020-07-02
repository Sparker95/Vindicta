#include "..\common.h"

params ["_pos", "_radius", "_size", "_slope"];
private _tryPos = [_pos, 0, _radius, _size, 0, _slope, 0, [], [[0,0,0], [0,0,0]]] call BIS_fnc_findSafePos;
// Fallback to something more forgiving
if (_tryPos isEqualTo [0,0,0]) then {
	_tryPos = [_pos, 0, _radius, _size, 0, 0.3, 0, [], [_pos, _pos]] call BIS_fnc_findSafePos;
};
return [ZERO_HEIGHT(_tryPos), random 360]
