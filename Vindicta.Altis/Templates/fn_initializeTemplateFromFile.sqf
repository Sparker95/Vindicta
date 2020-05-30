#include "..\config\global_config.hpp"

// !! Currently only called on server !!

#ifdef _SQF_VM
#define IS_SERVER true
#else
#define IS_SERVER isServer
#endif

params [["_filePath", "", [""]], "_factionType"];

// Call compile the file as usual...
_t = call compile preprocessFileLineNumbers _filePath;

// Set mission namespace variable
private _tName = _t select T_NAME;
if (isNil "_tName") exitWith {
	diag_log format ["[Template] error: tempalte name was not specified for %1", _filePath];
};

diag_log format ["[Template] Initializing template from file: %1", _filePath];

// Check if description is provided
private _tDescription = _t select T_DESCRIPTION;
if (isNil "_tDescription") exitWith {
	diag_log format ["[Template] error: template description was not specified for %1", _filePath];
};

// Check if display name is provided
private _tDisplayName = _t select T_DISPLAY_NAME;
if (isNil "_tDisplayName") exitWith {
	diag_log format ["[Template] error: template display name was not specified for %1", _filePath];
};

// Iterate all required addons, check if they are loaded
private _requiredAddons = _t select T_REQUIRED_ADDONS;
if (isNil "_requiredAddons") exitWith {
	diag_log format ["[Template] error: template required addons were not specified for %1", _filePath];
};
private _missingAddons = [];
#ifndef _SQF_VM
{
	if (!(isClass (configFile >> "cfgPatches" >> _x))) then {
		_missingAddons pushBack _x;
	};
} forEach _requiredAddons;
if (count _missingAddons > 0) then {
	diag_log format ["[Template] Error: addons %1 are not loaded on the server for %2", _missingAddons, _filePath];
};
#endif
_t set [T_MISSING_ADDONS, _missingAddons];

// Check for errors, inexistent class names or loadouts, etc
private _errorCount = 0;
if ((count _missingAddons) == 0) then {
	_errorCount = [_t, _factionType] call t_fnc_validateTemplate;
	if (_errorCount > 0) then {
		diag_log format ["[Template] ERROR: %1", _filePath];

		// If it's run in SQF VM, return an error code to the validation script
		#ifdef _SQF_VM
		exitcode__ _errorCount;
		#endif
	};
};

// Set 'valid' value
private _isValid = ((count _missingAddons) == 0) && (_errorCount == 0);
_t set [T_VALID, _isValid];

#ifndef _SQF_VM
// Convert class names to numbers, so that t_fnc_numberToClassName can work later
// Makes no use for tests with SQF VM
[_t] call t_fnc_convertTemplateClassNamesToNumbers;
#endif

// Process inventory items
#ifndef _SQF_VM
#define __PROCESS_ITEMS
#endif

// To speed things up when game mode is disabled, we don't process items
#ifdef GAME_MODE_DISABLE
#undef __PROCESS_ITEMS
#endif

#ifdef __PROCESS_ITEMS
// Process inventory items only if all classes are present
if (_isValid) then {
	private _result = [_t] call t_fnc_processTemplateItems;
	_result params ["_templateItems", "_loadoutGear"];
	_t set [T_INV, _templateItems];
	_t set [T_LOADOUT_GEAR, _loadoutGear];
};
#endif

// Broadcast data to clients
missionNamespace setVariable [_tName, _t, true];
if (_isValid) then {
	t_validTemplates pushBack _tName;	// It will be publicVariable'd later
};
t_allTemplates pushBack _tName;			// It will be publicVariable'd later

// diag_log format ["[Template] ^^ END Initializing template from file: %1", _filePath];

// Return the array
_t