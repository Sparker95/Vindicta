// Add controls to the map
#include "..\OOP_Light\OOP_Light.h"
#include "Resources\MapUI\MapUI_Macros.h";
#include "Resources\UndercoverUI\UndercoverUI_Macros.h"

diag_log "--- Initializing player UI";

_cfg = missionConfigFile >> "MapUI";
_idd = 12;
[_cfg, _idd] call ui_fnc_createControlsFromConfig;

rscLayerUndercover = ["rscLayerUndercover"] call BIS_fnc_rscLayer;	// register Undercover UI layer
uiNamespace setVariable ["undercoverUI_display", displayNull];		// set Undercover UI idd
rscLayerUndercover cutRsc ["UndercoverUI", "PLAIN", -1, false];

// Init abstract classes representing the UI
CALLSM0("PlayerListUI", "new");
