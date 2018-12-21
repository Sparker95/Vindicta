#include "defineCommon.inc"

params["_vehicle","_amount"];

pr _cargo = _vehicle call JN_fnc_ammo_getCargo;
_cargo = _cargo - _amount;
if(_cargo < 0)exitWith{false};//return failure

[_vehicle,_cargo]; call JN_fnc_ammo_setCargo;

//return succes
true;