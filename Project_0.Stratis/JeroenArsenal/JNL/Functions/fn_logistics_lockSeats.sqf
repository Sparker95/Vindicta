#include "defineCommon.inc"

params ["_vehicle"];

pr _type = -1;
pr _nodesLocked = [];
{
	pr _data = _x getVariable ["jnl_cargo",nil];
	if(!isnil "_data")then{
		_type = _data select 0;
		_nodesLocked pushback (_data select 1);
	};
} forEach attachedObjects _vehicle;

pr _nodes = [_vehicle,_type] call jn_fnc_logistics_getNodes;
_vehicle lockCargo false;
{
	_lockSeats = _nodes select _x select 1;//get seats to lock
	{
		_vehicle lockCargo [_x, true];
	} forEach _lockSeats;
}forEach _nodesLocked;

