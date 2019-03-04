#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\Resources\BuildUI\BuildUI_Macros.h"

/*
Class: BuildUI
Initializes the build menu UI, handles opening and closing, and handles the building itself

Author: Marvis
*/

#define CLASS_NAME "BuildUI"
#define pr private

g_buildUIRpt = ofstream_new "buildUI.rpt"; 
g_buildUIRpt << ".RPT VARIABLE: g_buildUIRpt";



CLASS(CLASS_NAME, "")

	VARIABLE("unit"); // player
	VARIABLE("EHKeyDown"); // input event handler
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_unit", objNull, [objNull]]];

		SETV(_thisObject, "unit", _unit);
		_unit setVariable ["BuildUI", _thisObject];
		g_buildUIRpt << format ["Class BuildUI: Player %1, build UI object created.", name _unit];
		
	} ENDMETHOD;

	METHOD("openUI") {
		params [["_thisObject", "", [""]]];
		pr _unit = GETV(_thisObject, "unit");

		g_buildUIRpt << "==== Class BuildUI: 'openUI' method called. =============================";

		// EH to handle menu input and placement of objects
		pr _EHKeyDown = (findDisplay 46) displayAddEventHandler ["KeyDown", {
			pr _keyText = keyName (_this select 1);

			switch (_keyText) do {
				default { false; }; 
				case """UP""": { pr _bUI = player getVariable "BuildUI"; CALLM0(_bUI, "navUp"); true;};
				case """DOWN""": { pr _bUI = player getVariable "BuildUI"; CALLM0(_bUI, "navDown"); true; };
				case """Escape""": { pr _bUI = player getVariable "BuildUI"; CALLM0(_bUI, "closeUI"); true; };
			};
		}];

		SET_VAR(_thisObject, "EHKeyDown", _EHKeyDown);
		
	} ENDMETHOD;

	METHOD("closeUI") {
		params [["_thisObject", "", [""]]];

			g_buildUIRpt << "Class BuildUI: 'closeUI' method called.";

			pr _EHKeyDown = GET_VAR(_thisObject, "EHKeyDown");
			(findDisplay 46) displayRemoveEventHandler ["KeyDown", _EHKeyDown];
			SET_VAR(_thisObject, "EHKeyDown", nil);

			g_buildUIRpt << "==== Class BuildUI: 'closeUI' method: Removed display event handler! ====";
		
	} ENDMETHOD;

	// navigate up item list
	METHOD("navUp") {
		params [["_thisObject", "", [""]]];

			g_buildUIRpt << "Class BuildUI: 'navUp' method called.";
		
	} ENDMETHOD;

	METHOD("navDown") {
		params [["_thisObject", "", [""]]];

			g_buildUIRpt << "Class BuildUI: 'navDown' method called.";
		
	} ENDMETHOD;

ENDCLASS;