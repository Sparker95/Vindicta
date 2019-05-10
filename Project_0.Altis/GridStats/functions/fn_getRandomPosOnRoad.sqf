/*
fn_getRandomPosOnRoad
Gets a random position on a road based on marker location
parameters: marker
returns: [x, y, z] - position
*/

params ["_marker"];

private _pos = getMarkerPos _marker;
private _size = getMarkerSize _marker;
private _dir = markerDir _marker;
private _halfWidth = _size select 0;
private _halfHeight = _size select 1;

//Select random position along the marker
_r = (random 2*(_halfHeight-_halfWidth)) - (_halfHeight-_halfWidth);

_pos = _pos vectorAdd [_r * (sin _dir), _r * (cos _dir), 0]; //The position to search from

//"Sign_Arrow_F" createVehicle _pos;

private _roads = [];
private _searchRadius = _halfWidth;
private _counter = 0;
while{count _roads < 1} do
{
	_roads = _pos nearRoads _searchRadius;
	_searchRadius = 1.5*_searchRadius;
	_counter = _counter + 1;
};
diag_log format ["fn_getRandomPosOnRoad.sqf: %1: found %2 roads in %3 iterations", _marker, count _roads, _counter];
//Find the nearest road segment
private _nearestRoad = _roads select 0;
private _nearestPos = position (_roads select 0);
private _nearestDistance = (_roads select 0) distance _pos;
//diag_log format ["_nd before: %1", _nearestDistance];
{
	_dist = _x distance _pos;
	if(_dist < _nearestDistance) then
	{
		_nearestDistance = _dist;
		_nearestPos = position _x;
		_nearestRoad = _x;
	};
}forEach _roads;
//diag_log format ["_nd after: %1", _nearestDistance];
//"Sign_Arrow_Pink_F" createVehicle _nearestPos;
_nearestPos