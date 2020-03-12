#include "defineCommon.inc"


params ["_unit_1","_unit_2"];

if(
	(!alive _unit_1 || {_unit_1 getVariable ["ace_isunconscious",false]}) ||
	{!alive _unit_2 || {_unit_2 getVariable ["ace_isunconscious",false]}} //alive returns false on objNull
)exitWith{
	TYPE_EVENT_DEATH;
};

if(_unit_1 distance _unit_2 > FLOAT_MAX_LEAVING_DISTANCE)exitWith{
	TYPE_EVENT_WALKED_AWAY
};

-1;
