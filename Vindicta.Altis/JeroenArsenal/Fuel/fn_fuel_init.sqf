#include "defineCommon.inc"

//init fuel stations

private _size = (worldName call BIS_fnc_mapSize)/2;
private _terrainObjs = nearestTerrainObjects [[_size,_size,0], ["FUELSTATION"], _size*1.42];
private _loc = [];
{
	private _pos = getPos _x;

	//_markerstr = createMarker [str _x, _pos];
	//_markerstr setMarkerShape "ICON";
	//_markerstr setMarkerType "hd_dot";
	_pos deleteAt 2;
	_loc pushBack _pos;
	
}forEach _terrainObjs;

{
	private _station = nearestObject _x;
	_station call jn_fnc_fuel_vehicleInit;
}forEach _loc;

//init mission file placed vehicles
{
	_x call jn_fnc_fuel_vehicleInit;
}forEach vehicles;