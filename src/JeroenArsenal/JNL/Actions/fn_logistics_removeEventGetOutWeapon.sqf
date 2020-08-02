#include "defineCommon.inc"

params ["_vehicle"];

pr _getOutEventID = _vehicle getVariable ["jnl_getOutGunnerEventID", nil];
if(!isnil "_getOutEventID")then{
	_vehicle removeEventHandler ["GetOut",_getOutEventID];
	_vehicle setVariable ["jnl_getOutGunnerEventID", nil];
};
