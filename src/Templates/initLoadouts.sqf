#include "..\common.h"

#ifndef _SQF_VM
// Hashmap that matches tag to script or code
t_loadouts_hashmap = [false] call CBA_fnc_createNamespace;
#else
t_loadouts_hashmap = "_loadouts_hashmap_" createVehicle [0, 0, 0];
#endif

// Initialize custom loadouts from mission
CALL_COMPILE_COMMON("Templates\Loadouts\init.sqf");

// Initialize custom loadouts from addons
#ifdef _SQF_VM
private _classes = [];
#else
private _classes = "isClass _x" configClasses (configFile >> "VinExternalFactions");
#endif

{
    private _loadoutsInit = getText (_x >> "loadoutsInitFile");
    if (_loadoutsInit != "") then {
        diag_log format ["[Template] Initializing loadouts from addon: %1, path: %2", configName _x, _loadoutsInit];
        call compile preprocessFileLineNumbers _loadoutsInit;
    };
} forEach _classes;