// Add controls to the map
#include "..\OOP_Light\OOP_Light.h"
#include "Resources\ClientMapUI\ClientMapUI_Macros.h";
#include "Resources\UndercoverUI\UndercoverUI_Macros.h"

diag_log "--- Initializing player UI";

_cfg = missionConfigFile >> "ClientMapUI";
_idd = 12;
[_cfg, _idd] call ui_fnc_createControlsFromConfig;

g_rscLayerUndercover = ["rscLayerUndercover"] call BIS_fnc_rscLayer;	// register UndercoverUI layer
uiNamespace setVariable ["undercoverUI_display", displayNull];			
g_rscLayerUndercover cutRsc ["UndercoverUI", "PLAIN", -1, false];

g_rscLayerClientMapUI = ["rscLayerClientMapUI"] call BIS_fnc_rscLayer;	// register clientMapUI layer
uiNamespace setVariable ["clientMapUI_display", displayNull];			

// Init abstract classes representing the UI
CALLSM0("PlayerListUI", "new");
gClientMapUI = NEW("ClientMapUI", []);