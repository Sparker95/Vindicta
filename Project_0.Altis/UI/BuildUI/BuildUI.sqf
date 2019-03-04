#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "buildUI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\Resources\BuildUI\BuildUI_Macros.h"

/*
Class: BuildUI
Initializes the build menu UI, handles opening and closing, and handles the building itself

Author: Marvis
*/

#define pr private

build_ui_activeBuildMenus = [];
build_ui_unit = objNull; // player
build_ui_EHKeyDown = objNull;
build_ui_EHKeyUp = objNull;

LOG_SCOPE("BuildUI");

build_ui_addOpenBuildMenuAction = {
	params ["_object"];
	OOP_INFO_1("Adding Open Build Menu action to %1.", _object);

	pr _id = _object addaction [format ["<img size='1.5' image='\A3\ui_f\data\GUI\Rsc\RscDisplayEGSpectator\Fps.paa' />  %1", "Open Build Menu"], {  
		params ["_target", "_caller", "_actionId", "_arguments"];
		call build_ui_openUI;
	}];

	build_ui_activeBuildMenus pushBack [_object, _id];
};

build_ui_removeAllActions = {
	OOP_INFO_0("Removing all active Open Build Menu actions.");

	{
		_x params ["_object", "_id"];
		_object removeAction _id;
	} forEach build_ui_activeBuildMenus;
};

build_ui_init = {
	OOP_INFO_1("Player %1, build UI initialized.", name player);

	// Maybe extra variable isn't even needed, can it be other than the player?!
	build_ui_unit = player;
};

build_ui_openUI = {
	OOP_INFO_0("'build_ui_openUI' method called.");

	// ? cutRsc ["buildUI", "PLAIN", 2];

	build_ui_EHKeyDown = (findDisplay 46) displayAddEventHandler ["KeyDown", {
		systemChat format ["%1", build_ui_EHKeyDown];
		
		switch (_keyText) do {
			default { false; }; 
			case """UP""": { call build_ui_navUp; true; };
			case """DOWN""": { call build_ui_navDown; true; };
			case """Escape""": { call build_ui_navDown; true; };
		};
	}];

	// TODO: Add player on death event to hide UI and drop held items etc.
	// Also for when they leave camp area.
};

build_ui_closeUI = {
	OOP_INFO_0("'build_ui_closeUI' method called.");

	(findDisplay 46) displayRemoveEventHandler ["KeyDown", build_ui_EHKeyDown];
	build_ui_EHKeyDown = nil;

	OOP_INFO_0("'build_ui_closeUI' method: Removed display event handler!");
};

// navigate up item list
build_ui_navUp = {
	OOP_INFO_0("'navUp' method called.");
};

build_ui_navDown = {
	OOP_INFO_0("'navDown' method called.");
};
