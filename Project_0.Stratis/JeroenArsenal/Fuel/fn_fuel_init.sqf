#include "defineCommon.inc"

private _loc = [];
private _size = (worldName call BIS_fnc_mapSize)/2;
private _objs = nearestTerrainObjects [[_size,_size,0], ["FUELSTATION"], _size*1.42];
{
	private _pos = getPos _x;

	//_markerstr = createMarker [str _x, _pos];
	//_markerstr setMarkerShape "ICON";
	//_markerstr setMarkerType "hd_dot";
	_pos deleteAt 2;
	_loc pushBack _pos;
	
}forEach _objs;

pr _objs = [];
{
	_objs pushBack nearestObject _x; 
}forEach _loc;

{
	[_x, 1000,1000] call jn_fnc_fuel_addActionRefuel;
}forEach _objs;
