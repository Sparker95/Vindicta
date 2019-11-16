/*

*/

params [["_tag", "", [""]], ["_scriptName", "", [""]]];

// Check if we are adding the same tag
if (!isNil {t_loadouts_hashmap getVariable _tag}) exitWith {
	diag_log format ["fn_addLoadout: template: Error: tag %1 is already added!", _tag];
};

t_loadouts_hashmap setVariable [_tag, _scriptName];

// Try to compile the script as well to report errors
compile preprocessFileLineNumbers ("Templates\Loadouts\" + _scriptName);