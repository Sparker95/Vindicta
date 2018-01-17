/*
Gets bounding box of vehicle bases on its type.
*/

params ["_vehType"];

private _veh = _vehType createVehicleLocal [0, 0, 666]; //createSimpleObject [_vehType, [0, 0, 666]];
private _bb = boundingBoxReal _veh;
deleteVehicle _veh;
_bb
