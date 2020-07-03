// Add controls to the map
#include "..\common.h"
#include "ClientMapUI\ClientMapUI_Macros.h"
#include "InGameUI\InGameUI_Macros.h"
#include "defineddikcodes.inc"

diag_log "--- Initializing player UI";

// Create map controls
//_cfg = missionConfigFile >> "ClientMapUI";
//_idd = 12;
//[_cfg, _idd] call ui_fnc_createControlsFromConfig; // Disable this, it's a weird workaround anyway

private _array = [];
{
	private _className = configName _x;
	private _idc = getNumber (_x >> "idc");
	private _newMapCtrl = (findDisplay 12) ctrlCreate [_className, _idc];
	_newMapCtrl setVariable ["__tag", _className];
	_newMapCtrl ctrlCommit 0;
	diag_log format ["UI: Created map control: %1 %2", _newMapCtrl, _className];
	_array pushBack _newMapCtrl;
} forEach ("isClass _x" configClasses (missionConfigFile >> "ClientMapUI" >> "Controls"));
uiNamespace setVariable ["__mapControls", _array];


g_rscLayerUndercover = ["rscLayerUndercover"] call BIS_fnc_rscLayer;	// register UndercoverUI layer, needed for debug UI
//uiNamespace setVariable ["undercoverUI_display", displayNull];
//g_rscLayerUndercover cutRsc ["UndercoverUI", "PLAIN", -1, false];

// Init abstract classes representing the UI
CALLSM0("PlayerListUI", "new");
gClientMapUI = NEW("ClientMapUI", []);
gInGameUI = NEW("InGameUI", []);
g_BuildUI = NEW("BuildUI", []);

// In Game Menu event handler
(finddisplay 46) displayAddEventHandler ["KeyDown", {
	params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];
	//diag_log format ["KeyDown: %1", _this];
	if (_key == DIK_U) then { // U key
		// Close previous menu
		if (!(isNil "gInGameMenu")) then {
			if (IS_OOP_OBJECT(gInGameMenu)) then {
				DELETE(gInGameMenu);
			};
		};

		// Create the menu again
		gInGameMenu = NEW("InGameMenu", []);
		true
	} else {
		false
	};
}];

// Update player markers
[true] call ui_fnc_enablePlayerMarkers;

// Close previous menu
if (!(isNil "gInGameMenu")) then {
	if (IS_OOP_OBJECT(gInGameMenu)) then {
		DELETE(gInGameMenu);
	};
};

// Open menu immediately if game mode is not initialized
private _gameModeInitialized = if(isNil "gGameManager") then {
	false
} else {
	CALLM0(gGameManager, "isGameModeInitialized");
};

if (!_gameModeInitialized && {call misc_fnc_isAdminLocal}) then {
	gInGameMenu = NEW("InGameMenu", []);
};

gPlayerUIInitialized = true;

// Enable the respawn panel the first time
CALLM1(gClientMapUI, "respawnPanelEnable", true);

// Center map once it becomes visible
[] spawn {
	sleep 1;
	waitUntil { visibleMap };
	mapAnimAdd [1, 1, [worldSize / 2, worldSize / 2, 0]];
	mapAnimCommit;
};

// Enable AI debug UI
CALLSM0("AIDebugUI", "staticInit");

// Add event handler for horn usage
// It's here because we add event handler to display
private _hornConfigs = "inheritsFrom _x == (configFile >> 'CfgWeapons' >> 'CarHorn')" configClasses (configFile >> "cfgWeapons");
vin_carHornClassNames = (_hornConfigs apply {configName _x}) + ["CarHorn"];
vin_carHornMouseDownHandler = {
	if ((vehicle player isEqualTo player)) exitWith {};

	pr _weapon = currentWeapon vehicle player;
	if (_weapon in vin_carHornClassNames) then {
		pr _nearMen = player nearObjects ["CAManBase", 15];
		//systemChat format ["Beep Beep! %1", time];
		//diag_log format ["Nearby men: %1", _nearMen];
		pr _args = [vehicle player, _nearMen];
		REMOTE_EXEC_CALL_STATIC_METHOD("AIUnitHuman", "addCarCollisionDanger", _args, ON_SERVER, false);
		//CALL_COMPILE_COMMON("temp.sqf");
	};
};
(finddisplay 46) displayAddEventHandler ["MouseButtonDown", "call vin_carHornMouseDownHandler"];