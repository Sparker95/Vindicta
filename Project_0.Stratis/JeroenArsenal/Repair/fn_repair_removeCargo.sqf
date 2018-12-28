#include "defineCommon.inc"

params [["_vehicle",objNull,[objNull]],["_amount",0,[0]]];

pr _cargo = (_vehicle call JN_fnc_repair_getCargo) - _amount;

pr _error = [_vehicle,_cargo] call JN_fnc_repair_setCargo;

_error;