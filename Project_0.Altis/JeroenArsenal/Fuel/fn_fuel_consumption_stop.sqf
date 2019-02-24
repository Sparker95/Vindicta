#include "defineCommon.inc"

params["_unit"];

pr _handle = _unit getVariable "fuelConsumtion_handle";
if(isNil "_handle" )exitWith{};
terminate _handle;
player setVariable ["fuelConsumtion_handle",nil];