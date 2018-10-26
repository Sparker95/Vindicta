/*
Gets specified garrison as main garrison of the location.
*/

params ["_loc"];

private _return = _loc getVariable ["l_garrison_main", objNull];

_return
