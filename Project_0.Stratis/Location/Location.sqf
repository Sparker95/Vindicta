/*
Location class

Author: Sparker 28.07.2018
*/

#include "..\OOP_Light\OOP_Light.h"

CLASS("Location", "MessageReceiverEx")

	VARIABLE("debugName");
	VARIABLE("garrisonCiv");
	VARIABLE("garrisonMilAA");
	VARIABLE("garrisonMilMain");
	VARIABLE("boundingRadius"); // _radius for a circle border, sqrt(a^2 + b^2) for a rectangular border
	VARIABLE("border"); // _radius for circle or [_a, _b, _dir] for rectangle
	VARIABLE("borderPatrolWaypoints"); // Array for patrol waypoints along the border
	VARIABLE("pos"); // Position of this location
	VARIABLE("spawnPosTypes"); // Array with spawn positions types
	STATIC_VARIABLE("all");
	
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
		params [["_thisObject", "", [""]], ["_pos", [], [[]]] ];
		
		SET_VAR(_thisObject, "debugName", "noname");
		SET_VAR(_thisObject, "garrisonCiv", "");
		SET_VAR(_thisObject, "garrisonMilAA", "");
		SET_VAR(_thisObject, "garrisonMilMain", "");
		SET_VAR(_thisObject, "boundingRadius", 50);
		SET_VAR(_thisObject, "border", 50);
		SET_VAR(_thisObject, "borderPatrolWaypoints", []);
		SET_VAR(_thisObject, "pos", _pos);
		SET_VAR(_thisObject, "spawnPosTypes", []);
		
		//Push the new object into the array with all units
		private _allArray = GET_STATIC_VAR("Location", "all");
		_allArray pushBack _thisObject;
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
		SET_VAR(_thisObject, "debugName", nil);
		SET_VAR(_thisObject, "garrisonCiv", nil);
		SET_VAR(_thisObject, "garrisonMilAA", nil);
		SET_VAR(_thisObject, "garrisonMilMain", nil);
		SET_VAR(_thisObject, "boundingRadius", nil);
		SET_VAR(_thisObject, "border", nil);
		SET_VAR(_thisObject, "borderPatrolWaypoints", nil);
		SET_VAR(_thisObject, "pos", nil);
		SET_VAR(_thisObject, "spawnPosTypes", nil);
		
		//Remove this unit from array with all units
		private _allArray = GET_STATIC_VAR("Location", "all");
		_allArray = _allArray - [_thisObject];
		SET_STATIC_VAR("Location", "all", _allArray);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            G E T   A L L                           |
	// ----------------------------------------------------------------------
	
	STATIC_METHOD("getAll") {
		private _all = GET_STATIC_VAR("Location", "all");
		private _return = +_all;
		_return
	} ENDMETHOD;
	
	// File-based methods
	// Sets border parameters
	METHOD_FILE("setBorder", "Location\setBorder.sqf");
	
	// Checks if given position is inside the border
	METHOD_FILE("inBorder", "Location\inBorder.sqf");
	
	// Initializes the location from editor-plased objects
	METHOD_FILE("initFromEditor", "Location\initFromEditor.sqf");
	
	// Adds a spawn position
	METHOD_FILE("addSpawnPos", "Location\addSpawnPos.sqf");
	
	STATIC_METHOD_FILE("createAllFromEditor", "Location\createAllFromEditor.sqf");
ENDCLASS;

SET_STATIC_VAR("Location", "all", []);