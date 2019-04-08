#define OOP_INFO
#define OOP_WARNING
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "Location.hpp"
#include "..\MessageTypes.hpp"

/*
Class: Location
Location has garrisons at a static place and spawns units.

Author: Sparker 28.07.2018
*/

#define pr private

CLASS("Location", "MessageReceiverEx")

	VARIABLE("type");
	VARIABLE("side");
	VARIABLE("debugName");
	
	VARIABLE("garrisons");
	/*
	VARIABLE("garrisonCiv");
	VARIABLE("garrisonMilAA");
	VARIABLE("garrisonMilMain");
	*/	
	VARIABLE("boundingRadius"); // _radius for a circle border, sqrt(a^2 + b^2) for a rectangular border
	VARIABLE("border"); // _radius for circle or [_a, _b, _dir] for rectangle
	VARIABLE("borderPatrolWaypoints"); // Array for patrol waypoints along the border
	VARIABLE("allowedAreas"); // Array with allowed areas
	VARIABLE("pos"); // Position of this location
	VARIABLE("spawnPosTypes"); // Array with spawn positions types
	VARIABLE("spawnState"); // Is this location spawned or not
	VARIABLE("timer"); // Timer object which generates messages for this location
	VARIABLE("capacityInf"); // Infantry capacity
	STATIC_VARIABLE("all");


	// |                 S E T   D E B U G   N A M E
	/*
	Method: setDebugName
	Sets debug name of this MessageLoop.

	Parameters: _debugName

	_debugName - String

	Returns: nil
	*/
	METHOD("setDebugName") {
		params [["_thisObject", "", [""]], ["_debugName", "", [""]]];
		T_SETV("debugName", _debugName);
	} ENDMETHOD;

	METHOD("setCapacityInf") {
		params [["_thisObject", "", [""]], ["_capacityInf", "", [""]]];
		T_SETV("capacityInf", parseNumber _capacityInf);
	} ENDMETHOD;

	METHOD("setSide") {
		params [["_thisObject", "", [""]], ["_side", EAST, [EAST]]];
		T_SETV("side", _side);
	} ENDMETHOD;



	// |                              N E W
	/*
	Method: new

	Parameters: _pos

	_pos - position of this location
	*/
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_pos", [], [[]]] ];

		// Check existance of neccessary global objects
		if (isNil "gTimerServiceMain") exitWith {"[MessageLoop] Error: global timer service doesn't exist!";};
		if (isNil "gMessageLoopLocation") exitWith {"[MessageLoop] Error: global location message loop doesn't exist!";};
		if (isNil "gLUAP") exitWith {"[MessageLoop] Error: global location unit array provider doesn't exist!";};

		T_SETV("debugName", "noname");
		T_SETV("garrisons", []);
		SET_VAR_PUBLIC(_thisObject, "boundingRadius", 50);
		SET_VAR_PUBLIC(_thisObject, "border", 50);
		T_SETV("borderPatrolWaypoints", []);
		SET_VAR_PUBLIC(_thisObject, "pos", _pos);
		T_SETV("spawnPosTypes", []);
		T_SETV("spawnState", 0);
		T_SETV("capacityInf", 0);
		SET_VAR_PUBLIC(_thisObject, "allowedAreas", []);
		SET_VAR_PUBLIC(_thisObject, "type", LOCATION_TYPE_UNKNOWN);

		// Setup basic border
		CALLM2(_thisObject, "setBorder", "circle", 20);

		// Create timer object
		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_DESTINATION, _thisObject];
		_msg set [MESSAGE_ID_SOURCE, ""];
		_msg set [MESSAGE_ID_DATA, 0];
		_msg set [MESSAGE_ID_TYPE, LOCATION_MESSAGE_PROCESS];
		private _args = [_thisObject, 1, _msg, gTimerServiceMain]; //["_messageReceiver", "", [""]], ["_interval", 1, [1]], ["_message", [], [[]]], ["_timerService", "", [""]]
		private _timer = NEW("Timer", _args);
		SET_VAR(_thisObject, "timer", _timer);

		//Push the new object into the array with all locations
		private _allArray = GET_STATIC_VAR("Location", "all");
		_allArray pushBack _thisObject;
		PUBLIC_STATIC_VAR("Location", "all");
	} ENDMETHOD;


	// |                            D E L E T E                             |
	/*
	Method: delete
	*/
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
		_allArray deleteAt (_allArray find _thisObject);
		PUBLIC_STATIC_VAR("Location", "all");
	} ENDMETHOD;


	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                               G E T T I N G   M E M B E R   V A L U E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


	// |                            G E T   A L L
	/*
	Method: (static)getAll
	Returns an array of all locations.

	Returns: Array of location objects
	*/
	STATIC_METHOD("getAll") {
		private _all = GET_STATIC_VAR("Location", "all");
		private _return = +_all;
		_return
	} ENDMETHOD;


	// |                            G E T   P O S                           |
	/*
	Method: getPos
	Returns position of this location

	Returns: Array, position
	*/
	METHOD("getPos") {
		params [ ["_thisObject", "", [""]] ];
		GETV(_thisObject, "pos")
	} ENDMETHOD;



	// |               G E T   P A T R O L   W A Y P O I N T S
	/*
	Method: getPatrolWaypoints
	Returns array with positions for patrol waypoints.

	Returns: Array of positions
	*/
	METHOD("getPatrolWaypoints") {
		params [ ["_thisObject", "", [""]] ];
		GETV(_thisObject, "borderPatrolWaypoints")
	} ENDMETHOD;

	// |                  G E T   M E S S A G E   L O O P
	METHOD("getMessageLoop") { //Derived classes must implement this method
		gMessageLoopLocation
	} ENDMETHOD;



	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                               S E T T I N G   M E M B E R   V A L U E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	
	
	
	
	// Old useless crap, delete it!11
	
	/*
	Method: setGarrisonMilitaryMain
	Sets the main military garrison located at this location

	Parameters: _garrison

	_garrison - <Garrison> object

	Returns: nil
	*/
	/*
	METHOD("setGarrisonMilitaryMain") {
		params [["_thisObject", "", [""]], ["_garrison", "", [""]] ];

		OOP_INFO_1("setGarrisonMilitaryMain: %1", _garrison);

		SET_VAR(_thisObject, "garrisonMilMain", _garrison);
		if (_garrison != "") then {
			CALLM2(_garrison, "postMethodAsync", "setLocation", [_thisObject]);
		};
	} ENDMETHOD;
	*/

	/*
	Method: getGarrisonMilitaryMain
	Gets the main military garrison located at this location

	Returns: <Garrison> or "" if there is no garrison there
	*/
	/*
	METHOD("getGarrisonMilitaryMain") {
		params [["_thisObject", "", [""]], ["_garrison", "", [""]] ];
		GET_VAR(_thisObject, "garrisonMilMain")
	} ENDMETHOD;
	*/
	/*
	Method: getGarrisonMilAA
	Gets the main military garrison located at this location

	Returns: <Garrison> or "" if there is no garrison there
	*/
	/*
	METHOD("getGarrisonMilAA") {
		params [["_thisObject", "", [""]], ["_garrison", "", [""]] ];
		GET_VAR(_thisObject, "garrisonMilAA")
	} ENDMETHOD;
	*/
	
	
	METHOD("registerGarrison") {
		params ["_thisObject", ["_gar", "", [""]]];
		
		pr _gars = T_GETV("garrisons");
		if (! (_gar in _gars)) then {
			_gars pushBack _gar;
			CALLM2(_gar, "postMethodAsync", "ref", []);
		};
		
	} ENDMETHOD;
	
	METHOD("unregisterGarrison") {
		params ["_thisObject", ["_gar", "", [""]]];
		
		pr _gars = T_GETV("garrisons");
		if (_gar in _gars) then {
			_gars deleteAt (_gars find _gar);
			CALLM2(_gar, "postMethodAsync", "unref", []);
		};
	} ENDMETHOD;
	
	
	METHOD("getGarrisons") {
		params ["_thisObject", ["_side", CIVILIAN, [CIVILIAN]]];
		
		if (_side == CIVILIAN) then {
			T_GETV("garrisons")
		} else {
			T_GETV("garrisons") select {CALLM0(_x, "getSide") == _side}
		};
	} ENDMETHOD;
	
	/*
	Method: setType
	Set the Type.

	Parameters: _type

	_type - String

	Returns: nil
	*/
	METHOD("setType") {
		params [["_thisObject", "", [""]], ["_type", "", [""]]];
		SET_VAR_PUBLIC(_thisObject, "type", _type);
	} ENDMETHOD;

	/*
	Method: getType
	Returns type of this location

	Returns: String
	*/
	METHOD("getType") {
		params [ ["_thisObject", "", [""]] ];
		GET_VAR(_thisObject, "type")
	} ENDMETHOD;
	
	/*
	Method: getSide
	Returns side of the garrison that controls this location.

	Returns: Side, or Civilian if there is no garrison
	*/
	/*
	METHOD("getSide") {
		params [ "_thisObject" ];
		pr _gar = T_GETV("garrisonMilMain");
		if (_gar == "") then {
			CIVILIAN
		} else {
			CALLM0(_gar, "getSide");
		};
	} ENDMETHOD;
	*/

	/*
	Method: getCapacityInf
	Returns type of this location

	Returns: Integer
	*/
	METHOD("getCapacityInf") {
		params [ ["_thisObject", "", [""]] ];
		GET_VAR(_thisObject, "capacityInf")
	} ENDMETHOD;

	/*
	Method: getCurrentGarrison
	Returns the current garrison attached to this location

	Returns: <Garrison> or "" if there is no current garrison
	*/
	METHOD("getCurrentGarrison") {
		params [ ["_thisObject", "", [""]] ];

		private _garrison = GETV(_thisObject, "garrisonMilAA");
		if (_garrison == "") then { _garrison = GETV(_thisObject, "garrisonMilMain"); };
		if (_garrison == "") then { OOP_WARNING_1("No garrison found for location %1", _thisObject); };
		_garrison
	} ENDMETHOD;

	/*
	Method: (static)findSafePosOnRoad
	Finds an empty position for a vehicle class name on road close to specified position.

	Parameters: _startPos 
	_startPos - start position where to start searching for a position.

	Returns: Array, [_pos, _dir]
	*/
	STATIC_METHOD("findSafePosOnRoad") {
		params ["_thisClass", ["_startPos", [], [[]]], ["_className", "", [""]] ];

		// Try to find a safe position on a road for this vehicle
		private _found = false;
		private _searchRadius = 100;
		pr _return = [];
		while {!_found} do {
			private _roads = _startPos nearRoads _searchRadius;
			if (count _roads < 3) then {
				// Search for more roads at the next iteration
				_searchRadius = _searchRadius * 2;
			} else {
				_roads = _roads apply {[_x distance2D _startPos, _x]};
				_roads sort true; // Ascending
				private _i = 0;
				while {_i < count _roads && !_found} do {
					(_roads select _i) params ["_dist", "_road"];
					private _rct = roadsConnectedTo _road;
					if (count _rct > 0) then { // We better don't use terminal road pieces
						// Check position if it's safe
						private _dir = _road getDir (_rct select 0);
						if (CALLSM3("Location", "isPosSafe", getPos _road, _dir, _className)) then {
							_return = [getPos _road, _dir];
							_found = true;
						};
					};
					_i = _i + 1;
				};
				if (!_found) then {
					// Failed to find a position here, increase the radius
					_searchRadius = _searchRadius * 3;
				};
			};			
		};

		_return
	} ENDMETHOD;

	/*
	Method: countAvailableUnits
	Returns an number of current units of this location

	Returns: Integer
	*/
	METHOD("countAvailableUnits") {
		params [ ["_thisObject", "", [""]] ];

		private _garrison = CALLM0(_thisObject, "getCurrentGarrison");
		if (_garrison == "") exitWith { 0 };

		private _countAllUnits = CALLM0(_garrison, "countAllUnits");
		private _getRequiredUnits = CALLM0(_garrison, "getRequiredCrew");
		private _minimumUnits = 0;
		{ _minimumUnits = _minimumUnits + _x; } forEach _getRequiredUnits;

		_countAllUnits - _minimumUnits
	} ENDMETHOD;

	// File-based methods

	// Handles messages
	METHOD_FILE("handleMessageEx", "Location\handleMessageEx.sqf");

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

	// Returns a random position within border
	METHOD_FILE("getRandomPos", "Location\getRandomPos.sqf");

	// Returns how many units of this type and group type this location can hold
	METHOD_FILE("getUnitCapacity", "Location\getUnitCapacity.sqf");

	// Checks if given position is safe to spawn a vehicle here
	STATIC_METHOD_FILE("isPosSafe", "Location\isPosSafe.sqf");

	// Returns the nearest location to given position and distance to it
	STATIC_METHOD_FILE("getNearestLocation", "Location\getNearestLocation.sqf");

	// Returns location that has its border overlapping given position
	STATIC_METHOD_FILE("getLocationAtPos", "Location\getLocationAtPos.sqf");

	// Adds an allowed area
	METHOD_FILE("addAllowedArea", "Location\addAllowedArea.sqf");

	// Checks if player is in any of the allowed areas
	METHOD_FILE("isInAllowedArea", "Location\isInAllowedArea.sqf");

	STATIC_METHOD_FILE("createAllFromEditor", "Location\createAllFromEditor.sqf");
ENDCLASS;

SET_STATIC_VAR("Location", "all", []);

// Initialize arrays with building types
call compile preprocessFileLineNumbers "Location\initBuildingTypes.sqf";
