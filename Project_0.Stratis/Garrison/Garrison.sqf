/*
Author: Sparker 12.07.2018

Garrison is an object which holds units and groups and handles their spawning.
Garrison typically is located in one area and is performing one task.
*/

#include "..\OOP_Light\OOP_Light.h"

CLASS("Garrison", "MessageReceiver")

	VARIABLE("units");
	VARIABLE("groups");

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]]];
		SET_VAR(_thisObject, "units", []);
		SET_VAR(_thisObject, "groups", []);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		SET_VAR(_thisObject, "units", nil);
		SET_VAR(_thisObject, "groups", nil);		
	} ENDMETHOD;
	
	METHOD_FILE("spawn", "Garrison\spawn.sqf");
	
	METHOD_FILE("despawn", "Garrison\despawn.sqf");
	
	METHOD_FILE("addUnit", "Garrison\addUnit.sqf");
	
	METHOD_FILE("moveUnit", "Garrison\moveUnit.sqf");

ENDCLASS;