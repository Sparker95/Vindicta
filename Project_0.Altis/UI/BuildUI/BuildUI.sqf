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

VARIABLE("unit"); // player
VARIABLE("EHKeyDown");
VARIABLE("EHKeyUp");

CLASS(CLASS_NAME, "")
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_unit", objNull, [objNull]]];

		SETV(_thisObject, "unit", _unit);
		_unit setVariable ["BuildUI", _thisObject];
		g_buildUIRpt << format ["Class BuildUI: Player %1, build UI object created.", name _unit];
		
	} ENDMETHOD;

	METHOD("openUI") {
		params [["_thisObject", "", [""]]];

		pr _unit = GETV(_thisObject, "unit");

		g_buildUIRpt << "Class BuildUI: 'openUI' method called.";

		pr _EHKeyDown = (findDisplay 46) displayAddEventHandler ["KeyDown", {

		systemChat format ["%1", _EHKeyDown];

		}];

		//SET_VAR(_thisObject, "EHKeyDown", _EHKeyDown);
		//SET_VAR(_thisObject, "EHKeyUp", _EHKeyUp);
		
	} ENDMETHOD;

	METHOD("closeUI") {
		params [["_thisObject", "", [""]]];

			
		
	} ENDMETHOD;

ENDCLASS;