#include "defineCommon.inc"

params [["_vehicle",objNull,[objNull]]];

round(fuel _vehicle * (_vehicle getVariable ["jn_fuel_capacity",0]));