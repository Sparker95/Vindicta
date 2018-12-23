#include "defineCommon.inc"

/*
	Author: Jeroen Notenbomer

	Description:
	increasses fuel consumption for a unit while driving a vehicle.
	unit must be local in order for the script to be presistent after respawn

	Parameter(s):
	unit object

	Returns:
	
	Usage: "player call jn_fnc_fuel_consumption_init;"
	
*/

params["_unit"];

if((_this select 0) isEqualTo "postInit")then {_unit = player};

if(isnil "_unit")ExitWith{diag_log "jn_fnc_fuel_consumption_init error 1"};

diag_log ("JNG_FUEL start for player:" + name _unit);

_unit addEventHandler ["GetInMan", {
	params ["_unit", "_role", "_vehicle", "_turret"];
	if(_role isEqualTo "driver")then{
		_unit call jn_fnc_fuel_consumption_start;
	};
}];

_unit addEventHandler ["GetOutMan", {
	params ["_unit", "_role", "_vehicle", "_turret"];
	if(_role isEqualTo "driver")then{
		_unit call jn_fnc_fuel_consumption_stop;
	};
}];

_unit addEventHandler ["SeatSwitchedMan", {
	params ["_unit1", "_unit2", "_vehicle"];
	if((assignedVehicleRole _unit1 select 0) isEqualTo "driver")then{
		_unit call jn_fnc_fuel_consumption_start;
	}else{
		_unit call jn_fnc_fuel_consumption_stop;
	};
}];


