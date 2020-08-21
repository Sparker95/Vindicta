#include "..\common.h"

/*
Sets a loadout of a vehicle (object handle) based on passed loadout tag
*/

params [["_veh", objNull, [objNull]], ["_tag", "", [""]]];

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

isNil { // Make it atomic
    private _array = call _code;
    _array params ["_className", "_loadoutCode"];
    if ((typeOf _veh) != _className) then {
        diag_log format ["fn_setVehicleLoadout: Error: vehicle class (%1) does not match vehicle loadout class name (%2)", typeOf _veh, _className];
    };
    [_veh] call _loadoutCode;
};
true;