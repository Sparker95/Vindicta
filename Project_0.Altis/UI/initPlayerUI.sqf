// Add controls to the map
#include "..\OOP_Light\OOP_Light.h"
#include "ClientMapUI\ClientMapUI_Macros.h";
#include "UndercoverUI\UndercoverUI_Macros.h"

diag_log "--- Initializing player UI";

_cfg = missionConfigFile >> "ClientMapUI";
_idd = 12;
[_cfg, _idd] call ui_fnc_createControlsFromConfig;

g_rscLayerUndercover = ["rscLayerUndercover"] call BIS_fnc_rscLayer;	// register UndercoverUI layer
uiNamespace setVariable ["undercoverUI_display", displayNull];			
g_rscLayerUndercover cutRsc ["UndercoverUI", "PLAIN", -1, false];	

// Init abstract classes representing the UI
CALLSM0("PlayerListUI", "new");
gClientMapUI = NEW("ClientMapUI", []);
gInGameUI = NEW("InGameUI", []);
gBuildUI = NEW("BuildUI", []);