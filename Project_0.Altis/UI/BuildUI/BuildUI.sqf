#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "buildUI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\Resources\BuildUI\BuildUI_Macros.h"
#include "..\..\GlobalAssert.hpp"

/*
Class: BuildUI
Initializes the build menu UI, handles opening and closing, and handles the building itself

Author: Marvis
*/

#define pr private

g_BuildUI = nil;

CLASS("BuildUI", "")

	VARIABLE("activeBuildMenus");
	VARIABLE("EHKeyDown");
	VARIABLE("EHKeyUp") ;

	METHOD("new") {
		params [["_thisObject", "", [""]]];

		if(!(isNil("g_BuildUI"))) exitWith {
			OOP_ERROR_0("BuildUI already initialized! Make sure to delete it before trying to initialize it again!");
		};

		g_BuildUI = _thisObject;

		OOP_INFO_1("Player %1 build UI initialized.", name player);

		T_SETV("activeBuildMenus", []);
		T_SETV("EHKeyDown", nil);
		T_SETV("EHKeyUp", nil);
	} ENDMETHOD;

	METHOD("delete") {
		params [["_thisObject", "", [""]]];

		OOP_INFO_1("Player %1 build UI destroyed.", name player);

		g_BuildUI = nil;
	} ENDMETHOD;

	METHOD("addOpenBuildMenuAction") {
		params [["_thisObject", "", [""]], "_object"];
		OOP_INFO_1("Adding Open Build Menu action to %1.", _object);

		pr _id = _object addaction [format ["<img size='1.5' image='\A3\ui_f\data\GUI\Rsc\RscDisplayEGSpectator\Fps.paa' />  %1", "Open Build Menu"], {  
			params ["_target", "_caller", "_actionId", "_arguments"];
			_arguments params ["_thisObject"];
			T_CALLM0("openUI");
		}, [_thisObject]];

		T_GETV("activeBuildMenus") pushBack [_object, _id];
	} ENDMETHOD;

	METHOD("removeAllActions") {
		OOP_INFO_0("Removing all active Open Build Menu actions.");

		{
			_x params ["_object", "_id"];
			_object removeAction _id;
		} forEach T_GETV("activeBuildMenus");
	} ENDMETHOD;

	METHOD("openUI") {
		OOP_INFO_0("method called");

		// ? cutRsc ["buildUI", "PLAIN", 2];

		pr _EHKeyDown = (findDisplay 46) displayAddEventHandler ["KeyDown", {
			systemChat format ["%1", str _this];
			
			switch (_keyText) do {
				default { false; }; 
				case """UP""": { CALLM0(g_BuildUI, "navUp"); true; };
				case """DOWN""": { CALLM0(g_BuildUI, "navDown"); true; };
				case """Escape""": { CALLM0(g_BuildUI, "closeUI"); true; };
			};
		}];

		T_SETV("EHKeyDown", _EHKeyDown);

		// TODO: Add player on death event to hide UI and drop held items etc.
		// Also for when they leave camp area.
	} ENDMETHOD;

	METHOD("closeUI") {
		OOP_INFO_0("method called");

		(findDisplay 46) displayRemoveEventHandler ["KeyDown", T_GETV("EHKeyDown")];
		T_SETV("EHKeyDown", nil);

		OOP_INFO_0("Removed display event handler!");
	} ENDMETHOD;

	// navigate up item list
	METHOD("navUp") {
		OOP_INFO_0("method called");
	} ENDMETHOD;

	METHOD("navDown") {
		OOP_INFO_0("method called");
	} ENDMETHOD;

ENDCLASS;

build_ui_addOpenBuildMenuAction = {
	ASSERT_GLOBAL_OBJECT(g_BuildUI);

	CALLM1(g_BuildUI, "addOpenBuildMenuAction", _this);
};
