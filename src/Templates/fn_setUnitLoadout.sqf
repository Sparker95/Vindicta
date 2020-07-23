#include "..\common.h"

/*
Sets a loadout of a unit (object handle) based on passed loadout tag
*/

params [["_unit", objNull, [objNull]], ["_tag", "", [""]]];

private _code = t_loadouts_hashmap getVariable _tag;

if (isNil "_code") exitWith {
	diag_log format ["fn_setUnitLoadout: template: Error: tag %1 doesn't exist!", _tag];
	false
};

if (_code isEqualType "") then {
	_code = compile preprocessFileLineNumbers _code;
	// Replace the scring in the hasm map with compiled code
	t_loadouts_hashmap setVariable [_tag, _code];
};

isNil { // Make it atomic
	private _oldThis = this; // Fuck knows what else might use the 'this' global variable :\
	this = _unit; // Inside the script, 'this' is the unit
	call _code;
	this = _oldThis;
};
true;