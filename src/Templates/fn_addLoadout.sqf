#include "..\common.h"

/*
Registers a new loadout.
*/

params [["_tag", "", [""]], ["_scriptPath", "", [""]]];

diag_log format ["addLoadout: %1", _scriptPath];

// Check if we are adding the same tag
if (!isNil {t_loadouts_hashmap getVariable _tag}) exitWith {
	diag_log format ["fn_addLoadout: template: Error: tag %1 is already added!", _tag];
};

t_loadouts_hashmap setVariable [_tag, _scriptPath];

// Try to compile the script as well to report errors
compile preprocessFileLineNumbers _scriptPath;