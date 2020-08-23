#include "..\common.h"

/*
Returns class name from vehicle loadout
*/

params [["_tag", "", [""]]];

private _code = t_loadouts_hashmap getVariable _tag;

if (isNil "_code") exitWith {
	diag_log format ["fn_setVehicleLoadout: template: Error: tag %1 doesn't exist!", _tag];
	false
};

if (_code isEqualType "") then {
	_code = compile preprocessFileLineNumbers _code;
	// Replace the scring in the hash map with compiled code
	t_loadouts_hashmap setVariable [_tag, _code];
};

private _array = call _code;
_array params ["_className", "_loadoutCode"];
_className;