// Add controls to the map
#include "..\OOP_Light\OOP_Light.h"
#include "ClientMapUI\ClientMapUI_Macros.h"
#include "UndercoverUI\UndercoverUI_Macros.h"
#include "defineddikcodes.inc"

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

// In Game Menu event handler
(finddisplay 46) displayAddEventHandler ["KeyDown", {
	params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];
	//diag_log format ["KeyDown: %1", _this];
	if (_key == DIK_U) then { // U key
		if (isNil "gInGameMenu") then {
			gInGameMenu = NEW("InGameMenu", []);
			private _code = {gInGameMenu = nil;};
			CALLM1(gInGameMenu, "onDelete", _code);
		};
		true
	} else {
		false
	};
}];