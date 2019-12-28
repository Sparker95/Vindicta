#include "defineCommon.inc"

params["_vehicle","_amount"];

pr _cargo = _vehicle call JN_fnc_fuel_get;
_cargo = _cargo - _amount;
if(_cargo < 0)then{
	_amount = _cargo;
	_cargo = 0;
};

[_vehicle,_cargo] call JN_fnc_fuel_set;

//return removed amount
_amount 