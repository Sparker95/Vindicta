/*
Function: misc_fnc_boundingBoxReal
Gets bounding box of vehicle bases on its type, unlike boundingBoxReal arma command which works with a created vehicle.

Parameters: _vehType

_vehType - String, class name of the vehicle

Author: Sparker 29.07.2018
*/

#define USE_CACHE

params [["_vehType", "", [""]]];

#ifdef USE_CACHE
private _bb = gBBoxCache getVariable _vehType;
#else
private _bb = [];
#endif

#ifdef USE_CACHE
if (isNil "_bb") then {
#endif

	private _veh = _vehType createVehicleLocal [0, 0, 666]; //createSimpleObject [_vehType, [0, 0, 666]];
#ifndef _SQF_VM
	_bb = 0 boundingBoxReal _veh;
#endif
	deleteVehicle _veh;

#ifdef USE_CACHE
	missionNamespace setVariable [_vehType, _bb];
};
#endif

_bb