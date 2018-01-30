/*
Moves units into vehicle roles they are assigned

Parameters:
	_units - array of units or one unit
*/

private _units = _this;
if(!(_units isEqualType [])) then
{
	_units = [_units];
};

{
	private _vr = assignedVehicleRole _x;
	private _v = assignedVehicle _x;
	[_v, _x, _vr] call BIS_fnc_moveIn;
} forEach _units;