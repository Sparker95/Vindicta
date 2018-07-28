/*
Author: Sparker 12.07.2018

Garrison is an object which holds units and groups and handles their lifecycle (spawning, despawning, destruction).
Garrison typically is located in one area and is performing one task.
*/

#include "..\OOP_Light\OOP_Light.h"

CLASS("Garrison", "MessageReceiverEx")

	VARIABLE("units");
	VARIABLE("groups");
	VARIABLE("spawned");
	VARIABLE("side");
	VARIABLE("debugName");
	
	// ----------------------------------------------------------------------
	// |                 S E T   D E B U G   N A M E                        |
	// ----------------------------------------------------------------------
	
	METHOD("setDebugName") {
		params [["_thisObject", "", [""]], ["_debugName", "", [""]]];
		SET_VAR(_thisObject, "debugName", _debugName);
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_side", WEST, [WEST]]];
		SET_VAR(_thisObject, "units", []);
		SET_VAR(_thisObject, "groups", []);
		SET_VAR(_thisObject, "spawned", false);
		SET_VAR(_thisObject, "side", WEST);
		SET_VAR(_thisObject, "debugName", "");
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		SET_VAR(_thisObject, "units", nil);
		SET_VAR(_thisObject, "groups", nil);	
		SET_VAR(_thisObject, "spawned", nil);
		SET_VAR(_thisObject, "side", nil);
		SET_VAR(_thisObject, "debugName", nil);
	} ENDMETHOD;
	
	// Returns the message loop this object is attached to
	METHOD("getMessageLoop") {
		gMessageLoopMain
	} ENDMETHOD;
	
	// Handles incoming messages. Since it's a MessageReceiverEx, we must overwrite handleMessageEx
	METHOD_FILE("handleMessageEx", "Garrison\handleMessageEx.sqf");
	
	// Spawns the whole garrison
	METHOD_FILE("spawn", "Garrison\spawn.sqf");
	
	// Despawns the whole garrison
	METHOD_FILE("despawn", "Garrison\despawn.sqf");
	
	// Adds an existing group into the garrison
	METHOD_FILE("addGroup", "Garrison\addGroup.sqf");
	
	// Adds an existing unit into the garrison
	METHOD_FILE("addUnit", "Garrison\addUnit.sqf");
	
	//Removes an existing unit from this garrison
	METHOD_FILE("removeUnit", "Garrison\removeUnit.sqf");
	
	// Move unit between garrisons
	METHOD_FILE("moveUnit", "Garrison\moveUnit.sqf");

ENDCLASS;