/*
Function: misc_fnc_boundingBoxReal
Gets bounding box of vehicle bases on its type, unlike boundingBoxReal arma command which works with a created vehicle.

Parameters: _vehType

_vehType - String, class name of the vehicle

Author: Sparker 29.07.2018
*/

params [["_vehType", "", [""]]];

// Check if we have it in cache. CreateVehicleLocal takes 5.6 ms
private _cacheEntry = "bbcache_"+_vehType;

private _bb = missionNamespace getVariable _cacheEntry;

if (isNil "_bb") then {
	private _veh = _vehType createVehicleLocal [0, 0, 666]; //createSimpleObject [_vehType, [0, 0, 666]];
	_bb = boundingBoxReal _veh;
	deleteVehicle _veh;
	missionNamespace setVariable [_cacheEntry, _bb];
};

_bb