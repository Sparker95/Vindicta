/*
Function: misc_fnc_getVehicleWidth
Returns the vehicle width derived from its model.

Parameters: _vehicle

_vehicle - objectHandle of the vehicle
*/

params ["_vehicle"];

private _bb = boundingBoxReal _vehicle;
private _width = abs (_bb select 0 select 0);

_width