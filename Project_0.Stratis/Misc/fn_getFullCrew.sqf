/*
Used to determine which crew this vehicle can have.

return value:
[_pilot, _copilot, _stdTurrets, _psgTurrets, _nCargo]
	0: _n_driver - 0 or 1, if there's a driver(pilot) or not
	1: _copilotTurrets - copilot's turret path
	2: _stdTurrets - standard(with AI inside by default) turret paths excluding the copilot turret.
	3: _psgTurrets - passenger turrets (FFVs).
	4: _n_cargo - number or passenger seats in cargo (non-FFV).
*/

params ["_vehicleName"];

if (_vehicleName isEqualType objNull) then {_vehicleName = typeOf _vehicleName};

private _vehCfg = configFIle >> "CfgVehicles" >> _vehicleName;

private _n_driver = getNumber (_vehCfg >> "hasDriver");

private _copilotTurrets = [_vehicleName, 1, 0] call misc_fnc_getTurrets;

private _stdTurrets = [_vehicleName, 0, 0] call misc_fnc_getTurrets;

private _psgTurrets = [_vehicleName, 0, 1] call misc_fnc_getTurrets;

private _n_cargo = getNumber (_vehCfg >> "transportSoldier");

[_n_driver, _copilotTurrets, _stdTurrets, _psgTurrets, _n_cargo]
