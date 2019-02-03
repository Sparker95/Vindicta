/*
Function: misc_fnc_boundingBoxReal
Gets bounding box of vehicle bases on its type, unlike boundingBoxReal arma command which works with a created vehicle.

Parameters: _vehType

_vehType - String, class name of the vehicle

Author: Sparker 29.07.2018
*/

params ["_vehType"];

private _veh = _vehType createVehicleLocal [0, 0, 666]; //createSimpleObject [_vehType, [0, 0, 666]];
private _bb = boundingBoxReal _veh;
deleteVehicle _veh;
_bb
