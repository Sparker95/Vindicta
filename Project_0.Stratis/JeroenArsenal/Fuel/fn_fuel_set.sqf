#include "defineCommon.inc"

params [["_vehicle",objNull,[objNull]],["_amount",0,[0]],["_global",false]];

pr _cap = [_vehicle] call JN_fnc_fuel_getCapacity;
if(_cap==0 || {_amount > _cap} || {_amount < 0})exitWith{};

_vehicle setFuel (_amount/_cap);
