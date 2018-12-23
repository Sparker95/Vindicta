/*
Location class

Author: Sparker 28.07.2018
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "Location.hpp"
#include "..\MessageTypes.hpp"

CLASS("Location", "MessageReceiver")

	VARIABLE("debugName");
	VARIABLE("garrisonCiv");
	VARIABLE("garrisonMilAA");
	VARIABLE("garrisonMilMain");
	VARIABLE("boundingRadius"); // _radius for a circle border, sqrt(a^2 + b^2) for a rectangular border
	VARIABLE("border"); // _radius for circle or [_a, _b, _dir] for rectangle
	VARIABLE("borderPatrolWaypoints"); // Array for patrol waypoints along the border
	VARIABLE("pos"); // Position of this location
	VARIABLE("spawnPosTypes"); // Array with spawn positions types
	VARIABLE("spawnState"); // Is this location spawned or not
	VARIABLE("timer"); // Timer object which generates messages for this location
	VARIABLE("capacityInf"); // Infantry capacity
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
		
		// Check existance of neccessary global objects
		if (isNil "gTimerServiceMain") exitWith {"[MessageLoop] Error: global timer service doesn't exist!";};
		if (isNil "gMessageLoopLocation") exitWith {"[MessageLoop] Error: global location message loop doesn't exist!";};
		if (isNil "gLUAP") exitWith {"[MessageLoop] Error: global location unit array provider doesn't exist!";};
		
		SET_VAR(_thisObject, "debugName", "noname");
		SET_VAR(_thisObject, "garrisonCiv", "");
		SET_VAR(_thisObject, "garrisonMilAA", "");
		SET_VAR(_thisObject, "garrisonMilMain", "");
		SET_VAR(_thisObject, "boundingRadius", 50);
		SET_VAR(_thisObject, "border", 50);
		SET_VAR(_thisObject, "borderPatrolWaypoints", []);
		SET_VAR(_thisObject, "pos", _pos);
		SET_VAR(_thisObject, "spawnPosTypes", []);
		SET_VAR(_thisObject, "spawnState", 0);
		SET_VAR(_thisObject, "capacityInf", 0);
		
		// Create timer object
		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_DESTINATION, _thisObject];
		_msg set [MESSAGE_ID_SOURCE, ""];
		_msg set [MESSAGE_ID_DATA, 0];
		_msg set [MESSAGE_ID_TYPE, LOCATION_MESSAGE_PROCESS];
		private _args = [_thisObject, 1, _msg, gTimerServiceMain]; //["_messageReceiver", "", [""]], ["_interval", 1, [1]], ["_message", [], [[]]], ["_timerService", "", [""]]
		private _timer = NEW("Timer", _args);
		SET_VAR(_thisObject, "timer", _timer);
		
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
		SET_VAR(_thisObject, "capacityInf", nil);
		
		
		// Remove the timer
		private _timer = GET_VAR(_thisObject, "timer");
		DELETE(_timer);
		SET_VAR(_thisObject, "timer", nil);
		
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
	
	// ----------------------------------------------------------------------
	// |                            G E T   P O S                           |
	// ----------------------------------------------------------------------
	
	METHOD("getPos") {
		params [ ["_thisObject", "", [""]] ];
		GETV(_thisObject, "pos")
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |               G E T   P A T R O L   W A Y P O I N T S 
	// ----------------------------------------------------------------------
	
	METHOD("getPatrolWaypoints") {
		params [ ["_thisObject", "", [""]] ];
		GETV(_thisObject, "borderPatrolWaypoints")
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                  G E T   M E S S A G E   L O O P                   |
	// ----------------------------------------------------------------------
	
	METHOD("getMessageLoop") { //Derived classes must implement this method
		gMessageLoopLocation
	} ENDMETHOD;
	
	// Adding garrisons
	METHOD("setGarrisonMilitaryMain") {
		params [["_thisObject", "", [""]], ["_garrison", "", [""]] ];
		SET_VAR(_thisObject, "garrisonMilMain", _garrison);
		CALL_METHOD(_garrison, "setLocation", [_thisObject]);
	} ENDMETHOD;
	
	// File-based methods
	
	// Handles messages
	METHOD_FILE("handleMessage", "Location\handleMessage.sqf");
	
	// Sets border parameters
	METHOD_FILE("setBorder", "Location\setBorder.sqf");
	
	// Checks if given position is inside the border
	METHOD_FILE("isInBorder", "Location\isInBorder.sqf");
	
	// Initializes the location from editor-plased objects
	METHOD_FILE("initFromEditor", "Location\initFromEditor.sqf");
	
	// Adds a spawn position
	METHOD_FILE("addSpawnPos", "Location\addSpawnPos.sqf");
	
	// Adds multiple spawn positions from a building
	METHOD_FILE("addSpawnPosFromBuilding", "Location\addSpawnposFromBuilding.sqf");
	
	// Calculates infantry capacity based on buildings at this location
	METHOD_FILE("calculateInfantryCapacity", "Location\calculateInfantryCapacity.sqf");
	
	// Gets a spawn position to spawn some unit
	METHOD_FILE("getSpawnPos", "Location\getSpawnPos.sqf");
	
	// Returns how many units of this type and group type this location can hold
	METHOD_FILE("getUnitCapacity", "Location\getUnitCapacity.sqf");
	
	// Checks if given position is safe to spawn a vehicle here
	STATIC_METHOD_FILE("isPosSafe", "Location\isPosSafe.sqf");
	
	
	
	// 
	STATIC_METHOD_FILE("createAllFromEditor", "Location\createAllFromEditor.sqf");
ENDCLASS;

SET_STATIC_VAR("Location", "all", []);

// Initialize arrays with building types
call compile preprocessFileLineNumbers "Location\initBuildingTypes.sqf";